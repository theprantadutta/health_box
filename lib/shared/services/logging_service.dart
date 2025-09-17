import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../error/error_handler.dart';

enum LogLevel {
  trace(0, 'TRACE'),
  debug(1, 'DEBUG'),
  info(2, 'INFO'),
  warning(3, 'WARN'),
  error(4, 'ERROR'),
  fatal(5, 'FATAL');

  const LogLevel(this.priority, this.label);
  final int priority;
  final String label;
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.context,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.label,
      'message': message,
      if (tag != null) 'tag': tag,
      if (context != null) 'context': context,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values.firstWhere(
        (level) => level.label == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      tag: json['tag'] as String?,
      context: json['context'] as Map<String, dynamic>?,
      error: json['error'],
      stackTrace: json['stackTrace'] != null
          ? StackTrace.fromString(json['stackTrace'] as String)
          : null,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('${timestamp.toIso8601String()} ');
    buffer.write('[${level.label}]');
    if (tag != null) {
      buffer.write(' [$tag]');
    }
    buffer.write(' $message');

    if (context != null && context!.isNotEmpty) {
      buffer.write(' | Context: ${jsonEncode(context)}');
    }

    if (error != null) {
      buffer.write('\nError: $error');
    }

    if (stackTrace != null) {
      buffer.write('\nStack Trace:\n$stackTrace');
    }

    return buffer.toString();
  }
}

abstract class LogWriter {
  Future<void> write(LogEntry entry);
  Future<void> flush();
  Future<void> dispose();
}

class ConsoleLogWriter implements LogWriter {
  @override
  Future<void> write(LogEntry entry) async {
    if (kDebugMode) {
      developer.log(
        entry.message,
        time: entry.timestamp,
        level: entry.level.priority * 100,
        name: entry.tag ?? 'HealthBox',
        error: entry.error,
        stackTrace: entry.stackTrace,
      );
    }
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> dispose() async {}
}

class FileLogWriter implements LogWriter {
  final String _fileName;
  final int _maxFileSize;
  final int _maxFiles;
  File? _logFile;
  int _currentSize = 0;

  FileLogWriter({
    String fileName = 'app.log',
    int maxFileSize = 5 * 1024 * 1024, // 5MB
    int maxFiles = 3,
  }) : _fileName = fileName,
       _maxFileSize = maxFileSize,
       _maxFiles = maxFiles;

  @override
  Future<void> write(LogEntry entry) async {
    try {
      await _ensureLogFile();
      if (_logFile == null) return;

      final logLine = '${entry.toString()}\n';
      await _logFile!.writeAsString(logLine, mode: FileMode.append);
      _currentSize += logLine.length;

      if (_currentSize > _maxFileSize) {
        await _rotateLog();
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Failed to write log to file: $error');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  @override
  Future<void> flush() async {
    // File.flush() is not available in Dart, files are automatically flushed
    // This method is kept for interface compliance
  }

  @override
  Future<void> dispose() async {
    try {
      await flush();
      _logFile = null;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to dispose log file: $error');
      }
    }
  }

  Future<void> _ensureLogFile() async {
    if (_logFile != null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      _logFile = File('${logDir.path}/$_fileName');

      if (await _logFile!.exists()) {
        _currentSize = await _logFile!.length();
      } else {
        await _logFile!.create();
        _currentSize = 0;
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to create log file: $error');
      }
      _logFile = null;
    }
  }

  Future<void> _rotateLog() async {
    try {
      if (_logFile == null) return;

      final logDir = _logFile!.parent;
      final baseName = _fileName.replaceAll('.log', '');

      // Rotate existing files
      for (int i = _maxFiles - 1; i >= 1; i--) {
        final oldFile = File('${logDir.path}/$baseName.$i.log');
        final newFile = File('${logDir.path}/$baseName.${i + 1}.log');

        if (await oldFile.exists()) {
          if (i == _maxFiles - 1) {
            await oldFile.delete();
          } else {
            await oldFile.rename(newFile.path);
          }
        }
      }

      // Move current log to .1
      final rotatedFile = File('${logDir.path}/$baseName.1.log');
      await _logFile!.rename(rotatedFile.path);

      // Create new log file
      _logFile = File('${logDir.path}/$_fileName');
      await _logFile!.create();
      _currentSize = 0;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to rotate log files: $error');
      }
    }
  }

  Future<List<String>> getLogFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      if (!await logDir.exists()) {
        return [];
      }

      final files = await logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.log'))
          .cast<File>()
          .toList();

      return files.map((file) => file.path).toList();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to get log files: $error');
      }
      return [];
    }
  }

  Future<String?> getLogContent(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to read log file: $error');
      }
    }
    return null;
  }
}

