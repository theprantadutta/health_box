import 'package:flutter_test/flutter_test.dart';

import 'package:health_box/shared/error/error_handler.dart';

void main() {
  late ErrorHandler errorHandler;

  setUp(() {
    errorHandler = ErrorHandler();
  });

  tearDown(() {
    errorHandler.dispose();
  });

  group('ErrorHandler', () {
    group('AppException types', () {
      test('should create DatabaseException correctly', () {
        const exception = DatabaseException(
          message: 'Database connection failed',
          code: 'DB001',
        );

        expect(exception.message, equals('Database connection failed'));
        expect(exception.code, equals('DB001'));
        expect(exception.toString(), contains('AppException: Database connection failed'));
      });

      test('should create NetworkException correctly', () {
        const exception = NetworkException(
          message: 'Network timeout',
          code: 'NET001',
        );

        expect(exception.message, equals('Network timeout'));
        expect(exception.code, equals('NET001'));
      });

      test('should create ValidationException with field errors', () {
        const exception = ValidationException(
          message: 'Validation failed',
          fieldErrors: {
            'email': ['Invalid email format'],
            'password': ['Password too short', 'Password must contain digits']
          },
        );

        expect(exception.message, equals('Validation failed'));
        expect(exception.fieldErrors!['email'], contains('Invalid email format'));
        expect(exception.fieldErrors!['password']!.length, equals(2));
      });
    });

    group('error conversion', () {
      test('should pass through AppException unchanged', () async {
        const originalException = DatabaseException(message: 'Test error');
        
        bool callbackCalled = false;
        errorHandler.addErrorCallback((error) {
          expect(error, same(originalException));
          callbackCalled = true;
        });

        await errorHandler.handleError(originalException);
        expect(callbackCalled, isTrue);
      });

      test('should convert FormatException to ValidationException', () async {
        final formatException = FormatException('Invalid format');
        
        AppException? capturedError;
        errorHandler.addErrorCallback((error) {
          capturedError = error;
        });

        await errorHandler.handleError(formatException);
        
        expect(capturedError, isA<ValidationException>());
        expect(capturedError!.message, contains('Invalid format'));
        expect(capturedError!.originalError, same(formatException));
      });

      test('should convert database-related errors to DatabaseException', () async {
        final dbError = Exception('SQL error: table not found');
        
        AppException? capturedError;
        errorHandler.addErrorCallback((error) {
          capturedError = error;
        });

        await errorHandler.handleError(dbError);
        
        expect(capturedError, isA<DatabaseException>());
        expect(capturedError!.message, contains('SQL error'));
      });

      test('should convert network-related errors to NetworkException', () async {
        final networkError = Exception('Connection timeout occurred');
        
        AppException? capturedError;
        errorHandler.addErrorCallback((error) {
          capturedError = error;
        });

        await errorHandler.handleError(networkError);
        
        expect(capturedError, isA<NetworkException>());
        expect(capturedError!.message, contains('Connection timeout'));
      });

      test('should convert unknown errors to generic AppException', () async {
        final unknownError = Exception('Unknown error type');
        
        AppException? capturedError;
        errorHandler.addErrorCallback((error) {
          capturedError = error;
        });

        await errorHandler.handleError(unknownError);
        
        expect(capturedError, isA<AppException>());
        expect(capturedError!.message, contains('Unknown error type'));
      });
    });

    group('error callbacks', () {
      test('should call all registered callbacks', () async {
        int callback1Called = 0;
        int callback2Called = 0;

        errorHandler.addErrorCallback((_) => callback1Called++);
        errorHandler.addErrorCallback((_) => callback2Called++);

        await errorHandler.handleError(Exception('Test error'));

        expect(callback1Called, equals(1));
        expect(callback2Called, equals(1));
      });

      test('should remove callbacks', () async {
        int callbackCalled = 0;

        void callback(AppException error) => callbackCalled++;
        
        errorHandler.addErrorCallback(callback);
        await errorHandler.handleError(Exception('Test error'));
        expect(callbackCalled, equals(1));

        errorHandler.removeErrorCallback(callback);
        await errorHandler.handleError(Exception('Test error'));
        expect(callbackCalled, equals(1)); // Should not increment
      });

      test('should handle callback exceptions gracefully', () async {
        errorHandler.addErrorCallback((_) => throw Exception('Callback error'));
        
        bool secondCallbackCalled = false;
        errorHandler.addErrorCallback((_) => secondCallbackCalled = true);

        // Should not throw despite first callback failing
        await errorHandler.handleError(Exception('Original error'));
        expect(secondCallbackCalled, isTrue);
      });
    });

    group('recovery callbacks', () {
      test('should call recovery callback for matching error type', () async {
        bool recoveryCalled = false;
        
        errorHandler.setRecoveryCallback<DatabaseException>((error) async {
          recoveryCalled = true;
          expect(error, isA<DatabaseException>());
        });

        await errorHandler.handleError(DatabaseException(message: 'DB error'));
        expect(recoveryCalled, isTrue);
      });

      test('should not call recovery callback for different error type', () async {
        bool recoveryCalled = false;
        
        errorHandler.setRecoveryCallback<DatabaseException>((error) async {
          recoveryCalled = true;
        });

        await errorHandler.handleError(NetworkException(message: 'Network error'));
        expect(recoveryCalled, isFalse);
      });

      test('should remove recovery callbacks', () async {
        bool recoveryCalled = false;
        
        errorHandler.setRecoveryCallback<DatabaseException>((error) async {
          recoveryCalled = true;
        });
        
        errorHandler.removeRecoveryCallback<DatabaseException>();
        
        await errorHandler.handleError(DatabaseException(message: 'DB error'));
        expect(recoveryCalled, isFalse);
      });

      test('should handle recovery callback exceptions', () async {
        errorHandler.setRecoveryCallback<DatabaseException>((error) async {
          throw Exception('Recovery failed');
        });

        // Should not throw despite recovery failing
        await errorHandler.handleError(DatabaseException(message: 'DB error'));
      });
    });

    group('error stream', () {
      test('should emit errors to stream', () async {
        final errors = <AppException>[];
        final subscription = errorHandler.errorStream.listen(errors.add);

        await errorHandler.handleError(Exception('Test error 1'));
        await errorHandler.handleError(Exception('Test error 2'));

        await subscription.cancel();

        expect(errors.length, equals(2));
        expect(errors[0].message, contains('Test error 1'));
        expect(errors[1].message, contains('Test error 2'));
      });

      test('should not emit to stream when notify is false', () async {
        final errors = <AppException>[];
        final subscription = errorHandler.errorStream.listen(errors.add);

        await errorHandler.handleError(Exception('Test error'), notify: false);
        await subscription.cancel();

        expect(errors, isEmpty);
      });
    });

    group('runGuarded', () {
      test('should return result when operation succeeds', () async {
        final result = await errorHandler.runGuarded(() async => 'success');
        expect(result, equals('success'));
      });

      test('should handle errors and return fallback', () async {
        final result = await errorHandler.runGuarded(
          () async => throw Exception('Operation failed'),
          fallback: 'fallback',
        );
        expect(result, equals('fallback'));
      });

      test('should rethrow error when no fallback provided', () async {
        expect(
          () => errorHandler.runGuarded(() async => throw Exception('Operation failed')),
          throwsException,
        );
      });

      test('should handle sync operations', () {
        final result = errorHandler.runSyncGuarded(() => 'sync success');
        expect(result, equals('sync success'));
      });

      test('should handle sync errors with fallback', () {
        final result = errorHandler.runSyncGuarded(
          () => throw Exception('Sync operation failed'),
          fallback: 'sync fallback',
        );
        expect(result, equals('sync fallback'));
      });
    });

    group('ErrorHandlerExtension', () {
      test('should handle errors on Future', () async {
        final result = await Future.value('success').handleErrors();
        expect(result, equals('success'));
      });

      test('should handle errors on failing Future', () async {
        bool errorHandled = false;
        errorHandler.addErrorCallback((_) => errorHandled = true);

        try {
          await Future<String>.error(Exception('Async error')).handleErrors();
        } catch (e) {
          // Expected to rethrow
        }

        expect(errorHandled, isTrue);
      });
    });

    group('ErrorHandlerMixin', () {
      test('should provide access to error handler', () {
        final testClass = _TestErrorHandlerMixin();
        expect(testClass.errorHandler, isA<ErrorHandler>());
      });

      test('should provide convenience methods', () async {
        final testClass = _TestErrorHandlerMixin();
        
        bool errorHandled = false;
        testClass.errorHandler.addErrorCallback((_) => errorHandled = true);

        await testClass.handleError(Exception('Mixin error'));
        expect(errorHandled, isTrue);
      });
    });

    group('disposal', () {
      test('should clean up resources on dispose', () {
        final handler = ErrorHandler();
        handler.addErrorCallback((_) {});
        handler.setRecoveryCallback<AppException>((error) async {});
        
        handler.dispose();
        
        // Should not throw when disposed
        expect(() => handler.dispose(), returnsNormally);
      });
    });
  });
}

class _TestErrorHandlerMixin with ErrorHandlerMixin {
  // Test class to verify mixin functionality
}