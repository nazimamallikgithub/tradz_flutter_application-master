import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:translator/translator.dart';

import 'helper_widget.dart';
class CategoryViewWidget extends StatefulWidget {
  String imageBlob,categoryText;
  CategoryViewWidget({
    Key? key,
    required this.imageBlob,
    required this.categoryText
  }) : super(key: key);

  @override
  State<CategoryViewWidget> createState() => _CategoryViewWidgetState();
}

class _CategoryViewWidgetState extends State<CategoryViewWidget> {
  final translator = GoogleTranslator();
  @override
  void initState() {
    print("the category initstate gets called");
    getTranslation();
    super.initState();
  }
  Future<void> getTranslation()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? locale = prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale!="en")
          {
            await translator.translate(widget.categoryText,to:locale).then((value)
            {
              print("The value after translate in category widget.categoryText is $value");
              if(!mounted)return;
              setState(() {
                widget.categoryText=value.toString();
              });
            });
          }
      }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.imageBlob.isNotEmpty?
        Image.memory(base64Decode(widget.imageBlob),fit: BoxFit.cover,)
            :SvgPicture.asset(
          'assets/images/electric_motor_icon.svg',
          height: 48.0,
          width: 48.0,
        ),
        addVerticalSpace(
            4.0
        ),
        Expanded(
            child: Text(
              widget.categoryText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: ConstantColors.primaryColor),
            )),
      ],
    );
  }
}
