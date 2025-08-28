import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:onclo/database.dart';
import 'package:onclo/extensions/extensions.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("Options")),
    body: Center(
      child: Column(
        children: [
          TextButton(
            child: Text("Export data"),
            onPressed: () async {
              // WARN: This works, but on Android there is no option to "share" the file
              // into Files. We need to use file_picker I think.
              SharePlus.instance.share(
                ShareParams(files: [XFile(await AppDatabase.databasePath())]),
              );
            },
          ),
          TextButton(child: Text("Import data"), onPressed: () {}),
        ],
      ),
    ),
  );
}
