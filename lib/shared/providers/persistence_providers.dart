import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' show Locale;
import '../../data/services/storage_service.dart';
import 'app_providers.dart';

// State persistence manager
class StatePersistenceManager {
  final StorageService _storageService;

  StatePersistenceManager(this._storageService);

  // Persist app state
  Future<void> persistAppState(AppState appState) async {
    try {
      final stateMap = {
        'isDarkMode': appState.isDarkMode,
        'locale':
            '${appState.locale.languageCode}_${appState.locale.countryCode}',
        'selectedProfileId': appState.selectedProfileId,
        'isOfflineMode': appState.isOfflineMode,
        'lastSyncTime': appState.lastSyncTime?.toIso8601String(),
        'userPreferences': appState.userPreferences,
        'unseenNotificationCount': appState.unseenNotificationCount,
      };

      await _storageService.storeJsonData('app_state', stateMap);
    } catch (error) {
      debugPrint('Failed to persist app state: $error');
    }
  }

  // Restore app state
  Future<AppState?> restoreAppState() async {
    try {
      final stateMap = await _storageService.retrieveJsonData('app_state');

      if (stateMap == null) return null;

      final localeString = stateMap['locale'] as String? ?? 'en_US';
      final localeParts = localeString.split('_');
      final locale = Locale(
        localeParts[0],
        localeParts.length > 1 ? localeParts[1] : null,
      );

      final lastSyncString = stateMap['lastSyncTime'] as String?;
      final lastSyncTime = lastSyncString != null
          ? DateTime.tryParse(lastSyncString)
          : null;

      return AppState(
        isInitialized: true,
        isDarkMode: stateMap['isDarkMode'] as bool? ?? false,
        locale: locale,
        selectedProfileId: stateMap['selectedProfileId'] as String?,
        isOfflineMode: stateMap['isOfflineMode'] as bool? ?? true,
        lastSyncTime: lastSyncTime,
        userPreferences:
            (stateMap['userPreferences'] as Map<String, dynamic>?) ?? {},
        unseenNotificationCount:
            stateMap['unseenNotificationCount'] as int? ?? 0,
        hasUnseenNotifications:
            (stateMap['unseenNotificationCount'] as int? ?? 0) > 0,
      );
    } catch (error) {
      debugPrint('Failed to restore app state: $error');
      return null;
    }
  }

  // Clear all persisted state
  Future<void> clearPersistedState() async {
    try {
      await _storageService.deleteFile('app_state');
      await _storageService.deleteFile('user_preferences');
    } catch (error) {
      debugPrint('Failed to clear persisted state: $error');
    }
  }
}

final statePersistenceManagerProvider = Provider<StatePersistenceManager>((
  ref,
) {
  final storageService = ref.read(storageServiceProvider);
  return StatePersistenceManager(storageService);
});

// Error handler and logger
class AppErrorHandler {
  final StorageService _storageService;
  final List<AppError> _errorBuffer = [];

  static const int _maxErrorBufferSize = 100;
  static const String _errorLogKey = 'error_log';

  AppErrorHandler(this._storageService);

  // Handle and log errors
  Future<void> handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    final appError = AppError(
      message: error.toString(),
      timestamp: DateTime.now(),
      stackTrace: stackTrace?.toString(),
      context: {
        if (context != null) 'context': context,
        if (additionalData != null) ...additionalData,
      },
    );

    // Add to buffer
    _errorBuffer.add(appError);

    // Keep buffer size manageable
    if (_errorBuffer.length > _maxErrorBufferSize) {
      _errorBuffer.removeAt(0);
    }

    // Log error
    await _logError(appError);

    // Print to console in debug mode
    if (kDebugMode) {
      debugPrint('AppError: ${appError.message}');
      if (appError.stackTrace != null) {
        debugPrint('StackTrace: ${appError.stackTrace}');
      }
    }
  }

  // Log error to persistent storage
  Future<void> _logError(AppError error) async {
    try {
      final errorData = await _storageService.retrieveJsonData(_errorLogKey);
      final existingLogs = errorData?['logs'] as List<dynamic>? ?? [];
      final errorMap = {
        'message': error.message,
        'code': error.code,
        'timestamp': error.timestamp.toIso8601String(),
        'stackTrace': error.stackTrace,
        'context': error.context,
      };

      existingLogs.add(errorMap);

      // Keep only last 50 errors in persistent storage
      if (existingLogs.length > 50) {
        existingLogs.removeAt(0);
      }

      await _storageService.storeJsonData(_errorLogKey, {'logs': existingLogs});
    } catch (e) {
      debugPrint('Failed to log error: $e');
    }
  }

  // Get recent errors
  Future<List<AppError>> getRecentErrors({int limit = 10}) async {
    try {
      final errorData = await _storageService.retrieveJsonData(_errorLogKey);
      final errorLogs = errorData?['logs'] as List<dynamic>? ?? [];

      return errorLogs
          .cast<Map<String, dynamic>>()
          .take(limit)
          .map(
            (errorMap) => AppError(
              message: errorMap['message'] as String? ?? 'Unknown error',
              code: errorMap['code'] as String?,
              timestamp:
                  DateTime.tryParse(errorMap['timestamp'] as String? ?? '') ??
                  DateTime.now(),
              stackTrace: errorMap['stackTrace'] as String?,
              context: errorMap['context'] as Map<String, dynamic>?,
            ),
          )
          .toList();
    } catch (error) {
      debugPrint('Failed to get recent errors: $error');
      return [];
    }
  }

  // Clear error logs
  Future<void> clearErrorLogs() async {
    try {
      await _storageService.deleteFile(_errorLogKey);
      _errorBuffer.clear();
    } catch (error) {
      debugPrint('Failed to clear error logs: $error');
    }
  }
}

