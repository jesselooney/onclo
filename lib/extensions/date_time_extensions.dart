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

  /// Returns the DateTime nearest to this one among those
  /// whose time of day is timeOfDay. If the new time of day
  /// is more than twelve hours forward from the current,
  /// then it is shorter to go back to that time on the previous
  /// day. Likewise, if the new time is more than twelve hours
  /// prior, then it is shorter to go to the next day.
  DateTime nearestWithTimeOfDay(TimeOfDay timeOfDay) {
    const oneDay = Duration(days: 1);
    const twelveHours = Duration(hours: 12);

    final newDate = this.atTimeOfDay(timeOfDay);
    final difference = newDate.difference(this);

    if (difference > twelveHours) {
      // This time of day on the previous day is closer.
      return newDate.subtract(oneDay);
    } else if (difference < -twelveHours) {
      // This time of day on the next day is closer.
      return newDate.add(oneDay);
    } else {
      return newDate;
    }
  }

  DateTime get atStartOfDay {
    return this.copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }
}
