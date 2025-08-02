import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:onclo_mobile/models/activity.dart';
import 'package:onclo_mobile/converters/activity_converter.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:onclo_mobile/extensions/date_time_extensions.dart';

part 'database.g.dart';

class SessionEnds extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get activity => text().map(const ActivityConverter())();
  TextColumn get note => text()();
}

@DriftDatabase(tables: [SessionEnds])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  /// Watches the sessionEnds in reverse order of endDate; the latest
  /// sessionEnd is the first in the list.
  // TODO: what should happen when two sessions end at the same time?
  Stream<List<SessionEnd>> get watchSessionEnds => (
    select(sessionEnds)
    ..orderBy([(s) => OrderingTerm(expression: s.endDate, mode: OrderingMode.desc)])
  ).watch();

  Future updateSessionEndTimeOfDay(SessionEnd sessionEnd, TimeOfDay newTimeOfDay) {
    final newEndDate = sessionEnd.endDate.nearestWithTimeOfDay(newTimeOfDay);
    final newSessionEnd = sessionEnd.copyWith(endDate: newEndDate);
    return update(sessionEnds).replace(newSessionEnd);
  }

  Future endSessionNow(Activity activity) {
    return into(sessionEnds).insert(SessionEndsCompanion.insert(
      endDate: DateTime.now(),
      activity: activity,
      note: '',
    ));
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'app_database',
      native: const DriftNativeOptions(
          databaseDirectory: getApplicationSupportDirectory,
      )
    );
  }
}

