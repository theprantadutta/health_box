import 'dart:async';
import 'package:flutter/foundation.dart';

// Temporary stub implementation of AlarmService without alarm package
// This prevents foreground service crashes while we implement notifications-only approach

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  bool _isInitialized = false;
  StreamController<AlarmSettings>? _alarmStreamController;

  static const Map<String, String> _alarmSounds = {
    'gentle': 'assets/sounds/gentle_alarm.mp3',
    'urgent': 'assets/sounds/urgent_alarm.mp3',
    'chime': 'assets/sounds/chime_alarm.mp3',
  };

  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      debugPrint('AlarmService: Initializing stub alarm service (notifications only)...');

      _isInitialized = true;
      _alarmStreamController = StreamController<AlarmSettings>.broadcast();

      debugPrint('AlarmService stub initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize AlarmService: $e');
      _isInitialized = false;
      return false;
    }
  }

  Stream<AlarmSettings> get alarmStream {
    if (_alarmStreamController == null) {
      throw const AlarmServiceException('AlarmService not initialized');
    }
    return _alarmStreamController!.stream;
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
    debugPrint('AlarmService stub: Alarm functionality disabled, returning false for fallback to notifications');
    return false; // Always return false to fallback to notifications
  }

  Future<bool> stopAlarm(String reminderId) async {
    debugPrint('AlarmService stub: No alarm to stop for reminder: $reminderId');
    return false;
  }

  Future<bool> isAlarmRinging(String reminderId) async {
    return false; // No alarms can be ringing in stub mode
  }

  Future<bool> hasAlarm(String reminderId) async {
    return false; // No alarms exist in stub mode
  }

  Future<List<AlarmSettings>> getActiveAlarms() async {
    return []; // No active alarms in stub mode
  }

  Future<AlarmSettings?> getAlarm(String reminderId) async {
    return null; // No alarms exist in stub mode
  }

  Future<void> stopAllAlarms() async {
    debugPrint('AlarmService stub: No alarms to stop');
  }

  Future<bool> snoozeAlarm({
    required String reminderId,
    required String title,
    required String body,
    int snoozeMinutes = 15,
    String alarmSound = 'gentle',
  }) async {
    debugPrint('AlarmService stub: Alarm snooze not available, returning false');
    return false;
  }

  List<String> getAvailableAlarmSounds() {
    return _alarmSounds.keys.toList();
  }

  String getAlarmSoundDisplayName(String soundKey) {
    switch (soundKey) {
      case 'gentle':
        return 'Gentle Chime';
      case 'urgent':
        return 'Urgent Alert';
      case 'chime':
        return 'Peaceful Chime';
      default:
        return 'Unknown Sound';
    }
  }

  Future<void> dispose() async {
    try {
      await _alarmStreamController?.close();
      _alarmStreamController = null;
      _isInitialized = false;
      debugPrint('AlarmService stub disposed');
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

// Stub AlarmSettings class to replace the one from alarm package
class AlarmSettings {
  final int id;
  final DateTime dateTime;
  final String assetAudioPath;
  final bool loopAudio;
  final bool vibrate;
  final double volume;
  final double fadeDuration;
  final String notificationTitle;
  final String notificationBody;
  final bool enableNotificationOnKill;

  const AlarmSettings({
    required this.id,
    required this.dateTime,
    required this.assetAudioPath,
    required this.loopAudio,
    required this.vibrate,
    required this.volume,
    required this.fadeDuration,
    required this.notificationTitle,
    required this.notificationBody,
    required this.enableNotificationOnKill,
  });
}

enum AlarmSoundType {
  gentle,
  urgent,
  chime,
}

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