import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:onclo/models/models.dart';

class SessionDetailView extends StatelessWidget {
  final Session session;

  const SessionDetailView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // TODO: Extract this modal bottom sheet design pattern into a generic component
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
                this.session.activity.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(this.session.note),
              Text(
                "start: " +
                    DateFormat(
                      "MMM d, yyyy 'at' HH:mm",
                    ).format(this.session.startDate),
              ),
              Text(
                "end: " +
                    DateFormat(
                      "MMM d, yyyy 'at' HH:mm",
                    ).format(this.session.endDate),
              ),
              Text(
                "${this.session.duration.inHours.remainder(24)}h${this.session.duration.inMinutes.remainder(60)}m",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
