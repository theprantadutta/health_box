# Alarm Package Reference

## Overview
Cross-platform alarm management for iOS and Android with native audio playback and vibration support.

## Key Features
- Cross-platform alarm management for iOS and Android
- Native audio playbook and vibration support
- Customizable alarm settings including volume, notifications, and ringtones
- Handles alarms across different device states (locked screen, silent mode, etc.)

## Platform Implementation
- Android: Uses "foreground service with AlarmManager" for reliable scheduling
- iOS: Keeps app awake using silent audio player and background app refresh

## Configuration Requirements

### 1. Initialize in main function:
```dart
WidgetsFlutterBinding.ensureInitialized();
await Alarm.init()
```

### 2. Create alarm settings:
```dart
final alarmSettings = AlarmSettings(
  id: 42,
  dateTime: dateTime,
  assetAudioPath: 'assets/alarm.mp3',
  loopAudio: true,
  vibrate: true
);
```

### 3. Set the alarm:
```dart
await Alarm.set(alarmSettings: alarmSettings)
```

## Key API Methods
- `Alarm.set()`: Schedule an alarm
- `Alarm.stop()`: Stop a specific alarm
- `Alarm.ringing.listen()`: Handle alarm trigger events

## Unique Capabilities
- Volume fade settings
- Customizable notification appearance
- Handles alarms when app is killed (especially on Android)

## Limitations
- No native periodic alarm support across platforms
- Potential reliability issues on some Android devices due to battery optimization
- Requires careful handling to prevent concurrent method calls

## Permissions
- Requires specific iOS and Android setup configurations
- May need user education about battery optimization settings

## Advanced Features
- Volume control with fade-in/fade-out
- Custom notification text and body
- Vibration patterns
- Audio asset management
- Background execution handling

## Platform-Specific Considerations

### Android
- Requires foreground service permissions
- May need battery optimization whitelist
- Uses system alarm manager for reliability

### iOS
- Requires background app refresh
- Uses silent audio to keep app active
- Limited by iOS background execution policies