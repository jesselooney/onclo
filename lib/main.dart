import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:collection';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SessionsModel(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
  bool _isAddingSession = false;

  final textInputController = TextEditingController();

  @override dispose() {
    textInputController.dispose();
    super.dispose();
  }

  void _setIsAddingSession() {
    setState(() {
      _isAddingSession = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _SessionList()
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
                      onSubmitted: (String activityName) {
                        Provider.of<SessionsModel>(context, listen: false).finishActivity(activityName);
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
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

class Session {
  final String activity;
  final DateTime startDate;
  final DateTime endDate;
  Session({required this.activity, required this.startDate, required this.endDate});

  // FIXME: prevent invalid states (endDate < startDate)
  update({String? activity, DateTime? startDate, DateTime? endDate}) {
    return Session(
      activity: activity ?? this.activity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class SessionsModel extends ChangeNotifier {
  final List<Session> _sessions = [
    Session(activity: "one", startDate: DateTime.utc(2025, 1, 1, 6, 15, 0), endDate: DateTime.utc(2025, 1, 1, 6, 25, 0)),
    Session(activity: "two", startDate: DateTime.utc(2025, 1, 1, 6, 25, 0), endDate: DateTime.utc(2025, 1, 1, 6, 35, 0)),
  ];

  UnmodifiableListView<Session> get sessions => UnmodifiableListView(_sessions);

  void _add(Session session) {
    _sessions.add(session);
    notifyListeners();
  }

  void finishActivity(String activity) {
    // FIXME: last is unsafe!
    _add(Session(activity: activity, startDate: _sessions.last.endDate, endDate: DateTime.now()));
  }

  DateTime _withTimeOfDay(DateTime dateTime, TimeOfDay timeOfDay) {
    // TODO: currently this drops the seconds and lower units. Is this desired?
    return DateTime(dateTime.year, dateTime.month, dateTime.day, timeOfDay.hour, timeOfDay.minute);
  }

  void changeEndTime(int index, TimeOfDay time) {
    // FIXME: what if index out of range?
    // FIXME: what if new time is before the session's startDate? What if it is later than the next session's endDate?
    final newEndDate = _withTimeOfDay(_sessions[index].endDate, time);
    _sessions[index] = _sessions[index].update(endDate: newEndDate);
    // Maintain the invariant that each session starts when the previous one ends.
    if (index + 1 < _sessions.length)
      _sessions[index + 1] = _sessions[index + 1].update(startDate: newEndDate);
    notifyListeners();
  }
}

class _SessionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var sessionsModel = context.watch<SessionsModel>();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: sessionsModel.sessions.length,
      itemBuilder: (context, index) => ListTile(
        leading: FilledButton(
          child: Text(DateFormat.Hm().format(sessionsModel.sessions[index].endDate)),
          onPressed: () => showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(sessionsModel.sessions[index].endDate),
          ).then((time) { if (time != null) sessionsModel.changeEndTime(index, time); }),
        ),
        title: Text(sessionsModel.sessions[index].activity),
      ),
    );
  }
}
