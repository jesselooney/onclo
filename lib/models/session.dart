import 'package:onclo/database.dart';
import 'package:onclo/models/activity.dart';

/// A contiguous period of time spent doing a certain [Activity].
///
/// Each session is backed by a [SessionEnd], a representation more suitable
/// for UI logic and persistence. Given a session end the date at which the
/// represented session started, one can construct the full session using
/// [Session.fromSessionEnd].
class Session {
  /// The `id` of the [SessionEnd] backing this session.
  final int sessionEndId;
  /// The moment in time marking the start of this session.
  final DateTime startDate;
  /// The moment in time marking the end of this session.
  final DateTime endDate;
  /// The [Activity] performed during this session.
  final Activity activity;
  /// An arbitrary note specific to this session.
  final String note;

  /// How long the session lasted, based on its start and end dates.
  Duration get duration => endDate.difference(startDate);

  const Session({
    required this.sessionEndId,
    required this.startDate,
    required this.endDate,
    required this.activity,
    required this.note,
  });

  /// Constructs a session from a [SessionEnd] and the session's start date.
  ///
  /// The resulting session's fields match those of the session end except for
  /// its start date, which is just `startDate`.
  Session.fromSessionEnd(SessionEnd sessionEnd, DateTime startDate)
    : this(
        sessionEndId: sessionEnd.id,
        startDate: startDate,
        endDate: sessionEnd.endDate,
        activity: sessionEnd.activity,
        note: sessionEnd.note,
      );
}
