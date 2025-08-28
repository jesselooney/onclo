import 'package:flutter/material.dart';

import 'package:onclo/database.dart';
import 'package:onclo/extensions/extensions.dart';

class OptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("Options")),
    body: Center(
      child: Column(
        children: [
          TextButton(child: Text("Export data"), onPressed: () {}),
          TextButton(child: Text("Import data"), onPressed: () {}),
        ],
      ),
    ),
  );
}
