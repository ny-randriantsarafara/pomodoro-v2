import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/shared/logging/app_logger.dart';

class _TestLogSink implements AppLogSink {
  final lines = <String>[];

  @override
  void log(String line) {
    lines.add(line);
  }
}

void main() {
  test('formatForTest includes level, domain, and event', () {
    final output = AppLogger.formatForTest(
      level: AppLogLevel.info,
      domain: 'auth',
      event: 'state_changed',
      context: {'hasSession': true},
    );

    expect(output, contains('level=info'));
    expect(output, contains('domain=auth'));
    expect(output, contains('event=state_changed'));
    expect(output, contains('hasSession: true'));
  });

  test('formatContext sorts keys deterministically', () {
    final ctx = AppLogger.formatContext({
      'z': 1,
      'a': 2,
      'm': 3,
    });
    expect(ctx, '{a: 2, m: 3, z: 1}');
  });

  test('AppLogger redacts email values in context', () {
    final output = AppLogger.formatForTest(
      level: AppLogLevel.error,
      domain: 'auth',
      event: 'magic_link_request_failed',
      context: {'email': 'name@example.com'},
    );

    expect(output, contains('domain=auth'));
    expect(output, contains('event=magic_link_request_failed'));
    expect(output, isNot(contains('name@example.com')));
    expect(output, contains('[REDACTED]'));
  });

  test('redacts token and key-like fields', () {
    final out = AppLogger.formatContext({
      'access_token': 'secret-value',
      'anon_key': 'eyJhbG',
      'safe': 'ok',
    });
    expect(out, isNot(contains('secret-value')));
    expect(out, isNot(contains('eyJhbG')));
    expect(out, contains('safe: ok'));
  });

  test('redacts bare string value that looks like an email', () {
    final out = AppLogger.formatContext({
      'hint': 'contact me@foo.com please',
    });
    expect(out, isNot(contains('me@foo.com')));
    expect(out, contains('[REDACTED]'));
  });

  test('auth magic_link failure log line redacts email', () {
    final output = AppLogger.formatForTest(
      level: AppLogLevel.error,
      domain: 'auth',
      event: 'magic_link_request_failed',
      context: {
        'action': 'signInWithMagicLink',
        'email': 'u@test.com',
      },
      error: Exception('network'),
    );
    expect(output, contains('event=magic_link_request_failed'));
    expect(output, isNot(contains('u@test.com')));
    expect(output, contains('action: signInWithMagicLink'));
  });

  test('auth state change debug line includes event and session flags', () {
    final output = AppLogger.formatForTest(
      level: AppLogLevel.debug,
      domain: 'auth',
      event: 'auth_state_changed',
      context: {
        'authEvent': 'signedIn',
        'hasSession': true,
        'sessionUserId': 'user-uuid-1',
        'currentUserId': 'user-uuid-1',
      },
    );
    expect(output, contains('domain=auth'));
    expect(output, contains('event=auth_state_changed'));
    expect(output, contains('authEvent: signedIn'));
    expect(output, contains('hasSession: true'));
  });

  test('redacts sensitive values embedded in error strings', () {
    final output = AppLogger.formatForTest(
      level: AppLogLevel.error,
      domain: 'auth',
      event: 'callback_failed',
      error: Exception(
        'Auth failed for jane@example.com access_token=secret-token code=pkce-code',
      ),
    );

    expect(output, isNot(contains('jane@example.com')));
    expect(output, isNot(contains('secret-token')));
    expect(output, isNot(contains('pkce-code')));
    expect(output, contains('[REDACTED]'));
  });

  test('AppLogger writes through configured sink', () {
    final sink = _TestLogSink();

    AppLogger.setSinkForTest(sink);
    addTearDown(AppLogger.resetSinkForTest);

    AppLogger.info(
      domain: 'auth',
      event: 'state_changed',
      context: {'hasSession': true},
    );

    expect(sink.lines, hasLength(1));
    expect(sink.lines.single, contains('domain=auth'));
    expect(sink.lines.single, contains('event=state_changed'));
  });
}
