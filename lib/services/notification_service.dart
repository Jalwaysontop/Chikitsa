import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

import 'package:flutter_timezone/flutter_timezone.dart' as ft;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  // Track active timers so we can cancel them
  final Map<int, Timer> _activeTimers = {};

  Future<void> init() async {
    print('NotificationService: Initializing...');

    // Configure timezone
    tz.initializeTimeZones();
    try {
      final timeZoneName = await ft.FlutterTimezone.getLocalTimezone();
      print('NotificationService: Raw timezone detected: $timeZoneName');

      String cleanTimeZone = timeZoneName.toString();
      if (cleanTimeZone.contains('TimezoneInfo') &&
          cleanTimeZone.contains('(')) {
        final start = cleanTimeZone.indexOf('(') + 1;
        final end = cleanTimeZone.indexOf(',', start);
        if (start != -1 && end != -1) {
          cleanTimeZone = cleanTimeZone.substring(start, end).trim();
        }
      }

      print('NotificationService: Setting location to: $cleanTimeZone');
      tz.setLocalLocation(tz.getLocation(cleanTimeZone));
    } catch (e) {
      print('NotificationService: Error setting timezone: $e');
      try {
        print('NotificationService: Fallback option - Setting to Asia/Kolkata');
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch (e2) {
        print('NotificationService: Failed to set fallback timezone: $e2');
      }
    }
    print(
        'NotificationService: Timezones initialized with location: ${tz.local.name}');

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    final fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) {
        print('NotificationService: Notification tapped: ${response.payload}');
      },
    );
    print('NotificationService: Initialization complete');

    // Request permissions for Android 13+
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? notifGranted =
          await androidImplementation.requestNotificationsPermission();
      print(
          'NotificationService: Android notifications permission granted: $notifGranted');

      // Request exact alarm permission (opens system settings)
      final bool? exactAlarmGranted =
          await androidImplementation.requestExactAlarmsPermission();
      print(
          'NotificationService: Exact alarm permission granted: $exactAlarmGranted');
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    DateTime scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    final Duration delay = scheduledDateTime.difference(now);
    print(
        'NotificationService: Scheduling notification ID:$id for $scheduledDateTime (in ${delay.inSeconds} seconds)');

    // Strategy 1: Try AlarmManager-based zonedSchedule (works on real devices)
    try {
      final scheduledTime = _nextInstanceOfTime(time);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: _notificationDetails,
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: fln.DateTimeComponents.time,
      );
      print('NotificationService: zonedSchedule succeeded');
    } catch (e) {
      print('NotificationService: zonedSchedule failed: $e');
    }

    // Strategy 2: Dart Timer fallback (works while app is in foreground/running)
    // Cancel any existing timer for this ID
    _activeTimers[id]?.cancel();
    _activeTimers[id] = Timer(delay, () {
      print('NotificationService: Timer fired for notification ID:$id');
      _showNotification(id: id, title: title, body: body);
    });
    print('NotificationService: Timer set for ${delay.inSeconds}s from now');
  }

  Future<void> cancelNotification(int id) async {
    print('NotificationService: Canceling notification ID:$id');

    // Cancel AlarmManager schedule
    await flutterLocalNotificationsPlugin.cancel(id: id);

    // Cancel Dart timer
    _activeTimers[id]?.cancel();
    _activeTimers.remove(id);
  }

  /// Fire a notification immediately
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _showNotification(id: id, title: title, body: body);
  }

  /// Internal method to show a notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    print('NotificationService: Showing notification ID:$id - "$title"');
    try {
      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _notificationDetails,
      );
      print('NotificationService: Notification shown successfully');
    } catch (e) {
      print('NotificationService: Error showing notification: $e');
    }
  }

  /// Shared notification details
  static const fln.NotificationDetails _notificationDetails =
      fln.NotificationDetails(
    android: fln.AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Daily reminders for medication',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
    ),
    iOS: fln.DarwinNotificationDetails(),
  );

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    print(
        'NotificationService: Calculated next instance: $scheduledDate (Now: $now)');
    return scheduledDate;
  }
}
