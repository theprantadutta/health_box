import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings state model
class AppSettings {
  final bool notificationsEnabled;
  final bool autoBackupEnabled;
  final bool debugModeEnabled;

  const AppSettings({
    this.notificationsEnabled = true,
    this.autoBackupEnabled = false,
    this.debugModeEnabled = false,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? autoBackupEnabled,
    bool? debugModeEnabled,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      debugModeEnabled: debugModeEnabled ?? this.debugModeEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'autoBackupEnabled': autoBackupEnabled,
      'debugModeEnabled': debugModeEnabled,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      autoBackupEnabled: map['autoBackupEnabled'] as bool? ?? false,
      debugModeEnabled: map['debugModeEnabled'] as bool? ?? false,
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
      settingsMap['notificationsEnabled'] = prefs.getBool('notifications_enabled') ?? true;
      settingsMap['autoBackupEnabled'] = prefs.getBool('auto_backup_enabled') ?? false;
      settingsMap['debugModeEnabled'] = prefs.getBool('debug_mode_enabled') ?? false;

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
}

// Settings provider
final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
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