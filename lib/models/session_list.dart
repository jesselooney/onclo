import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../extensions/date_time_extensions.dart';
import 'session.dart';

typedef SessionEnd = ({String activity, DateTime endDate});

// TODO: ensure we maintain the invariant that:
// _sessions[i].endDate == _sessions[i + 1].startDate for all 0 <= i < _sessions.length - 1
class SessionList extends ChangeNotifier {
  final List<Session> _sessions = [
    Session.create(activity: "one", startDate: DateTime(2025, 1, 1, 6, 15, 0), endDate: DateTime(2025, 1, 1, 6, 25, 0)),
    Session.create(activity: "two", startDate: DateTime(2025, 1, 1, 6, 25, 0), endDate: DateTime(2025, 1, 1, 6, 35, 0)),
  ];

  UnmodifiableListView<Session> get sessions => UnmodifiableListView(_sessions);

  void _add(Session session) {
    _sessions.add(session);
    notifyListeners();
  }

  int _lastIndexBefore(DateTime date) {
    for (int i = _sessions.length - 1; i >= 0; i--) {
      if (_sessions[i].endDate.compareTo(date) < 0)
        return i;
    }

    return -1;
  }

  // TODO: check that this method is correct and preserves invariants.
  Session _insert(SessionEnd sessionEnd) {
    final lastIndex = _lastIndexBefore(sessionEnd.endDate);

    final DateTime startDate;
    if (lastIndex == -1) {
      startDate = endDate.subtract(const Duration(microseconds: 1));
    }
    else {
      startDate = _sessions[lastIndex].endDate;
    }

    final newSession = Session.create(activity: sessionEnd.activity, startDate: startDate, endDate: endDate);

    _sessions.insert(lastIndex + 1, newSession);

    if (lastIndex >= 0) {
      _sessions[lastIndex].endDate = newSession.startDate;
    }
    if (lastIndex + 2 < _sessions.length) {
      _sessions[lastIndex + 2].startDate = newSession.endDate;
    }

    notifyListeners();
    return newSession;
  }

  Session endActivity(String activity) {
    return _insert((activity: activity, endDate: DateTime.now()))
  }

  void changeEndTime(int index, TimeOfDay timeOfDay) {
    // FIXME: what if index out of range?
    // FIXME: what if new time is before the session's startDate? What if it is later than the next session's endDate?
    final newEndDate = _sessions[index].endDate.atTimeOfDay(timeOfDay);
    _sessions[index] = _sessions[index].copyWith(endDate: newEndDate);
    // Maintain the invariant that each session starts when the previous one ends.
    if (index + 1 < _sessions.length)
      _sessions[index + 1] = _sessions[index + 1].copyWith(startDate: newEndDate);
    notifyListeners();
  }
}

