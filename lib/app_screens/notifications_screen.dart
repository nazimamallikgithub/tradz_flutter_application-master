import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Constant/Constant.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/empty_result_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/allWidgets/notification_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/login_screen.dart';
import 'package:tradz/app_screens/notification_user_list_screen.dart';
import 'package:tradz/model/notification_model.dart';
import 'package:translator/translator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final translator = GoogleTranslator();
  bool _isGridView = true;
  int page = 1;
  bool _isProgressVisible = false;
  bool _isValidateResponse=true;
  ScrollController _controller = ScrollController();
  late NotificationModel notificationModel;
  List<Data> notificationList = [];

  String notifications='';
  String noNotificationMessage='';
  String notificationlistTitle='';
  String noInternetMessage='';
  bool _isInternet = false;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;



  @override
  void initState() {
    // checkLayoutView(); //check if layout is GridView or LinearLayout
    authProvider=context.read<AuthProvider>();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    checkSelectedLanguage();
    getCallNotificationAPI(page);
    _controller.addListener(() {
      _scrollListener();
    });
    super.initState();
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
        _isProgressVisible = false;
        _isValidateResponse=false;
        print("insternet becomes exception " + _isInternet.toString());
        if(page!=1)
        {
          page--;
        }
      });
    }
  }

  Future<bool> checkInternetFromWithinWidgets() async
  {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _isInternet = false;
          print("insternet becomes if " + _isInternet.toString());
        });
      }
      return true;
    } on SocketException catch (_)
    {
      setState(() {
        _isInternet = true;
        _isProgressVisible = false;
        _isValidateResponse=false;
        print("insternet becomes exception " + _isInternet.toString());
      });
      return false;
    }
  }


  void checkSelectedLanguage() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
    {
      if(locale=='hi')
        {
          if(!mounted)return;
          setState(() {
            notifications=Strings.notifications_hi;
            noNotificationMessage=Strings.noNotificationMessage_hi;
            notificationlistTitle=Strings.notificationlistTitle_hi;
            noInternetMessage=Strings.noInternetMessage_hi;
          });
        }
      else if(locale=='bn')
        {
          if(!mounted)return;
          setState(() {
            notifications=Strings.notifications_bn;
            noNotificationMessage=Strings.noNotificationMessage_bn;
            notificationlistTitle=Strings.notificationlistTitle_bn;
            noInternetMessage=Strings.noInternetMessage_bn;
          });
        }else if(locale=='te')
          {
            if(!mounted)return;
            setState(() {
              notifications=Strings.notifications_te;
              noNotificationMessage=Strings.noNotificationMessage_te;
              notificationlistTitle=Strings.notificationlistTitle_te;
              noInternetMessage=Strings.noInternetMessage_te;
            });
          }
      else
      {
        if(!mounted)return;
        setState(() {
          notifications=Strings.notifications;
          noNotificationMessage=Strings.noNotificationMessage;
          notificationlistTitle=Strings.notificationlistTitle;
          noInternetMessage=Strings.noInternetMessage;
        });
      }
      // else
      // {
      //   await translator.translate(notifications,to:locale).then((value){
      //     print("The value after translate is $value");
      //     if(!mounted)return;
      //     setState(() {
      //       notifications=value.toString();
      //     });
      //   });
      //   await translator.translate(noNotificationMessage,to:locale).then((value){
      //     print("The value after translate is $value");
      //     if(!mounted)return;
      //     setState(() {
      //       noNotificationMessage=value.toString();
      //     });
      //   });
      //   await translator.translate(notificationlistTitle,to:locale).then((value){
      //     print("The value after translate is $value");
      //     if(!mounted)return;
      //     setState(() {
      //       notificationlistTitle=value.toString();
      //     });
      //   });
      // }
    }
    else{
      if(!mounted)return;
      setState(() {
        notifications=Strings.notifications;
        noNotificationMessage=Strings.noNotificationMessage;
        notificationlistTitle=Strings.notificationlistTitle;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
  }

  void _scrollListener()
  {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (!mounted) return;
      setState(() {
        _isProgressVisible = true;
        page = page + 1;
        if (kDebugMode) {
          print("page value is $page");
        }
      });
      getCallNotificationAPI(page);
    }
  }

  void getCallSignout(AuthProvider authProvider, FacebookLoginProvider facebookLoginProvider) async
  {
    if(!mounted)return;
    setState(() {
      _isProgressVisible=true;
    });
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? loginProfileType=prefs.getString(Strings.loginProfileType);
    if(loginProfileType==Strings.facebook)
    {
      bool isSuccess=await facebookLoginProvider.allowUserToSignOut();
      if(isSuccess)
      {
        if(!mounted)return;
        setState(() {
          _isProgressVisible=false;
        });
        SharedPreferences prefs=await SharedPreferences.getInstance();
        prefs.clear();
        Fluttertoast.showToast(msg: "Account already deleted");
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const LoginScreen()),
                (Route<dynamic>route) => false);
      }
      else{
        if (kDebugMode) {
          print("something went wrong");
        }
        if(!mounted)return;
        setState(() {
          _isProgressVisible=false;
        });
      }
    }
    else{
      bool isSuccess= await authProvider.handleSignout();
      if(isSuccess)
      {
        print("success in logout");
        if(!mounted)return;
        setState(() {
          _isProgressVisible=false;
        });
        SharedPreferences prefs=await SharedPreferences.getInstance();
        prefs.clear();
        Fluttertoast.showToast(msg: "Account already deleted");
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const LoginScreen()),
                (Route<dynamic>route) => false);
        // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>LoginScreen()));
      }
      else{
        print("something went wrong");
        if(!mounted)return;
        setState(() {
          _isProgressVisible=false;
        });
      }
    }



  }

  void getCallNotificationAPI(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    checkInternet();
    try{
      API.getCALLNOTIFICATIONS(token, page).then((response) {
        int statusCode = response.statusCode;
        if (kDebugMode) {
          print(
              "the status of notification api is StatusCode \nresponse is ${response.body}");
        }
        if (statusCode == 200 || statusCode == 201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if(!mounted)return;
              setState(()
              {
                _isProgressVisible = false;
                _isValidateResponse=false;
                notificationModel =
                    NotificationModel.fromJson(json.decode(response.body));
                notificationList.addAll(notificationModel.notifications.data);
              });
            }else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isProgressVisible = false;
                  _isValidateResponse=false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
          else {
            if(!mounted)return;
            setState(() {
              _isProgressVisible = false;
              _isValidateResponse=false;
            });
          }

        } else {
          if(!mounted)return;
          setState(() {
            _isProgressVisible = false;
            _isValidateResponse=false;
          });
        }
      });
    }catch(e)
    {
      if (kDebugMode) {
        print("The exception in getNotification is $e");
      }
    }
  }

