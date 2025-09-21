import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<PermissionStatus> checkNotificationPermissions() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidNotificationPermissions();
      } else if (Platform.isIOS) {
        return await _checkIOSNotificationPermissions();
      } else {
        return const PermissionStatus(
          notificationsEnabled: true,
          exactAlarmsEnabled: true,
          canScheduleExactAlarms: true,
          batteryOptimizationDisabled: true,
        );
      }
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return const PermissionStatus(
        notificationsEnabled: false,
        exactAlarmsEnabled: false,
        canScheduleExactAlarms: false,
        batteryOptimizationDisabled: false,
      );
    }
  }

  Future<bool> requestNotificationPermissions() async {
    try {
      if (Platform.isAndroid) {
        return await _requestAndroidNotificationPermissions();
      } else if (Platform.isIOS) {
        return await _requestIOSNotificationPermissions();
      } else {
        return true;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  Future<PermissionStatus> _checkAndroidNotificationPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) {
      return const PermissionStatus(
        notificationsEnabled: false,
        exactAlarmsEnabled: false,
        canScheduleExactAlarms: false,
        batteryOptimizationDisabled: false,
      );
    }

    final notificationsEnabled = await androidImplementation.areNotificationsEnabled() ?? false;
    final exactAlarmsEnabled = await androidImplementation.canScheduleExactNotifications() ?? false;

    return PermissionStatus(
      notificationsEnabled: notificationsEnabled,
      exactAlarmsEnabled: exactAlarmsEnabled,
      canScheduleExactAlarms: exactAlarmsEnabled,
      batteryOptimizationDisabled: await _checkBatteryOptimization(),
    );
  }

  Future<PermissionStatus> _checkIOSNotificationPermissions() async {
    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation == null) {
      return const PermissionStatus(
        notificationsEnabled: false,
        exactAlarmsEnabled: false,
        canScheduleExactAlarms: false,
        batteryOptimizationDisabled: true,
      );
    }

    final permissions = await iosImplementation.checkPermissions();

    return PermissionStatus(
      notificationsEnabled: permissions?.isEnabled ?? false,
      exactAlarmsEnabled: permissions?.isAlertEnabled ?? false,
      canScheduleExactAlarms: permissions?.isAlertEnabled ?? false,
      batteryOptimizationDisabled: true,
      soundEnabled: permissions?.isSoundEnabled ?? false,
      badgeEnabled: permissions?.isBadgeEnabled ?? false,
    );
  }

  Future<bool> _requestAndroidNotificationPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return false;

    bool allPermissionsGranted = true;

    try {
      final notificationPermission = await androidImplementation.requestNotificationsPermission();
      if (notificationPermission != true) {
        debugPrint('Notification permission not granted');
        allPermissionsGranted = false;
      }

      final exactAlarmPermission = await androidImplementation.requestExactAlarmsPermission();
      if (exactAlarmPermission != true) {
        debugPrint('Exact alarm permission not granted');
        allPermissionsGranted = false;
      }

      await _requestBatteryOptimizationExemption();

    } catch (e) {
      debugPrint('Error requesting Android permissions: $e');
      allPermissionsGranted = false;
    }

    return allPermissionsGranted;
  }

  Future<bool> _requestIOSNotificationPermissions() async {
    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation == null) return false;

    try {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: false,
      );

      debugPrint('iOS notification permissions granted: $granted');
      return granted ?? false;
    } catch (e) {
      debugPrint('Error requesting iOS permissions: $e');
      return false;
    }
  }

  Future<bool> _checkBatteryOptimization() async {
    try {
      if (!Platform.isAndroid) return true;

      return await _isIgnoringBatteryOptimizations();
    } catch (e) {
      debugPrint('Error checking battery optimization: $e');
      return false;
    }
  }

  Future<bool> _isIgnoringBatteryOptimizations() async {
    try {
      const platform = MethodChannel('health_box/battery_optimization');
      final isIgnoring = await platform.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return isIgnoring ?? false;
    } catch (e) {
      debugPrint('Error checking battery optimization ignore status: $e');
      return false;
    }
  }

  Future<void> _requestBatteryOptimizationExemption() async {
    try {
      if (!Platform.isAndroid) return;

      const platform = MethodChannel('health_box/battery_optimization');
      await platform.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      debugPrint('Error requesting battery optimization exemption: $e');
    }
  }

  Future<void> openAppSettings() async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('health_box/app_settings');
        await platform.invokeMethod('openNotificationSettings');
      } else if (Platform.isIOS) {
        const platform = MethodChannel('health_box/app_settings');
        await platform.invokeMethod('openAppSettings');
      }
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  Future<bool> shouldShowPermissionRationale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAskedBefore = prefs.getBool('notification_permission_asked') ?? false;

      if (!hasAskedBefore) {
        await prefs.setBool('notification_permission_asked', true);
        return true;
      }

      final status = await checkNotificationPermissions();
      return !status.notificationsEnabled;
    } catch (e) {
      debugPrint('Error checking permission rationale: $e');
      return true;
    }
  }

  Future<PermissionGuideStep> getNextPermissionStep() async {
    final status = await checkNotificationPermissions();

    if (!status.notificationsEnabled) {
      return PermissionGuideStep(
        title: 'Enable Notifications',
        description: 'Allow HealthBox to send you medication reminders and health alerts.',
        actionText: 'Grant Permission',
        isRequired: true,
        action: () => requestNotificationPermissions(),
      );
    }

    if (Platform.isAndroid && !status.exactAlarmsEnabled) {
      return PermissionGuideStep(
        title: 'Enable Exact Alarms',
        description: 'Allow HealthBox to set precise alarm times for critical medication reminders.',
        actionText: 'Enable Alarms',
        isRequired: false,
        action: () async {
          final androidImplementation = _notificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          return await androidImplementation?.requestExactAlarmsPermission() ?? false;
        },
      );
    }

    if (Platform.isAndroid && !status.batteryOptimizationDisabled) {
      return PermissionGuideStep(
        title: 'Disable Battery Optimization',
        description: 'Prevent Android from stopping HealthBox in the background to ensure reliable reminders.',
        actionText: 'Optimize Settings',
        isRequired: false,
        action: () async {
          await _requestBatteryOptimizationExemption();
          return true;
        },
      );
    }

    return PermissionGuideStep(
      title: 'All Set!',
      description: 'Your notification permissions are properly configured.',
      actionText: 'Continue',
      isRequired: false,
      action: () async => true,
    );
  }

  Future<List<PermissionGuideStep>> getAllPermissionSteps() async {
    final steps = <PermissionGuideStep>[];

    steps.add(PermissionGuideStep(
      title: 'Enable Notifications',
      description: 'Allow HealthBox to send you medication reminders and health alerts.',
      actionText: 'Grant Permission',
      isRequired: true,
      action: () => requestNotificationPermissions(),
    ));

    if (Platform.isAndroid) {
      steps.add(PermissionGuideStep(
        title: 'Enable Exact Alarms',
        description: 'Allow HealthBox to set precise alarm times for critical medication reminders.',
        actionText: 'Enable Alarms',
        isRequired: false,
        action: () async {
          final androidImplementation = _notificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          return await androidImplementation?.requestExactAlarmsPermission() ?? false;
        },
      ));

      steps.add(PermissionGuideStep(
        title: 'Disable Battery Optimization',
        description: 'Prevent Android from stopping HealthBox in the background to ensure reliable reminders.',
        actionText: 'Optimize Settings',
        isRequired: false,
        action: () async {
          await _requestBatteryOptimizationExemption();
          return true;
        },
      ));
    }

    return steps;
  }
}

