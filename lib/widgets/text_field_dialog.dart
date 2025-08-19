import 'package:flutter/material.dart';

/// Displays a dialog containing a [TextFieldDialog].
///
/// The resulting [Future] resolves to the string the user submitted, whether
/// they modified the `initialText` or not, or null if the user canceled the
/// dialog.
Future<String?> showTextFieldDialog({
  required BuildContext context,
  required String title,
  String initialText = '',
  bool autofocus = false,
  bool autoselect = false,
}) async {
  final result = await showDialog(
    context: context,
    builder: (context) => TextFieldDialog(
      title: title,
      initialText: initialText,
      autofocus: autofocus,
      autoselect: autoselect,
    ),
  );
  assert(result is String?);
  return result;
}

/// A dialog allowing the user to edit a [TextField].
///
/// Usually displayed by calling [showTextFieldDialog].
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
    controller.text = widget.initialText;

    if (widget.autoselect) {
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
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: controller,
      autofocus: widget.autofocus,
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
