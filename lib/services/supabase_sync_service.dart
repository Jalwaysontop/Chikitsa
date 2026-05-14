import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles all data exchange with the Supabase backend.
/// Field workers: can only INSERT (anon key, RLS enforced server-side).
/// Admins: must be signed in via Supabase Auth to SELECT data.
class SupabaseSyncService {
  static final SupabaseSyncService _instance = SupabaseSyncService._internal();
  static SupabaseSyncService get instance => _instance;
  SupabaseSyncService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  // ─────────────────────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────────────────────

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) return null; // success
      return 'Sign in failed — please try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Network error: $e';
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  bool get isSignedIn => _client.auth.currentSession != null;

  String? get adminEmail => _client.auth.currentUser?.email;

  // ─────────────────────────────────────────────────────────────
  // Field Worker: Upload anonymized case (anon key allowed)
  // ─────────────────────────────────────────────────────────────

  /// Called after every successful assessment. Fire-and-forget.
  Future<void> uploadCase({
    required String abhaHash,
    required String district,
    required String state,
    required String diseaseCat,
  }) async {
    try {
      await _client.from('surveillance_cases').insert({
        'abha_hash': abhaHash,
        'district': district,
        'state': state,
        'disease_cat': diseaseCat,
      });
    } catch (e) {
      // Silently fail — local SQLite already has it
      debugPrint('[Supabase] Case upload failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Admin: Read aggregate data (requires Supabase Auth session)
  // ─────────────────────────────────────────────────────────────

  /// Daily counts for a specific district (for region drill-down).
  Future<List<Map<String, dynamic>>> fetchDailyCountsByRegion({
    required String district,
    required String state,
    int days = 30,
  }) async {
    if (!isSignedIn) return [];
    try {
      final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
      final data = await _client
          .from('daily_district_counts')
          .select()
          .eq('district', district)
          .eq('state', state)
          .gte('day', since);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('[Supabase] Fetch region counts failed: $e');
      return [];
    }
  }

  /// Daily counts for all districts.
  Future<List<Map<String, dynamic>>> fetchDailyDistrictCounts({int days = 30}) async {
    if (!isSignedIn) return [];
    try {
      final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
      final data = await _client
          .from('daily_district_counts')
          .select()
          .gte('day', since);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('[Supabase] Fetch daily counts failed: $e');
      return [];
    }
  }

  /// District-level totals for heatmap.
  Future<List<Map<String, dynamic>>> fetchDistrictTotals({int days = 7}) async {
    if (!isSignedIn) return [];
    try {
      final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
      final data = await _client
          .from('surveillance_cases')
          .select('district, state')
          .gte('created_at', since);

      // Aggregate in Dart (minimal data transferred)
      final Map<String, Map<String, dynamic>> totals = {};
      for (final row in List<Map<String, dynamic>>.from(data)) {
        final key = '${row['district']}_${row['state']}';
        if (!totals.containsKey(key)) {
          totals[key] = {'district': row['district'], 'state': row['state'], 'count': 0};
        }
        totals[key]!['count'] = (totals[key]!['count'] as int) + 1;
      }
      final result = totals.values.toList()..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      return result;
    } catch (e) {
      debugPrint('[Supabase] Fetch district totals failed: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Admin: Outbreak Alerts
  // ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchActiveAlerts() async {
    if (!isSignedIn) return [];
    try {
      final data = await _client
          .from('outbreak_alerts')
          .select()
          .eq('is_resolved', false)
          .order('detected_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('[Supabase] Fetch alerts failed: $e');
      return [];
    }
  }

  Future<void> insertAlert({
    required String regionKey,
    required String diseaseCat,
    required int caseCount,
    required double threshold,
  }) async {
    if (!isSignedIn) return;
    try {
      await _client.from('outbreak_alerts').insert({
        'region_key': regionKey,
        'disease_cat': diseaseCat,
        'case_count': caseCount,
        'threshold': threshold,
      });
    } catch (e) {
      debugPrint('[Supabase] Alert insert failed: $e');
    }
  }

  Future<void> resolveAlert(String id) async {
    if (!isSignedIn) return;
    try {
      await _client.from('outbreak_alerts').update({'is_resolved': true}).eq('id', id);
    } catch (e) {
      debugPrint('[Supabase] Resolve alert failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Counterfeit Reporting
  // ─────────────────────────────────────────────────────────────

  Future<void> reportCounterfeit({
    required String barcode,
    required String company,
    required String location,
    String? abhaId,
  }) async {
    try {
      await _client.from('counterfeit_reports').insert({
        'barcode': barcode,
        'company': company,
        'location': location,
        if (abhaId != null) 'reported_by_abha': abhaId,
      });
    } catch (e) {
      debugPrint('[Supabase] Counterfeit report failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Report Export
  // ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> generateReport({int days = 30}) async {
    if (!isSignedIn) return {'error': 'Not authenticated'};
    final districtData = await fetchDistrictTotals(days: days);
    final alerts = await fetchActiveAlerts();
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'report_period_days': days,
      'generated_by': adminEmail ?? 'unknown',
      'district_summary': districtData,
      'active_alerts': alerts,
    };
  }
}
