import 'package:drift/drift.dart';

/// Table for storing user notification settings and preferences
class NotificationSettings extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().nullable().named('profile_id')();

  // Sound Settings
  TextColumn get medicationSoundName =>
      text().withDefault(const Constant('default')).named('medication_sound_name')();
  TextColumn get medicationSoundPath =>
      text().nullable().named('medication_sound_path')();
  RealColumn get medicationSoundVolume =>
      real().withDefault(const Constant(0.8)).named('medication_sound_volume')();

  TextColumn get appointmentSoundName =>
      text().withDefault(const Constant('default')).named('appointment_sound_name')();
  TextColumn get appointmentSoundPath =>
      text().nullable().named('appointment_sound_path')();
  RealColumn get appointmentSoundVolume =>
      real().withDefault(const Constant(0.8)).named('appointment_sound_volume')();

  TextColumn get generalSoundName =>
      text().withDefault(const Constant('default')).named('general_sound_name')();
  TextColumn get generalSoundPath =>
      text().nullable().named('general_sound_path')();
  RealColumn get generalSoundVolume =>
      real().withDefault(const Constant(0.8)).named('general_sound_volume')();

  // Vibration Settings
  BoolColumn get enableVibration =>
      boolean().withDefault(const Constant(true)).named('enable_vibration')();
  TextColumn get vibrationPattern =>
      text().withDefault(const Constant('default')).named('vibration_pattern')();

  // Persistent Notification Settings
  BoolColumn get enablePersistentNotifications =>
      boolean().withDefault(const Constant(true)).named('enable_persistent_notifications')();
  IntColumn get persistentNotificationTimeout =>
      integer().withDefault(const Constant(60)).named('persistent_notification_timeout')(); // minutes

  // Do Not Disturb Settings
  BoolColumn get respectDoNotDisturb =>
      boolean().withDefault(const Constant(true)).named('respect_do_not_disturb')();
  TextColumn get quietHoursStart =>
      text().nullable().named('quiet_hours_start')(); // HH:MM format
  TextColumn get quietHoursEnd =>
      text().nullable().named('quiet_hours_end')(); // HH:MM format

  // Notification Display Settings
  BoolColumn get showOnLockScreen =>
      boolean().withDefault(const Constant(true)).named('show_on_lock_screen')();
  BoolColumn get showMedicationName =>
      boolean().withDefault(const Constant(true)).named('show_medication_name')();
  BoolColumn get showDosage =>
      boolean().withDefault(const Constant(true)).named('show_dosage')();

  // LED Settings (Android)
  BoolColumn get enableLed =>
      boolean().withDefault(const Constant(false)).named('enable_led')();
  TextColumn get ledColor =>
      text().withDefault(const Constant('#2196F3')).named('led_color')();

  // Snooze Settings
  IntColumn get defaultSnoozeMinutes =>
      integer().withDefault(const Constant(15)).named('default_snooze_minutes')();
  TextColumn get availableSnoozeIntervals =>
      text().withDefault(const Constant('[5,10,15,30,60]')).named('available_snooze_intervals')(); // JSON array

  // Metadata
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (medication_sound_volume >= 0.0 AND medication_sound_volume <= 1.0)',
    'CHECK (appointment_sound_volume >= 0.0 AND appointment_sound_volume <= 1.0)',
    'CHECK (general_sound_volume >= 0.0 AND general_sound_volume <= 1.0)',
    'CHECK (persistent_notification_timeout >= 1 AND persistent_notification_timeout <= 1440)',
    'CHECK (default_snooze_minutes >= 1 AND default_snooze_minutes <= 1440)',
    'CHECK (LENGTH(TRIM(medication_sound_name)) > 0)',
    'CHECK (LENGTH(TRIM(appointment_sound_name)) > 0)',
    'CHECK (LENGTH(TRIM(general_sound_name)) > 0)',
  ];
}

/// Built-in notification sound options
class NotificationSounds {
  static const String defaultSound = 'default';
  static const String gentle = 'gentle';
  static const String chime = 'chime';
  static const String bell = 'bell';
  static const String alert = 'alert';
  static const String reminder = 'reminder';
  static const String ping = 'ping';
  static const String beep = 'beep';
  static const String custom = 'custom';

  static const List<String> allSounds = [
    defaultSound,
    gentle,
    chime,
    bell,
    alert,
    reminder,
    ping,
    beep,
    custom,
  ];

  static String getDisplayName(String soundName) {
    switch (soundName) {
      case defaultSound:
        return 'Default';
      case gentle:
        return 'Gentle';
      case chime:
        return 'Chime';
      case bell:
        return 'Bell';
      case alert:
        return 'Alert';
      case reminder:
        return 'Reminder';
      case ping:
        return 'Ping';
      case beep:
        return 'Beep';
      case custom:
        return 'Custom Sound';
      default:
        return soundName;
    }
  }

  static String? getSoundPath(String soundName) {
    switch (soundName) {
      case defaultSound:
        return null; // Use system default
      case gentle:
        return 'assets/sounds/gentle.mp3';
      case chime:
        return 'assets/sounds/chime.mp3';
      case bell:
        return 'assets/sounds/bell.mp3';
      case alert:
        return 'assets/sounds/alert.mp3';
      case reminder:
        return 'assets/sounds/reminder.mp3';
      case ping:
        return 'assets/sounds/ping.mp3';
      case beep:
        return 'assets/sounds/beep.mp3';
      default:
        return null;
    }
  }
}

/// Vibration pattern options
class VibrationPatterns {
  static const String defaultPattern = 'default';
  static const String gentle = 'gentle';
  static const String double = 'double';
  static const String triple = 'triple';
  static const String long = 'long';
  static const String pulse = 'pulse';
  static const String none = 'none';

  static const List<String> allPatterns = [
    defaultPattern,
    gentle,
    double,
    triple,
    long,
    pulse,
    none,
  ];

  static String getDisplayName(String pattern) {
    switch (pattern) {
      case defaultPattern:
        return 'Default';
      case gentle:
        return 'Gentle';
      case double:
        return 'Double Pulse';
      case triple:
        return 'Triple Pulse';
      case long:
        return 'Long';
      case pulse:
        return 'Pulse';
      case none:
        return 'No Vibration';
      default:
        return pattern;
    }
  }

  static List<int>? getVibrationPattern(String pattern) {
    switch (pattern) {
      case defaultPattern:
        return [0, 500, 250, 500]; // Default Android pattern
      case gentle:
        return [0, 200, 100, 200];
      case double:
        return [0, 300, 150, 300];
      case triple:
        return [0, 200, 100, 200, 100, 200];
      case long:
        return [0, 1000];
      case pulse:
        return [0, 100, 100, 100, 100, 100];
      case none:
        return null; // No vibration
      default:
        return [0, 500, 250, 500];
    }
  }
}