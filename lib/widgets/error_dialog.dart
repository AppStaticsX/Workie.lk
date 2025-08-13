import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../values/dimension.dart';

class ErrorDialog extends StatelessWidget {
  final List<Widget> actions;
  final String title;
  final String contentText;
  final String? contentText2;
  final String? contentText3;
  final String? contentText4;
  final String? contentText5;

  const ErrorDialog({
    super.key,
    required this.actions,
    required this.title,
    required this.contentText,
    this.contentText2,
    this.contentText3,
    this.contentText4,
    this.contentText5
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: AppDimension.paddingDefault),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            children: [
              TextSpan(
                  text: contentText),
              TextSpan(
                text: contentText2,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: contentText3,
                  style: TextStyle(
                  )),
              TextSpan(
                text: contentText4,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: contentText5),
            ],
          ),
        ),
      ),
      actions: actions,
    );
  }
}
