import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:onclo_mobile/database.dart';

import 'session_view.dart';

class DayView extends StatefulWidget {
  final AppDatabase db;
  final DateTime day;

  const DayView({super.key, required this.db, required this.day});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late Stream<List<SessionEnd>> sessionEndsStream;

  @override
  void initState() {
    super.initState();
    sessionEndsStream = this.widget.db.watchSessionEndsOnDay(this.widget.day);
  }

  @override
  void didUpdateWidget(covariant DayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    sessionEndsStream = this.widget.db.watchSessionEndsOnDay(this.widget.day);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: [],
      stream: sessionEndsStream,
      builder: (context, snapshot) {
        final sessionEnds = snapshot.data ?? [];

        return Column(
          children: [
            ListTile(title: Text(DateFormat.yMMMd().format(this.widget.day))),
            ListView.builder(
              reverse: true,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessionEnds.length,
              itemBuilder: (context, index) {
                final sessionEnd = sessionEnds[index];
                return SessionView(
                  key: ValueKey(sessionEnd.id),
                  sessionEnd: sessionEnd,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
