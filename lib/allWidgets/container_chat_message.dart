import 'package:flutter/material.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
class ContainerChatMessage extends StatelessWidget {
  final String message;
  const ContainerChatMessage(this.message,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(message,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500
        ),),
      width: MediaQuery.of(context).size.width.toDouble(),
      padding: const EdgeInsets.all(16.0),
      color: ConstantColors.primaryColor,
      alignment: Alignment.center,
    );
  }
}
