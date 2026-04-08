import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps auth/CORS/supabase errors to short copy for the auth UI.
String userVisibleAuthErrorMessage(Object error) {
  if (error is AuthApiException) {
    final rateLimited = error.statusCode == '429' ||
        error.code == 'over_email_send_rate_limit';
    if (rateLimited) {
      return 'Too many email requests. Please wait before requesting '
          'another magic link.';
    }
  }
  return 'Something went wrong. Try again.';
}
