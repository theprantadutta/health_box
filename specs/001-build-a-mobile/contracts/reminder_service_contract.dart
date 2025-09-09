// Reminder Service Contract - Medication and appointment notifications
// Corresponds to FR-004: System MUST provide medication and appointment reminder functionality

abstract class ReminderServiceContract {
  // Create new reminder
  // Returns: Reminder ID on success, throws ValidationException on invalid data
  Future<String> createReminder({
    String? medicationId,
    required String title,
    String? description,
    required DateTime scheduledTime,
    required String frequency, // once, daily, weekly, monthly
    List<int>? daysOfWeek, // 1=Monday, 7=Sunday
    List<String>? timeSlots,
    int snoozeMinutes = 10,
  });

  // Update existing reminder
  // Returns: true on success, throws ReminderNotFoundException if not found
  Future<bool> updateReminder({
    required String reminderId,
    String? title,
    String? description,
    DateTime? scheduledTime,
    String? frequency,
    List<int>? daysOfWeek,
    List<String>? timeSlots,
    int? snoozeMinutes,
  });

  // Get reminder by ID
  // Returns: Reminder or null if not found
  Future<Reminder?> getReminder(String reminderId);

  // Get all active reminders
  // Returns: List of active reminders, optionally for specific profile
  Future<List<Reminder>> getActiveReminders({String? profileId});

  // Get reminders for specific medication
  // Returns: List of reminders linked to medication
  Future<List<Reminder>> getRemindersForMedication(String medicationId);

  // Enable/disable reminder
  // Returns: true on success, throws ReminderNotFoundException if not found
  Future<bool> toggleReminder(String reminderId, bool isActive);

  // Delete reminder
  // Returns: true on success, throws ReminderNotFoundException if not found
  Future<bool> deleteReminder(String reminderId);

  // Schedule next notification
  // Returns: DateTime of next scheduled notification
  Future<DateTime?> scheduleNext(String reminderId);

  // Mark reminder as completed (for one-time reminders)
  // Returns: true on success
  Future<bool> markCompleted(String reminderId);

  // Snooze active reminder
  // Returns: DateTime of snoozed notification
  Future<DateTime> snoozeReminder(String reminderId, {int? customMinutes});

  // Get upcoming reminders
  // Returns: List of reminders scheduled within next X hours
  Future<List<Reminder>> getUpcomingReminders({int hoursAhead = 24});

  // Validate reminder data
  ValidationResult validateReminderData({
    required String title,
    required DateTime scheduledTime,
    required String frequency,
    List<int>? daysOfWeek,
    List<String>? timeSlots,
  });
}

// Notification handling contract
abstract class NotificationServiceContract {
  // Schedule local notification
  Future<void> scheduleNotification({
    required String reminderId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? payload,
  });

  // Cancel scheduled notification
  Future<void> cancelNotification(String reminderId);

  // Cancel all notifications for profile
  Future<void> cancelAllNotifications({String? profileId});

  // Handle notification tap/action
  Future<void> handleNotificationTap(String reminderId, String? action);

  // Check notification permissions
  Future<bool> hasNotificationPermissions();

  // Request notification permissions
  Future<bool> requestNotificationPermissions();
}

class ReminderNotFoundException implements Exception {
  final String reminderId;
  ReminderNotFoundException(this.reminderId);
}