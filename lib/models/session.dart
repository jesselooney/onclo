class Session {
  final String activity;
  final DateTime startDate;
  final DateTime endDate;
  
  Session._({required this.activity, required this.startDate, required this.endDate});

  static Session? create({required String activity, required DateTime startDate, required DateTime endDate}) {
    if (startDate.compareTo(endDate) <= 0)
      return Session._(activity: activity, startDate: startDate, endDate: endDate);
  }

  Session? copyWith({String? activity, DateTime? startDate, DateTime? endDate}) {
    return Session.create(
      activity: activity ?? this.activity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
