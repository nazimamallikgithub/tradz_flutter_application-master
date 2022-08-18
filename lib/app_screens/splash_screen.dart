import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/app_screens/login_screen.dart';
import 'package:tradz/app_screens/main_screen.dart';
import 'package:tradz/app_screens/profile_screen.dart';
class SplashScreen extends StatefulWidget
{
  const SplashScreen({Key? key}) : super(key: key);

@override
  SplashScreenState createState()=> SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 5),(){
      checkSignedIn();
    });
  }

  void checkSignedIn() async{
    bool isLoggedIn=false;
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? googleToken=prefs.getString(Strings.google_token);
    print("The google token is $googleToken");
    String? location=prefs.getString(Strings.location);
    if(googleToken!=null){
      isLoggedIn=true;
    }


    if(isLoggedIn)
      {
        if(location!=null)
          {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext)=>MainScreen()));
          }
        else{
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext)=>const ProfileScreen(isAppBarVisible: true)));
        }
      }
    else{
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext)=>const LoginScreen()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: ConstantColors.primaryColor,
        child:  Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/ic_app_icon.png',width: MediaQuery.of(context).size.width*0.25,),
                addVerticalSpace(8.0),
                Text(Strings.app_tagLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                  color: ConstantColors.primaryDarkColor
                ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}