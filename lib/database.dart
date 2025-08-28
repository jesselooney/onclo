import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:onclo/converters/converters.dart';
import 'package:onclo/extensions/extensions.dart';
import 'package:onclo/models/models.dart';

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

  /// Watch the [SessionEnd]s that end on a given day.
  ///
  /// The session ends are sorted in reverse order of endDate; the latest
  /// ending session end comes first in the list.
  // TODO: Define the ordering of sessionEnds that end at the same time.
  Stream<List<SessionEnd>> watchSessionEndsOnDay(DateTime date) {
    // Discard hours and lower time units from `date`.
    final startOfDay = date.atStartOfDay;
    // WARN: This may not get the start of the next day due to daylight savings.
    final startOfNextDay = startOfDay.add(const Duration(days: 1));

    return (select(sessionEnds)
          ..where(
            (s) =>
                s.endDate.isBiggerOrEqualValue(startOfDay) &
                s.endDate.isSmallerThanValue(startOfNextDay),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.endDate)]))
        .watch();
  }

  /// Watch the earliest date on which a [SessionEnd] ends.
  ///
  /// Returns null if there are no session ends in the database.
  Stream<DateTime?> watchFirstEndDate() {
    final Expression<DateTime> earliestEndDate = sessionEnds.endDate.min();
    final rowStream = (selectOnly(
      sessionEnds,
    )..addColumns([earliestEndDate])).watchSingle();
    return rowStream.map((row) => row.read(earliestEndDate));
  }

  /// Update the [TimeOfDay] at which a [SessionEnd] ends.
  ///
  /// The `endDate` is changed using [DateTime.nearestWithTimeOfDay].
  Future updateSessionEndTimeOfDay(
    SessionEnd sessionEnd,
    TimeOfDay newTimeOfDay,
  ) {
    final newEndDate = sessionEnd.endDate.nearestWithTimeOfDay(newTimeOfDay);
    final newSessionEnd = sessionEnd.copyWith(endDate: newEndDate);
    return update(sessionEnds).replace(newSessionEnd);
  }

  /// Create a [SessionEnd] by ending a session of `activity` now.
  Future endSessionNow(Activity activity) {
    return into(sessionEnds).insert(
      SessionEndsCompanion.insert(
        endDate: DateTime.now(),
        activity: activity,
        note: '',
      ),
    );
  }

  /// Constructs a [Session] from `sessionEnd` by finding its start date.
  ///
  /// The session's `startDate` is the `endDate` of the latest ending session
  /// that ends prior to `sessionEnd`.
  Future<Session> getSessionFromSessionEnd(SessionEnd sessionEnd) async {
    final priorSessionEnd =
        await (select(sessionEnds)
              ..where((s) => s.endDate.isSmallerThanValue(sessionEnd.endDate))
              ..orderBy([(s) => OrderingTerm.desc(s.endDate)])
              ..limit(1))
            .get();

    // If there is no prior session, use `sessionEnd`'s end date as the start
    // date.
    final startDate = priorSessionEnd.isEmpty
        ? sessionEnd.endDate
        : priorSessionEnd[0].endDate;

    return Session.fromSessionEnd(sessionEnd, startDate);
  }

  static String databaseName = "app_database";
  static Future<String> databasePath() async {
    return p.join(
      (await getApplicationSupportDirectory()).path,
      "$databaseName.sqlite",
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: databaseName,
      native: const DriftNativeOptions(databasePath: databasePath),
    );
  }
}
