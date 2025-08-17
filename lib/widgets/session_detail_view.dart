import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:onclo/models/models.dart';

/// A widget showing a [Session] in detail.
///
/// Usually shown in a bottom sheet created by a [SessionEndView].
class SessionDetailView extends StatelessWidget {
  final Session session;

  const SessionDetailView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.6,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.activity.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(session.note),
              Text(
                "start: " +
                    DateFormat(
                      "MMM d, yyyy 'at' HH:mm",
                    ).format(session.startDate),
              ),
              Text(
                "end: " +
                    DateFormat(
                      "MMM d, yyyy 'at' HH:mm",
                    ).format(session.endDate),
              ),
              Text(
                "${session.duration.inHours.remainder(24)}h${session.duration.inMinutes.remainder(60)}m",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
