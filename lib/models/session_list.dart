import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../extensions/date_time_extensions.dart';
import 'session.dart';

typedef SessionEnd = ({String activity, DateTime endDate});

// NOTE: This implementation is somewhat silly. We are storing full Sessions,
// but really we could do everything in terms of SessionEnds, as that is what
// the user interface presents. Then we can convert to Sessions for analysis if
// necessary. The current implementation costs much complexity for only a potential
// benefit elsewhere in the application.
// NOTE: Instances must always maintain the following invariants:
// 1. _sessions[i].endDate == _sessions[i + 1].startDate for all 0 <= i < _sessions.length - 1
class SessionList extends ChangeNotifier {
  final List<Session> _sessions = [];

  UnmodifiableListView<Session> get sessions => UnmodifiableListView(_sessions);

  /// Return the index of the Session that ends the latest
  /// among those that end before (or at) `date`. If there are none,
  /// return -1.
  int _indexOfLastSessionBefore(DateTime date) {
    // This implementation depends on `_sessions` being ordered by endDate,
    // which is a corollary of invariant (1).
    for (int i = _sessions.length - 1; i >= 0; i--) {
      if (_sessions[i].endDate.compareTo(date) <= 0)
        return i;
    }

    return -1;
  }

  /// Insert a SessionEnd into the list, creating a Session based on the startDate
  /// of the last Session preceeding the given endDate.
  /// Returns the newly created Session.
  Session insert(SessionEnd sessionEnd) {
    final lastIndex = _indexOfLastSessionBefore(sessionEnd.endDate);

    // We first compute the startDate of the new Session.
    final DateTime startDate;
    if (lastIndex == -1) {
      // If nothing comes before the end of this session, we will create an
      // "instantaneous" session lasting no time at all. 
      startDate = sessionEnd.endDate;
    }
    else {
      startDate = _sessions[lastIndex].endDate;
    }

    assert(startDate.compareTo(sessionEnd.endDate) <= 0);
    // The following Session.create call must return a non-null value because startDate preceeds sessionEnd.endDate.
    final newSession = Session.create(activity: sessionEnd.activity, startDate: startDate, endDate: sessionEnd.endDate)!;
    _sessions.insert(lastIndex + 1, newSession);

    // If there is a following Session, fix its startDate to preserve invariant (1).
    final nextIndex = lastIndex + 2;
    if (nextIndex < _sessions.length) {
      // The copyWith method must return a non-null value because newSession.endDate must
      // preceed _sessions[nextIndex].endDate due to how lastIndex was computed.
      _sessions[nextIndex] = _sessions[nextIndex].copyWith(startDate: newSession.endDate)!;
    }

    return newSession;
  }

  /// Remove the Session at index `index` and return it,
  /// or return null if `index` is out of range.
  Session? removeAt(int index) {
    if (index < 0 || _sessions.length <= index) return null;

    final prevIndex = index - 1;
    final nextIndex = index + 1;
    // If there are Sessions on both sides of the deletion target,
    // we must update the startDate of the latter to preserve invariant (1).
    if (0 <= prevIndex && nextIndex < _sessions.length) {
      // The copyWith call must return a non-null value because we are moving the startDate earlier.
      _sessions[nextIndex] = _sessions[nextIndex].copyWith(startDate: _sessions[prevIndex].endDate)!;
    }

    // At long last, actually delete the target Session.
    return _sessions.removeAt(index);
  }

  Session endActivity(String activity) {
    final newSession = insert((activity: activity, endDate: DateTime.now()));
    notifyListeners();
    return newSession;
  }

  /// Modify a Session by changing the time of day at which it ends.
  /// Returns the modified session, or null if the index is out of range. 
  Session? changeEndTime(int index, TimeOfDay timeOfDay) {
    if (index < 0 || _sessions.length <= index) return null;

    final targetSession = _sessions[index];
    final modifiedSessionEnd = (activity: targetSession.activity, endDate: targetSession.endDate.atTimeOfDay(timeOfDay));

    if (targetSession.endDate.compareTo(modifiedSessionEnd.endDate) == 0)
      return targetSession;
   
    // Remove the original Session.
    removeAt(index);
    // Add it back with a modified endDate.
    final modifiedSession = insert(modifiedSessionEnd);

    notifyListeners();

    return modifiedSession;
  }
}

