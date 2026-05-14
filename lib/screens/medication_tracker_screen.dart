import 'package:chikitsa/services/language_service.dart';
import 'package:flutter/material.dart';

class MedicationTrackerScreen extends StatefulWidget {
  const MedicationTrackerScreen({super.key});

  @override
  State<MedicationTrackerScreen> createState() =>
      _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen> {
  // Dummy data for prototype
  final List<Map<String, dynamic>> _medications = [
    {
      'id': 1,
      'name': 'Amoxicillin',
      'dosage': '500mg',
      'time': '08:00 AM',
      'taken': true,
      'stock': 12,
      'total_stock': 30,
    },
    {
      'id': 2,
      'name': 'Vitamin D',
      'dosage': '1000 IU',
      'time': '01:00 PM',
      'taken': false,
      'stock': 25,
      'total_stock': 30,
    },
    {
      'id': 3,
      'name': 'Paracetamol',
      'dosage': '650mg',
      'time': '08:00 PM',
      'taken': false,
      'stock': 4, // Low stock
      'total_stock': 20,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.current;
    final theme = Theme.of(context);

    // Calculate adherence
    int takenCount = _medications.where((m) => m['taken'] as bool).length;
    double adherence =
        _medications.isEmpty ? 0 : takenCount / _medications.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.get('MED_TRACKER_TITLE')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Adherence Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    value: adherence,
                    strokeWidth: 8,
                    backgroundColor: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.2),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(adherence * 100).toInt()}%',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        lang.get('MED_ADHERENCE_LABEL'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Today's Schedule Header
            Text(
              lang.get('MED_TODAY_SCHEDULE'),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Medication List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final med = _medications[index];
                final isLowStock = (med['stock'] as int) <= 5;

                return Card(
                  elevation: 0,
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: med['taken'] as bool,
                              onChanged: (val) {
                                setState(() {
                                  med['taken'] = val;
                                });
                              },
                              shape: const CircleBorder(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med['name'] as String,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: med['taken'] as bool
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: med['taken'] as bool
                                          ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5)
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '${med['dosage']} • ${med['time']}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  lang.get('MED_LOW_STOCK'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Mini inventory bar
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: (med['stock'] as int) /
                                    (med['total_stock'] as int),
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                color: isLowStock
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${med['stock']} / ${med['total_stock']} ${lang.get('MED_LEFT')}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: Text(lang.get('MED_BTN_ADD')),
      ),
    );
  }
}
