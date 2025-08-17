import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:onclo/database.dart';
import 'package:onclo/models/models.dart';

// Shows a modal bottom sheet containing an [ActivityPicker].
//
// The returned [Future] resolves to the [Activity] picked by the user, or null
// if the user closed the bottom sheet.
Future<Activity?> showActivityPicker({required BuildContext context}) async {
  final result = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(padding: EdgeInsets.all(16.0), child: ActivityPicker()),
    ),
  );
  assert(result is Activity?);
  return result;
}

class ActivityPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          autofocus: true,
          onSubmitted: (String activityName) {
            final activity = Activity(activityName);
            Navigator.pop(context, activity.name.isEmpty ? null : activity);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter an activity",
          ),
        ),
        ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: const Text("option one")),
            ListTile(title: const Text("option two")),
          ],
        ),
      ],
    ),
  );
}
