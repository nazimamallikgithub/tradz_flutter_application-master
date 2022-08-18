import 'package:flutter/material.dart';
class TextButtonView extends StatelessWidget {
  final String text;
  final VoidCallback voidCallback;
  const TextButtonView({Key? key,required this.text,required this.voidCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: voidCallback,
        child: Text(text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0
        ),)
    );
  }
}
