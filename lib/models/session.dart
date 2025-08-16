import './activity.dart';
import 'package:onclo_mobile/database.dart';

class Session {
  final int sessionEndId;
  final DateTime startDate;
  final DateTime endDate;
  final Activity activity;
  final String note;

  Duration get duration => endDate.difference(startDate);

  const Session({
    required this.sessionEndId,
    required this.startDate,
    required this.endDate,
    required this.activity,
    required this.note,
  });

  Session.fromSessionEnd(SessionEnd sessionEnd, DateTime startDate) : this(
    sessionEndId: sessionEnd.id,
    startDate: startDate,
    endDate: sessionEnd.endDate,
    activity: sessionEnd.activity,
    note: sessionEnd.note,
  );
}
