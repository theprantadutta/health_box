import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Data Access Object for notification settings
class NotificationSettingsDao {
  final AppDatabase _database;

  NotificationSettingsDao(this._database);

  // CRUD Operations

  /// Get notification settings for a profile
  Future<NotificationSetting?> getNotificationSettings({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.notificationSettings);

      if (profileId != null) {
        query = query..where((s) => s.profileId.equals(profileId));
      } else {
        query = query..where((s) => s.profileId.isNull());
      }

      query = query..limit(1);

      final result = await query.get();
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw Exception('Failed to get notification settings from database: $e');
    }
  }

  /// Get notification settings by ID
  Future<NotificationSetting?> getNotificationSettingsById(String id) async {
    try {
      final query = _database.select(_database.notificationSettings)
        ..where((s) => s.id.equals(id))
        ..limit(1);

      final result = await query.get();
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw Exception('Failed to get notification settings by ID from database: $e');
    }
  }

  /// Create default notification settings
  Future<String> createNotificationSettings({
    String? profileId,
  }) async {
    try {
      final settingsId = 'notification_settings_${DateTime.now().millisecondsSinceEpoch}';

      final settingsCompanion = NotificationSettingsCompanion(
        id: Value(settingsId),
        profileId: Value(profileId),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        // All other fields will use their default values
      );

      await _database.into(_database.notificationSettings).insert(settingsCompanion);
      return settingsId;
    } catch (e) {
      throw Exception('Failed to create notification settings in database: $e');
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(
    String id,
    NotificationSettingsCompanion settingsCompanion,
  ) async {
    try {
      final rowsAffected = await (_database.update(_database.notificationSettings)
            ..where((s) => s.id.equals(id)))
          .write(settingsCompanion.copyWith(
            updatedAt: Value(DateTime.now()),
          ));
      return rowsAffected > 0;
    } catch (e) {
      throw Exception('Failed to update notification settings in database: $e');
    }
  }

  /// Get or create notification settings for a profile
  Future<NotificationSetting> getOrCreateNotificationSettings({
    String? profileId,
  }) async {
    var settings = await getNotificationSettings(profileId: profileId);

    if (settings == null) {
      final settingsId = await createNotificationSettings(profileId: profileId);
      settings = await getNotificationSettingsById(settingsId);
    }

    return settings!;
  }

  // Sound Settings

  /// Update medication sound settings
  Future<bool> updateMedicationSound({
    required String settingsId,
    required String soundName,
    String? soundPath,
    double? volume,
  }) async {
    final settingsCompanion = NotificationSettingsCompanion(
      medicationSoundName: Value(soundName),
      medicationSoundPath: Value(soundPath),
      medicationSoundVolume: volume != null ? Value(volume) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(settingsId, settingsCompanion);
  }

  /// Update appointment sound settings
  Future<bool> updateAppointmentSound({
    required String settingsId,
    required String soundName,
    String? soundPath,
    double? volume,
  }) async {
    final settingsCompanion = NotificationSettingsCompanion(
      appointmentSoundName: Value(soundName),
      appointmentSoundPath: Value(soundPath),
      appointmentSoundVolume: volume != null ? Value(volume) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(settingsId, settingsCompanion);
  }

  /// Update general sound settings
  Future<bool> updateGeneralSound({
    required String settingsId,
    required String soundName,
    String? soundPath,
    double? volume,
  }) async {
    final settingsCompanion = NotificationSettingsCompanion(
      generalSoundName: Value(soundName),
      generalSoundPath: Value(soundPath),
      generalSoundVolume: volume != null ? Value(volume) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(settingsId, settingsCompanion);
  }

  // Vibration Settings

  /// Update vibration settings
  Future<bool> updateVibrationSettings({
    required String settingsId,
    required bool enableVibration,
    String? vibrationPattern,
  }) async {
    final settingsCompanion = NotificationSettingsCompanion(
      enableVibration: Value(enableVibration),
      vibrationPattern: vibrationPattern != null
          ? Value(vibrationPattern)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(settingsId, settingsCompanion);
  }

  // Persistent Notification Settings

  /// Update persistent notification settings
  Future<bool> updatePersistentNotificationSettings({
    required String settingsId,
    required bool enablePersistentNotifications,
    int? timeoutMinutes,
  }) async {
    final settingsCompanion = NotificationSettingsCompanion(
      enablePersistentNotifications: Value(enablePersistentNotifications),
      persistentNotificationTimeout: timeoutMinutes != null
          ? Value(timeoutMinutes)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(settingsId, settingsCompanion);
  }

  // Do Not Disturb Settings

  /// Update do not disturb settings
  Future<bool> updateDoNotDisturbSettings({
    required String settingsId,
    required bool respectDoNotDisturb,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    final settingsCompanion = NotificationSettingsCompanion(
      respectDoNotDisturb: Value(respectDoNotDisturb),
      quietHoursStart: Value(quietHoursStart),
      quietHoursEnd: Value(quietHoursEnd),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(settingsId, settingsCompanion);
  }

  // Display Settings

  /// Update notification display settings
  Future<bool> updateDisplaySettings({
    required String settingsId,
    bool? showOnLockScreen,
    bool? showMedicationName,
    bool? showDosage,
  }) async {
    final settingsCompanion = NotificationSettingsCompanion(
      showOnLockScreen: showOnLockScreen != null
          ? Value(showOnLockScreen)
          : const Value.absent(),
      showMedicationName: showMedicationName != null
          ? Value(showMedicationName)
          : const Value.absent(),
      showDosage: showDosage != null
          ? Value(showDosage)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(settingsId, settingsCompanion);
  }

  // LED Settings

  /// Update LED settings
  Future<bool> updateLedSettings({
    required String settingsId,
    required bool enableLed,
    String? ledColor,
  }) async {
    final settingsCompanion = NotificationSettingsCompanion(
      enableLed: Value(enableLed),
      ledColor: ledColor != null ? Value(ledColor) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(settingsId, settingsCompanion);
  }

  // Snooze Settings

  /// Update snooze settings
  Future<bool> updateSnoozeSettings({
    required String settingsId,
    int? defaultSnoozeMinutes,
    String? availableSnoozeIntervals,
  }) async {
    final settingsCompanion = NotificationSettingsCompanion(
      defaultSnoozeMinutes: defaultSnoozeMinutes != null
          ? Value(defaultSnoozeMinutes)
          : const Value.absent(),
      availableSnoozeIntervals: availableSnoozeIntervals != null
          ? Value(availableSnoozeIntervals)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(settingsId, settingsCompanion);
  }

  // Utility Methods

  /// Check if settings exist for a profile
  Future<bool> settingsExistForProfile({String? profileId}) async {
    final settings = await getNotificationSettings(profileId: profileId);
    return settings != null;
  }

  /// Delete notification settings
  Future<bool> deleteNotificationSettings(String id) async {
    try {
      final rowsAffected = await (_database.delete(_database.notificationSettings)
            ..where((s) => s.id.equals(id)))
          .go();
      return rowsAffected > 0;
    } catch (e) {
      throw Exception('Failed to delete notification settings from database: $e');
    }
  }

  /// Reset notification settings to defaults
  Future<bool> resetToDefaults(String id) async {
    final settingsCompanion = NotificationSettingsCompanion(
      medicationSoundName: const Value('default'),
      medicationSoundPath: const Value(null),
      medicationSoundVolume: const Value(0.8),
      appointmentSoundName: const Value('default'),
      appointmentSoundPath: const Value(null),
      appointmentSoundVolume: const Value(0.8),
      generalSoundName: const Value('default'),
      generalSoundPath: const Value(null),
      generalSoundVolume: const Value(0.8),
      enableVibration: const Value(true),
      vibrationPattern: const Value('default'),
      enablePersistentNotifications: const Value(true),
      persistentNotificationTimeout: const Value(60),
      respectDoNotDisturb: const Value(true),
      quietHoursStart: const Value(null),
      quietHoursEnd: const Value(null),
      showOnLockScreen: const Value(true),
      showMedicationName: const Value(true),
      showDosage: const Value(true),
      enableLed: const Value(false),
      ledColor: const Value('#2196F3'),
      defaultSnoozeMinutes: const Value(15),
      availableSnoozeIntervals: const Value('[5,10,15,30,60]'),
      updatedAt: Value(DateTime.now()),
    );

    return await updateNotificationSettings(id, settingsCompanion);
  }

  // Stream Operations

  /// Watch notification settings for a profile
  Stream<NotificationSetting?> watchNotificationSettings({
    String? profileId,
  }) {
    var query = _database.select(_database.notificationSettings);

    if (profileId != null) {
      query = query..where((s) => s.profileId.equals(profileId));
    } else {
      query = query..where((s) => s.profileId.isNull());
    }

    return query.watchSingleOrNull();
  }
}