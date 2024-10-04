import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_irrigation_system/widgets/Colord.dart';

class LoadingAlertDialog extends StatelessWidget {
  final String? message;
  const LoadingAlertDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(
            height: 10,
          ),
          Text(
            message!,
            style: const TextStyle(
              color: CustomColors.PrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
