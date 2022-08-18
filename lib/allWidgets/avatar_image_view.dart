import 'package:flutter/material.dart';
class AvatarImageView extends StatelessWidget {
  final String assetImage;
  final VoidCallback voidCallBack;
  const AvatarImageView({required this.assetImage,required this.voidCallBack,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: voidCallBack,
      child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
      ),
        child: ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(assetImage),
        )
      ),
    );
  }
}
