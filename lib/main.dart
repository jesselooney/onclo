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
              child: DaysView(),
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
                        hintText: "search me",
                      ),
                    ),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        Container(child: const Text("option one")),
                        Container(child: const Text("option two")),
                      ],
                    ),
                    ElevatedButton(
                      child: const Text("close"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
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
    );
  }
}

class DaysView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final today = DateTime.now();

    // TODO: compute dynamically
    final itemCount = 100;

    return ListView.builder(
      reverse: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return DayView(db: db, day: today.subtract(Duration(days: index)));
      }
    );
  }
}

class DayView extends StatefulWidget {
  final AppDatabase db;
  final DateTime day;

  const DayView({super.key, required this.db, required this.day});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late Stream<List<SessionEnd>> sessionEndsStream;

  @override
  void initState() {
    super.initState();
    sessionEndsStream = this.widget.db.watchSessionEndsOnDay(this.widget.day);
  }

  @override
  void didUpdateWidget(covariant DayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    sessionEndsStream = this.widget.db.watchSessionEndsOnDay(this.widget.day);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: [],
      stream: sessionEndsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.requireData.isEmpty) {
          return Column(children: []);
        }

        final sessionEnds = snapshot.requireData;

        return Column(
          children: [
            ListTile(title: Text(this.widget.day.toString())),
            ListView.builder(
              reverse: true,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessionEnds.length,
              itemBuilder: (context, index) {
                final sessionEnd = sessionEnds[index];
                return SessionView(
                  key: ValueKey(sessionEnd.id),
                  sessionEnd: sessionEnd,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class TextFieldDialog extends StatefulWidget {
  final String title;
  final String initialText;
  final bool autofocus;
  final bool autoselect;

  const TextFieldDialog({super.key, required this.title, this.initialText = '', this.autofocus = false, this.autoselect = false});

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = this.widget.initialText;
    if (this.widget.autoselect) {
      controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.widget.title),
      content: TextField(
        controller: controller,
        autofocus: this.widget.autofocus,
        onSubmitted: (newText) {
          Navigator.pop(context, newText);
        },
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        TextButton(
          child: const Text('Submit'),
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
        ),
      ]
    );
  }
}


class SessionView extends StatelessWidget {
  final SessionEnd sessionEnd;

  const SessionView({super.key, required this.sessionEnd});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Dismissible(
      key: ValueKey(sessionEnd.id),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // WARN: showDialog is not type safe.
          final String? newNote = await showDialog(context: context, builder: (context) {
            return TextFieldDialog(title: 'New session note', initialText: sessionEnd.note, autofocus: true, autoselect: true);
          });

          if (newNote != null) {
            final newSessionEnd = sessionEnd.copyWith(note: newNote);
            db.update(db.sessionEnds).replace(newSessionEnd);
          }

          return false;
        }

        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete session?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ]
            );
          }
        );
      },

      onDismissed: (direction) {
        db.delete(db.sessionEnds).delete(sessionEnd);
      },

      background: const ColoredBox(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      secondaryBackground: const ColoredBox(
        color: Colors.green,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),

      child: ListTile(
        leading: FilledButton(
          child: Text(DateFormat.Hm().format(sessionEnd.endDate)),
          onPressed: () =>
              showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(sessionEnd.endDate),
              ).then((timeOfDay) {
                if (timeOfDay != null) {
                  db.updateSessionEndTimeOfDay(sessionEnd, timeOfDay);
                }
              }),
        ),
        title: Text(sessionEnd.activity.name),
        trailing: Text(sessionEnd.note),
      ),
    );
  }
}