class PermissionStatus {
  final bool notificationsEnabled;
  final bool exactAlarmsEnabled;
  final bool canScheduleExactAlarms;
  final bool batteryOptimizationDisabled;
  final bool? soundEnabled;
  final bool? badgeEnabled;

  const PermissionStatus({
    required this.notificationsEnabled,
    required this.exactAlarmsEnabled,
    required this.canScheduleExactAlarms,
    required this.batteryOptimizationDisabled,
    this.soundEnabled,
    this.badgeEnabled,
  });

  bool get isFullyConfigured {
    if (Platform.isAndroid) {
      return notificationsEnabled && exactAlarmsEnabled && batteryOptimizationDisabled;
    } else if (Platform.isIOS) {
      return notificationsEnabled && (soundEnabled ?? true);
    } else {
      return notificationsEnabled;
    }
  }

  bool get hasBasicPermissions => notificationsEnabled;

  PermissionLevel get level {
    if (isFullyConfigured) return PermissionLevel.optimal;
    if (hasBasicPermissions) return PermissionLevel.basic;
    return PermissionLevel.none;
  }

  String get statusDescription {
    switch (level) {
      case PermissionLevel.optimal:
        return 'All permissions configured for reliable reminders';
      case PermissionLevel.basic:
        return 'Basic notifications enabled, some features may be limited';
      case PermissionLevel.none:
        return 'Notifications disabled, reminders will not work';
    }
  }
}

enum PermissionLevel {
  none,
  basic,
  optimal,
}

class PermissionGuideStep {
  final String title;
  final String description;
  final String actionText;
  final bool isRequired;
  final Future<bool> Function() action;

  const PermissionGuideStep({
    required this.title,
    required this.description,
    required this.actionText,
    required this.isRequired,
    required this.action,
  });
}