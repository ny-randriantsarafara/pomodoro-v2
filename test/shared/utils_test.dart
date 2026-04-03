import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/shared/utils/date_helpers.dart';
import 'package:rhythm/shared/utils/format_helpers.dart';

void main() {
  group('date_helpers', () {
    test('isSameDay returns true for same day', () {
      expect(isSameDay(DateTime(2026, 4, 3, 10), DateTime(2026, 4, 3, 22)), true);
    });

    test('isSameDay returns false for different days', () {
      expect(isSameDay(DateTime(2026, 4, 3), DateTime(2026, 4, 4)), false);
    });

    test('isToday returns true for today', () {
      expect(isToday(DateTime.now()), true);
    });

    test('isYesterday returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(isYesterday(yesterday), true);
    });
  });

  group('format_helpers', () {
    test('formatDuration with hours', () {
      expect(formatDuration(3660), '1h 1m');
    });

    test('formatDuration minutes only', () {
      expect(formatDuration(1500), '25m');
    });

    test('formatDuration zero', () {
      expect(formatDuration(0), '0m');
    });

    test('formatTimer', () {
      expect(formatTimer(1500), '25:00');
      expect(formatTimer(65), '01:05');
      expect(formatTimer(0), '00:00');
    });

    test('breakMinutesForPreset', () {
      expect(breakMinutesForPreset(25), 5);
      expect(breakMinutesForPreset(50), 10);
      expect(breakMinutesForPreset(90), 20);
    });
  });
}
