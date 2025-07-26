import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'models/session.dart';
import 'models/session_list.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SessionList(),
      child: const MyApp(),
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
            _SessionListView()
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
                        Provider.of<SessionList>(context, listen: false).endActivity(activityName);
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

class _SessionListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sessionList = context.watch<SessionList>();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: sessionList.sessions.length,
      itemBuilder: (context, index) => ListTile(
        leading: FilledButton(
          child: Text(DateFormat.Hm().format(sessionList.sessions[index].endDate)),
          onPressed: () => showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(sessionList.sessions[index].endDate),
          ).then((time) { if (time != null) sessionList.changeEndTime(index, time); }),
        ),
        title: Text(sessionList.sessions[index].activity + sessionList.sessions[index].startDate.toString()),
      ),
    );
  }
}
