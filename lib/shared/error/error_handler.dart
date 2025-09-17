import 'dart:async';
import 'package:flutter/foundation.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.fieldErrors,
  });
}

class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class SyncException extends AppException {
  const SyncException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ImportExportException extends AppException {
  const ImportExportException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ReminderException extends AppException {
  const ReminderException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class OCRException extends AppException {
  const OCRException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

typedef ErrorCallback = void Function(AppException error);
typedef ErrorRecoveryCallback = Future<void> Function(AppException error);

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final List<ErrorCallback> _errorCallbacks = [];
  final Map<Type, ErrorRecoveryCallback> _recoveryCallbacks = {};
  final StreamController<AppException> _errorStreamController =
      StreamController<AppException>.broadcast();

  Stream<AppException> get errorStream => _errorStreamController.stream;

  void addErrorCallback(ErrorCallback callback) {
    _errorCallbacks.add(callback);
  }

  void removeErrorCallback(ErrorCallback callback) {
    _errorCallbacks.remove(callback);
  }

  void setRecoveryCallback<T extends AppException>(
    ErrorRecoveryCallback callback,
  ) {
    _recoveryCallbacks[T] = callback;
  }

  void removeRecoveryCallback<T extends AppException>() {
    _recoveryCallbacks.remove(T);
  }

  Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    bool notify = true,
    bool recover = true,
  }) async {
    final appException = _convertToAppException(error, stackTrace);

    if (kDebugMode) {
      debugPrint('Error handled: ${appException.message}');
      if (appException.stackTrace != null) {
        debugPrint('Stack trace: ${appException.stackTrace}');
      }
    }

    if (notify) {
      _notifyCallbacks(appException);
      _errorStreamController.add(appException);
    }

    if (recover) {
      await _attemptRecovery(appException);
    }
  }

  AppException _convertToAppException(dynamic error, StackTrace? stackTrace) {
    if (error is AppException) {
      return error;
    }

    final errorMessage = error?.toString() ?? 'Unknown error occurred';

    if (error is FormatException || error is ArgumentError) {
      return ValidationException(
        message: errorMessage,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error.toString().toLowerCase().contains('database') ||
        error.toString().toLowerCase().contains('sql')) {
      return DatabaseException(
        message: errorMessage,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('connection') ||
        error.toString().toLowerCase().contains('timeout')) {
      return NetworkException(
        message: errorMessage,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error.toString().toLowerCase().contains('storage') ||
        error.toString().toLowerCase().contains('file')) {
      return StorageException(
        message: errorMessage,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return AppException(
      message: errorMessage,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  void _notifyCallbacks(AppException error) {
    for (final callback in _errorCallbacks) {
      try {
        callback(error);
      } catch (callbackError, callbackStackTrace) {
        if (kDebugMode) {
          debugPrint('Error in error callback: $callbackError');
          debugPrint('Stack trace: $callbackStackTrace');
        }
      }
    }
  }

  Future<void> _attemptRecovery(AppException error) async {
    final recoveryCallback = _recoveryCallbacks[error.runtimeType];
    if (recoveryCallback != null) {
      try {
        await recoveryCallback(error);
      } catch (recoveryError, recoveryStackTrace) {
        if (kDebugMode) {
          debugPrint('Error during recovery: $recoveryError');
          debugPrint('Stack trace: $recoveryStackTrace');
        }
      }
    }
  }

  Future<T> runGuarded<T>(
    Future<T> Function() operation, {
    T? fallback,
    bool notify = true,
    bool recover = true,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      await handleError(
        error,
        stackTrace: stackTrace,
        notify: notify,
        recover: recover,
      );

      if (fallback != null) {
        return fallback;
      }
      rethrow;
    }
  }

  T runSyncGuarded<T>(
    T Function() operation, {
    T? fallback,
    bool notify = true,
    bool recover = false,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      handleError(
        error,
        stackTrace: stackTrace,
        notify: notify,
        recover: recover,
      );

      if (fallback != null) {
        return fallback;
      }
      rethrow;
    }
  }

  void dispose() {
    _errorCallbacks.clear();
    _recoveryCallbacks.clear();
    _errorStreamController.close();
  }
}

extension ErrorHandlerExtension<T> on Future<T> {
  Future<T> handleErrors({bool notify = true, bool recover = true}) {
    return ErrorHandler().runGuarded(
      () => this,
      notify: notify,
      recover: recover,
    );
  }
}

mixin ErrorHandlerMixin {
  ErrorHandler get errorHandler => ErrorHandler();

  Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    bool notify = true,
    bool recover = true,
  }) {
    return errorHandler.handleError(
      error,
      stackTrace: stackTrace,
      notify: notify,
      recover: recover,
    );
  }

  Future<T> runGuarded<T>(
    Future<T> Function() operation, {
    T? fallback,
    bool notify = true,
    bool recover = true,
  }) {
    return errorHandler.runGuarded(
      operation,
      fallback: fallback,
      notify: notify,
      recover: recover,
    );
  }

  T runSyncGuarded<T>(
    T Function() operation, {
    T? fallback,
    bool notify = true,
    bool recover = false,
  }) {
    return errorHandler.runSyncGuarded(
      operation,
      fallback: fallback,
      notify: notify,
      recover: recover,
    );
  }
}
