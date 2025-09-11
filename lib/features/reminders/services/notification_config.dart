import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

/// Configuration class for flutter_local_notifications
class NotificationConfig {
  static const String _channelId = 'health_box_reminders';
  static const String _channelName = 'HealthBox Medication Reminders';
  static const String _channelDescription = 'Notifications for medication and appointment reminders';

  static FlutterLocalNotificationsPlugin? _notificationsPlugin;
  static final StreamController<NotificationResponse> _notificationStream = 
      StreamController<NotificationResponse>.broadcast();

  /// Stream for handling notification responses
  static Stream<NotificationResponse> get notificationStream => _notificationStream.stream;

  /// Get the singleton instance of FlutterLocalNotificationsPlugin
  static FlutterLocalNotificationsPlugin get instance {
    _notificationsPlugin ??= FlutterLocalNotificationsPlugin();
    return _notificationsPlugin!;
  }

  /// Initialize notification settings and permissions
  static Future<bool> initialize() async {
    tz.initializeTimeZones();
    
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request these separately
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    final bool? result = await instance.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
    );

    // Request permissions for Android 13+ and iOS
    await _requestPermissions();

    return result ?? false;
  }

  /// Request notification permissions
  static Future<bool> _requestPermissions() async {
    bool granted = false;

    if (Platform.isIOS || Platform.isMacOS) {
      granted = await instance
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          instance.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permission for Android 13+
      final bool? notificationPermission = 
          await androidImplementation?.requestNotificationsPermission();
      
      // Request exact alarm permission for Android 12+
      final bool? exactAlarmPermission = 
          await androidImplementation?.requestExactAlarmsPermission();
      
      granted = (notificationPermission ?? true) && (exactAlarmPermission ?? true);
    }

    return granted;
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          instance.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS || Platform.isMacOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          instance.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final permissions = await iosImplementation?.checkPermissions();
      return permissions?.isEnabled == true && permissions?.isAlertEnabled == true;
    }
    return false;
  }

  /// Get Android notification details
  static AndroidNotificationDetails get androidNotificationDetails =>
      const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'HealthBox Reminder',
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      );

  /// Get iOS/macOS notification details
  static DarwinNotificationDetails get darwinNotificationDetails =>
      const DarwinNotificationDetails(
        categoryIdentifier: _channelId,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        interruptionLevel: InterruptionLevel.active,
      );

  /// Get platform-specific notification details
  static NotificationDetails get platformChannelSpecifics =>
      NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
        macOS: darwinNotificationDetails,
      );

  /// Handle notification response when user taps on notification
  static void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    _notificationStream.add(response);
  }

  /// Handle notification response when app is in background
  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) async {
    // Handle background notification response
    // Note: This runs in a separate isolate, so it has limited capabilities
    print('Background notification received: ${response.payload}');
  }

  /// Create notification action buttons (for Android)
  static List<AndroidNotificationAction> get medicationActions => [
    const AndroidNotificationAction(
      'take_medication',
      'Take Medication',
      showsUserInterface: true,
    ),
    const AndroidNotificationAction(
      'skip_medication', 
      'Skip',
      showsUserInterface: false,
    ),
    const AndroidNotificationAction(
      'snooze_medication',
      'Snooze 15 min',
      showsUserInterface: false,
    ),
  ];

  /// Create iOS notification categories with actions
  static List<DarwinNotificationCategory> get iosCategories => [
    DarwinNotificationCategory(
      _channelId,
      actions: [
        DarwinNotificationAction.plain(
          'take_medication',
          'Take Medication',
        ),
        DarwinNotificationAction.plain(
          'skip_medication',
          'Skip',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          'snooze_medication',
          'Snooze 15 min',
        ),
      ],
    ),
  ];

  /// Set up notification categories (call after initialization)
  static Future<void> setupCategories() async {
    if (Platform.isIOS || Platform.isMacOS) {
      // Note: In newer versions, categories might be set differently
      // For now, we'll skip this as it's not critical for basic functionality
      // Categories can be configured when needed
    }
  }

  /// Dispose of resources
  static void dispose() {
    _notificationStream.close();
  }
}