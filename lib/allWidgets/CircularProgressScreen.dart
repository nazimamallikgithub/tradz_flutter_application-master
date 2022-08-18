import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';

class CircularProgressScreen extends StatefulWidget
{

  const CircularProgressScreen({Key? key}) : super(key: key);

  CircularState createState()=> CircularState();
}

class CircularState extends State<CircularProgressScreen>
{
  @override
  Widget build(BuildContext context)
  {
    // TODO: implement build
    return Center(
      child:  CircleAvatar(
        // backgroundColor: Colors.white,
        radius:MediaQuery.of(context).size.width/15,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}