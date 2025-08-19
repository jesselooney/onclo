import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:onclo/database.dart';
import 'package:onclo/models/models.dart';
import 'package:onclo/widgets/session_detail_view.dart';
import 'package:onclo/widgets/text_field_dialog.dart';

/// A widget displaying a [SessionEnd] as a [ListTile].
class SessionEndView extends StatelessWidget {
  final SessionEnd sessionEnd;

  const SessionEndView({super.key, required this.sessionEnd});

  Widget buildListTile({required BuildContext context}) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    return ListTile(
      leading: FilledButton.tonal(
        child: Text(DateFormat.Hm().format(sessionEnd.endDate)),
        onPressed: () async {
          final newTimeOfDay = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(sessionEnd.endDate),
          );
          // If the user picked a time, update the end time of `sessionEnd`.
          if (newTimeOfDay != null) {
            db.updateSessionEndTimeOfDay(sessionEnd, newTimeOfDay);
          }
        },
      ),

      title: Text.rich(
        TextSpan(
          text: sessionEnd.activity.name,
          // Show `sessionEnd`'s `note` in a different style, but only if it is
          // nonempty.
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

      // Open a detailed view of the represented Session on tap.
      onTap: () async {
        final session = await db.getSessionFromSessionEnd(sessionEnd);

        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) =>
              SessionDetailView(session: session),
        );
      },

      // Open a [TextFieldDialog] to edit the session end's activity on long press.
      onLongPress: () async {
        final newActivityName = await showTextFieldDialog(
          context: context,
          title: 'Edit activity',
          initialText: sessionEnd.activity.name,
          autofocus: true,
          autoselect: true,
        );

        // If the user entered and confirmed a different activity name than the
        // existing one, update `sessionEnd`.
        if (newActivityName != null &&
            newActivityName != sessionEnd.activity.name) {
          final newActivity = Activity(newActivityName);

          // Prevent empty activity names.
          // TODO: We should give user feedback for this.
          // TODO: We should enforce this constraint further downstream rather
          // than in every place one can enter/modify activities.
          if (newActivity.name.isEmpty) return;

          final newSessionEnd = sessionEnd.copyWith(activity: newActivity);
          db.update(db.sessionEnds).replace(newSessionEnd);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);

    return Dismissible(
      key: ValueKey(sessionEnd.id),

      child: buildListTile(context: context),

      // Show a dialog when the user swipes this widget.
      confirmDismiss: (direction) async {
        // If the user swiped left, show a dialog for editing the session end's
        // `note` field.
        if (direction == DismissDirection.endToStart) {
          final String? newNote = await showTextFieldDialog(
            context: context,
            title: 'Edit session note',
            initialText: sessionEnd.note,
            autofocus: true,
            autoselect: true,
          );

          // If the user did not cancel the dialog, update `sessionEnd`.
          if (newNote != null) {
            final newSessionEnd = sessionEnd.copyWith(note: newNote.trim());
            db.update(db.sessionEnds).replace(newSessionEnd);
          }

          // Return false unconditionally to indicate we do not confirm the
          // dismissal. Otherwise, the component will show a deletion
          // animation that removes this widget from view.
          return false;
        }

        // Otherwise, the user swiped right, so we ask them to confirm whether,
        // they wish to delete `sessionEnd`.
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

      // Once the user confirms a deletion and the widget animates away,
      // actually delete the `sessionEnd`.
      onDismissed: (direction) {
        db.delete(db.sessionEnds).delete(sessionEnd);
      },

      // The background for swipes to the right (deletions).
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

      // The background for swipes to the left (note edits).
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
    );
  }
}
