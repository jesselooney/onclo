import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'extensions/date_time_extensions.dart';
import 'database.dart';
import 'package:onclo_mobile/models/activity.dart';

void main() {
  runApp(
    Provider<AppDatabase>(
      create: (context) => AppDatabase(),
      child: MyApp(),
      dispose: (context, db) => db.close(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: _SessionsEndsView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: Center(
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      onSubmitted: (String activityString) {
                        final activity = Activity(activityString);
                        if (!activity.name.isEmpty) {
                          final db = Provider.of<AppDatabase>(context, listen: false);
                          db.endSessionNow(activity);
                        }
                        Navigator.pop(context);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "search me",
                      ),
                    ),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        Container(child: const Text("option one")),
                        Container(child: const Text("option two")),
                      ]
                    ),
                    ElevatedButton(
                      child: const Text("close"),
                      onPressed: () => Navigator.pop(context)
                    )
                  ]
                )
              )
            )
          );
        },
        tooltip: 'Add Session',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Track Time",
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_sharp),
            label: "Analyze Time",
          )
        ]
      ),
    );
  }
}

class _SessionsEndsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return StreamBuilder(
      initialData: [],
      stream: db.watchSessionEnds,
      builder: (context, snapshot) {
        // TODO: correctly handle the case where there is no data
        final sessionEnds = snapshot.requireData;

        // TODO: is there a better way to build a ListView when the
        // items already have their own IDs?
        // TODO: it is maybe inefficient to rebuild the ListView every time
        // anything changes. Plus, we are not actually taking advantage of the
        // lazy-loading capabilities since we could precompute every widget from
        // the SessionEnd list we have already.
        // TODO: Using separators doesn't really work since they are only placed
        // between items, meaning we won't have one showing the day of the first
        // day of items.
        return ListView.separated(
          reverse: true,
          shrinkWrap: true,
          itemCount: sessionEnds.length,
          itemBuilder: (context, index) {
            final SessionEnd sessionEnd = sessionEnds[index];

            return ListTile(
              leading: FilledButton(
                child: Text(DateFormat.Hm().format(sessionEnd.endDate)),
                onPressed: () => showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(sessionEnd.endDate),
                ).then((timeOfDay) {
                  if (timeOfDay != null) {
                    db.updateSessionEndTimeOfDay(sessionEnd, timeOfDay);
                  }
                }),
              ),
              title: Text(sessionEnd.activity.name),
            );
          },
          separatorBuilder: (context, index) {
            final SessionEnd sessionEnd = sessionEnds[index];
            // if (sameDay(sessionEnds[index], sessionEnds[index + 1]))
            //     dontShowSeparator(); // still need to return a widget
            return ListTile(
              title: Text(sessionEnd.endDate.toString()),
            );
          },
        );
      }
    );
  }
}

