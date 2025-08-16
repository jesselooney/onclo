import 'package:test/test.dart';
import 'package:onclo_mobile/extensions/date_time_extensions.dart';
import 'package:flutter/material.dart' show TimeOfDay;

void main() {
  group('DateTime.nearestWithTimeOfDay() returns', () {
    test('prev day when new time is ahead by more than 12 hrs', () {
      final originalDate = DateTime(2025, 1, 2, 10, 0);
      final newDate = originalDate.nearestWithTimeOfDay(
        TimeOfDay(hour: 22, minute: 1),
      );
      expect(newDate, DateTime(2025, 1, 1, 22, 1));
    });

    test('next day when new time is behind by more than 12 hrs', () {
      final originalDate = DateTime(2025, 1, 2, 22, 0);
      final newDate = originalDate.nearestWithTimeOfDay(
        TimeOfDay(hour: 9, minute: 59),
      );
      expect(newDate, DateTime(2025, 1, 3, 9, 59));
    });

    test('same day when new time is ahead by at most 12 hours', () {
      final originalDate = DateTime(2025, 1, 2, 10, 0);
      final newDate = originalDate.nearestWithTimeOfDay(
        TimeOfDay(hour: 22, minute: 0),
      );
      expect(newDate, DateTime(2025, 1, 2, 22, 0));
    });

    test('same day when new time is behind by at most 12 hours', () {
      final originalDate = DateTime(2025, 1, 2, 22, 0);
      final newDate = originalDate.nearestWithTimeOfDay(
        TimeOfDay(hour: 10, minute: 0),
      );
      expect(newDate, DateTime(2025, 1, 2, 10, 0));
    });
  });
}
