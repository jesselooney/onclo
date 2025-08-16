import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'widgets/days_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'models/activity.dart';
import 'extensions/date_time_extensions.dart';

void main() {
  runApp(
    Provider<AppDatabase>(
      create: (context) => AppDatabase(),
      child: MyApp(),
      dispose: (context, db) => db.close(),
    ),
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
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        db: Provider.of<AppDatabase>(context),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.db});

  final String title;
  final AppDatabase db;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  late final Future<DateTime> future;

  @override
  void initState() {
    super.initState();
    // TODO: Ideally this value is reactive -> streambuilder?
    future = this.widget.db.earliestEndDate.then(
      (date) => (date ?? DateTime.now()).atStartOfDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: snapshot.hasData
              ? [
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        firstDate: snapshot.requireData,
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate == null) return;
                      // WARN: This value is probably not always right.
                      final daysBetween = DateTime.now()
                          .difference(pickedDate)
                          .inDays;
                      itemScrollController.jumpTo(index: daysBetween);
                    },
                  ),
                ]
              : [],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: snapshot.hasData
                    ? DaysView(
                        firstDate: snapshot.requireData,
                        itemScrollController: itemScrollController,
                      )
                    : Container(),
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
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          autofocus: true,
                          onSubmitted: (String activityString) {
                            final activity = Activity(activityString);
                            if (!activity.name.isEmpty) {
                              final db = Provider.of<AppDatabase>(
                                context,
                                listen: false,
                              );
                              db.endSessionNow(activity);
                            }
                            Navigator.pop(context);
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
                  ),
                ),
              ),
            );
          },
          tooltip: 'Add Session',
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.home), label: "Track Time"),
            NavigationDestination(
              icon: Icon(Icons.notifications_sharp),
              label: "Analyze Time",
            ),
          ],
        ),
      ),
    );
  }
}
