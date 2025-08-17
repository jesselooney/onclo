import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:onclo/models/models.dart';

/// A Drift [TypeConverter] for the [Activity] class.
class ActivityConverter extends TypeConverter<Activity, String> {
  const ActivityConverter();

  @override
  Activity fromSql(String string) {
    return Activity(string);
  }

  @override
  String toSql(Activity activity) {
    return activity.name;
  }
}
