import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/surveillance_service.dart';
import '../services/supabase_sync_service.dart';

class SurveillanceScreen extends StatefulWidget {
  const SurveillanceScreen({super.key});
  @override
  State<SurveillanceScreen> createState() => _SurveillanceScreenState();
}

class _SurveillanceScreenState extends State<SurveillanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isSignedIn = false;

  // Login form
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _loginError;
  bool _signingIn = false;
  bool _obscurePass = true;

  // Dashboard state (only populated after auth)
  List<Map<String, dynamic>> _activeAlerts = [];
  Map<String, List<DailyCount>> _allTrends = {};
  List<Map<String, dynamic>> _heatmapData = [];
  String _selectedDisease = 'Respiratory';
  int _heatmapDays = 7;

  // Region filter — null = all regions
  String? _selectedDistrict; // e.g. 'SOUTH WEST'
  String? _selectedState;    // e.g. 'DELHI'
  List<Map<String, dynamic>> _availableRegions = []; // [{district, state}]

  final List<String> _diseaseCategories = [
    'Respiratory', 'Fever (Unspecified)', 'Gastrointestinal',
    'Vector-Borne', 'Conjunctivitis', 'Skin/Rash', 'Neurological', 'Other'
  ];

  final Map<String, Color> _diseaseColors = {
    'Respiratory': const Color(0xFF4FC3F7),
    'Fever (Unspecified)': const Color(0xFFFF8A65),
    'Gastrointestinal': const Color(0xFF81C784),
    'Vector-Borne': const Color(0xFFFFB74D),
    'Conjunctivitis': const Color(0xFFBA68C8),
    'Skin/Rash': const Color(0xFF4DB6AC),
    'Neurological': const Color(0xFFE57373),
    'Other': const Color(0xFF90A4AE),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isSignedIn = SupabaseSyncService.instance.isSignedIn;
    if (_isSignedIn) _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    setState(() { _signingIn = true; _loginError = null; });
    final error = await SupabaseSyncService.instance.signIn(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (error != null) {
      setState(() { _loginError = error; _signingIn = false; });
    } else {
      setState(() { _isSignedIn = true; _signingIn = false; });
      _loadData();
    }
  }

  Future<void> _signOut() async {
    await SupabaseSyncService.instance.signOut();
    setState(() {
      _isSignedIn = false;
      _activeAlerts = [];
      _allTrends = {};
      _heatmapData = [];
    });
  }

  // ─────────────────────────────────────────────────────────────
  // Data loading (admin-only, auth required)
  // ─────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final svc = SupabaseSyncService.instance;

    // Always fetch heatmap for all districts (used for region selector too)
    final rawTotals = await svc.fetchDistrictTotals(days: _heatmapDays);

    // Build available regions from heatmap data
    final regions = rawTotals
        .map((d) => {'district': d['district'] as String, 'state': d['state'] as String})
        .toSet()
        .toList();

    final rawAlerts = await svc.fetchActiveAlerts();

    // Load trend data: filtered by region if one is selected, global otherwise
    List<Map<String, dynamic>> rawDaily;
    if (_selectedDistrict != null && _selectedState != null) {
      rawDaily = await svc.fetchDailyCountsByRegion(
        district: _selectedDistrict!,
        state: _selectedState!,
        days: 30,
      );
    } else {
      rawDaily = await svc.fetchDailyDistrictCounts(days: 30);
    }

    // Build trend map
    final Map<String, List<DailyCount>> trends = {};
    for (final row in rawDaily) {
      final cat = row['disease_cat'] as String? ?? 'Other';
      final day = (row['day'] as String? ?? '').substring(0, 10);
      final count = row['case_count'] is int
          ? row['case_count'] as int
          : int.tryParse(row['case_count'].toString()) ?? 0;
      trends.putIfAbsent(cat, () => []);
      trends[cat]!.add(DailyCount(date: day, count: count));
    }

    // Filter alerts by selected region
    final filteredAlerts = _selectedDistrict == null
        ? rawAlerts
        : rawAlerts.where((a) =>
            (a['region_key'] as String? ?? '').startsWith(_selectedDistrict!)).toList();

    setState(() {
      _activeAlerts = filteredAlerts;
      _allTrends = trends;
      _heatmapData = rawTotals;
      _availableRegions = regions;
      _isLoading = false;
    });
  }

  // ─────────────────────────────────────────────────────────────
  // Heatmap color
  // ─────────────────────────────────────────────────────────────

  Color _heatColor(int count, int max) {
    if (max == 0) return Colors.grey.shade200;
    final r = count / max;
    if (r < 0.25) return const Color(0xFF4CAF50).withValues(alpha: 0.6);
    if (r < 0.5) return const Color(0xFFFFC107).withValues(alpha: 0.75);
    if (r < 0.75) return const Color(0xFFFF5722).withValues(alpha: 0.85);
    return const Color(0xFFC62828);
  }

  Future<void> _exportReport() async {
    final report = await SupabaseSyncService.instance.generateReport();
    final json = report.toString();
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('📋 Report copied to clipboard'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('DISEASE SURVEILLANCE',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900, letterSpacing: 2, color: onBg)),
        actions: _isSignedIn ? [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                SupabaseSyncService.instance.adminEmail ?? '',
                style: TextStyle(fontSize: 11, color: onBg.withValues(alpha: 0.5)),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: _exportReport, tooltip: 'Export'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData, tooltip: 'Refresh'),
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut, tooltip: 'Sign Out'),
        ] : null,
        bottom: _isSignedIn ? TabBar(
          controller: _tabController,
          indicatorColor: onBg,
          labelColor: onBg,
          unselectedLabelColor: onBg.withValues(alpha: 0.4),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'TRENDS'),
            Tab(icon: Icon(Icons.grid_view), text: 'HEATMAP'),
            Tab(icon: Icon(Icons.warning_amber_outlined), text: 'ALERTS'),
          ],
        ) : null,
      ),
      body: _isSignedIn ? _buildDashboard(theme, onBg) : _buildLoginScreen(theme, onBg),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Region Filter Bar (shown above all three tabs when signed in)
  // ─────────────────────────────────────────────────────────────
  Widget _buildRegionBar(Color onBg) {
    final isFiltered = _selectedDistrict != null;
    return Container(
      color: onBg.withValues(alpha: 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Icon(Icons.filter_alt_outlined, size: 14, color: onBg.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Text(
                  isFiltered
                    ? 'FILTERED: $_selectedDistrict, $_selectedState'
                    : 'ALL REGIONS (tap to filter)',
                  style: TextStyle(
                    fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700,
                    color: isFiltered ? Colors.orange : onBg.withValues(alpha: 0.45),
                  ),
                ),
                if (isFiltered) ...[  
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() { _selectedDistrict = null; _selectedState = null; });
                      _loadData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      color: Colors.orange.withValues(alpha: 0.2),
                      child: const Text('✕ CLEAR', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                // All regions chip
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: const Text('ALL', style: TextStyle(fontSize: 11)),
                    selected: _selectedDistrict == null,
                    selectedColor: onBg,
                    labelStyle: TextStyle(color: _selectedDistrict == null ? Colors.white : onBg.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
                    onSelected: (_) {
                      if (_selectedDistrict != null) {
                        setState(() { _selectedDistrict = null; _selectedState = null; });
                        _loadData();
                      }
                    },
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                // One chip per known district
                ..._availableRegions.map((r) {
                  final dist = r['district'] as String;
                  final st = r['state'] as String;
                  final isSelected = _selectedDistrict == dist && _selectedState == st;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('$dist, $st', style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      selectedColor: Colors.orange,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : onBg.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      onSelected: (_) {
                        setState(() { _selectedDistrict = dist; _selectedState = st; });
                        _loadData();
                      },
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════
  // Login Gate
  // ═════════════════════════════════════
  Widget _buildLoginScreen(ThemeData theme, Color onBg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.biotech_outlined, size: 48, color: onBg.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text('HEALTH AUTHORITY ACCESS',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: onBg)),
          const SizedBox(height: 8),
          Text('Surveillance data is restricted to verified health officials. Sign in with your Supabase credentials.',
            style: TextStyle(fontSize: 13, color: onBg.withValues(alpha: 0.6))),
          const SizedBox(height: 36),

          // Email field
          Text('EMAIL', style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900, color: onBg.withValues(alpha: 0.5))),
          const SizedBox(height: 8),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'health.officer@gov.in',
              border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: onBg.withValues(alpha: 0.3))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: onBg, width: 2)),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            onSubmitted: (_) => _signIn(),
          ),
          const SizedBox(height: 16),

          // Password field
          Text('PASSWORD', style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900, color: onBg.withValues(alpha: 0.5))),
          const SizedBox(height: 8),
          TextField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            decoration: InputDecoration(
              hintText: '••••••••',
              border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: onBg.withValues(alpha: 0.3))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: onBg, width: 2)),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            onSubmitted: (_) => _signIn(),
          ),

          if (_loginError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.withValues(alpha: 0.1),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_loginError!, style: const TextStyle(color: Colors.red, fontSize: 13))),
              ]),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _signingIn ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: onBg,
                foregroundColor: theme.colorScheme.surface,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: _signingIn
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            color: onBg.withValues(alpha: 0.05),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, size: 14, color: onBg.withValues(alpha: 0.4)),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'This screen is not visible to field workers. Only users with a verified health authority account can access surveillance data.',
                style: TextStyle(fontSize: 11, color: onBg.withValues(alpha: 0.5)),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════
  // Authenticated Dashboard
  // ═════════════════════════════════════
  Widget _buildDashboard(ThemeData theme, Color onBg) {
    if (_isLoading) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Loading surveillance data from Supabase...', style: theme.textTheme.bodyMedium),
        ],
      ));
    }
    return Column(
      children: [
        _buildRegionBar(onBg),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTrendsTab(theme, onBg),
              _buildHeatmapTab(theme, onBg),
              _buildAlertsTab(theme, onBg),
            ],
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════
  // TAB 1 — Time-Series Trends
  // ═════════════════════════════════════
  Widget _buildTrendsTab(ThemeData theme, Color onBg) {
    final trendData = _allTrends[_selectedDisease] ?? [];
    final spots = <FlSpot>[];
    for (int i = 0; i < trendData.length; i++) {
      spots.add(FlSpot(i.toDouble(), trendData[i].count.toDouble()));
    }

    double growthRate = 0;
    if (trendData.length >= 14) {
      final last7 = trendData.sublist(trendData.length - 7).fold<int>(0, (s, d) => s + d.count);
      final prev7 = trendData.sublist(trendData.length - 14, trendData.length - 7).fold<int>(0, (s, d) => s + d.count);
      if (prev7 > 0) growthRate = ((last7 - prev7) / prev7) * 100;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('DISEASE CATEGORY', onBg),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _diseaseCategories.map((cat) {
              final selected = cat == _selectedDisease;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat, style: TextStyle(fontSize: 11,
                    color: selected ? Colors.white : onBg.withValues(alpha: 0.7))),
                  selected: selected,
                  selectedColor: _diseaseColors[cat] ?? Colors.blue,
                  backgroundColor: onBg.withValues(alpha: 0.08),
                  checkmarkColor: Colors.white,
                  onSelected: (_) => setState(() => _selectedDisease = cat),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        if (trendData.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: onBg.withValues(alpha: 0.15), width: 1.5)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('7-DAY GROWTH RATE', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: onBg.withValues(alpha: 0.5))),
                const SizedBox(height: 4),
                Text(
                  '${growthRate >= 0 ? '+' : ''}${growthRate.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                    color: growthRate > 20 ? Colors.red : growthRate > 0 ? Colors.orange : Colors.green),
                ),
              ]),
              Icon(growthRate > 0 ? Icons.trending_up : Icons.trending_down, size: 44,
                color: growthRate > 20 ? Colors.red : growthRate > 0 ? Colors.orange : Colors.green),
            ]),
          ),
          const SizedBox(height: 20),
        ],

        _sectionLabel('30-DAY TREND — $_selectedDisease', onBg),
        const SizedBox(height: 12),
        if (spots.isEmpty)
          _emptyState('No data recorded for this category yet.', onBg)
        else
          SizedBox(
            height: 220,
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(color: onBg.withValues(alpha: 0.07), strokeWidth: 1)),
              borderData: FlBorderData(show: true, border: Border(
                bottom: BorderSide(color: onBg.withValues(alpha: 0.25), width: 1.5),
                left: BorderSide(color: onBg.withValues(alpha: 0.25), width: 1.5),
              )),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                  getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 10, color: onBg.withValues(alpha: 0.4))))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, interval: 5,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < trendData.length && idx % 5 == 0) {
                      return Text(trendData[idx].date.substring(5), style: TextStyle(fontSize: 9, color: onBg.withValues(alpha: 0.4)));
                    }
                    return const SizedBox.shrink();
                  })),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [LineChartBarData(
                spots: spots,
                isCurved: true,
                color: _diseaseColors[_selectedDisease] ?? Colors.blue,
                barWidth: 2.5,
                dotData: FlDotData(show: true,
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3,
                    color: _diseaseColors[_selectedDisease] ?? Colors.blue, strokeWidth: 0)),
                belowBarData: BarAreaData(show: true,
                  color: (_diseaseColors[_selectedDisease] ?? Colors.blue).withValues(alpha: 0.1)),
              )],
            )),
          ),

        const SizedBox(height: 24),
        _sectionLabel('CASES BY CATEGORY (LAST 7 DAYS)', onBg),
        const SizedBox(height: 12),
        _buildCategoryBars(onBg),
      ]),
    );
  }

  Widget _buildCategoryBars(Color onBg) {
    final Map<String, int> totals = {};
    for (final cat in _diseaseCategories) {
      final data = _allTrends[cat] ?? [];
      final last7 = data.length > 7 ? data.sublist(data.length - 7) : data;
      totals[cat] = last7.fold(0, (s, d) => s + d.count);
    }
    final maxVal = totals.values.isEmpty ? 1 : totals.values.reduce((a, b) => a > b ? a : b);
    return Column(
      children: _diseaseCategories.map((cat) {
        final count = totals[cat] ?? 0;
        final ratio = maxVal > 0 ? count / maxVal : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            SizedBox(width: 110, child: Text(cat, style: TextStyle(fontSize: 10, color: onBg.withValues(alpha: 0.7)), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Expanded(child: Stack(children: [
              Container(height: 20, color: onBg.withValues(alpha: 0.06)),
              FractionallySizedBox(widthFactor: ratio,
                child: Container(height: 20, color: (_diseaseColors[cat] ?? Colors.blue).withValues(alpha: 0.8))),
            ])),
            const SizedBox(width: 8),
            SizedBox(width: 28, child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: onBg))),
          ]),
        );
      }).toList(),
    );
  }

  // ═════════════════════════════════════
  // TAB 2 — Heatmap
  // ═════════════════════════════════════
  Widget _buildHeatmapTab(ThemeData theme, Color onBg) {
    final maxCount = _heatmapData.isEmpty ? 1
        : _heatmapData.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _sectionLabel('DISTRICT CASE INTENSITY', onBg),
          SegmentedButton<int>(
            style: SegmentedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            segments: const [
              ButtonSegment(value: 7, label: Text('7D')),
              ButtonSegment(value: 14, label: Text('14D')),
              ButtonSegment(value: 30, label: Text('30D')),
            ],
            selected: {_heatmapDays},
            onSelectionChanged: (s) { setState(() => _heatmapDays = s.first); _loadData(); },
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Text('LOW ', style: TextStyle(fontSize: 10, color: onBg.withValues(alpha: 0.5))),
          ...List.generate(5, (i) {
            Color c;
            final r = i / 4;
            if (r < 0.25) c = const Color(0xFF4CAF50).withValues(alpha: 0.6);
            else if (r < 0.5) c = const Color(0xFFFFC107).withValues(alpha: 0.75);
            else if (r < 0.75) c = const Color(0xFFFF5722).withValues(alpha: 0.85);
            else c = const Color(0xFFC62828);
            return Expanded(child: Container(height: 14, color: c));
          }),
          Text(' HIGH', style: TextStyle(fontSize: 10, color: onBg.withValues(alpha: 0.5))),
        ]),
        const SizedBox(height: 16),
        if (_heatmapData.isEmpty)
          _emptyState('No district data yet.\nSubmit assessments to populate the heatmap.', onBg)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 2.2, crossAxisSpacing: 2, mainAxisSpacing: 2),
            itemCount: _heatmapData.length,
            itemBuilder: (ctx, i) {
              final d = _heatmapData[i];
              final count = d['count'] as int;
              final dist = d['district'] as String;
              final st = d['state'] as String;
              
              final isTarget = _selectedDistrict == dist && _selectedState == st;
              final isDimmed = _selectedDistrict != null && !isTarget;
              
              final baseColor = _heatColor(count, maxCount);
              final color = isDimmed ? baseColor.withValues(alpha: 0.2) : baseColor;

              return Container(
                decoration: BoxDecoration(
                  color: color,
                  border: isTarget ? Border.all(color: Colors.white, width: 3) : null,
                ),
                padding: const EdgeInsets.all(8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(dist, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDimmed ? Colors.white38 : Colors.white), overflow: TextOverflow.ellipsis),
                  Text(st, style: TextStyle(fontSize: 9, color: isDimmed ? Colors.white24 : Colors.white70)),
                  const SizedBox(height: 2),
                  Text('$count CASES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isDimmed ? Colors.white38 : Colors.white)),
                ]),
              );
            },
          ),
      ]),
    );
  }

  // ═════════════════════════════════════
  // TAB 3 — Alerts
  // ═════════════════════════════════════
  Widget _buildAlertsTab(ThemeData theme, Color onBg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.all(16),
          color: _activeAlerts.isEmpty ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
          child: Row(children: [
            Icon(_activeAlerts.isEmpty ? Icons.check_circle_outline : Icons.crisis_alert,
              color: _activeAlerts.isEmpty ? Colors.green : Colors.red, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                _activeAlerts.isEmpty ? 'NO ACTIVE OUTBREAKS' : '${_activeAlerts.length} ACTIVE OUTBREAK${_activeAlerts.length > 1 ? 'S' : ''}',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5,
                  color: _activeAlerts.isEmpty ? Colors.green : Colors.red)),
              Text(
                _activeAlerts.isEmpty ? 'All regions within normal parameters'
                    : 'Exceeding 2σ baseline — immediate review recommended',
                style: TextStyle(fontSize: 12, color: onBg.withValues(alpha: 0.65))),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        if (_activeAlerts.isNotEmpty) ...[
          _sectionLabel('ACTIVE ALERTS', onBg),
          const SizedBox(height: 8),
          ..._activeAlerts.map((alert) => _buildAlertCard(alert, onBg)),
          const SizedBox(height: 20),
        ],

        _sectionLabel('EXPORT REPORT', onBg),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: onBg.withValues(alpha: 0.15), width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Export an anonymized JSON summary of all Supabase surveillance data to share with health authorities.',
              style: TextStyle(fontSize: 13, color: onBg.withValues(alpha: 0.75))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('EXPORT SURVEILLANCE REPORT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: onBg, foregroundColor: theme.colorScheme.surface,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              onPressed: _exportReport,
            )),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12), color: onBg.withValues(alpha: 0.05),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 14, color: onBg.withValues(alpha: 0.4)),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Detection uses 14-day rolling baseline + 2σ (WHO methodology). Requires ≥3 cases. No PII is stored — only SHA-256 hashed ABHA identifiers.',
              style: TextStyle(fontSize: 11, color: onBg.withValues(alpha: 0.5)))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, Color onBg) {
    final detectedAt = DateTime.tryParse(alert['detected_at'] as String? ?? '') ?? DateTime.now();
    final daysAgo = DateTime.now().difference(detectedAt).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.red.withValues(alpha: 0.6), width: 2)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: const Icon(Icons.crisis_alert, color: Colors.red),
        title: Text('${alert['disease_cat']} — ${(alert['region_key'] as String?)?.replaceAll('_', ', ')}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('$daysAgo day(s) ago · ${alert['case_count']} cases',
          style: TextStyle(fontSize: 11, color: onBg.withValues(alpha: 0.65))),
        children: [Padding(
          padding: const EdgeInsets.all(12),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton.icon(
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Mark Resolved', style: TextStyle(fontSize: 12)),
              onPressed: () async {
                await SupabaseSyncService.instance.resolveAlert(alert['id'] as String);
                _loadData();
              },
            ),
          ]),
        )],
      ),
    );
  }

  Widget _sectionLabel(String text, Color onBg) => Text(text,
    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: onBg.withValues(alpha: 0.45)));

  Widget _emptyState(String msg, Color onBg) => Container(
    padding: const EdgeInsets.all(32), alignment: Alignment.center,
    child: Column(children: [
      Icon(Icons.bar_chart_outlined, size: 48, color: onBg.withValues(alpha: 0.15)),
      const SizedBox(height: 12),
      Text(msg, textAlign: TextAlign.center, style: TextStyle(color: onBg.withValues(alpha: 0.35), fontSize: 13)),
    ]),
  );
}
