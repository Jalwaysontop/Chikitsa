import 'package:chikitsa/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  List<Map<String, dynamic>> _assessments = [];
  bool _isLoading = true;
  String _patientName = '';
  String _patientPhone = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _patientName = prefs.getString('patient_name') ?? 'Patient';
    _patientPhone = prefs.getString('patient_phone') ?? '';

    final String? historyJson = prefs.getString('assessment_history');
    if (historyJson != null) {
      final List<dynamic> decodedList = jsonDecode(historyJson);
      _assessments = decodedList
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
          .reversed
          .toList();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _clearHistory() async {
    final lang = LanguageService.current;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.get('BTN_CLEAR')),
        content: Text(lang.get('MSG_CLEAR_CONFIRM')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang.get('BTN_CANCEL'),
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lang.get('BTN_CLEAR'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('assessment_history');
      setState(() => _assessments = []);
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  void _showDetailedReport(Map<String, dynamic> assessment) {
    final lang = LanguageService.current;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.get('TITLE_HISTORY'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSection(lang.get('LABEL_PATIENT_DATA')),
                  _buildDetailRow(
                      lang.get('LABEL_NAME'), assessment['patient_name']),
                  _buildDetailRow(lang.get('LABEL_AGE'), assessment['age']),
                  _buildDetailRow(
                      lang.get('LABEL_GENDER'), assessment['gender']),
                  _buildDetailRow(lang.get('LABEL_PHONE'), assessment['phone']),
                  const SizedBox(height: 24),
                  _buildSection(lang.get('LABEL_VITALS')),
                  _buildDetailRow(
                      lang.get('LABEL_TEMP'),
                      assessment['temperature'] != null
                          ? '${assessment['temperature']}°C'
                          : '-'),
                  _buildDetailRow(
                      'Heart Rate', // TODO: Add key if needed or keep English
                      assessment['heart_rate'] != null
                          ? '${assessment['heart_rate']} bpm'
                          : '-'),
                  _buildDetailRow(lang.get('LABEL_BP'),
                      assessment['blood_pressure'] ?? '-'),
                  const SizedBox(height: 24),
                  _buildSection(lang.get('LABEL_SYMPTOMS')),
                  if (assessment['symptoms'] != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (assessment['symptoms'] as List)
                          .map((s) => Chip(
                                label: Text(s.toString()),
                                backgroundColor: Theme.of(context).cardColor,
                                side: BorderSide(
                                    color: Theme.of(context).dividerColor),
                                labelStyle:
                                    Theme.of(context).textTheme.bodyMedium,
                              ))
                          .toList(),
                    )
                  else
                    Text('None', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  _buildSection(lang.get('LABEL_TRANSMISSION')),
                  Row(
                    children: [
                      Icon(
                        (assessment['send_success'] == true)
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: (assessment['send_success'] == true)
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (assessment['send_success'] == true)
                            ? lang.get('STATUS_SUCCESS')
                            : lang.get('STATUS_FAILED'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              letterSpacing: 1.0,
            ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value?.toString() ?? 'N/A',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.current;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.get('TITLE_HISTORY')),
        actions: [
          if (_assessments.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Patient Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patientName.isNotEmpty ? _patientName : 'Guest',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _patientPhone.isNotEmpty
                            ? _patientPhone
                            : 'No contact info',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _assessments.isEmpty
                      ? Center(
                          child: Text(
                            lang.get('MSG_NO_HISTORY'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.separated(
                          itemCount: _assessments.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            indent: 24,
                            endIndent: 24,
                            color: Theme.of(context).dividerColor,
                          ),
                          itemBuilder: (context, index) {
                            final assessment = _assessments[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              onTap: () => _showDetailedReport(assessment),
                              title: Text(
                                _formatDate(assessment['timestamp'] ?? ''),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  (assessment['symptoms'] as List?)
                                          ?.join(', ') ??
                                      'No symptoms',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