class LoggingService with ErrorHandlerMixin {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  final List<LogWriter> _writers = [];
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  final List<LogEntry> _buffer = [];
  final int _bufferSize = 100;

  LogLevel get minLevel => _minLevel;

  set minLevel(LogLevel level) {
    _minLevel = level;
  }

  List<LogEntry> get recentLogs => List.unmodifiable(_buffer);

  void addWriter(LogWriter writer) {
    _writers.add(writer);
  }

  void removeWriter(LogWriter writer) {
    _writers.remove(writer);
  }

  Future<void> initialize() async {
    await runGuarded(() async {
      // Add console writer for debug mode
      if (kDebugMode) {
        addWriter(ConsoleLogWriter());
      }

      // Add file writer for persistent logging
      addWriter(FileLogWriter());

      // Set up error handler integration
      errorHandler.addErrorCallback(_logError);
    });
  }

  void _logError(AppException error) {
    this.error(
      error.message,
      tag: 'ErrorHandler',
      error: error.originalError ?? error,
      stackTrace: error.stackTrace,
      context: {'code': error.code, 'type': error.runtimeType.toString()},
    );
  }

  Future<void> _log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (level.priority < _minLevel.priority) {
      return;
    }

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );

    // Add to buffer
    _buffer.add(entry);
    if (_buffer.length > _bufferSize) {
      _buffer.removeAt(0);
    }

    // Write to all writers
    for (final writer in _writers) {
      try {
        await writer.write(entry);
      } catch (writerError) {
        if (kDebugMode) {
          debugPrint('Log writer error: $writerError');
        }
      }
    }
  }

  void trace(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.trace,
      message,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void debug(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void info(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void warning(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void fatal(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> flush() async {
    await runGuarded(() async {
      for (final writer in _writers) {
        await writer.flush();
      }
    });
  }

  Future<void> dispose() async {
    await runGuarded(() async {
      for (final writer in _writers) {
        await writer.dispose();
      }
      _writers.clear();
      _buffer.clear();
    });
  }
}

// Global logger instance
final logger = LoggingService();

// Convenient logging functions
void logTrace(String message, {String? tag, Map<String, dynamic>? context}) {
  logger.trace(message, tag: tag, context: context);
}

void logDebug(String message, {String? tag, Map<String, dynamic>? context}) {
  logger.debug(message, tag: tag, context: context);
}

void logInfo(String message, {String? tag, Map<String, dynamic>? context}) {
  logger.info(message, tag: tag, context: context);
}

void logWarning(
  String message, {
  String? tag,
  Map<String, dynamic>? context,
  Object? error,
}) {
  logger.warning(message, tag: tag, context: context, error: error);
}

void logError(
  String message, {
  String? tag,
  Map<String, dynamic>? context,
  Object? error,
  StackTrace? stackTrace,
}) {
  logger.error(
    message,
    tag: tag,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );
}

void logFatal(
  String message, {
  String? tag,
  Map<String, dynamic>? context,
  Object? error,
  StackTrace? stackTrace,
}) {
  logger.fatal(
    message,
    tag: tag,
    context: context,
    error: error,
    stackTrace: stackTrace,
  );
}
