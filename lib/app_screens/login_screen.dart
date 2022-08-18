import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Constant/Constant.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allMethods/Methods.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/allWidgets/login_button.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/main_screen.dart';
import 'package:tradz/app_screens/profile_screen.dart';
import 'package:tradz/model/token_model.dart';
import 'package:tradz/model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? backButtonPressTime;
  static const snackBarDuration = Duration(seconds: 3);
  bool _isProgressBar = false;

  String noInternetMessage = Strings.noInternetMessage;
  bool _isInternet = false;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;

  @override
  void initState() {
    authProvider= context.read<AuthProvider>();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    checkInternet();
    super.initState();
  }

  @override
  void dispose() {
    Fluttertoast.cancel();
    super.dispose();
  }

  checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _isInternet = false;
          print("insternet becomes if " + _isInternet.toString());
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _isInternet = true;
        _isProgressBar = false;
      });
    }
  }

  Future<bool> checkInternetFromWithinWidgets() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _isInternet = false;
          print("insternet becomes if " + _isInternet.toString());
        });
      }
      return true;
    } on SocketException catch (_) {
      setState(() {
        _isInternet = true;
        _isProgressBar = false;
        print("insternet becomes exception " + _isInternet.toString());
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //GoogleAuth
    // AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        //  Fluttertoast.showToast(msg: Strings.signInFailedMessage);
        break;
      case Status.authenticateCanceled:
        //  Fluttertoast.showToast(msg: Strings.signInCancel);
        break;
      case Status.authenticated:
        break;
      case Status.uninitialized:
        // TODO: Handle this case.
        break;
      case Status.authenticating:
        // TODO: Handle this case.
        break;
    }

    // FacebookLoginProvider facebookLoginProvider =
    //     Provider.of<FacebookLoginProvider>(context);

    Future<bool> _onBackPressed() async {
      DateTime currentTime = DateTime.now();
      bool backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
          backButtonPressTime == null ||
              currentTime.difference(backButtonPressTime!) > snackBarDuration;

      if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
        backButtonPressTime = currentTime;
        Fluttertoast.showToast(msg: 'Press back again to leave!');
        return Future.value(false);
      }
      //SystemNavigator.pop();
      exit(0);
      return Future.value(true);
    }

    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    color: ConstantColors.primaryColor,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/ic_app_icon.png',
                            height: MediaQuery.of(context).size.height * 0.15,
                          ),
                          addVerticalSpace(8.0),
                          Text(
                            Strings.app_tagLine,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                color: ConstantColors.primaryDarkColor),
                          )
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width.toDouble(),
                      height: MediaQuery.of(context).size.height.toDouble(),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 24.0, left: 16.0, right: 16.0, bottom: 16.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              Strings.new_login_title_text,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            addVerticalSpace(10.0),
                            Text(Strings.loginSubTitle),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  LoginButton(
                                    textTitle: Strings.facebook_login,
                                    imagePath:
                                        'assets/images/facebook_icon.svg',
                                    navigateCallBack: () async {
                                      // Fluttertoast.showToast(msg: "Under Progress");
                                      bool value =
                                          await checkInternetFromWithinWidgets();
                                      if (value) {
                                        if (!mounted) return;
                                        setState(() {
                                          _isProgressBar = true;
                                        });
                                        bool isSuccess =
                                            await facebookLoginProvider
                                                .allowUserToSignInwithFb();
                                        if (isSuccess) {
                                          getCallUserProfile(Strings.facebook);
                                        } else {
                                          if (!mounted) return;
                                          setState(() {
                                            _isProgressBar = false;
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  addVerticalSpace(10.0),
                                  LoginButton(
                                    imagePath: 'assets/images/gogle_icon.svg',
                                    textTitle: Strings.google_login,
                                    navigateCallBack: () async {
                                      bool value =
                                          await checkInternetFromWithinWidgets();
                                      if (value) {
                                        try {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          String? token = prefs
                                              .getString(Strings.google_token);
                                          print("the token value in google_login is $token");
                                          if (!mounted) return;
                                          setState(() {
                                            _isProgressBar = true;
                                          });
                                          if (token != null)  //If  token not null then Navigate to Profile screen.
                                          {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        const ProfileScreen(
                                                            isAppBarVisible:
                                                                true)));
                                          }
                                          else {
                                            bool isSuccess = await authProvider.handleSignIn();  //check Google Auth here, if auth success then save all the Google Auth values in the database.
                                            if (isSuccess) {
                                              getCallUserProfile(
                                                  Strings.google);
                                            }
                                            else {
                                              if (!mounted) return;
                                              setState(() {
                                                _isProgressBar = false;
                                                Fluttertoast.showToast(
                                                    msg: Strings
                                                        .unSuccessfullLoginMessage);
                                              });
                                            }
                                          }
                                        } catch (e) {
                                          if (!mounted) return;
                                          setState(() {
                                            _isProgressBar = false;
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Something went wrong with exception $e");
                                          });
                                          if (kDebugMode) {
                                            print(
                                                "The exception catch in login google is $e");
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Visibility(
                child: const CircularProgressScreen(),
                visible: _isProgressBar,
              ),
              NoInternetView(
                isInternet: _isInternet,
                noInternetMessage: noInternetMessage,
              ),
            ],
          )),
    );
  }

  void getCallUserProfile(String ProfileType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Strings.loginProfileType, ProfileType);
    String? firstName = prefs.getString(FirestoreConstants.firstName);
    String? lastName = prefs.getString(FirestoreConstants.lastName);
    String? email = prefs.getString(FirestoreConstants.email);
    String? imagePath=prefs.getString(FirestoreConstants.photoUrl);
    String? profileType = ProfileType;
    String? profileID = prefs.getString(FirestoreConstants.id);
    String? location = Strings.location;
    print(
        "The user save is $firstName \n $lastName \n $email \n $imagePath \n $profileType \n $profileID \n $location");

    if(email==null || email.isEmpty) // this condition work with facebook Auth as Some account didn't have email so in that case we save dummy email and on profile screen ask User to enter email address manually.
      {
        email="$profileID@gmail.com"; //profileId is unique with every account that's why use ProfileId with dummy email creation.

      }

    UserModel post = UserModel(
        first_name: firstName ?? "",
        last_name: lastName ?? "",
        email: email,
        image_path: imagePath ?? "",
        profile_type: profileType,
        profile_id: profileID ?? "",
        location_locality: location,
        latitude: '0.0',
        longitude: '0.0',
        country: 'IN',
        state: 'state',
        city: 'city',
        pincode: 'pincode');  //latitude,longitude,country,state,city,pincode all are part of Geolocation so it will be filled up on Profile screen, here we save the dummy data

    try
  {
    API.postUserProfile(post.toMap()).then((response)
    async {
      final int statusCode = response.statusCode;
      print("response is ${response.body}");
      print("\n the status is $statusCode");

      if (statusCode == 200 || statusCode == 201) {
        if (!mounted) return;
        setState(() {
          _isProgressBar = false;
        });
        TokenModel model = TokenModel.fromJson(json.decode(response.body));
        String token = model.token.toString();
        String status = model.status;
        if (kDebugMode) {
          print("the token value is $token\n the status is $status");
        }

        if (status ==
            Strings
                .loggedInStatus) //user already exists in database, so open marketplace
            {
          prefs.setString(Strings.google_token, token);
          Fluttertoast.showToast(msg: status.toUpperCase());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const MainScreen()));
        }
        else if(status ==Strings.exist) //If account already exist
          {
            if(profileType==Strings.google)
              {
                bool isSuccess= await authProvider.handleSignout(); //this is needed as to logout user in order to PopUp DialogBox with Google Email id's.
                if(isSuccess)
                  {
                    SharedPreferences prefs=await SharedPreferences.getInstance();
                    prefs.clear();
                  }
                Fluttertoast.showToast(msg: Strings.googleExistToastMsg,toastLength: Toast.LENGTH_LONG);
              }
            else{
              bool isSuccess=await facebookLoginProvider.allowUserToSignOut();//this is needed as to logout Facebook account.
              if(isSuccess)
              {
                SharedPreferences prefs=await SharedPreferences.getInstance();
                prefs.clear();
              }
              Fluttertoast.showToast(msg: Strings.fbExistToastMsg,toastLength: Toast.LENGTH_LONG);
            }
          }
        else //new user,so open profilescreen
            {
          prefs.setString(Strings.google_token, token);
          Fluttertoast.showToast(msg: status.toUpperCase());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                  const ProfileScreen(isAppBarVisible: true)));
        }
      }
      else
      {
        if (!mounted) return;
        setState(()
        {
          _isProgressBar = false;
        });
      }
    });
  }catch(e)
    {
      if (!mounted) return;
      setState(()
      {
        _isProgressBar = false;
      });
      Fluttertoast.showToast(msg: "Exception is $e");
    }
  }
}
