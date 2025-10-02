import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:alarm/alarm.dart';
import '../../../shared/widgets/alarm_sound_picker.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  bool _isInitialized = false;

  // Use the alarm sounds from the AlarmSoundPicker extension
  static Map<String, AlarmSoundInfo> get _alarmSounds {
    final Map<String, AlarmSoundInfo> sounds = {};
    for (final sound in AlarmSoundExtension.allSounds) {
      sounds[sound.key] = sound;
    }
    return sounds;
  }

  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      debugPrint('AlarmService: Initializing alarm service...');

      // Initialize the alarm package (only once)
      await Alarm.init();

      _isInitialized = true;

      // DON'T listen to ringStream here - AlarmListener widget handles it globally
      // Listening in multiple places causes "Stream has already been listened to" error

      debugPrint('AlarmService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize AlarmService: $e');
      _isInitialized = false;
      return false;
    }
  }

  Future<bool> setAlarm({
    required String reminderId,
    required DateTime scheduledTime,
    required String title,
    required String body,
    String alarmSound = 'gentle',
    bool loopAudio = true,
    bool vibrate = true,
    double volume = 0.8,
    double? volumeMin,
    double? volumeMax,
    int fadeInDuration = 0,
    bool enableNotificationOnKill = true,
  }) async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          debugPrint(
            'AlarmService: Failed to initialize, falling back to notifications',
          );
          return false;
        }
      }

      final soundInfo = _alarmSounds[alarmSound];
      if (soundInfo == null) {
        debugPrint(
          'AlarmService: Invalid alarm sound: $alarmSound, using default',
        );
        return false;
      }

      final alarmId = reminderId.hashCode;

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: scheduledTime,
        assetAudioPath: soundInfo.assetPath,
        loopAudio: loopAudio,
        vibrate: vibrate,
        // VolumeSettings controls alarm volume when it rings
        // Use 1ms fade for near-instant sound (null would use system volume)
        volumeSettings: VolumeSettings.fade(
          fadeDuration: const Duration(seconds: 3),
          volume: volume.clamp(0.0, 1.0),
          volumeEnforced: true,
        ),
        notificationSettings: NotificationSettings(
          title: title,
          body: body,
          stopButton: 'Stop Alarm',
        ),
        androidFullScreenIntent:
            false, // We handle our own alarm screen via AlarmListener
        warningNotificationOnKill: enableNotificationOnKill,
      );

      final success = await Alarm.set(alarmSettings: alarmSettings);

      if (success) {
        debugPrint(
          'AlarmService: Successfully set alarm for $reminderId at $scheduledTime',
        );
      } else {
        debugPrint('AlarmService: Failed to set alarm for $reminderId');
      }

      return success;
    } catch (e) {
      debugPrint('AlarmService: Error setting alarm: $e');
      return false;
    }
  }

  Future<bool> stopAlarm(String reminderId) async {
    try {
      final alarmId = reminderId.hashCode;
      final success = await Alarm.stop(alarmId);

      if (success) {
        debugPrint('AlarmService: Successfully stopped alarm for $reminderId');
      } else {
        debugPrint('AlarmService: No alarm found to stop for $reminderId');
      }

      return success;
    } catch (e) {
      debugPrint('AlarmService: Error stopping alarm: $e');
      return false;
    }
  }

  Future<bool> isAlarmRinging(String reminderId) async {
    try {
      final alarmId = reminderId.hashCode;
      return Alarm.isRinging(alarmId);
    } catch (e) {
      debugPrint('AlarmService: Error checking if alarm is ringing: $e');
      return false;
    }
  }

  Future<bool> hasAlarm(String reminderId) async {
    try {
      final alarmId = reminderId.hashCode;
      final alarms = await getActiveAlarms();
      return alarms.any((alarm) => alarm.id == alarmId);
    } catch (e) {
      debugPrint('AlarmService: Error checking if alarm exists: $e');
      return false;
    }
  }

  Future<List<AlarmSettings>> getActiveAlarms() async {
    try {
      return Alarm.getAlarms();
    } catch (e) {
      debugPrint('AlarmService: Error getting active alarms: $e');
      return [];
    }
  }

  Future<AlarmSettings?> getAlarm(String reminderId) async {
    try {
      final alarmId = reminderId.hashCode;
      final alarms = await getActiveAlarms();
      for (final alarm in alarms) {
        if (alarm.id == alarmId) {
          return alarm;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> stopAllAlarms() async {
    try {
      await Alarm.stopAll();
      debugPrint('AlarmService: Stopped all alarms');
    } catch (e) {
      debugPrint('AlarmService: Error stopping all alarms: $e');
    }
  }

  Future<bool> snoozeAlarm({
    required String reminderId,
    required String title,
    required String body,
    int snoozeMinutes = 15,
    String alarmSound = 'gentle',
  }) async {
    try {
      // Stop the current alarm
      await stopAlarm(reminderId);

      // Schedule a new alarm for the snooze time
      final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));
      final snoozedReminderId =
          '${reminderId}_snoozed_${DateTime.now().millisecondsSinceEpoch}';

      return await setAlarm(
        reminderId: snoozedReminderId,
        scheduledTime: snoozeTime,
        title: '$title (Snoozed)',
        body: body,
        alarmSound: alarmSound,
      );
    } catch (e) {
      debugPrint('AlarmService: Error snoozing alarm: $e');
      return false;
    }
  }

  List<String> getAvailableAlarmSounds() {
    return _alarmSounds.keys.toList();
  }

  List<AlarmSoundInfo> getAlarmSoundInfoList() {
    return _alarmSounds.values.toList();
  }

  AlarmSoundInfo? getAlarmSoundInfo(String soundKey) {
    return _alarmSounds[soundKey];
  }

  String getAlarmSoundDisplayName(String soundKey) {
    final soundInfo = _alarmSounds[soundKey];
    return soundInfo?.displayName ?? 'Unknown Sound';
  }

  Future<void> dispose() async {
    try {
      await stopAllAlarms();
      _isInitialized = false;
      debugPrint('AlarmService disposed');
    } catch (e) {
      debugPrint('Error disposing AlarmService: $e');
    }
  }
}

class AlarmServiceException implements Exception {
  final String message;

  const AlarmServiceException(this.message);

  @override
  String toString() => 'AlarmServiceException: $message';
}

// AlarmSoundInfo is imported from alarm_sound_picker.dart

enum AlarmSoundType { gentle, urgent, chime }

extension AlarmSoundTypeExtension on AlarmSoundType {
  String get key {
    switch (this) {
      case AlarmSoundType.gentle:
        return 'gentle';
      case AlarmSoundType.urgent:
        return 'urgent';
      case AlarmSoundType.chime:
        return 'chime';
    }
  }

  String get displayName {
    switch (this) {
      case AlarmSoundType.gentle:
        return 'Gentle Chime';
      case AlarmSoundType.urgent:
        return 'Urgent Alert';
      case AlarmSoundType.chime:
        return 'Peaceful Chime';
    }
  }

  String get assetPath {
    switch (this) {
      case AlarmSoundType.gentle:
        return 'assets/sounds/gentle_alarm.mp3';
      case AlarmSoundType.urgent:
        return 'assets/sounds/urgent_alarm.mp3';
      case AlarmSoundType.chime:
        return 'assets/sounds/chime_alarm.mp3';
    }
  }
}
