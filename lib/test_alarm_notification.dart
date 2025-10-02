import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/alarm.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'features/reminders/services/notification_service.dart';
import 'features/reminders/services/alarm_service.dart';
import 'features/reminders/services/notification_alarm_service.dart';

/// Test screen to verify alarm and notification functionality
class TestAlarmNotificationScreen extends ConsumerStatefulWidget {
  const TestAlarmNotificationScreen({super.key});

  @override
  ConsumerState<TestAlarmNotificationScreen> createState() =>
      _TestAlarmNotificationScreenState();
}

class _TestAlarmNotificationScreenState
    extends ConsumerState<TestAlarmNotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final AlarmService _alarmService = AlarmService();
  final NotificationAlarmService _unifiedService = NotificationAlarmService();

  String _status = 'Not initialized';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      setState(() => _status = 'Initializing timezone...');
      tz.initializeTimeZones();

      setState(() => _status = 'Initializing alarm package...');
      await Alarm.init();

      setState(() => _status = 'Initializing notification service...');
      final notifSuccess = await _notificationService.initialize();

      setState(() => _status = 'Requesting permissions...');
      final permissionsGranted = await _notificationService.requestPermissions();

      setState(() => _status = 'Initializing alarm service...');
      final alarmSuccess = await _alarmService.initialize();

      setState(() => _status = 'Initializing unified service...');
      final unifiedSuccess = await _unifiedService.initialize();

      if (notifSuccess && alarmSuccess && unifiedSuccess && permissionsGranted) {
        setState(() {
          _status = '✅ All services initialized successfully!';
          _isInitialized = true;
        });
      } else {
        setState(() {
          _status =
              '⚠️ Partial initialization (Notif: $notifSuccess, Alarm: $alarmSuccess, Unified: $unifiedSuccess, Perms: $permissionsGranted)';
          _isInitialized = true;
        });
      }
    } catch (e) {
      setState(() => _status = '❌ Initialization failed: $e');
    }
  }

  Future<void> _testNotification() async {
    try {
      setState(() => _status = 'Scheduling test notification in 5 seconds...');

      final scheduledTime = DateTime.now().add(const Duration(seconds: 5));

      await _notificationService.scheduleMedicationReminder(
        reminderId: 'test_notification_${DateTime.now().millisecondsSinceEpoch}',
        medicationName: 'Test Medicine',
        dosage: '10mg',
        scheduledTime: scheduledTime,
      );

      setState(() =>
          _status = '✅ Notification scheduled for ${scheduledTime.toString()}');
    } catch (e) {
      setState(() => _status = '❌ Notification test failed: $e');
    }
  }

  Future<void> _testAlarm() async {
    try {
      setState(() => _status = 'Scheduling test alarm in 10 seconds...');

      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));

      final success = await _alarmService.setAlarm(
        reminderId: 'test_alarm_${DateTime.now().millisecondsSinceEpoch}',
        scheduledTime: scheduledTime,
        title: 'Test Alarm',
        body: 'This is a test alarm',
        alarmSound: 'gentle',
        volume: 0.8,
        vibrate: true,
      );

      if (success) {
        setState(() =>
            _status = '✅ Alarm scheduled for ${scheduledTime.toString()}');
      } else {
        setState(() => _status = '❌ Alarm scheduling failed');
      }
    } catch (e) {
      setState(() => _status = '❌ Alarm test failed: $e');
    }
  }

  Future<void> _testImmediateNotification() async {
    try {
      setState(() => _status = 'Showing immediate notification...');

      await _notificationService.showImmediateNotification(
        title: 'Immediate Test',
        body: 'This notification appears immediately',
        type: NotificationType.medication,
      );

      setState(() => _status = '✅ Immediate notification sent');
    } catch (e) {
      setState(() => _status = '❌ Immediate notification failed: $e');
    }
  }

  Future<void> _checkActiveAlarms() async {
    try {
      final alarms = await _alarmService.getActiveAlarms();
      setState(() => _status = 'Active alarms: ${alarms.length}');

      for (final alarm in alarms) {
        debugPrint(
            'Alarm ID: ${alarm.id}, Time: ${alarm.dateTime}, Title: ${alarm.notificationSettings.title}');
      }
    } catch (e) {
      setState(() => _status = '❌ Failed to get active alarms: $e');
    }
  }

  Future<void> _checkPendingNotifications() async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      setState(() => _status = 'Pending notifications: ${pending.length}');

      for (final notif in pending) {
        debugPrint('Notification ID: ${notif.id}, Title: ${notif.title}');
      }
    } catch (e) {
      setState(() => _status = '❌ Failed to get pending notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm & Notification Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isInitialized) ...[
              ElevatedButton.icon(
                onPressed: _testImmediateNotification,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Test Immediate Notification'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _testNotification,
                icon: const Icon(Icons.notification_add),
                label: const Text('Test Scheduled Notification (5s)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _testAlarm,
                icon: const Icon(Icons.alarm),
                label: const Text('Test Alarm (10s)'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _checkActiveAlarms,
                icon: const Icon(Icons.alarm_on),
                label: const Text('Check Active Alarms'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _checkPendingNotifications,
                icon: const Icon(Icons.schedule),
                label: const Text('Check Pending Notifications'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
