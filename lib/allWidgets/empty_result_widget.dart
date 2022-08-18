import 'package:flutter/material.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
class EmptyResultWidget extends StatelessWidget {
  final String message;
  const EmptyResultWidget(this.message,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
         // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,color: ConstantColors.primaryDarkColor,),
            Text(message,
              style: const TextStyle(
                color: ConstantColors.primaryColor,
                fontWeight: FontWeight.w500
              ),),
          ],
        ),
      ),
    );
  }
}
