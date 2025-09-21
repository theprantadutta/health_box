# Flutter Local Notifications Package Reference

## Overview
Cross-platform local notification support for Android, iOS, macOS, Linux, and Windows.

## Key Features
- Cross-platform local notification support for Android, iOS, macOS, Linux, and Windows
- Ability to display and schedule notifications
- Supports notification actions
- Platform-specific customization options

## Platform Support
- Android: Uses NotificationCompat APIs
- iOS: Uses UserNotification Framework
- macOS: Uses UserNotification Framework
- Linux: Uses Desktop Notifications Specification
- Windows: Uses C++/WinRT Toast Notifications

## Core Capabilities

### 1. Notification Scheduling
- Schedule notifications at specific times
- Periodic notifications
- Daily/weekly scheduled notifications
- Supports time zone-based scheduling

### 2. Notification Customization
- Custom notification sounds
- Grouping notifications
- Platform-specific styling
- Notification actions
- Importance and priority settings

## Configuration Requirements
- Requires Flutter SDK 3.22+
- Platform-specific setup (AndroidManifest.xml, AppDelegate)
- Time zone initialization
- Explicit permission requests on iOS/Android

## Notable Limitations
- iOS limits pending notifications to 64
- Android background notification challenges on some devices
- Platform-specific restrictions on notification features
- Windows does not support repeating notifications

## Setup Example
```dart
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('app_icon'),
    iOS: DarwinInitializationSettings(),
    // Other platform settings
);

await flutterLocalNotificationsPlugin.initialize(initializationSettings);
```

## Scheduling Example
```dart
await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Scheduled Title',
    'Scheduled Body',
    tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),
    NotificationDetails(android: AndroidNotificationDetails(...)),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
);
```

## Permissions Required

### Android
- `android.permission.POST_NOTIFICATIONS` (Android 13+)
- `android.permission.SCHEDULE_EXACT_ALARM` (Android 12+)
- `android.permission.USE_EXACT_ALARM` (Android 12+)

### iOS
- User notification permissions requested at runtime
- Background app refresh for scheduled notifications