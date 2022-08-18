import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ZoomableDialog extends StatelessWidget
{
  ZoomableDialog( {required this.networkImage,required this.assetImage,Key? key}) : super(key: key);
  String networkImage;
  String assetImage;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        child: Stack(
          children:<Widget>[
            assetImage.isNotEmpty?
                PhotoView(imageProvider: AssetImage(assetImage),
                  backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                )
            :PhotoView(
              imageProvider: MemoryImage(base64Decode(networkImage)),
              backgroundDecoration: const BoxDecoration(color: Colors.transparent),
            ),
            Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: const Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

}