import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:onclo/database.dart';
import 'package:onclo/pages/pages.dart';

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
    home: TrackingPage(db: Provider.of<AppDatabase>(context, listen: false)),
  );
}
