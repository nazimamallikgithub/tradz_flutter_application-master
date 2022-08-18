import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
class LoginButton extends StatelessWidget {
  final String imagePath, textTitle;
  final  VoidCallback navigateCallBack;

  const LoginButton(
      {Key? key,
        required this.imagePath,
        required this.textTitle,
        required this.navigateCallBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            ConstantColors.loginButtonColor,
          ),
        ),
        onPressed: navigateCallBack,
        icon: Align(
          alignment: Alignment.centerLeft,
          child: SvgPicture.asset(
            imagePath,
            height: 24.0,
            width: 24.0,
          ),
        ),
        label: Text(
          textTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ));
  }
}