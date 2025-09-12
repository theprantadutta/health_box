import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/file_storage_service.dart';

// Core service providers
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  return FileStorageService();
});

// App-wide state management
class AppState {
  final bool isInitialized;
  final bool isDarkMode;
  final Locale locale;
  final String? selectedProfileId;
  final bool isOfflineMode;
  final DateTime? lastSyncTime;
  final String appVersion;
  final bool hasUnseenNotifications;
  final int unseenNotificationCount;
  final Map<String, dynamic> userPreferences;
  final bool isLoading;
  final String? error;

  const AppState({
    this.isInitialized = false,
    this.isDarkMode = false,
    this.locale = const Locale('en', 'US'),
    this.selectedProfileId,
    this.isOfflineMode = true,
    this.lastSyncTime,
    this.appVersion = '1.0.0',
    this.hasUnseenNotifications = false,
    this.unseenNotificationCount = 0,
    this.userPreferences = const {},
    this.isLoading = false,
    this.error,
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isDarkMode,
    Locale? locale,
    String? selectedProfileId,
    bool? isOfflineMode,
    DateTime? lastSyncTime,
    String? appVersion,
    bool? hasUnseenNotifications,
    int? unseenNotificationCount,
    Map<String, dynamic>? userPreferences,
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
      selectedProfileId: selectedProfileId ?? this.selectedProfileId,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      appVersion: appVersion ?? this.appVersion,
      hasUnseenNotifications:
          hasUnseenNotifications ?? this.hasUnseenNotifications,
      unseenNotificationCount:
          unseenNotificationCount ?? this.unseenNotificationCount,
      userPreferences: userPreferences ?? this.userPreferences,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier(this.ref) : super(const AppState()) {
    _initializeApp();
  }

  final Ref ref;

  Future<void> _initializeApp() async {
    state = state.copyWith(isLoading: true);

    try {
      // Initialize database
      ref.read(appDatabaseProvider);

      // Load user preferences
      final storageService = ref.read(storageServiceProvider);
      await storageService.initialize();
      final preferences =
          await storageService.retrieveJsonData('user_preferences') ?? {};

      // Set initial state from preferences
      final isDarkMode = preferences['dark_mode'] as bool? ?? false;
      final localeCode = preferences['locale'] as String? ?? 'en_US';
      final selectedProfileId = preferences['selected_profile_id'] as String?;

      final localeParts = localeCode.split('_');
      final locale = Locale(
        localeParts[0],
        localeParts.length > 1 ? localeParts[1] : null,
      );

      state = state.copyWith(
        isInitialized: true,
        isDarkMode: isDarkMode,
        locale: locale,
        selectedProfileId: selectedProfileId,
        userPreferences: preferences,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize app: ${error.toString()}',
      );
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final updatedPreferences = Map<String, dynamic>.from(
        state.userPreferences,
      );
      updatedPreferences['dark_mode'] = isDark;

      await storageService.storeJsonData(
        'user_preferences',
        updatedPreferences,
      );

      state = state.copyWith(
        isDarkMode: isDark,
        userPreferences: updatedPreferences,
      );
    } catch (error) {
      state = state.copyWith(
        error: 'Failed to update theme: ${error.toString()}',
      );
    }
  }

  Future<void> setSelectedProfile(String? profileId) async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final updatedPreferences = Map<String, dynamic>.from(
        state.userPreferences,
      );
      updatedPreferences['selected_profile_id'] = profileId;

      await storageService.storeJsonData(
        'user_preferences',
        updatedPreferences,
      );

      state = state.copyWith(
        selectedProfileId: profileId,
        userPreferences: updatedPreferences,
      );
    } catch (error) {
      state = state.copyWith(
        error: 'Failed to set selected profile: ${error.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final appNotifierProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier(ref);
});

// Theme provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final appState = ref.watch(appNotifierProvider);
  return appState.isDarkMode ? ThemeMode.dark : ThemeMode.light;
});

final appThemeProvider = Provider<ThemeData>((ref) {
  final appState = ref.watch(appNotifierProvider);

  if (appState.isDarkMode) {
    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  } else {
    return ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }
});
