import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Privacy-first local disease surveillance database.
/// Stores only anonymized, non-identifiable case data.
class SurveillanceDatabase {
  static final SurveillanceDatabase _instance = SurveillanceDatabase._internal();
  static SurveillanceDatabase get instance => _instance;
  SurveillanceDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chikitsa_surveillance.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Anonymized case table — no PII ever stored here
        await db.execute('''
          CREATE TABLE cases (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            abha_hash   TEXT NOT NULL,
            district    TEXT NOT NULL,
            state       TEXT NOT NULL,
            disease_cat TEXT NOT NULL,
            timestamp   TEXT NOT NULL
          )
        ''');

        // Baseline statistics table
        await db.execute('''
          CREATE TABLE baselines (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            region_key    TEXT NOT NULL,
            disease_cat   TEXT NOT NULL,
            moving_avg    REAL NOT NULL DEFAULT 0,
            std_dev       REAL NOT NULL DEFAULT 0,
            last_updated  TEXT NOT NULL,
            UNIQUE(region_key, disease_cat)
          )
        ''');

        // Outbreak alerts log
        await db.execute('''
          CREATE TABLE alerts (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            region_key  TEXT NOT NULL,
            disease_cat TEXT NOT NULL,
            case_count  INTEGER NOT NULL,
            threshold   REAL NOT NULL,
            detected_at TEXT NOT NULL,
            is_resolved INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // ---------- Cases ----------

  Future<int> insertCase(Map<String, dynamic> caseData) async {
    final db = await database;
    return db.insert('cases', caseData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get daily case counts for a region+disease over the past [days] days
  Future<List<Map<String, dynamic>>> getDailyCounts({
    required String regionKey,
    required String diseaseCategory,
    int days = 30,
  }) async {
    final db = await database;
    final sinceDate = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    return db.rawQuery('''
      SELECT DATE(timestamp) as date, COUNT(*) as count
      FROM cases
      WHERE district || '_' || state = ? AND disease_cat = ? AND timestamp >= ?
      GROUP BY DATE(timestamp)
      ORDER BY date ASC
    ''', [regionKey, diseaseCategory, sinceDate]);
  }

  /// Get all cases grouped by district for heatmap
  Future<List<Map<String, dynamic>>> getDistrictCounts({int days = 7}) async {
    final db = await database;
    final sinceDate = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    return db.rawQuery('''
      SELECT district, state, COUNT(*) as count
      FROM cases
      WHERE timestamp >= ?
      GROUP BY district, state
      ORDER BY count DESC
    ''', [sinceDate]);
  }

  /// Get all cases over last [days] days for total trends
  Future<List<Map<String, dynamic>>> getAllDailyCounts({int days = 30}) async {
    final db = await database;
    final sinceDate = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    return db.rawQuery('''
      SELECT DATE(timestamp) as date, disease_cat, COUNT(*) as count
      FROM cases
      WHERE timestamp >= ?
      GROUP BY DATE(timestamp), disease_cat
      ORDER BY date ASC
    ''', [sinceDate]);
  }

  // ---------- Baselines ----------

  Future<void> upsertBaseline(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('baselines', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getBaseline(String regionKey, String diseaseCat) async {
    final db = await database;
    final rows = await db.query(
      'baselines',
      where: 'region_key = ? AND disease_cat = ?',
      whereArgs: [regionKey, diseaseCat],
    );
    return rows.isEmpty ? null : rows.first;
  }

  // ---------- Alerts ----------

  Future<int> insertAlert(Map<String, dynamic> alertData) async {
    final db = await database;
    return db.insert('alerts', alertData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getActiveAlerts() async {
    final db = await database;
    return db.query(
      'alerts',
      where: 'is_resolved = 0',
      orderBy: 'detected_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllAlerts() async {
    final db = await database;
    return db.query('alerts', orderBy: 'detected_at DESC', limit: 50);
  }

  Future<void> resolveAlert(int id) async {
    final db = await database;
    await db.update('alerts', {'is_resolved': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getActiveAlertCount() async {
    final alerts = await getActiveAlerts();
    return alerts.length;
  }

  Future<void> close() async {
    await _db?.close();
  }
}
