import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:onclo/database.dart';
import 'package:onclo/widgets/session_end_view.dart';

/// A widget listing the [SessionEnds] that end on `day`.
class DayView extends StatefulWidget {
  final AppDatabase db;
  final DateTime day;

  const DayView({super.key, required this.db, required this.day});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  /// A stream of the [SessionEnds] that end on the DayView's `day`.
  late Stream<List<SessionEnd>> sessionEndsStream;

  @override
  void initState() {
    super.initState();
    sessionEndsStream = widget.db.watchSessionEndsOnDay(widget.day);
  }

  @override
  void didUpdateWidget(covariant DayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    sessionEndsStream = widget.db.watchSessionEndsOnDay(widget.day);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(title: Text(DateFormat.yMMMd().format(widget.day))),
      StreamBuilder(
        initialData: [],
        stream: sessionEndsStream,
        builder: (context, snapshot) {
          // If there is no data, assume an empty list.
          // TODO: It would be better to indicate the data is loading or
          // unavailable somehow.
          final sessionEnds = snapshot.data ?? [];
          return ListView.builder(
            reverse: true,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessionEnds.length,
            itemBuilder: (context, index) {
              final sessionEnd = sessionEnds[index];
              return SessionEndView(
                key: ValueKey(sessionEnd.id),
                sessionEnd: sessionEnd,
              );
            },
          );
        },
      ),
    ],
  );
}
