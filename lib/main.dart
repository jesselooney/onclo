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
  Widget build(BuildContext context) => MaterialApp(
    title: 'Onclo (Alpha)',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    ),
    home: TrackingPage(db: Provider.of<AppDatabase>(context)),
  );
}

class TrackingPage extends StatefulWidget {
  final AppDatabase db;

  const TrackingPage({super.key, required this.db});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final ItemScrollController scrollController = ItemScrollController();
  final DateTime defaultFirstDay = DateTime.now().atStartOfDay;
  late final Stream<DateTime> firstDayStream;

  @override
  void initState() {
    super.initState();
    firstDayStream = widget.db.watchFirstEndDate().map(
      (firstEndDate) => (firstEndDate ?? defaultFirstDay).atStartOfDay,
    );
  }

  Widget buildJumpToDayAction({required DateTime firstDay}) => IconButton(
    icon: const Icon(Icons.calendar_month),
    onPressed: () async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: firstDay,
        lastDate: DateTime.now(),
      );

      // If the user canceled the dialog, do nothing.
      if (pickedDate == null) return;

      // Use the number of days between now and the desired date as the index
      // to jump to. Due to DateTime shenanigans, we may get the wrong number
      // of days, but it will be close enough.
      final daysBetween = DateTime.now().difference(pickedDate).inDays;
      scrollController.jumpTo(index: daysBetween);
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

  Widget buildNavigationBar() => NavigationBar(
    destinations: [
      NavigationDestination(icon: Icon(Icons.punch_clock), label: "Track Time"),
      NavigationDestination(icon: Icon(Icons.bar_chart), label: "Analyze Time"),
    ],
  );

  @override
  Widget build(BuildContext context) => StreamBuilder(
    initialData: defaultFirstDay,
    stream: firstDayStream,
    builder: (context, snapshot) => Scaffold(
      appBar: AppBar(
        title: Text('Track Time'),
        actions: snapshot.hasData
            ? [buildJumpToDayAction(firstDay: snapshot.requireData)]
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
                      itemScrollController: scrollController,
                    )
                  : Container(),
            ),
          ],
        ),
      ),
      floatingActionButton: buildFab(),
      bottomNavigationBar: buildNavigationBar(),
    ),
  );
}
