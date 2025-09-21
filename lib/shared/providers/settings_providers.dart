import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Reminder type enum
enum ReminderType {
  notification,
  alarm,
  both,
}

// Settings state model
class AppSettings {
  final bool notificationsEnabled;
  final bool autoBackupEnabled;
  final bool debugModeEnabled;
  final ReminderType reminderType;
  final String alarmSound;
  final double alarmVolume;
  final bool enableAlarmVibration;
  final int defaultSnoozeMinutes;
  final bool enableCriticalAlarmOverride;

  const AppSettings({
    this.notificationsEnabled = true,
    this.autoBackupEnabled = false,
    this.debugModeEnabled = false,
    this.reminderType = ReminderType.notification,
    this.alarmSound = 'gentle',
    this.alarmVolume = 0.8,
    this.enableAlarmVibration = true,
    this.defaultSnoozeMinutes = 15,
    this.enableCriticalAlarmOverride = false,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? autoBackupEnabled,
    bool? debugModeEnabled,
    ReminderType? reminderType,
    String? alarmSound,
    double? alarmVolume,
    bool? enableAlarmVibration,
    int? defaultSnoozeMinutes,
    bool? enableCriticalAlarmOverride,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      debugModeEnabled: debugModeEnabled ?? this.debugModeEnabled,
      reminderType: reminderType ?? this.reminderType,
      alarmSound: alarmSound ?? this.alarmSound,
      alarmVolume: alarmVolume ?? this.alarmVolume,
      enableAlarmVibration: enableAlarmVibration ?? this.enableAlarmVibration,
      defaultSnoozeMinutes: defaultSnoozeMinutes ?? this.defaultSnoozeMinutes,
      enableCriticalAlarmOverride: enableCriticalAlarmOverride ?? this.enableCriticalAlarmOverride,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'autoBackupEnabled': autoBackupEnabled,
      'debugModeEnabled': debugModeEnabled,
      'reminderType': reminderType.index,
      'alarmSound': alarmSound,
      'alarmVolume': alarmVolume,
      'enableAlarmVibration': enableAlarmVibration,
      'defaultSnoozeMinutes': defaultSnoozeMinutes,
      'enableCriticalAlarmOverride': enableCriticalAlarmOverride,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      autoBackupEnabled: map['autoBackupEnabled'] as bool? ?? false,
      debugModeEnabled: map['debugModeEnabled'] as bool? ?? false,
      reminderType: ReminderType.values[map['reminderType'] as int? ?? 0],
      alarmSound: map['alarmSound'] as String? ?? 'gentle',
      alarmVolume: map['alarmVolume'] as double? ?? 0.8,
      enableAlarmVibration: map['enableAlarmVibration'] as bool? ?? true,
      defaultSnoozeMinutes: map['defaultSnoozeMinutes'] as int? ?? 15,
      enableCriticalAlarmOverride: map['enableCriticalAlarmOverride'] as bool? ?? false,
    );
  }
}

// Settings notifier
class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsNotifier() : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsMap = <String, dynamic>{};

      // Load individual settings
      settingsMap['notificationsEnabled'] =
          prefs.getBool('notifications_enabled') ?? true;
      settingsMap['autoBackupEnabled'] =
          prefs.getBool('auto_backup_enabled') ?? false;
      settingsMap['debugModeEnabled'] =
          prefs.getBool('debug_mode_enabled') ?? false;
      settingsMap['reminderType'] =
          prefs.getInt('reminder_type') ?? ReminderType.notification.index;
      settingsMap['alarmSound'] =
          prefs.getString('alarm_sound') ?? 'gentle';
      settingsMap['alarmVolume'] =
          prefs.getDouble('alarm_volume') ?? 0.8;
      settingsMap['enableAlarmVibration'] =
          prefs.getBool('enable_alarm_vibration') ?? true;
      settingsMap['defaultSnoozeMinutes'] =
          prefs.getInt('default_snooze_minutes') ?? 15;
      settingsMap['enableCriticalAlarmOverride'] =
          prefs.getBool('enable_critical_alarm_override') ?? false;

      final settings = AppSettings.fromMap(settingsMap);
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);

      state = AsyncValue.data(
        currentSettings.copyWith(notificationsEnabled: enabled),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleAutoBackup(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_backup_enabled', enabled);

      state = AsyncValue.data(
        currentSettings.copyWith(autoBackupEnabled: enabled),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleDebugMode(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('debug_mode_enabled', enabled);

      state = AsyncValue.data(
        currentSettings.copyWith(debugModeEnabled: enabled),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateReminderType(ReminderType type) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_type', type.index);

      state = AsyncValue.data(
        currentSettings.copyWith(reminderType: type),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateAlarmSound(String soundKey) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alarm_sound', soundKey);

      state = AsyncValue.data(
        currentSettings.copyWith(alarmSound: soundKey),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateAlarmVolume(double volume) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('alarm_volume', volume);

      state = AsyncValue.data(
        currentSettings.copyWith(alarmVolume: volume),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleAlarmVibration(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('enable_alarm_vibration', enabled);

      state = AsyncValue.data(
        currentSettings.copyWith(enableAlarmVibration: enabled),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateDefaultSnoozeMinutes(int minutes) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('default_snooze_minutes', minutes);

      state = AsyncValue.data(
        currentSettings.copyWith(defaultSnoozeMinutes: minutes),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleCriticalAlarmOverride(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('enable_critical_alarm_override', enabled);

      state = AsyncValue.data(
        currentSettings.copyWith(enableCriticalAlarmOverride: enabled),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Settings provider
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
      return SettingsNotifier();
    });

// Convenience providers for individual settings
final notificationsEnabledProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.value?.notificationsEnabled ?? true;
});

final autoBackupEnabledProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.value?.autoBackupEnabled ?? false;
});

final debugModeEnabledProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.value?.debugModeEnabled ?? false;
});

// New providers for reminder/alarm settings
final reminderTypeProvider = Provider<ReminderType>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.value?.reminderType ?? ReminderType.notification;
});

final alarmSoundProvider = Provider<String>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.value?.alarmSound ?? 'gentle';
});

final alarmVolumeProvider = Provider<double>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.value?.alarmVolume ?? 0.8;
});

final enableAlarmVibrationProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.value?.enableAlarmVibration ?? true;
});

final defaultSnoozeMinutesProvider = Provider<int>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.value?.defaultSnoozeMinutes ?? 15;
});

final enableCriticalAlarmOverrideProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.value?.enableCriticalAlarmOverride ?? false;
});

// Helper extensions
extension ReminderTypeExtension on ReminderType {
  String get displayName {
    switch (this) {
      case ReminderType.notification:
        return 'Notifications Only';
      case ReminderType.alarm:
        return 'Alarms Only';
      case ReminderType.both:
        return 'Notifications + Alarms';
    }
  }

  String get description {
    switch (this) {
      case ReminderType.notification:
        return 'Show quiet notifications that appear in your notification panel';
      case ReminderType.alarm:
        return 'Play loud alarms that work even when your phone is silenced';
      case ReminderType.both:
        return 'Show notifications first, then escalate to alarms if not acknowledged';
    }
  }

  bool get usesNotifications => this == ReminderType.notification || this == ReminderType.both;
  bool get usesAlarms => this == ReminderType.alarm || this == ReminderType.both;
}