final appErrorHandlerProvider = Provider<AppErrorHandler>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return AppErrorHandler(storageService);
});

// Error classes
class AppError {
  final String message;
  final String? code;
  final DateTime timestamp;
  final String? stackTrace;
  final Map<String, dynamic>? context;

  const AppError({
    required this.message,
    this.code,
    required this.timestamp,
    this.stackTrace,
    this.context,
  });
}

// Global error boundary state
class ErrorBoundaryState {
  final bool hasError;
  final AppError? error;
  final int errorCount;
  final DateTime? lastErrorTime;

  const ErrorBoundaryState({
    this.hasError = false,
    this.error,
    this.errorCount = 0,
    this.lastErrorTime,
  });

  ErrorBoundaryState copyWith({
    bool? hasError,
    AppError? error,
    int? errorCount,
    DateTime? lastErrorTime,
  }) {
    return ErrorBoundaryState(
      hasError: hasError ?? this.hasError,
      error: error ?? this.error,
      errorCount: errorCount ?? this.errorCount,
      lastErrorTime: lastErrorTime ?? this.lastErrorTime,
    );
  }
}

class ErrorBoundaryNotifier extends StateNotifier<ErrorBoundaryState> {
  ErrorBoundaryNotifier(this.ref) : super(const ErrorBoundaryState());

  final Ref ref;

  Future<void> captureError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    final errorHandler = ref.read(appErrorHandlerProvider);
    await errorHandler.handleError(
      error,
      stackTrace,
      context: context,
      additionalData: additionalData,
    );

    final appError = AppError(
      message: error.toString(),
      timestamp: DateTime.now(),
      stackTrace: stackTrace?.toString(),
      context: {
        if (context != null) 'context': context,
        if (additionalData != null) ...additionalData,
      },
    );

    state = state.copyWith(
      hasError: true,
      error: appError,
      errorCount: state.errorCount + 1,
      lastErrorTime: DateTime.now(),
    );
  }

  void clearError() {
    state = state.copyWith(hasError: false, error: null);
  }

  void resetErrorCount() {
    state = state.copyWith(errorCount: 0);
  }
}

final errorBoundaryNotifierProvider =
    StateNotifierProvider<ErrorBoundaryNotifier, ErrorBoundaryState>((ref) {
      return ErrorBoundaryNotifier(ref);
    });

// Recovery manager for corrupted state
class StateRecoveryManager {
  final StatePersistenceManager _persistenceManager;
  final AppErrorHandler _errorHandler;

  StateRecoveryManager(this._persistenceManager, this._errorHandler);

  // Attempt to recover app state
  Future<AppState> recoverAppState() async {
    try {
      // Try to restore from persistent storage
      final restoredState = await _persistenceManager.restoreAppState();

      if (restoredState != null) {
        return restoredState;
      }

      // Fallback to default state
      return _createDefaultAppState();
    } catch (error, stackTrace) {
      await _errorHandler.handleError(
        error,
        stackTrace,
        context: 'App state recovery',
      );
      return _createDefaultAppState();
    }
  }

  // Create safe default app state
  AppState _createDefaultAppState() {
    return const AppState(
      isInitialized: true,
      isDarkMode: false,
      locale: Locale('en', 'US'),
      isOfflineMode: true,
      userPreferences: {},
    );
  }

  // Emergency state reset
  Future<void> emergencyReset() async {
    try {
      await _persistenceManager.clearPersistedState();
      await _errorHandler.clearErrorLogs();
    } catch (error, stackTrace) {
      await _errorHandler.handleError(
        error,
        stackTrace,
        context: 'Emergency reset',
      );
    }
  }
}

final stateRecoveryManagerProvider = Provider<StateRecoveryManager>((ref) {
  final persistenceManager = ref.read(statePersistenceManagerProvider);
  final errorHandler = ref.read(appErrorHandlerProvider);
  return StateRecoveryManager(persistenceManager, errorHandler);
});
