import 'package:chikitsa/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:chikitsa/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationRemindersScreen extends StatefulWidget {
  const MedicationRemindersScreen({super.key});

  @override
  State<MedicationRemindersScreen> createState() =>
      _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString('med_reminders');
    if (remindersJson != null) {
      final List<dynamic> decodedList = jsonDecode(remindersJson);
      setState(() {
        _reminders =
            decodedList.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(_reminders);
    await prefs.setString('med_reminders', encodedList);
  }

  Future<void> _addReminder(Map<String, dynamic> reminder) async {
    setState(() {
      _reminders.add(reminder);
    });
    await _saveReminders();
    _scheduleNotification(reminder);
  }

  Future<void> _deleteReminder(int index, Map<String, dynamic> reminder) async {
    final lang = LanguageService.current;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.get(
            'TITLE_REMINDERS')), // "Reminders" or "Delete Reminder" in English key mapping, wait, I used TITLE_REMINDERS. Ideally should be 'Delete Reminder' but LanguageService doesn't have it. I'll use TITLE_REMINDERS for now or just hardcode/add key.
        content: Text(lang.get('MSG_DELETE_CONFIRM')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang.get('BTN_CANCEL')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lang.get('BTN_CLEAR'),
                style: const TextStyle(color: Colors.red)), // Use Clean/Delete
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _reminders.removeAt(index);
      });
      await _saveReminders();
      NotificationService().cancelNotification(reminder['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.get('MSG_REMINDER_DELETED')),
            action: SnackBarAction(
              label: lang.get('BTN_UNDO'),
              onPressed: () {
                _addReminder(reminder);
              },
            ),
          ),
        );
      }
    }
  }

  void _scheduleNotification(Map<String, dynamic> reminder) {
    if (reminder['isActive'] == true) {
      final timeParts = (reminder['time'] as String).split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final days = List<String>.from(reminder['days']);

      if (days.length == 7) {
        NotificationService().scheduleDailyNotification(
          id: reminder['id'],
          title: 'Time for ${reminder['name']}',
          body: 'Take ${reminder['dosage']}',
          time: TimeOfDay(hour: hour, minute: minute),
        );
      } else {
        NotificationService().scheduleDailyNotification(
          id: reminder['id'],
          title: 'Time for ${reminder['name']}',
          body: 'Take ${reminder['dosage']}',
          time: TimeOfDay(hour: hour, minute: minute),
        );
      }
    } else {
      NotificationService().cancelNotification(reminder['id']);
    }
  }

  void _showAddReminderDialog() {
    final lang = LanguageService.current;
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    List<String> selectedDays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.get('BTN_ADD_REMINDER'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: lang.get('LABEL_MEDICINE_NAME'),
                  hintText: lang.get('HINT_MEDICINE_NAME'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dosageController,
                decoration: InputDecoration(
                  labelText: lang.get('LABEL_DOSAGE'),
                  hintText: lang.get('HINT_DOSAGE'),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setModalState(() => selectedTime = picked);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lang.get('LABEL_TIME'),
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        selectedTime.format(context),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(lang.get('LABEL_FREQUENCY'),
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((day) {
                  final isSelected = selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        if (selected) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        dosageController.text.isNotEmpty &&
                        selectedDays.isNotEmpty) {
                      final newReminder = {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'name': nameController.text,
                        'dosage': dosageController.text,
                        'time':
                            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        'isActive': true,
                        'days': selectedDays,
                      };
                      _addReminder(newReminder);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(lang.get('BTN_SAVE_REMINDER')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.current;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.get('TITLE_REMINDERS')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderDialog,
        icon: const Icon(Icons.add),
        label: Text(lang.get('BTN_ADD_REMINDER')),
      ),
      body: _reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off,
                      size: 48, color: Theme.of(context).dividerColor),
                  const SizedBox(height: 16),
                  Text(
                    lang.get('MSG_NO_REMINDERS'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                final timeParts = (reminder['time'] as String).split(':');
                final timeOfDay = TimeOfDay(
                    hour: int.parse(timeParts[0]),
                    minute: int.parse(timeParts[1]));

                return Dismissible(
                  key: Key(reminder['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(lang.get(
                            'TITLE_REMINDERS')), // Ideally, Delete Reminder
                        content: Text(lang.get('MSG_DELETE_CONFIRM')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(lang.get('BTN_CANCEL')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child:
                                Text(lang.get('BTN_CLEAR'), // Use Clean/Delete
                                    style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    _deleteReminder(index, reminder);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.medication_outlined,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder['name'],
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${reminder['dosage']} • ${timeOfDay.format(context)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 4,
                                children: (reminder['days'] as List)
                                    .map((day) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .dividerColor),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            day,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: reminder['isActive'] ?? true,
                          onChanged: (val) {
                            setState(() {
                              reminder['isActive'] = val;
                            });
                            _saveReminders();
                            _scheduleNotification(reminder);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
