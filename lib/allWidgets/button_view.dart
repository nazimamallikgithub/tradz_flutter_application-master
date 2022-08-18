import 'package:flutter/material.dart';
class ButtonView extends StatelessWidget {
  final String text;
  final VoidCallback clickButton;
  final bool isButtonEnabled;
  const ButtonView({Key? key,required this.text,required this.clickButton,required this.isButtonEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
      onPressed: isButtonEnabled?clickButton:null,
      child: Text(text),);
  }
}
