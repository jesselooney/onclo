import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:onclo_mobile/models/activity.dart';
import 'package:onclo_mobile/converters/activity_converter.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:onclo_mobile/extensions/date_time_extensions.dart';
import 'package:onclo_mobile/models/session.dart';

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

  /// Watches the sessionEnds that end on a given day in reverse order
  /// of endDate; the latest sessionEnd is the first in the list.
  Stream<List<SessionEnd>> watchSessionEndsOnDay(DateTime day) {
    final startOfDay = day.atStartOfDay;
    final startOfNextDay = startOfDay.add(const Duration(days: 1));
    return (select(sessionEnds)
      ..where((s) => s.endDate.isBiggerOrEqualValue(startOfDay) & s.endDate.isSmallerThanValue(startOfNextDay))
      ..orderBy([(s) => OrderingTerm(expression: s.endDate, mode: OrderingMode.desc)])
    ).watch();
  }

  Future<DateTime?> get earliestEndDate async {
    final Expression<DateTime> getEarliestEndDate = sessionEnds.endDate.min();
    final query = selectOnly(sessionEnds)..addColumns([getEarliestEndDate]);
    final row = await query.getSingle();
    return row.read(getEarliestEndDate);
  }

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

  Future<Session> getSessionFromSessionEnd(SessionEnd sessionEnd) async {
    final priorSessionEnd = await (select(sessionEnds)
      ..where((s) => s.endDate.isSmallerThanValue(sessionEnd.endDate))
      ..orderBy([(s) => OrderingTerm(expression: s.endDate, mode: OrderingMode.desc)])
      ..limit(1)).get();

    final startDate = priorSessionEnd.isEmpty ? sessionEnd.endDate : priorSessionEnd[0].endDate;

    return Session.fromSessionEnd(sessionEnd, startDate);
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

