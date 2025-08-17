import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:onclo_mobile/database.dart';
import 'package:onclo_mobile/models/models.dart';

import 'session_detail_view.dart';
import 'text_field_dialog.dart';

class SessionView extends StatelessWidget {
  final SessionEnd sessionEnd;

  const SessionView({super.key, required this.sessionEnd});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Dismissible(
      key: ValueKey(sessionEnd.id),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // WARN: showDialog is not type safe.
          final String? newNote = await showDialog(
            context: context,
            builder: (context) {
              return TextFieldDialog(
                title: 'New session note',
                initialText: sessionEnd.note,
                autofocus: true,
                autoselect: true,
              );
            },
          );

          if (newNote != null) {
            final newSessionEnd = sessionEnd.copyWith(note: newNote);
            db.update(db.sessionEnds).replace(newSessionEnd);
          }

          return false;
        }

        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete session?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        );
      },

      onDismissed: (direction) {
        db.delete(db.sessionEnds).delete(sessionEnd);
      },

      background: const ColoredBox(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      secondaryBackground: const ColoredBox(
        color: Colors.green,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),

      child: ListTile(
        leading: FilledButton(
          child: Text(DateFormat.Hm().format(sessionEnd.endDate)),
          onPressed: () =>
              showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(sessionEnd.endDate),
              ).then((timeOfDay) {
                if (timeOfDay != null) {
                  db.updateSessionEndTimeOfDay(sessionEnd, timeOfDay);
                }
              }),
        ),
        title: Text.rich(
          TextSpan(
            text: sessionEnd.activity.name,
            children: sessionEnd.note.isEmpty
                ? []
                : [
                    TextSpan(text: ' • '),
                    TextSpan(
                      text: sessionEnd.note,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
          ),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () async {
          final session = await db.getSessionFromSessionEnd(sessionEnd);

          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) =>
                SessionDetailView(session: session),
          );
        },
        onLongPress: () async {
          // WARN: showDialog is not type safe.
          final String? newActivityName = await showDialog(
            context: context,
            builder: (context) {
              return TextFieldDialog(
                title: 'Edit activity',
                initialText: sessionEnd.activity.name,
                autofocus: true,
                autoselect: true,
              );
            },
          );

          if (newActivityName != null) {
            final newSessionEnd = sessionEnd.copyWith(
              activity: Activity(newActivityName),
            );
            db.update(db.sessionEnds).replace(newSessionEnd);
          }
        },
      ),
    );
  }
}
