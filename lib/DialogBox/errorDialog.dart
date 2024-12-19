import 'package:flutter/material.dart';
import 'package:simple_irrigation_system/widgets/Colord.dart';

class ErrorAlertDialog extends StatelessWidget {
  final String message;
  const ErrorAlertDialog({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(
        message,
        style: const TextStyle(
          color: CustomColors.PrimaryColor,
        ),
        textAlign: TextAlign.end,
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Center(
            child: Text(
              "حسنا",
            ),
          ),
        )
      ],
    );
  }
}
