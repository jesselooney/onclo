import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:onclo_mobile/models/activity.dart';
import 'package:onclo_mobile/converters/activity_converter.dart';

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

  // TODO: what should happen when two sessions end at the same time?
  Stream<List<SessionEnd>> get watchSessionEnds => (
    select(sessionEnds)
    ..orderBy([(s) => OrderingTerm(expression: s.endDate)])
  ).watch();

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'app_database',
      native: const DriftNativeOptions(
          databaseDirectory: getApplicationSupportDirectory,
      )
    );
  }
}

