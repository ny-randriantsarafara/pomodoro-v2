import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/features/auth/auth_user_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('userVisibleAuthErrorMessage', () {
    test('AuthApiException 429 maps to rate limit message', () {
      final msg = userVisibleAuthErrorMessage(
        AuthApiException(
          'Email rate limit exceeded',
          statusCode: '429',
          code: 'over_email_send_rate_limit',
        ),
      );
      expect(
        msg,
        'Too many email requests. Please wait before requesting another magic link.',
      );
    });

    test('AuthApiException rate limit code without 429 still maps', () {
      final msg = userVisibleAuthErrorMessage(
        AuthApiException(
          'Too many requests',
          statusCode: '400',
          code: 'over_email_send_rate_limit',
        ),
      );
      expect(
        msg,
        'Too many email requests. Please wait before requesting another magic link.',
      );
    });

    test('unknown errors use generic fallback', () {
      expect(
        userVisibleAuthErrorMessage(Exception('weird')),
        'Something went wrong. Try again.',
      );
      expect(
        userVisibleAuthErrorMessage(
          AuthApiException('Invalid', statusCode: '400', code: 'invalid'),
        ),
        'Something went wrong. Try again.',
      );
    });
  });
}
