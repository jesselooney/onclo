import 'package:flutter/material.dart';

extension AtTimeOfDay on DateTime {
  DateTime atTimeOfDay(TimeOfDay timeOfDay) {
    return this.copyWith(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }
}
