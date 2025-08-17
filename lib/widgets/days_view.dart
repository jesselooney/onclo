import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:onclo_mobile/database.dart';
import 'package:onclo_mobile/extensions/extensions.dart';

import 'day_view.dart';

class DaysView extends StatelessWidget {
  final DateTime firstDate;
  final ItemScrollController? itemScrollController;

  const DaysView({
    super.key,
    required this.firstDate,
    this.itemScrollController,
  });

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final today = DateTime.now().atStartOfDay;
    // TODO: Make this safe against time shenanigans.
    final itemCount = today.difference(firstDate).inDays + 1;

    return ScrollablePositionedList.builder(
      reverse: true,
      itemCount: itemCount,
      itemScrollController: itemScrollController,
      itemBuilder: (context, index) {
        // TODO: Make this safe against daylight savings. Days shorter or
        // longer than 24 hours might be skipped or double-rendered using this
        // method.
        return DayView(
          db: db,
          day: today.subtract(Duration(days: index)),
        );
      },
    );
  }
}
