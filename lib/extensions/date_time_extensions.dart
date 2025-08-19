import 'package:flutter/material.dart';

/// Methods for changing the time of day of [DateTime]s while keeping other fields.
extension AtTimeOfDay on DateTime {
  /// Copies this DateTime with the hour and minute matching `timeOfDay`.
  ///
  /// The resulting DateTime has the same year, month, and day as this one, but
  /// an hour and minute specified by `timeOfDay`. The smaller units are all
  /// set to zero.
  DateTime atTimeOfDay(TimeOfDay timeOfDay) {
    return copyWith(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }

  /// The earliest DateTime on the same day as this one.
  ///
  /// The resulting DateTime has the same year, month, and day as this one, but
  /// the hour and lower units are all set to zero.
  DateTime get atStartOfDay {
    return copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }

  /// Returns the nearest DateTime whose time of day is timeOfDay.
  ///
  /// If the new time of day is more than twelve hours forward from the current,
  /// then it is shorter to go back to that time on the previous day. Likewise,
  /// if the new time is more than twelve hours prior, then it is shorter to go
  /// to the next day.
  DateTime nearestWithTimeOfDay(TimeOfDay timeOfDay) {
    const oneDay = Duration(days: 1);
    const twelveHours = Duration(hours: 12);

    final newDate = atTimeOfDay(timeOfDay);
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
}