//check if layout is GridView or LinearLayout
//   void checkLayoutView() async {
//     SharedPreferences prefs=await SharedPreferences.getInstance();
//     bool? prefView = prefs.getBool(Strings.isGridView);
//     if (prefView != null) {
//       setState(() {
//         _isGridView = prefView;
//       });
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(
        isAppBackBtnVisible: true,
        titleText: notifications,
      ),
      body: _isValidateResponse
          ? const CircularProgressScreen()
          :notificationList.isEmpty?EmptyResultWidget(noNotificationMessage)
        :Stack(
        children: <Widget>[
          ListView.builder(
              //padding: const EdgeInsets.all(8.0),
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemCount:
                  notificationList.isNotEmpty ? notificationList.length : 0,
              itemBuilder: (BuildContext context, int index) {
                final model = notificationList[index];
                return GestureDetector(
                  onTap: () async{
                    bool value=await checkInternetFromWithinWidgets();
                    if(value)
                      {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    NotificationUserListScreen(
                                        userID: model.user_details.id,
                                        userName: model.user_details.first_name+" "+'Product')
                            )
                        );
                      }
                  },
                  child: NotificationView(
                      message: model.message_text,
                      productImage: model.base64_images[0],
                      title: notificationlistTitle,
                      userImage: model.user_details.image_blob,
                      userName: model.user_details.first_name),
                );
              }),
          Visibility(
            child: const CircularProgressScreen(),
            visible: _isProgressVisible,
          ),
          NoInternetView(isInternet: _isInternet, noInternetMessage: noInternetMessage,),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     Center(
          //       child: Visibility(
          //         child: Column(
          //           children: <Widget>[
          //             // new Image.asset(
          //             //   'assets/images/ic_error.png',
          //             //   height: 50.0,
          //             //   width: 50.0,
          //             // ),
          //             Icon(Icons.error_outline,color: ConstantColors.primaryColor,size: MediaQuery.of(context).size.height*0.10,),
          //             new Text(
          //               noInternetMessage,
          //               textDirection: TextDirection.rtl,
          //               style: TextStyle(
          //                 fontSize: 18.0,
          //                 color: Colors.black,
          //               ),
          //             ),
          //           ],
          //         ),
          //         visible: _isInternet,
          //       ),
          //     )
          //   ],
          // ),
        ],
      ),
    );
  }
}
