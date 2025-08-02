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
            _SessionsEndsView(),
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
                        final db = Provider.of<AppDatabase>(context, listen: false);
                        // TODO: Extract this query to DB class.
                        db.into(db.sessionEnds).insert(
                          SessionEndsCompanion.insert(
                            endDate: DateTime.now(),
                            activity: Activity(activityString),
                            note: '',
                          )
                        );
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
        return ListView.builder(
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
                ).then((time) {
                  if (time != null) {
                    // TODO: extract this query to DB class
                    // TODO: changing time should yield the nearest date
                    // with that time of day (e.g. 01:00 -> 23:00 should
                    // yield a datetime on the previous day). *Maybe* add
                    // an option for moving activities further distances
                    // or to an exact day and time.
                    final updatedSessionEnd = sessionEnd.copyWith(
                      endDate: sessionEnd.endDate.atTimeOfDay(time),
                    );
                    db.update(db.sessionEnds).replace(updatedSessionEnd);
                  }
                }),
              ),
              title: Text(sessionEnd.activity.name),
            );
          },
        );
      }
    );
  }
}

//class _SessionListView extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    final sessionList = context.watch<SessionList>();
//
//    return ListView.builder(
//      shrinkWrap: true,
//      itemCount: sessionList.sessions.length,
//      itemBuilder: (context, index) => ListTile(
//        leading: FilledButton(
//          child: Text(DateFormat.Hm().format(sessionList.sessions[index].endDate)),
//          onPressed: () => showTimePicker(
//            context: context,
//            initialTime: TimeOfDay.fromDateTime(sessionList.sessions[index].endDate),
//          ).then((time) { if (time != null) sessionList.changeEndTime(index, time); }),
//        ),
//        title: Text(sessionList.sessions[index].activity + sessionList.sessions[index].startDate.toString()),
//      ),
//    );
//  }
//}
