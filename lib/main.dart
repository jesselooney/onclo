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
      child: App(),
      dispose: (context, db) => db.close(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onclo (Alpha)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: TrackingPage(db: Provider.of<AppDatabase>(context)),
    );
  }
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key, required this.db});

  final AppDatabase db;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  late final Future<DateTime> firstDateFuture;

  @override
  void initState() {
    super.initState();
    // TODO: Ideally this value is reactive -> streambuilder?
    firstDateFuture = this.widget.db.earliestEndDate.then(
      (date) => (date ?? DateTime.now()).atStartOfDay,
    );
  }

  Widget buildJumpToDayAction(
    DateTime firstDate,
    ItemScrollController itemScrollController,
  ) => IconButton(
    icon: const Icon(Icons.calendar_month),
    onPressed: () async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: firstDate,
        lastDate: DateTime.now(),
      );
      if (pickedDate == null) return;
      // WARN: This value is probably not always right.
      final daysBetween = DateTime.now().difference(pickedDate).inDays;
      itemScrollController.jumpTo(index: daysBetween);
    },
  );

  Widget buildFab() => FloatingActionButton(
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
  );

  Widget buildNavigationBar(BuildContext context) => NavigationBar(
    destinations: [
      NavigationDestination(icon: Icon(Icons.punch_clock), label: "Track Time"),
      NavigationDestination(icon: Icon(Icons.bar_chart), label: "Analyze Time"),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firstDateFuture,
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          title: Text('Track Time'),
          actions: snapshot.hasData
              ? [
                  buildJumpToDayAction(
                    snapshot.requireData,
                    itemScrollController,
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
        floatingActionButton: buildFab(),
        bottomNavigationBar: buildNavigationBar(context),
      ),
    );
  }
}
