import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/notification_settings_dao.dart';
import '../../../data/models/notification_settings.dart';

/// Service for managing notification settings and sound preferences
class NotificationSettingsService {
  final NotificationSettingsDao _settingsDao;

  NotificationSettingsService({
    NotificationSettingsDao? settingsDao,
    AppDatabase? database,
  }) : _settingsDao = settingsDao ??
           NotificationSettingsDao(database ?? AppDatabase.instance);

  // CRUD Operations

  /// Get notification settings for a profile
  Future<NotificationSetting> getNotificationSettings({
    String? profileId,
  }) async {
    try {
      return await _settingsDao.getOrCreateNotificationSettings(
        profileId: profileId,
      );
    } catch (e) {
      throw NotificationSettingsServiceException(
        'Failed to get notification settings: ${e.toString()}',
      );
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings({
    required String settingsId,
    required NotificationSettingsCompanion settings,
  }) async {
    try {
      return await _settingsDao.updateNotificationSettings(
        settingsId,
        settings,
      );
    } catch (e) {
      throw NotificationSettingsServiceException(
        'Failed to update notification settings: ${e.toString()}',
      );
    }
  }

  // Sound Settings

  /// Update medication sound
  Future<bool> updateMedicationSound({
    String? profileId,
    required String soundName,
    String? customSoundPath,
    double? volume,
  }) async {
    try {
      final settings = await getNotificationSettings(profileId: profileId);

      _validateSoundSettings(soundName, volume);

      final soundPath = soundName == NotificationSounds.custom
          ? customSoundPath
          : NotificationSounds.getSoundPath(soundName);

      return await _settingsDao.updateMedicationSound(
        settingsId: settings.id,
        soundName: soundName,
        soundPath: soundPath,
        volume: volume,
      );
    } catch (e) {
      if (e is NotificationSettingsServiceException) rethrow;
      throw NotificationSettingsServiceException(
        'Failed to update medication sound: ${e.toString()}',
      );
    }
  }

  /// Update appointment sound
  Future<bool> updateAppointmentSound({
    String? profileId,
    required String soundName,
    String? customSoundPath,
    double? volume,
  }) async {
    try {
      final settings = await getNotificationSettings(profileId: profileId);

      _validateSoundSettings(soundName, volume);

      final soundPath = soundName == NotificationSounds.custom
          ? customSoundPath
          : NotificationSounds.getSoundPath(soundName);

      return await _settingsDao.updateAppointmentSound(
        settingsId: settings.id,
        soundName: soundName,
        soundPath: soundPath,
        volume: volume,
      );
    } catch (e) {
      if (e is NotificationSettingsServiceException) rethrow;
      throw NotificationSettingsServiceException(
        'Failed to update appointment sound: ${e.toString()}',
      );
    }
  }

  /// Update general reminder sound
  Future<bool> updateGeneralSound({
    String? profileId,
    required String soundName,
    String? customSoundPath,
    double? volume,
  }) async {
    try {
      final settings = await getNotificationSettings(profileId: profileId);

      _validateSoundSettings(soundName, volume);

      final soundPath = soundName == NotificationSounds.custom
          ? customSoundPath
          : NotificationSounds.getSoundPath(soundName);

      return await _settingsDao.updateGeneralSound(
        settingsId: settings.id,
        soundName: soundName,
        soundPath: soundPath,
        volume: volume,
      );
    } catch (e) {
      if (e is NotificationSettingsServiceException) rethrow;
      throw NotificationSettingsServiceException(
        'Failed to update general sound: ${e.toString()}',
      );
    }
  }

  // Vibration Settings

  /// Update vibration settings
  Future<bool> updateVibrationSettings({
    String? profileId,
    required bool enableVibration,
    String? vibrationPattern,
  }) async {
    try {
      final settings = await getNotificationSettings(profileId: profileId);

      if (vibrationPattern != null &&
          !VibrationPatterns.allPatterns.contains(vibrationPattern)) {
        throw const NotificationSettingsServiceException(
          'Invalid vibration pattern',
        );
      }

      return await _settingsDao.updateVibrationSettings(
        settingsId: settings.id,
        enableVibration: enableVibration,
        vibrationPattern: vibrationPattern,
      );
    } catch (e) {
      if (e is NotificationSettingsServiceException) rethrow;
      throw NotificationSettingsServiceException(
        'Failed to update vibration settings: ${e.toString()}',
      );
    }
  }

  // Persistent Notification Settings

  /// Update persistent notification settings
  Future<bool> updatePersistentNotificationSettings({
    String? profileId,
    required bool enablePersistentNotifications,
    int? timeoutMinutes,
  }) async {
    try {
      final settings = await getNotificationSettings(profileId: profileId);

      if (timeoutMinutes != null &&
          (timeoutMinutes < 1 || timeoutMinutes > 1440)) {
        throw const NotificationSettingsServiceException(
          'Timeout must be between 1 and 1440 minutes',
        );
      }

      return await _settingsDao.updatePersistentNotificationSettings(
        settingsId: settings.id,
        enablePersistentNotifications: enablePersistentNotifications,
        timeoutMinutes: timeoutMinutes,
      );
    } catch (e) {
      if (e is NotificationSettingsServiceException) rethrow;
      throw NotificationSettingsServiceException(
        'Failed to update persistent notification settings: ${e.toString()}',
      );
    }
  }

  // Do Not Disturb Settings

  /// Update do not disturb settings
  Future<bool> updateDoNotDisturbSettings({
    String? profileId,
    required bool respectDoNotDisturb,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    try {
      final settings = await getNotificationSettings(profileId: profileId);

      _validateTimeFormat(quietHoursStart);
      _validateTimeFormat(quietHoursEnd);

      return await _settingsDao.updateDoNotDisturbSettings(
        settingsId: settings.id,
        respectDoNotDisturb: respectDoNotDisturb,
        quietHoursStart: quietHoursStart,
        quietHoursEnd: quietHoursEnd,
      );
    } catch (e) {
      if (e is NotificationSettingsServiceException) rethrow;
      throw NotificationSettingsServiceException(
        'Failed to update do not disturb settings: ${e.toString()}',
      );
    }
  }

  // Utility Methods

  /// Test a notification sound
  Future<bool> testNotificationSound({
    required String soundName,
    String? customSoundPath,
    double? volume,
  }) async {
    try {
      _validateSoundSettings(soundName, volume);

      final soundPath = soundName == NotificationSounds.custom
          ? customSoundPath
          : NotificationSounds.getSoundPath(soundName);

      if (soundPath != null) {
        // Check if custom sound file exists
        if (soundName == NotificationSounds.custom && customSoundPath != null) {
          final file = File(customSoundPath);
          if (!await file.exists()) {
            throw const NotificationSettingsServiceException(
              'Custom sound file not found',
            );
          }
        }
      }

      // TODO: Implement actual sound playback test
      // This would use a sound player library to play the sound
      return true;
    } catch (e) {
      if (e is NotificationSettingsServiceException) rethrow;
      throw NotificationSettingsServiceException(
        'Failed to test sound: ${e.toString()}',
      );
    }
  }

  /// Get available snooze intervals
  List<int> getAvailableSnoozeIntervals({String? profileId}) {
    // This would typically fetch from settings, but for now return defaults
    return [5, 10, 15, 30, 60];
  }

  /// Update available snooze intervals
  Future<bool> updateAvailableSnoozeIntervals({
    String? profileId,
    required List<int> intervals,
  }) async {
    try {
      final settings = await getNotificationSettings(profileId: profileId);

      // Validate intervals
      for (final interval in intervals) {
        if (interval < 1 || interval > 1440) {
          throw const NotificationSettingsServiceException(
            'Snooze intervals must be between 1 and 1440 minutes',
          );
        }
      }

      final intervalsJson = json.encode(intervals);

      return await _settingsDao.updateSnoozeSettings(
        settingsId: settings.id,
        availableSnoozeIntervals: intervalsJson,
      );
    } catch (e) {
      if (e is NotificationSettingsServiceException) rethrow;
      throw NotificationSettingsServiceException(
        'Failed to update snooze intervals: ${e.toString()}',
      );
    }
  }

  /// Reset all settings to defaults
  Future<bool> resetToDefaults({String? profileId}) async {
    try {
      final settings = await getNotificationSettings(profileId: profileId);
      return await _settingsDao.resetToDefaults(settings.id);
    } catch (e) {
      throw NotificationSettingsServiceException(
        'Failed to reset settings to defaults: ${e.toString()}',
      );
    }
  }

  /// Check if it's currently quiet hours
  bool isInQuietHours(NotificationSetting settings) {
    if (!settings.respectDoNotDisturb ||
        settings.quietHoursStart == null ||
        settings.quietHoursEnd == null) {
      return false;
    }

    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

      final startTime = _parseTimeString(settings.quietHoursStart!);
      final endTime = _parseTimeString(settings.quietHoursEnd!);

      if (startTime.hour < endTime.hour ||
          (startTime.hour == endTime.hour && startTime.minute <= endTime.minute)) {
        // Same day quiet hours
        return _isTimeInRange(currentTime, startTime, endTime);
      } else {
        // Overnight quiet hours
        return _isTimeAfter(currentTime, startTime) ||
               _isTimeBefore(currentTime, endTime);
      }
    } catch (e) {
      // If there's any error parsing times, assume not in quiet hours
      return false;
    }
  }

  // Stream Operations

  /// Watch notification settings for a profile
  Stream<NotificationSetting?> watchNotificationSettings({
    String? profileId,
  }) {
    return _settingsDao.watchNotificationSettings(profileId: profileId);
  }

  // Private Helper Methods

  void _validateSoundSettings(String soundName, double? volume) {
    if (!NotificationSounds.allSounds.contains(soundName)) {
      throw NotificationSettingsServiceException(
        'Invalid sound name: $soundName',
      );
    }

    if (volume != null && (volume < 0.0 || volume > 1.0)) {
      throw const NotificationSettingsServiceException(
        'Volume must be between 0.0 and 1.0',
      );
    }
  }

  void _validateTimeFormat(String? timeString) {
    if (timeString == null) return;

    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(timeString)) {
      throw NotificationSettingsServiceException(
        'Invalid time format: $timeString. Expected HH:MM',
      );
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  bool _isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  bool _isTimeAfter(TimeOfDay time, TimeOfDay reference) {
    final timeMinutes = time.hour * 60 + time.minute;
    final refMinutes = reference.hour * 60 + reference.minute;
    return timeMinutes >= refMinutes;
  }

  bool _isTimeBefore(TimeOfDay time, TimeOfDay reference) {
    final timeMinutes = time.hour * 60 + time.minute;
    final refMinutes = reference.hour * 60 + reference.minute;
    return timeMinutes <= refMinutes;
  }
}

/// Exception for notification settings service errors
class NotificationSettingsServiceException implements Exception {
  final String message;

  const NotificationSettingsServiceException(this.message);

  @override
  String toString() => 'NotificationSettingsServiceException: $message';
}