import 'package:flutter_test/flutter_test.dart';

import 'package:health_box/shared/services/logging_service.dart';
import 'package:health_box/shared/error/error_handler.dart';

class TestLogWriter implements LogWriter {
  final List<LogEntry> entries = [];
  bool disposed = false;
  
  @override
  Future<void> write(LogEntry entry) async {
    if (!disposed) {
      entries.add(entry);
    }
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  late LoggingService loggingService;
  late TestLogWriter testLogWriter;

  setUp(() {
    // Create fresh instance for each test
    loggingService = LoggingService();
    testLogWriter = TestLogWriter();
    loggingService.addWriter(testLogWriter);
  });

  tearDown(() {
    loggingService.dispose();
  });

  group('LoggingService', () {
    group('LogEntry', () {
      test('should create log entry with required fields', () {
        final entry = LogEntry(
          timestamp: DateTime(2025, 1, 1),
          level: LogLevel.info,
          message: 'Test message',
        );

        expect(entry.timestamp, equals(DateTime(2025, 1, 1)));
        expect(entry.level, equals(LogLevel.info));
        expect(entry.message, equals('Test message'));
        expect(entry.tag, isNull);
        expect(entry.context, isNull);
        expect(entry.error, isNull);
        expect(entry.stackTrace, isNull);
      });

      test('should serialize to JSON correctly', () {
        final entry = LogEntry(
          timestamp: DateTime(2025, 1, 1),
          level: LogLevel.error,
          message: 'Test error',
          tag: 'TestTag',
          context: {'key': 'value'},
          error: 'Test exception',
        );

        final json = entry.toJson();

        expect(json['timestamp'], equals('2025-01-01T00:00:00.000'));
        expect(json['level'], equals('ERROR'));
        expect(json['message'], equals('Test error'));
        expect(json['tag'], equals('TestTag'));
        expect(json['context'], equals({'key': 'value'}));
        expect(json['error'], equals('Test exception'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'timestamp': '2025-01-01T00:00:00.000Z',
          'level': 'ERROR',
          'message': 'Test error',
          'tag': 'TestTag',
          'context': {'key': 'value'},
          'error': 'Test exception',
        };

        final entry = LogEntry.fromJson(json);

        expect(entry.timestamp, equals(DateTime.parse('2025-01-01T00:00:00.000Z')));
        expect(entry.level, equals(LogLevel.error));
        expect(entry.message, equals('Test error'));
        expect(entry.tag, equals('TestTag'));
        expect(entry.context, equals({'key': 'value'}));
        expect(entry.error, equals('Test exception'));
      });
    });

    group('LogLevel', () {
      test('should have correct priorities', () {
        expect(LogLevel.trace.priority, lessThan(LogLevel.debug.priority));
        expect(LogLevel.debug.priority, lessThan(LogLevel.info.priority));
        expect(LogLevel.info.priority, lessThan(LogLevel.warning.priority));
        expect(LogLevel.warning.priority, lessThan(LogLevel.error.priority));
        expect(LogLevel.error.priority, lessThan(LogLevel.fatal.priority));
      });

      test('should have correct labels', () {
        expect(LogLevel.trace.label, equals('TRACE'));
        expect(LogLevel.debug.label, equals('DEBUG'));
        expect(LogLevel.info.label, equals('INFO'));
        expect(LogLevel.warning.label, equals('WARN'));
        expect(LogLevel.error.label, equals('ERROR'));
        expect(LogLevel.fatal.label, equals('FATAL'));
      });
    });

    group('logging methods', () {
      test('should log trace messages', () async {
        loggingService.minLevel = LogLevel.trace;
        
        loggingService.trace('Test trace message', tag: 'TestTag');
        
        // Allow async operations to complete
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(1));
        expect(testLogWriter.entries.first.level, equals(LogLevel.trace));
        expect(testLogWriter.entries.first.message, equals('Test trace message'));
        expect(testLogWriter.entries.first.tag, equals('TestTag'));
      });

      test('should log debug messages', () async {
        loggingService.minLevel = LogLevel.debug;
        
        loggingService.debug('Test debug message');
        
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(1));
        expect(testLogWriter.entries.first.level, equals(LogLevel.debug));
        expect(testLogWriter.entries.first.message, equals('Test debug message'));
      });

      test('should log info messages', () async {
        loggingService.info('Test info message');
        
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(1));
        expect(testLogWriter.entries.first.level, equals(LogLevel.info));
        expect(testLogWriter.entries.first.message, equals('Test info message'));
      });

      test('should log warning messages', () async {
        loggingService.warning('Test warning message', error: 'Test error');
        
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(1));
        expect(testLogWriter.entries.first.level, equals(LogLevel.warning));
        expect(testLogWriter.entries.first.message, equals('Test warning message'));
        expect(testLogWriter.entries.first.error, equals('Test error'));
      });

      test('should log error messages', () async {
        final stackTrace = StackTrace.current;
        
        loggingService.error(
          'Test error message', 
          error: 'Test exception',
          stackTrace: stackTrace,
        );
        
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(1));
        expect(testLogWriter.entries.first.level, equals(LogLevel.error));
        expect(testLogWriter.entries.first.message, equals('Test error message'));
        expect(testLogWriter.entries.first.error, equals('Test exception'));
        expect(testLogWriter.entries.first.stackTrace, equals(stackTrace));
      });

      test('should log fatal messages', () async {
        loggingService.fatal('Test fatal message');
        
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(1));
        expect(testLogWriter.entries.first.level, equals(LogLevel.fatal));
        expect(testLogWriter.entries.first.message, equals('Test fatal message'));
      });
    });

    group('log level filtering', () {
      test('should respect minimum log level', () async {
        loggingService.minLevel = LogLevel.warning;
        
        loggingService.trace('Trace message');
        loggingService.debug('Debug message');
        loggingService.info('Info message');
        loggingService.warning('Warning message');
        loggingService.error('Error message');
        
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(2));
        expect(testLogWriter.entries[0].level, equals(LogLevel.warning));
        expect(testLogWriter.entries[1].level, equals(LogLevel.error));
      });

      test('should allow changing log level', () {
        expect(loggingService.minLevel, isA<LogLevel>());
        
        loggingService.minLevel = LogLevel.error;
        expect(loggingService.minLevel, equals(LogLevel.error));
      });
    });

    group('log buffer', () {
      test('should maintain recent logs in buffer', () async {
        for (int i = 0; i < 5; i++) {
          loggingService.info('Message $i');
        }
        
        await Future.delayed(Duration.zero);
        
        final recentLogs = loggingService.recentLogs;
        expect(recentLogs.length, equals(5));
        expect(recentLogs.last.message, equals('Message 4'));
      });

      test('should limit buffer size', () async {
        // Exceed buffer size (default is 100)
        for (int i = 0; i < 150; i++) {
          loggingService.info('Message $i');
        }
        
        await Future.delayed(Duration.zero);
        
        final recentLogs = loggingService.recentLogs;
        expect(recentLogs.length, equals(100));
        expect(recentLogs.first.message, equals('Message 50')); // First 50 should be removed
        expect(recentLogs.last.message, equals('Message 149'));
      });
    });

    group('multiple writers', () {
      test('should write to all registered writers', () async {
        final secondWriter = TestLogWriter();
        loggingService.addWriter(secondWriter);
        
        loggingService.info('Test message');
        
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(1));
        expect(secondWriter.entries.length, equals(1));
        expect(testLogWriter.entries.first.message, equals('Test message'));
        expect(secondWriter.entries.first.message, equals('Test message'));
      });

      test('should remove writers', () async {
        final secondWriter = TestLogWriter();
        loggingService.addWriter(secondWriter);
        loggingService.removeWriter(secondWriter);
        
        loggingService.info('Test message');
        
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(1));
        expect(secondWriter.entries.length, equals(0));
      });
    });

    group('context logging', () {
      test('should log with context', () async {
        final context = {'userId': '123', 'action': 'login'};
        
        loggingService.info('User action', context: context);
        
        await Future.delayed(Duration.zero);
        
        expect(testLogWriter.entries.length, equals(1));
        expect(testLogWriter.entries.first.context, equals(context));
      });
    });

    group('error integration', () {
      test('should log errors from error handler', () async {
        await loggingService.initialize();
        
        final error = DatabaseException(message: 'Test database error');
        await ErrorHandler().handleError(error);
        
        await Future.delayed(Duration.zero);
        
        // Should have at least one log entry for the error
        expect(testLogWriter.entries.isNotEmpty, isTrue);
        
        final errorLog = testLogWriter.entries
            .where((entry) => entry.tag == 'ErrorHandler')
            .firstOrNull;
        
        expect(errorLog, isNotNull);
        expect(errorLog!.level, equals(LogLevel.error));
        expect(errorLog.message, equals('Test database error'));
      });
    });
  });

  group('Global logger functions', () {
    test('should use global logger instance', () async {
      final globalTestWriter = TestLogWriter();
      logger.addWriter(globalTestWriter);
      
      logInfo('Global info message');
      logError('Global error message', error: 'Test error');
      
      await Future.delayed(Duration.zero);
      
      expect(globalTestWriter.entries.length, equals(2));
      expect(globalTestWriter.entries.first.message, equals('Global info message'));
      expect(globalTestWriter.entries.last.message, equals('Global error message'));
    });
  });
}