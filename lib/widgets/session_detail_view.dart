import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:onclo/models/models.dart';

/// A widget showing a [Session] in detail.
///
/// Usually shown in a bottom sheet created by a [SessionEndView].
class SessionDetailView extends StatelessWidget {
  final Session session;

  String get startTime => DateFormat.Hm().format(session.startDate);
  String get startDay => DateFormat('MMM dd, yyyy').format(session.startDate);

  String get endTime => DateFormat.Hm().format(session.endDate);
  String get endDay => DateFormat('MMM dd, yyyy').format(session.endDate);

  String get durationText {
    final hours = session.duration.inHours.remainder(24);
    final minutes = session.duration.inMinutes.remainder(60);
    return "${hours}h${minutes}m";
  }

  const SessionDetailView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.6,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Table(
            // WARN: This width setting is supposedly very expensive.
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                children: [
                  Text(
                    '$durationText   ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    session.activity.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              TableRow(
                children: [
                  Container(),
                  session.note.isEmpty
                      ? Container()
                      : Text(
                          session.note,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                ],
              ),
              // A spacer between the activity/note and from/to fields.
              TableRow(
                children: [SizedBox(height: 8.0), SizedBox(height: 8.0)],
              ),
              TableRow(
                children: [
                  Text(
                    'from   ',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  Text('$startTime on $startDay'),
                ],
              ),
              TableRow(
                children: [
                  Text('to   ', style: TextStyle(fontStyle: FontStyle.italic)),
                  Text('$endTime on $endDay'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
