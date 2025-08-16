import 'package:flutter/material.dart';

class TextFieldDialog extends StatefulWidget {
  final String title;
  final String initialText;
  final bool autofocus;
  final bool autoselect;

  const TextFieldDialog({
    super.key,
    required this.title,
    this.initialText = '',
    this.autofocus = false,
    this.autoselect = false,
  });

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
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
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
      ],
    );
  }
}
