import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys for storing backup preferences
const String _backupEnabledKey = 'backup_enabled';
const String _backupProviderKey = 'backup_provider'; // 'google_drive' or 'local_only'

// Enum for backup strategies
enum BackupStrategy {
  localOnly,
  googleDrive,
}

// Provider to check if backup is enabled
final backupEnabledProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_backupEnabledKey) ?? false;
});

// Provider to get backup strategy
final backupStrategyProvider = FutureProvider<BackupStrategy>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final strategyString = prefs.getString(_backupProviderKey) ?? 'local_only';

  switch (strategyString) {
    case 'google_drive':
      return BackupStrategy.googleDrive;
    default:
      return BackupStrategy.localOnly;
  }
});

// Provider to manage backup preferences
final backupPreferenceNotifierProvider =
    StateNotifierProvider<BackupPreferenceNotifier, AsyncValue<BackupPreference>>((ref) {
      return BackupPreferenceNotifier();
    });

class BackupPreference {
  final bool enabled;
  final BackupStrategy strategy;

  const BackupPreference({
    required this.enabled,
    required this.strategy,
  });

  BackupPreference copyWith({
    bool? enabled,
    BackupStrategy? strategy,
  }) {
    return BackupPreference(
      enabled: enabled ?? this.enabled,
      strategy: strategy ?? this.strategy,
    );
  }
}

class BackupPreferenceNotifier extends StateNotifier<AsyncValue<BackupPreference>> {
  BackupPreferenceNotifier() : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_backupEnabledKey) ?? false;
      final strategyString = prefs.getString(_backupProviderKey) ?? 'local_only';

      final strategy = strategyString == 'google_drive'
          ? BackupStrategy.googleDrive
          : BackupStrategy.localOnly;

      state = AsyncValue.data(BackupPreference(
        enabled: enabled,
        strategy: strategy,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> setBackupPreference({
    required bool enabled,
    required BackupStrategy strategy,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_backupEnabledKey, enabled);
      await prefs.setString(_backupProviderKey,
          strategy == BackupStrategy.googleDrive ? 'google_drive' : 'local_only');

      state = AsyncValue.data(BackupPreference(
        enabled: enabled,
        strategy: strategy,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> enableBackup(BackupStrategy strategy) async {
    await setBackupPreference(enabled: true, strategy: strategy);
  }

  Future<void> disableBackup() async {
    final currentState = state.value;
    if (currentState != null) {
      await setBackupPreference(
        enabled: false,
        strategy: currentState.strategy,
      );
    }
  }

  Future<void> updateStrategy(BackupStrategy strategy) async {
    final currentState = state.value;
    if (currentState != null) {
      await setBackupPreference(
        enabled: currentState.enabled,
        strategy: strategy,
      );
    }
  }
}