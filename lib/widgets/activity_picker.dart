import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:onclo/database.dart';
import 'package:onclo/models/models.dart';

class ActivitySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          autofocus: true,
          onSubmitted: (String activityString) {
            final activity = Activity(activityString);
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
