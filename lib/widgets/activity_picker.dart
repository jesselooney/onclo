import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:onclo/database.dart';
import 'package:onclo/models/models.dart';

// Shows a modal bottom sheet containing an [ActivityPicker].
//
// The returned [Future] resolves to the [Activity] picked by the user, or null
// if the user closed the bottom sheet without picking an activity.
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

/// A widget that allows picking an [Activity] by search or manual input.
///
/// This widget is usually displayed by calling [showActivityPicker].
class ActivityPicker extends StatelessWidget {
  final List<Activity> activitySuggestions = [
    Activity('sleep'),
    Activity('prep morning'),
    Activity('eat lunch'),
    Activity('eat dinner'),
    Activity('rest'),
    Activity('prep night'),
  ];

  List<Widget> buildListTiles({required BuildContext context}) =>
      activitySuggestions
          .map(
            (activity) => ListTile(
              title: Text(activity.name),
              onTap: () {
                Navigator.pop(context, activity);
              },
            ),
          )
          .toList();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8.0,
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
        Expanded(child: ListView(children: buildListTiles(context: context))),
      ],
    ),
  );
}
