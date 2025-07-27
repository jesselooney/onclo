import 'package:test/test.dart';
import 'package:onclo_mobile/models/session_list.dart';

void main() {
  final SessionEnd preceedingSessionEnd = (activity: "preceeding", endDate: DateTime(2024, 1, 1));
  final SessionEnd newSessionEnd = (activity: "new", endDate: DateTime(2025, 1, 1));
  final SessionEnd simultaneousSessionEnd = (activity: "simultaneous", endDate: newSessionEnd.endDate);
  final SessionEnd followingSessionEnd = (activity: "following", endDate: DateTime(2026, 1, 1));

  late SessionList sessionList;

  setUp(() {
    sessionList = SessionList();
    assert(sessionList.sessions.length == 0);
  });

  group('SessionList.insert()', () {
    test('works with no other Sessions', () {
      final newSession = sessionList.insert(newSessionEnd);

      expect(sessionList.sessions.length, equals(1));
      expect(sessionList.sessions[0], equals(newSession));

      expect(newSession.activity, equals(newSessionEnd.activity));
      expect(newSession.startDate, equals(newSession.endDate));
      expect(newSession.endDate, equals(newSessionEnd.endDate));
    });

    test('works with preceeding Session', () {
      final preceedingSession = sessionList.insert(preceedingSessionEnd);
      final newSession = sessionList.insert(newSessionEnd);

      expect(sessionList.sessions.length, equals(2));
      expect(sessionList.sessions[0], equals(preceedingSession));
      expect(sessionList.sessions[1], equals(newSession));

      expect(newSession.activity, equals(newSessionEnd.activity));
      expect(newSession.startDate, equals(preceedingSessionEnd.endDate));
      expect(newSession.endDate, equals(newSessionEnd.endDate));
    });

    test('works with following Session', () {
      sessionList.insert(followingSessionEnd);
      final newSession = sessionList.insert(newSessionEnd);

      expect(sessionList.sessions.length, equals(2));
      expect(sessionList.sessions[0], equals(newSession));

      expect(newSession.activity, equals(newSessionEnd.activity));
      expect(newSession.startDate, equals(newSessionEnd.endDate));
      expect(newSession.endDate, equals(newSessionEnd.endDate));

      final followingSession = sessionList.sessions[1];
      expect(followingSession.activity, equals(followingSessionEnd.activity));
      expect(followingSession.startDate, equals(newSessionEnd.endDate));
      expect(followingSession.endDate, equals(followingSessionEnd.endDate));
    });
    test('works with preceeding and following Sessions', () {
      final preceedingSession = sessionList.insert(preceedingSessionEnd);
      sessionList.insert(followingSessionEnd);
      final newSession = sessionList.insert(newSessionEnd);

      expect(sessionList.sessions.length, equals(3));
      expect(sessionList.sessions[0], equals(preceedingSession));
      expect(sessionList.sessions[1], equals(newSession));

      expect(newSession.activity, equals(newSessionEnd.activity));
      expect(newSession.startDate, equals(preceedingSessionEnd.endDate));
      expect(newSession.endDate, equals(newSessionEnd.endDate));

      final followingSession = sessionList.sessions[2];
      expect(followingSession.activity, equals(followingSessionEnd.activity));
      expect(followingSession.startDate, equals(newSessionEnd.endDate));
      expect(followingSession.endDate, equals(followingSessionEnd.endDate));
    });

    test('works with simultaneous Session', () {
      assert(simultaneousSessionEnd.endDate == newSessionEnd.endDate);

      final simultaneousSession = sessionList.insert(simultaneousSessionEnd);
      final newSession = sessionList.insert(newSessionEnd);

      expect(sessionList.sessions.length, equals(2));
      expect(sessionList.sessions[0], equals(simultaneousSession));
      expect(sessionList.sessions[1], equals(newSession));

      expect(newSession.activity, equals(newSessionEnd.activity));
      expect(newSession.startDate, equals(simultaneousSessionEnd.endDate));
      expect(newSession.endDate, equals(newSessionEnd.endDate));
    });
  });

  group('SessionList.removeAt()', () {
    test('returns null when `index` is negative', () {
      sessionList.insert(newSessionEnd);

      expect(sessionList.removeAt(-1), equals(null));
    });

    test('returns null when `index` is too large', () {
      sessionList.insert(newSessionEnd);

      expect(sessionList.removeAt(1), equals(null));
    });

    test('works with no other Sessions', () {
      final newSession = sessionList.insert(newSessionEnd);
      final removedSession = sessionList.removeAt(0);

      expect(removedSession, equals(newSession));
      expect(sessionList.sessions.length, equals(0));
    });

    test('works with preceeding Session', () {
      final preceedingSession = sessionList.insert(preceedingSessionEnd);
      final newSession = sessionList.insert(newSessionEnd);
      final removedSession = sessionList.removeAt(1);

      expect(removedSession, equals(newSession));
      expect(sessionList.sessions.length, equals(1));
      expect(sessionList.sessions[0], equals(preceedingSession));
    });

    test('works with following Session', () {
      final newSession = sessionList.insert(newSessionEnd);
      final followingSession = sessionList.insert(followingSessionEnd);
      final removedSession = sessionList.removeAt(0);

      expect(removedSession, equals(newSession));
      expect(sessionList.sessions.length, equals(1));
      expect(sessionList.sessions[0], equals(followingSession));
    });

    test('works with preceeding and following Sessions', () {
      final preceedingSession = sessionList.insert(preceedingSessionEnd);
      final newSession = sessionList.insert(newSessionEnd);
      sessionList.insert(followingSessionEnd);
      final removedSession = sessionList.removeAt(1);

      expect(removedSession, equals(newSession));
      expect(sessionList.sessions.length, equals(2));
      expect(sessionList.sessions[0], equals(preceedingSession));
      
      final followingSession = sessionList.sessions[1];
      expect(followingSession.activity, equals(followingSessionEnd.activity));
      expect(followingSession.startDate, equals(preceedingSessionEnd.endDate));
      expect(followingSession.endDate, equals(followingSessionEnd.endDate));
    });
  });
}
