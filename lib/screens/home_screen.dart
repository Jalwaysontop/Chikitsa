import 'package:flutter/material.dart';
import 'package:chikitsa/screens/bson_demo_screen.dart';
import 'package:chikitsa/services/language_service.dart';
import 'package:chikitsa/screens/medical_reminders_screen.dart';
import 'package:chikitsa/screens/activity_history_screen.dart';
import 'package:chikitsa/screens/rx_scanner_screen.dart';
import 'package:chikitsa/screens/medication_tracker_screen.dart';
import 'package:chikitsa/screens/generic_alts_screen.dart';
import 'package:chikitsa/screens/abha_scanner_screen.dart';
import 'package:chikitsa/screens/surveillance_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chikitsa/main.dart'; // For toggleTheme
import '../services/surveillance_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  String? _abhaId;
  int _activeAlertCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAlertCount();
  }

  Future<void> _loadAlertCount() async {
    final count = await SurveillanceService.instance.getActiveAlertCount();
    if (mounted) setState(() => _activeAlertCount = count);
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('abha_name');
      _abhaId = prefs.getString('abha_address');
    });
  }

  void _onStartAssessment() {
    if (_abhaId != null && _abhaId!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BsonDemoScreen()),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Link ABHA ID',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan your ABHA QR Code to automatically fill your assessment details and effortlessly link your health records.',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan ABHA Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AbhaScannerScreen()),
                  ).then((_) => _loadProfile().then((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BsonDemoScreen()),
                    );
                  }));
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BsonDemoScreen()),
                  );
                },
                child: const Text('Skip / Continue without linking'),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.current;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(lang.get('BRAND'),
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  Row(
                    children: [
                      // Language Toggle
                      TextButton(
                        onPressed: () {
                          LanguageService.current.toggleLanguage();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          side: BorderSide(
                              color: theme.colorScheme.onSurface, width: 2),
                        ),
                        child: Text(
                          LanguageService.current.isHindi ? 'EN' : 'हिंदी',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Theme Toggle
                      IconButton(
                        onPressed: toggleTheme,
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ActivityHistoryScreen()),
                          );
                        },
                        icon: Icon(Icons.history,
                            color: theme.colorScheme.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Big Headline Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_userName != null && _userName!.isNotEmpty) ...[
                            Text(
                              'Hello,\n$_userName!',
                              style: theme.textTheme.displayLarge?.copyWith(fontSize: 40),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ABHA ID: $_abhaId',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              lang.get('HEADLINE'),
                              style: theme.textTheme.displayLarge,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              lang.get('SUBHEAD'),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                          const SizedBox(height: 32),

                          // Primary CTA (Full width sharp button)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onStartAssessment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.onSurface,
                                foregroundColor: theme.colorScheme.surface,
                              ),
                              child: Text(lang.get('CTA_START')),
                            ),
                          ),
                          if (_abhaId != null && _abhaId!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AbhaScannerScreen()),
                                  );
                                  _loadProfile();
                                },
                                icon: const Icon(Icons.qr_code_scanner),
                                label: Text(lang.get('CTA_RESCAN_ABHA')),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: theme.colorScheme.onSurface,
                                  side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), width: 2),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    Divider(
                        height: 1,
                        thickness: 2,
                        color: theme.colorScheme.onSurface),

                    // Feature Grid
                    // Brutalism grid: Borders between elements
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      padding: EdgeInsets.zero,
                      children: [
                        _buildBrutalistCard(
                          context,
                          lang.get('CARD_GENERIC'),
                          Icons.currency_exchange,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const GenericAltsScreen()),
                            );
                          },
                          borderRight: true,
                          borderBottom: true,
                        ),
                        _buildBrutalistCard(
                          context,
                          lang.get('CARD_RX'),
                          Icons.document_scanner_outlined,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RxScannerScreen()),
                            );
                          },
                          borderRight: false,
                          borderBottom: true,
                        ),
                        _buildBrutalistCard(
                          context,
                          lang.get('CARD_MEDS'),
                          Icons.medication_outlined,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MedicationTrackerScreen()),
                            );
                          },
                          borderRight: true,
                          borderBottom: true,
                        ),
                        _buildBrutalistCard(
                          context,
                          lang.get('CARD_REMINDERS'),
                          Icons.alarm,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MedicationRemindersScreen()),
                            );
                          },
                          borderRight: false,
                          borderBottom: true,
                        ),
                        // Surveillance tile with alert badge
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            _buildBrutalistCard(
                              context,
                              lang.get('CARD_SURVEILLANCE'),
                              Icons.biotech_outlined,
                              () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SurveillanceScreen()),
                                );
                                _loadAlertCount();
                              },
                              borderRight: true,
                              borderBottom: false,
                            ),
                            if (_activeAlertCount > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  color: Colors.red,
                                  child: Text(
                                    '$_activeAlertCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        _buildBrutalistCard(
                          context,
                          'HISTORY',
                          Icons.history_outlined,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ActivityHistoryScreen()),
                            );
                          },
                          borderRight: false,
                          borderBottom: false,
                        ),
                      ],
                    ),

                    Divider(
                        height: 1,
                        thickness: 2,
                        color: theme.colorScheme.onSurface),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrutalistCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap,
      {bool borderRight = false, bool borderBottom = false}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border(
            right: borderRight
                ? BorderSide(color: theme.colorScheme.onSurface, width: 2)
                : BorderSide.none,
            bottom: borderBottom
                ? BorderSide(color: theme.colorScheme.onSurface, width: 2)
                : BorderSide.none,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.onSurface),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
