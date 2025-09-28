import 'package:flutter/material.dart';
import 'lib/features/reminders/services/notification_service.dart';
import 'lib/features/reminders/services/alarm_service.dart';

// Simple test file to validate notification and alarm functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🧪 Testing HealthBox Notification & Alarm System');

  // Test NotificationService
  try {
    print('📱 Testing NotificationService...');
    final notificationService = NotificationService();
    final notificationSuccess = await notificationService.initialize();
    print('NotificationService initialization: ${notificationSuccess ? "✅ SUCCESS" : "❌ FAILED"}');

    if (notificationSuccess) {
      // Try to show an immediate notification
      await notificationService.showImmediateNotification(
        title: 'Test Notification',
        body: 'HealthBox notifications are working!',
      );
      print('✅ Test notification sent successfully');
    }
  } catch (e) {
    print('❌ NotificationService error: $e');
  }

  // Test AlarmService
  try {
    print('🔔 Testing AlarmService...');
    final alarmService = AlarmService();
    final alarmSuccess = await alarmService.initialize();
    print('AlarmService initialization: ${alarmSuccess ? "✅ SUCCESS" : "❌ FAILED"}');

    if (alarmSuccess) {
      final sounds = alarmService.getAvailableAlarmSounds();
      print('✅ Available alarm sounds: $sounds');
    }
  } catch (e) {
    print('❌ AlarmService error: $e');
  }

  print('🎉 Test completed!');
}