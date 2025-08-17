import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:onclo/database.dart';
import 'package:onclo/extensions/extensions.dart';
import 'package:onclo/models/models.dart';
import 'package:onclo/widgets/widgets.dart';

/// A widget that renders the time-tracking page.
class TrackingPage extends StatefulWidget {
  final AppDatabase db;

  const TrackingPage({super.key, required this.db});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final ItemScrollController scrollController = ItemScrollController();
  final DateTime defaultFirstDay = DateTime.now().atStartOfDay;

  /// A stream whose values are the first day on which there is a [SessionEnd].
  ///
  /// In this case, "day" indicates that the DateTimes are rounded down to the,
  /// start of the day on which they fall, since we only care about the day and
  /// not the hour, minute, or lower units.
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
    onPressed: () async {
      final activity = await showActivityPicker(context: context);
      if (activity != null) widget.db.endSessionNow(activity);
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
