import 'package:flutter_test/flutter_test.dart';
import '../../specs/001-build-a-mobile/contracts/reminder_service_contract.dart';
import '../../specs/001-build-a-mobile/contracts/shared_models.dart';

void main() {
  group('ReminderServiceContract', () {
    late ReminderServiceContract service;

    setUpAll(() async {
      // This will fail until we implement ReminderService
      throw UnimplementedError('ReminderService not yet implemented - this test MUST fail');
    });

    group('createReminder', () {
      test('should create daily medication reminder', () async {
        final reminderId = await service.createReminder(
          medicationId: 'test-medication-id',
          title: 'Take Blood Pressure Medication',
          description: 'Lisinopril 10mg',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
          timeSlots: ['08:00'],
          snoozeMinutes: 15,
        );

        expect(reminderId, isNotEmpty);
        expect(reminderId.length, equals(36)); // UUID length
      });

      test('should create weekly appointment reminder', () async {
        final reminderId = await service.createReminder(
          title: 'Doctor Appointment',
          description: 'Annual checkup with Dr. Smith',
          scheduledTime: DateTime.now().add(const Duration(days: 7)),
          frequency: 'weekly',
          daysOfWeek: [1], // Monday
        );

        expect(reminderId, isNotEmpty);
      });

      test('should create one-time reminder', () async {
        final reminderId = await service.createReminder(
          title: 'Lab Test',
          scheduledTime: DateTime.now().add(const Duration(days: 1)),
          frequency: 'once',
        );

        expect(reminderId, isNotEmpty);
      });

      test('should throw ValidationException for invalid frequency', () async {
        expect(
          () => service.createReminder(
            title: 'Test Reminder',
            scheduledTime: DateTime.now().add(const Duration(hours: 1)),
            frequency: 'invalid_frequency',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for past scheduledTime', () async {
        expect(
          () => service.createReminder(
            title: 'Test Reminder',
            scheduledTime: DateTime.now().subtract(const Duration(hours: 1)),
            frequency: 'once',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for empty title', () async {
        expect(
          () => service.createReminder(
            title: '',
            scheduledTime: DateTime.now().add(const Duration(hours: 1)),
            frequency: 'once',
          ),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('updateReminder', () {
      late String existingReminderId;

      setUp(() async {
        existingReminderId = await service.createReminder(
          title: 'Original Reminder',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
        );
      });

      test('should update reminder with valid data', () async {
        final result = await service.updateReminder(
          reminderId: existingReminderId,
          title: 'Updated Reminder',
          description: 'Updated description',
        );

        expect(result, isTrue);
      });

      test('should throw ReminderNotFoundException for non-existent reminder', () async {
        expect(
          () => service.updateReminder(
            reminderId: 'non-existent-id',
            title: 'Updated Title',
          ),
          throwsA(isA<ReminderNotFoundException>()),
        );
      });
    });

    group('getReminder', () {
      late String existingReminderId;

      setUp(() async {
        existingReminderId = await service.createReminder(
          title: 'Test Reminder',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
        );
      });

      test('should return reminder for existing ID', () async {
        final reminder = await service.getReminder(existingReminderId);

        expect(reminder, isNotNull);
        expect(reminder!.id, equals(existingReminderId));
        expect(reminder.title, equals('Test Reminder'));
      });

      test('should return null for non-existent ID', () async {
        final reminder = await service.getReminder('non-existent-id');
        expect(reminder, isNull);
      });
    });

    group('getActiveReminders', () {
      setUp(() async {
        // Create test reminders
        await service.createReminder(
          title: 'Active Reminder 1',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
        );

        await service.createReminder(
          title: 'Active Reminder 2',
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          frequency: 'weekly',
        );
      });

      test('should return all active reminders', () async {
        final reminders = await service.getActiveReminders();

        expect(reminders, hasLength(greaterThanOrEqualTo(2)));
        expect(reminders.every((r) => r.isActive), isTrue);
      });
    });

    group('getRemindersForMedication', () {
      test('should return reminders for specific medication', () async {
        final medicationId = 'test-medication-id';
        
        // Create medication reminder
        await service.createReminder(
          medicationId: medicationId,
          title: 'Medication Reminder',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
        );

        final reminders = await service.getRemindersForMedication(medicationId);

        expect(reminders, hasLength(1));
        expect(reminders.first.medicationId, equals(medicationId));
      });
    });

    group('toggleReminder', () {
      late String existingReminderId;

      setUp(() async {
        existingReminderId = await service.createReminder(
          title: 'Test Reminder',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
        );
      });

      test('should toggle reminder active status', () async {
        // Disable reminder
        final disableResult = await service.toggleReminder(existingReminderId, false);
        expect(disableResult, isTrue);

        // Enable reminder
        final enableResult = await service.toggleReminder(existingReminderId, true);
        expect(enableResult, isTrue);
      });

      test('should throw ReminderNotFoundException for non-existent reminder', () async {
        expect(
          () => service.toggleReminder('non-existent-id', false),
          throwsA(isA<ReminderNotFoundException>()),
        );
      });
    });

    group('deleteReminder', () {
      late String existingReminderId;

      setUp(() async {
        existingReminderId = await service.createReminder(
          title: 'Test Reminder',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
        );
      });

      test('should delete existing reminder', () async {
        final result = await service.deleteReminder(existingReminderId);
        expect(result, isTrue);

        // Reminder should not be found
        final reminder = await service.getReminder(existingReminderId);
        expect(reminder, isNull);
      });

      test('should throw ReminderNotFoundException for non-existent reminder', () async {
        expect(
          () => service.deleteReminder('non-existent-id'),
          throwsA(isA<ReminderNotFoundException>()),
        );
      });
    });

    group('scheduleNext', () {
      late String dailyReminderId;

      setUp(() async {
        dailyReminderId = await service.createReminder(
          title: 'Daily Reminder',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
          timeSlots: ['08:00'],
        );
      });

      test('should schedule next occurrence for daily reminder', () async {
        final nextTime = await service.scheduleNext(dailyReminderId);

        expect(nextTime, isNotNull);
        expect(nextTime!.isAfter(DateTime.now()), isTrue);
      });
    });

    group('markCompleted', () {
      late String oneTimeReminderId;

      setUp(() async {
        oneTimeReminderId = await service.createReminder(
          title: 'One Time Reminder',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'once',
        );
      });

      test('should mark one-time reminder as completed', () async {
        final result = await service.markCompleted(oneTimeReminderId);
        expect(result, isTrue);
      });
    });

    group('snoozeReminder', () {
      late String activeReminderId;

      setUp(() async {
        activeReminderId = await service.createReminder(
          title: 'Active Reminder',
          scheduledTime: DateTime.now().add(const Duration(minutes: 5)),
          frequency: 'daily',
        );
      });

      test('should snooze reminder with default minutes', () async {
        final snoozedTime = await service.snoozeReminder(activeReminderId);

        expect(snoozedTime.isAfter(DateTime.now()), isTrue);
      });

      test('should snooze reminder with custom minutes', () async {
        final snoozedTime = await service.snoozeReminder(
          activeReminderId,
          customMinutes: 30,
        );

        expect(snoozedTime.isAfter(DateTime.now()), isTrue);
      });
    });

    group('getUpcomingReminders', () {
      test('should return reminders scheduled within next 24 hours', () async {
        final upcomingReminders = await service.getUpcomingReminders();
        expect(upcomingReminders, isA<List<Reminder>>());
      });

      test('should return reminders scheduled within custom hours', () async {
        final upcomingReminders = await service.getUpcomingReminders(hoursAhead: 48);
        expect(upcomingReminders, isA<List<Reminder>>());
      });
    });

    group('validateReminderData', () {
      test('should return valid result for correct data', () {
        final result = service.validateReminderData(
          title: 'Test Reminder',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
          timeSlots: ['08:00'],
        );

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
      });

      test('should return invalid result for empty title', () {
        final result = service.validateReminderData(
          title: '',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'daily',
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('Title cannot be empty'));
      });

      test('should return invalid result for past scheduled time', () {
        final result = service.validateReminderData(
          title: 'Test Reminder',
          scheduledTime: DateTime.now().subtract(const Duration(hours: 1)),
          frequency: 'daily',
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('Scheduled time cannot be in the past'));
      });

      test('should return invalid result for invalid frequency', () {
        final result = service.validateReminderData(
          title: 'Test Reminder',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          frequency: 'invalid_frequency',
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('Frequency must be once, daily, weekly, or monthly'));
      });
    });
  });

  group('NotificationServiceContract', () {
    late NotificationServiceContract service;

    setUpAll(() {
      throw UnimplementedError('NotificationService not yet implemented - this test MUST fail');
    });

    test('should schedule notification', () async {
      await service.scheduleNotification(
        reminderId: 'test-reminder-id',
        title: 'Medication Reminder',
        body: 'Time to take your medication',
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );
    });

    test('should cancel notification', () async {
      await service.cancelNotification('test-reminder-id');
    });

    test('should check notification permissions', () async {
      final hasPermissions = await service.hasNotificationPermissions();
      expect(hasPermissions, isA<bool>());
    });

    test('should request notification permissions', () async {
      final granted = await service.requestNotificationPermissions();
      expect(granted, isA<bool>());
    });

    test('should handle notification tap', () async {
      await service.handleNotificationTap('test-reminder-id', 'mark_taken');
    });
  });
}