import 'package:flutter/foundation.dart';

enum AppLogLevel {
  debug,
  info,
  warn,
  error,
}

abstract interface class AppLogSink {
  void log(String line);
}

final class ConsoleAppLogSink implements AppLogSink {
  const ConsoleAppLogSink();

  @override
  void log(String line) {
    debugPrint(line);
  }
}

/// Structured console logging with redacted context. Use for diagnostics only.
abstract final class AppLogger {
  static final RegExp _emailInString = RegExp(r'\S+@\S+\.\S+');
  static final RegExp _queryParamSecret = RegExp(
    r'((?:access|refresh|id)?_?token|anon_key|api_key|code)=([^&\s]+)',
    caseSensitive: false,
  );
  static final RegExp _bearerSecret = RegExp(
    r'(Bearer\s+)([^\s]+)',
    caseSensitive: false,
  );

  static const Set<String> _sensitiveKeyHints = {
    'email',
    'user_email',
    'password',
    'access_token',
    'refresh_token',
    'token',
    'anon_key',
    'api_key',
    'secret',
    'auth_code',
    'authorization',
  };

  static AppLogSink _sink = const ConsoleAppLogSink();

  static void debug({
    required String domain,
    required String event,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(
      AppLogLevel.debug,
      domain: domain,
      event: event,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info({
    required String domain,
    required String event,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(
      AppLogLevel.info,
      domain: domain,
      event: event,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warn({
    required String domain,
    required String event,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(
      AppLogLevel.warn,
      domain: domain,
      event: event,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error({
    required String domain,
    required String event,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(
      AppLogLevel.error,
      domain: domain,
      event: event,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @visibleForTesting
  static void setSinkForTest(AppLogSink sink) {
    _sink = sink;
  }

  @visibleForTesting
  static void resetSinkForTest() {
    _sink = const ConsoleAppLogSink();
  }

  static void _emit(
    AppLogLevel level, {
    required String domain,
    required String event,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    final line = formatForTest(
      level: level,
      domain: domain,
      event: event,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
    _sink.log(line);
  }

  /// Deterministic, redacted single-line format for tests and console sink.
  static String formatForTest({
    required AppLogLevel level,
    required String domain,
    required String event,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    final ctx = formatContext(context);
    final buffer = StringBuffer()
      ..write('level=${level.name} ')
      ..write('domain=$domain ')
      ..write('event=$event ')
      ..write('context=$ctx');
    if (error != null) {
      buffer.write(' error=${redactText(error.toString())}');
    }
    if (stackTrace != null) {
      buffer.write(' stackTrace=${stackTrace.toString().split('\n').first}');
    }
    return buffer.toString();
  }

  static String formatContext(Map<String, Object?> context) {
    final redacted = redactContext(context);
    final entries = redacted.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) {
      return '{}';
    }
    final inner = entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return '{$inner}';
  }

  static String redactText(String text) {
    var redacted = text;
    redacted = redacted.replaceAllMapped(
      _bearerSecret,
      (match) => '${match.group(1)}[REDACTED]',
    );
    redacted = redacted.replaceAllMapped(
      _queryParamSecret,
      (match) => '${match.group(1)}=[REDACTED]',
    );
    redacted = redacted.replaceAll(_emailInString, '[REDACTED]');
    return redacted;
  }

  static Map<String, Object?> redactContext(Map<String, Object?> context) {
    final out = <String, Object?>{};
    for (final entry in context.entries) {
      out[entry.key] = _redactEntry(entry.key, entry.value);
    }
    return out;
  }

  static Object? _redactEntry(String key, Object? value) {
    if (value == null) return null;
    final keyLower = key.toLowerCase();
    if (_keyLooksSensitive(keyLower)) {
      return '[REDACTED]';
    }
    if (value is String) {
      final redacted = redactText(value);
      return redacted == value ? value : '[REDACTED]';
    }
    if (value is num || value is bool) {
      return value;
    }
    return value.toString();
  }

  static bool _keyLooksSensitive(String keyLower) {
    for (final hint in _sensitiveKeyHints) {
      if (keyLower == hint || keyLower.endsWith('_$hint')) {
        return true;
      }
    }
    if (keyLower.contains('token')) return true;
    if (keyLower.contains('secret')) return true;
    if (keyLower.endsWith('_key') && keyLower != 'keyboard') return true;
    return false;
  }
}
