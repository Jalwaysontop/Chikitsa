import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'surveillance_database.dart';
import 'supabase_sync_service.dart';

/// The core statistical outbreak detection engine.
/// All data processed here is anonymized — no PII ever flows through.
class SurveillanceService {
  static final SurveillanceService _instance = SurveillanceService._internal();
  static SurveillanceService get instance => _instance;
  SurveillanceService._internal();

  final SurveillanceDatabase _db = SurveillanceDatabase.instance;

  // Standard epidemiological significance threshold: baseline + 2σ
  static const double _sigmaThreshold = 2.0;
  // Minimum window needed to compute a meaningful baseline
  static const int _baselineWindowDays = 14;

  // ─────────────────────────────────────────────────────────────
  // 1. Case Ingestion
  // ─────────────────────────────────────────────────────────────

  /// Records a new anonymized case from an assessment submission.
  /// Call this after each successful assessment in BsonDemoScreen.
  Future<OutbreakAlert?> recordCaseAndCheck({
    required String symptoms,
    String? abhaAddress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final district = prefs.getString('abha_district_name') ?? 'Unknown';
    final state = prefs.getString('abha_state_name') ?? 'Unknown';

    // Create privacy-safe ABHA hash (SHA-256 of ABHA address)
    final hash = abhaAddress != null && abhaAddress.isNotEmpty
        ? sha256.convert(utf8.encode(abhaAddress)).toString()
        : sha256.convert(utf8.encode(DateTime.now().millisecondsSinceEpoch.toString())).toString();

    final diseaseCategory = _categorizeSymptoms(symptoms);

    await _db.insertCase({
      'abha_hash': hash,
      'district': district,
      'state': state,
      'disease_cat': diseaseCategory,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Upload anonymized case to Supabase (central aggregation, fire-and-forget)
    SupabaseSyncService.instance.uploadCase(
      abhaHash: hash,
      district: district,
      state: state,
      diseaseCat: diseaseCategory,
    );

    // Run outbreak detection after each new case
    return await detectOutbreak(district: district, state: state, diseaseCategory: diseaseCategory);
  }

  // ─────────────────────────────────────────────────────────────
  // 2. Symptom → Category Classifier
  // ─────────────────────────────────────────────────────────────

  String _categorizeSymptoms(String symptoms) {
    final s = symptoms.toLowerCase();
    if (s.contains('fever') || s.contains('बुखार') || s.contains('temperature') || s.contains('chills')) {
      if (s.contains('cough') || s.contains('cold') || s.contains('flu') || s.contains('खांसी')) return 'Respiratory';
      if (s.contains('rash') || s.contains('denge') || s.contains('dengue') || s.contains('body pain')) return 'Vector-Borne';
      return 'Fever (Unspecified)';
    }
    if (s.contains('diarrhea') || s.contains('vomiting') || s.contains('nausea') ||
        s.contains('stomach') || s.contains('दस्त') || s.contains('उल्टी')) return 'Gastrointestinal';
    if (s.contains('cough') || s.contains('breathe') || s.contains('asthma') ||
        s.contains('pneumonia') || s.contains('खांसी') || s.contains('chest')) return 'Respiratory';
    if (s.contains('eye') || s.contains('conjunctivitis') || s.contains('आंख')) return 'Conjunctivitis';
    if (s.contains('rash') || s.contains('skin') || s.contains('itching') || s.contains('खुजली')) return 'Skin/Rash';
    if (s.contains('headache') || s.contains('migraine') || s.contains('सिरदर्द')) return 'Neurological';
    return 'Other';
  }

  // ─────────────────────────────────────────────────────────────
  // 3. Regional Aggregation
  // ─────────────────────────────────────────────────────────────

  /// Returns rolling daily counts for a region+disease for the last [days] days.
  Future<List<DailyCount>> aggregateByRegion({
    required String district,
    required String state,
    required String diseaseCategory,
    int days = 30,
  }) async {
    final regionKey = '${district}_$state';
    final rows = await _db.getDailyCounts(
      regionKey: regionKey,
      diseaseCategory: diseaseCategory,
      days: days,
    );
    return rows.map((r) => DailyCount(date: r['date'] as String, count: r['count'] as int)).toList();
  }

  /// Returns all districts with case counts for the heatmap.
  Future<List<DistrictCaseCount>> getDistrictHeatmapData({int days = 7}) async {
    final rows = await _db.getDistrictCounts(days: days);
    return rows.map((r) => DistrictCaseCount(
      district: r['district'] as String,
      state: r['state'] as String,
      count: r['count'] as int,
    )).toList();
  }

  /// Returns aggregate daily totals across all diseases for trend chart.
  Future<Map<String, List<DailyCount>>> getAllDailyTrends({int days = 30}) async {
    final rows = await _db.getAllDailyCounts(days: days);
    final Map<String, List<DailyCount>> result = {};
    for (final r in rows) {
      final cat = r['disease_cat'] as String;
      result.putIfAbsent(cat, () => []);
      result[cat]!.add(DailyCount(date: r['date'] as String, count: r['count'] as int));
    }
    return result;
  }

  // ─────────────────────────────────────────────────────────────
  // 4. Statistical Baseline Engine
  // ─────────────────────────────────────────────────────────────

  /// Computes a 14-day rolling mean and standard deviation as the baseline.
  Future<BaselineStats?> computeBaseline({
    required String district,
    required String state,
    required String diseaseCategory,
  }) async {
    final regionKey = '${district}_$state';
    final rows = await _db.getDailyCounts(
      regionKey: regionKey,
      diseaseCategory: diseaseCategory,
      days: _baselineWindowDays,
    );

    if (rows.length < 3) return null; // Insufficient data

    final counts = rows.map((r) => (r['count'] as int).toDouble()).toList();
    final mean = counts.reduce((a, b) => a + b) / counts.length;
    final variance = counts.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / counts.length;
    final stdDev = variance > 0 ? variance : 0.0; // keep as variance for simplicity in low-count areas
    final threshold = mean + (_sigmaThreshold * stdDev);

    final stats = BaselineStats(mean: mean, stdDev: stdDev, threshold: threshold);

    // Persist the baseline for dashboard display
    await _db.upsertBaseline({
      'region_key': regionKey,
      'disease_cat': diseaseCategory,
      'moving_avg': mean,
      'std_dev': stdDev,
      'last_updated': DateTime.now().toIso8601String(),
    });

    return stats;
  }

  // ─────────────────────────────────────────────────────────────
  // 5. Outbreak Detection
  // ─────────────────────────────────────────────────────────────

  /// Returns an OutbreakAlert if today's count exceeds baseline + 2σ, else null.
  Future<OutbreakAlert?> detectOutbreak({
    required String district,
    required String state,
    required String diseaseCategory,
  }) async {
    final regionKey = '${district}_$state';
    final stats = await computeBaseline(district: district, state: state, diseaseCategory: diseaseCategory);
    if (stats == null) return null;

    // Get today's count for that region+disease
    final db = SurveillanceDatabase.instance;
    final todayRows = await db.getDailyCounts(regionKey: regionKey, diseaseCategory: diseaseCategory, days: 1);
    final todayCount = todayRows.isEmpty ? 0 : (todayRows.first['count'] as int);

    if (todayCount > stats.threshold && todayCount >= 3) {
      // Outbreak detected — save it
      final alert = OutbreakAlert(
        district: district,
        state: state,
        diseaseCategory: diseaseCategory,
        caseCount: todayCount,
        threshold: stats.threshold,
        detectedAt: DateTime.now(),
      );

      await _db.insertAlert({
        'region_key': regionKey,
        'disease_cat': diseaseCategory,
        'case_count': todayCount,
        'threshold': stats.threshold,
        'detected_at': DateTime.now().toIso8601String(),
        'is_resolved': 0,
      });

      return alert;
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // 6. Alert Access
  // ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getActiveAlerts() => _db.getActiveAlerts();
  Future<List<Map<String, dynamic>>> getAllAlerts() => _db.getAllAlerts();
  Future<int> getActiveAlertCount() => _db.getActiveAlertCount();
  Future<void> resolveAlert(int id) => _db.resolveAlert(id);

  // ─────────────────────────────────────────────────────────────
  // 7. Report Export (JSON Bundle for health authorities)
  // ─────────────────────────────────────────────────────────────

  Future<String> generateJsonReport() async {
    final districtData = await getDistrictHeatmapData(days: 30);
    final allAlerts = await getAllAlerts();
    final dailyData = await _db.getAllDailyCounts(days: 30);

    final report = {
      'generated_at': DateTime.now().toIso8601String(),
      'report_period_days': 30,
      'district_summary': districtData.map((d) => {
        'district': d.district,
        'state': d.state,
        'case_count_7d': d.count,
      }).toList(),
      'outbreak_alerts': allAlerts,
      'daily_trend': dailyData,
    };

    return jsonEncode(report);
  }
}

// ─────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────

class DailyCount {
  final String date;
  final int count;
  const DailyCount({required this.date, required this.count});
}

class DistrictCaseCount {
  final String district;
  final String state;
  final int count;
  const DistrictCaseCount({required this.district, required this.state, required this.count});
}

class BaselineStats {
  final double mean;
  final double stdDev;
  final double threshold;
  const BaselineStats({required this.mean, required this.stdDev, required this.threshold});
}

class OutbreakAlert {
  final String district;
  final String state;
  final String diseaseCategory;
  final int caseCount;
  final double threshold;
  final DateTime detectedAt;

  const OutbreakAlert({
    required this.district,
    required this.state,
    required this.diseaseCategory,
    required this.caseCount,
    required this.threshold,
    required this.detectedAt,
  });
}
