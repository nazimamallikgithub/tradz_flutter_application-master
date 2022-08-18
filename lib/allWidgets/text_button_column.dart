import 'package:flutter/material.dart';
class TextButtonColumn extends StatelessWidget {
  final VoidCallback voidCallback;
  final Icon icon;
  final String text;
  const TextButtonColumn({Key? key,required this.voidCallback,required this.icon,required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: voidCallback,
        child: Column(
          children: <Widget>[
            icon,
            Text(text)
          ],
        ));
  }
}
