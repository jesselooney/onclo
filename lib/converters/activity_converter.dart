import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:onclo_mobile/models/activity.dart';

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

