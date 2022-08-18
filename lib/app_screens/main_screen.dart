import 'dart:convert';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Constant/Constant.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allProvider/home_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/drawer_listTile_view.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/api/http_parameter.dart';
import 'package:tradz/app_screens/category_screen.dart';
import 'package:tradz/app_screens/empty_container_screen.dart';
import 'package:tradz/app_screens/market_screen.dart';
import 'package:tradz/app_screens/liked_screen.dart';
import 'package:tradz/app_screens/login_screen.dart';
import 'package:tradz/app_screens/product_details_screen.dart';
import 'package:tradz/app_screens/profile_screen.dart';
import 'package:tradz/app_screens/message_screen.dart';
import 'package:tradz/app_screens/search_screen.dart';
import 'package:tradz/app_screens/setting_screen.dart';
import 'package:tradz/app_screens/my_product_screen.dart';
import 'package:tradz/allProvider/view_provider.dart';
import 'package:tradz/model/profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:tradz/model/user_product_model.dart';
import 'package:translator/translator.dart';


import 'group_message_screen.dart';
import 'notifications_screen.dart';

class MainScreen extends StatefulWidget
{
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState()=>MainScreenState();
}
class MainScreenState extends State<MainScreen>
{
  final translator = GoogleTranslator();
  final FirebaseMessaging firebaseMessaging=FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();


  final GoogleSignIn googleSignIn=GoogleSignIn();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool isLoading=false;
  bool _isGridView=true;
  bool _isSearchIconEnabled=true;
  bool _isMessageScreenEnabled=false;
  bool _isProgressBar=false;
  String savecurrentLocality="";//save the current user localty and check if it equals to one on profile table of server.
  bool _isLayoutIconVisisble=true;
  int currentTab=0;
  late String currentUserId;
  bool _centerTitleEnable=false;
  List<Placemark>  _userLocation=[];
  late String latitudeValue,longitudeValue;
  late HomeProvider homeProvider;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;
  late ViewProvider viewProvider;
  String noInternetMessage='';
  bool _isInternet = false;

  String? currentLatLng="";
  String Address = 'search';

  String home_item='';String myLikes='';String message_item='';
  String profile_item='';
  String appSetting='';String notifications='';String my_items='';
  String logout='';String backPressToast='';String _titleAppbar='';


  DateTime? backButtonPressTime;
  static const snackBarDuration = Duration(seconds: 3);



  final List<Widget> screens = [
    const MarketScreen(),
    const ProfileScreen(isAppBarVisible: false,),
    const MessageScreen()
  ];
  late Widget currentScreen;


  @override
  void initState() {
    checkInternet();
    checkSelectedLanguage(); //select the language chjoosen by user
    initDynamicLinks(context); //On click from socialMedia  deeplink this method getsCall
    getUserProfile();
    _centerTitleEnable=true;
    currentScreen=const EmptyContainer();
    // currentScreen=const HomeGridScreen();
    super.initState();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    authProvider=context.read<AuthProvider>();
    homeProvider=context.read<HomeProvider>();
    viewProvider=context.read<ViewProvider>();
    if(authProvider.getUserFirebaseId()?.isNotEmpty==true)
    {
      currentUserId =authProvider.getUserFirebaseId()!;
    }
    registerNotification();
    configureLocalNotification();
    // else{
    //   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const login_screen()),
    //           (Route<dynamic>route) => false);
    // }
    // listScrollController.addListener(scrollListener);
  }

  checkInternet() async
  {
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
        print("insternet becomes exception " + _isInternet.toString());
      });
    }
  }

  Future<bool> checkInternetFromWithinWidgets() async
  {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty)
      {
        setState(() {
          _isInternet = false;
          print("checkInternetFromWithinWidgets internet" + _isInternet.toString());
        });
      }
      return true;
    }
    on SocketException catch (_)
    {
      setState(() {
        _isInternet = true;
        _isProgressBar = false;
        print("checkInternetFromWithinWidgets internet becomes exception " + _isInternet.toString());
      });
      return false;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void checkSelectedLanguage() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
    {

      getCallLanguageTranslate(locale);

    }else{
      if(!mounted)return;
      setState(() {
        _titleAppbar=Strings.appname;
        home_item=Strings.home_item;
        myLikes=Strings.myLikes;
        message_item=Strings.message_item;
        profile_item=Strings.profile_item;
        appSetting=Strings.appSetting;
        notifications=Strings.notifications;
        my_items=Strings.my_items;
        logout=Strings.logout;
        backPressToast=Strings.backPressToast;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
  }

  void changeTitle_asLanguage(String appBarTitleText, String titleFrom)async{
    print("changeTitle_asLanguage title is $appBarTitleText\n the titleFrom is $titleFrom");
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
    {
      if(locale=='hi')
      {
        if(titleFrom=='appname')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.appname;
          });
        }else if(titleFrom=='like_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.like_item_hi;
          });
        }
        else if(titleFrom=='message_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.message_item_hi;
          });
        }
        else{
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.profile_item_hi;
          });
        }
      }

      else if(locale=='bn')
      {
        if(titleFrom=='appname')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.appname;
          });
        }else if(titleFrom=='like_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.like_item_bn;
          });
        }
        else if(titleFrom=='message_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.message_item_bn;
          });
        }
        else{
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.profile_item_bn;
          });
        }
      }
      else if(locale=='ta')
      {
        if(titleFrom=='appname')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.appname;
          });
        }else if(titleFrom=='like_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.like_item_ta;
          });
        }
        else if(titleFrom=='message_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.message_item_ta;
          });
        }
        else{
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.profile_item_ta;
          });
        }
      }
      else if(locale=='te')
      {
        if(titleFrom=='appname')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.appname;
          });
        }else if(titleFrom=='like_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.like_item_te;
          });
        }
        else if(titleFrom=='message_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.message_item_te;
          });
        }
        else{
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.profile_item_te;
          });
        }
      }

      else{
        if(titleFrom=='appname')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.appname;
          });
        }else if(titleFrom=='like_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.like_item;
          });
        }
        else if(titleFrom=='message_item')
        {
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.message_item;
          });
        }
        else{
          if(!mounted)return;
          setState(() {
            _titleAppbar=Strings.profile_item;
          });
        }
      }
    }
    else{
      if(titleFrom=='appname')
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.appname;
        });
      }else if(titleFrom=='like_item')
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.like_item;
        });
      }
      else if(titleFrom=='message_item')
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.message_item;
        });
      }
      else{
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.profile_item;
        });
      }
    }
  }

  void getCallLanguageTranslate(String locale)async{
    if(locale=='hi')
    {
      if(currentTab==0)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.appname;
        });
      }
      else if(currentTab==1)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.myLikes_hi;
        });
      }
      else if(currentTab==2)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.message_item_hi;
        });
      }
      else if(currentTab==3)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.profile_item_hi;
        });
      }
      home_item=Strings.home_item_hi;
      myLikes=Strings.myLikes_hi;
      message_item=Strings.message_item_hi;
      profile_item=Strings.profile_item_hi;
      appSetting=Strings.appSetting_hi;
      notifications=Strings.notifications_hi;
      my_items=Strings.my_items_hi;
      logout=Strings.logout_hi;
      backPressToast=Strings.backPressToast_hi;
      noInternetMessage=Strings.noInternetMessage_hi;
    }

    else if(locale=='bn')
    {
      if(currentTab==0)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.appname;
        });
      }
      else if(currentTab==1)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.myLikes_bn;
        });
      }
      else if(currentTab==2)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.message_item_bn;
        });
      }
      else if(currentTab==3)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.profile_item_bn;
        });
      }
      if(!mounted)return;
      setState(()
      {
        home_item=Strings.home_item_bn;
        myLikes=Strings.myLikes_bn;
        message_item=Strings.message_item_bn;
        profile_item=Strings.profile_item_bn;
        appSetting=Strings.appSetting_bn;
        notifications=Strings.notifications_bn;
        my_items=Strings.my_items_bn;
        logout=Strings.logout_bn;
        backPressToast=Strings.backPressToast_bn;
        noInternetMessage=Strings.noInternetMessage_bn;
      });
    }


    else if(locale=='te')
    {
      if(currentTab==0)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.appname;
        });
      }
      else if(currentTab==1)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.myLikes_te;
        });
      }
      else if(currentTab==2)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.message_item_te;
        });
      }
      else if(currentTab==3)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.profile_item_te;
        });
      }

      if(!mounted)return;
      setState(() {
        home_item=Strings.home_item_te;
        myLikes=Strings.myLikes_te;
        message_item=Strings.message_item_te;
        profile_item=Strings.profile_item_te;
        appSetting=Strings.appSetting_te;
        notifications=Strings.notifications_te;
        my_items=Strings.my_items_te;
        logout=Strings.logout_te;
        backPressToast=Strings.backPressToast_te;
        noInternetMessage=Strings.noInternetMessage_te;
      });
    }
    else
    {
      if(currentTab==0)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.appname;
        });
      }
      else if(currentTab==1)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.myLikes;
        });
      }
      else if(currentTab==2)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.message_item;
        });
      }
      else if(currentTab==3)
      {
        if(!mounted)return;
        setState(() {
          _titleAppbar=Strings.profile_item;
        });
      }

      if(!mounted)return;
      setState(() {
        home_item=Strings.home_item;
        myLikes=Strings.myLikes;
        message_item=Strings.message_item;
        profile_item=Strings.profile_item;
        appSetting=Strings.appSetting;
        notifications=Strings.notifications;
        my_items=Strings.my_items;
        logout=Strings.logout;
        backPressToast=Strings.backPressToast;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
    // await translator.translate(titleAppbar,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     _titleAppbar=value.toString();
    //   });
    // });
    // await translator.translate(backPressToast,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     backPressToast=value.toString();
    //   });
    // });
    // await translator.translate(home_item,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     home_item=value.toString();
    //   });
    // });
    // await translator.translate(myLikes,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     myLikes=value.toString();
    //   });
    // });
    // await translator.translate(message_item,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     message_item=value.toString();
    //   });
    // });
    // // await translator.translate(message_item,to: locale).then((value){
    // //   setState(() {
    // //     message_item=value.toString();
    // //   });
    // // });
    // await translator.translate(profile_item,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     profile_item=value.toString();
    //   });
    // });
    // await translator.translate(my_items,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     my_items=value.toString();
    //   });
    // });
    // await translator.translate(notifications,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     notifications=value.toString();
    //   });
    // });
    // await translator.translate(appSetting,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     appSetting=value.toString();
    //   });
    // });
    // await translator.translate(logout,to: locale).then((value){
    //   if(!mounted)return;
    //   setState(() {
    //     logout=value.toString();
    //   });
    // });
  }

  static Future<void> initDynamicLinks(BuildContext context) async
  {
    print("inside the initDynamicLinks()");
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
          final Uri? deeplink=dynamicLink!.link;
          print("the deep link is ${deeplink}");
          var isStory=deeplink?.pathSegments.contains('tradzDetails');
          if(isStory!)
          {
            String? id=deeplink!.queryParameters['id'];
            print("the id of deeplink is  is $id");
            Navigator.push(context, MaterialPageRoute(builder:(BuildContext context)=>ProductDetailsScreen(productID: int.parse(id!), isMessageIconVisible: true)));
          }
          else
          {
            print("inside else of initDynamicLinks");
          }
          // if(deeplink!=null)
          //   {
          //     handleMyLink(deeplink);
          //   }
        },onError: (OnLinkErrorException e)async //OnError calls when user deleted the PostedItem
        {
      if(kDebugMode)
      {
        print("We got error is $e");
      }
    }
    );

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    try{
      final Uri? deeplink=data!.link;
      print("the deep link in getInitialLink is ${deeplink}");
      var isStory=deeplink?.pathSegments.contains('tradzDetails');
      if(isStory!)
      {
        String? id=deeplink!.queryParameters['id'];
        Navigator.push(context, MaterialPageRoute(builder:(BuildContext context)=>ProductDetailsScreen(productID: int.parse(id!), isMessageIconVisible: true)));
      }else{
        print("inside else of getInitialLink");
      }

    }catch(e){
      print("exception in catch of initDynamicLinks is $e");
    }

  }


  void registerNotification()
  {
    firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(message.notification!=null)
      {
        showNotification(message.notification!);
      }
      return;
    });

    firebaseMessaging.getToken().then((token){
      if(token!=null)
      {
        homeProvider.updateFirestore(
            FirestoreConstants.pathUserCollection, currentUserId,
            {'pushToken':token});
      }
    }).catchError((error){
      Fluttertoast.showToast(msg: error.message.toString());
    });
  }


  void configureLocalNotification()
  {
    AndroidInitializationSettings initializationAndroidSettings=AndroidInitializationSettings("app_icon");
    IOSInitializationSettings initializationIOsSettings=IOSInitializationSettings();
    InitializationSettings initializationSettings=InitializationSettings(
      android: initializationAndroidSettings,
      iOS: initializationIOsSettings,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  void showNotification(RemoteNotification remoteNotification)async
  {
    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
        'com.bcit.tradz',
        'Tradz',
        playSound: true,
        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high
    );

    IOSNotificationDetails iosNotificationDetails=IOSNotificationDetails();
    NotificationDetails notificationDetails=NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      notificationDetails,
      payload: null,
    );

  }

  void checkView() async
  {
    try{
      SharedPreferences prefs=await SharedPreferences.getInstance();
      if(!mounted)return;
      setState(() {
        _isGridView=prefs.getBool(Strings.isGridView)!;
        print("checkview is ${prefs.getBool(Strings.isGridView)}");
        currentScreen=const MarketScreen();
        // if(_isGridView) //check if layout opened is GridLayout or Linearlayout
        // {
        //   currentScreen=const HomeGridScreen();
        // }
        // else{
        //   currentScreen=const HomeLinearScreen();
        // }
      });
    }catch(e)
    {
      if(kDebugMode)
      {
        print("the exception in checkView of mainScreen is $e");
      }
      if(!mounted) return;
      setState(() {
        currentScreen=const MarketScreen();
      });
    }
  }

  // void checkCurrentView() async{
  //   SharedPreferences prefs=await SharedPreferences.getInstance();
  //   _isGridView=prefs.getBool(Strings.isGridView)!;
  //   if(_isGridView)
  //     {
  //       currentScreen=HomeGridScreen();
  //     }
  //   else{
  //     currentScreen=HomeLinearScreen();
  //   }
  // }

  Future<bool> _onBackPressed() async {
    DateTime currentTime = DateTime.now();
    bool backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            currentTime.difference(backButtonPressTime!) > snackBarDuration;

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = currentTime;
      Fluttertoast.showToast(msg: backPressToast);
      return Future.value(false);
    }
    //SystemNavigator.pop();
    exit(0);
    return Future.value(true);
  }

  //Hide the Navigation Drawer
  void hideDrawer() {

    if (_key.currentState!.isDrawerOpen)
    {
      _key.currentState!.openEndDrawer();
    }
    else {
      _key.currentState!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context)
  {

    //facebook Auth
    FacebookLoginProvider facebookLoginProvider=Provider.of<FacebookLoginProvider>(context);
    ViewProvider viewProvider=Provider.of<ViewProvider>(context);
    //GoogleAuth
    AuthProvider authProvider= Provider.of<AuthProvider>(context);
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child:
      Scaffold(
        key: _key,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          titleSpacing: 0.0,
          centerTitle: true,
          title:
          _centerTitleEnable?Center(child: Text(_titleAppbar)):Text(_titleAppbar),
          actions:  [
            Visibility(
              visible: _isSearchIconEnabled,
              child: IconButton(
                  onPressed: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>const SearchScreen()));
                  },
                  icon: const Icon(Icons.search)
              ),
            ),
            Visibility(
              visible: _isMessageScreenEnabled,
              child: IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> GroupMessageScreen(
                  name: '',  groupChatId: '', membersList: [],

                )));
              },
                icon: Icon(Icons.group),
              ),
            ),
            Visibility(
              child: _isGridView
                  ? IconButton(
                  icon: const Icon(
                    Icons.grid_on_sharp,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    checkFilter();
                    // context.read<ViewProvider>().checkView();
                  })
                  : IconButton
                (
                  icon: const Icon(Icons.list,
                      color: Colors.white),
                  onPressed: ()
                  {
                    checkFilter();
                  }),
              visible: _isLayoutIconVisisble,
            ),
            // const Padding(
            //   padding: EdgeInsets.only(right: 8.0),
            //   child: Icon(Icons.notifications,
            //   size: 24.0,
            //   ),
            // )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: AppBar().preferredSize.height,
                child: DrawerHeader(
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/images/ic_app_icon.png',width: MediaQuery.of(context).size.width*0.10,),
                        Text(Strings.appname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                              letterSpacing: 1.0,
                              color: Colors.white,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 2.0,
                                  color: Colors.black,
                                ),
                                Shadow(
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 2.0,
                                  color: Colors.black,
                                ),
                              ],
                            ))
                      ],
                    ),
                    decoration:
                    const BoxDecoration(color: ConstantColors.primaryColor)),
              ),
              ListTile(
                trailing: const Icon(
                  Icons.list_alt_outlined,
                ),
                title: Text(
                  my_items,
                ),
                onTap: () async{
                  bool value=await checkInternetFromWithinWidgets();
                  if(value)
                  {
                    getCall_MYITEMS(viewProvider);
                  }

                  hideDrawer();
                },
              ),
              ListTile(
                trailing: const Icon(
                  Icons.notifications,
                ),
                title: Text(
                  notifications,
                ),
                onTap: () async{
                  bool value=await checkInternetFromWithinWidgets();
                  if(value)
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>const NotificationScreen()));
                  }

                  hideDrawer();
                },
              ),
              ListTile(
                trailing: const Icon(
                  Icons.settings,
                ),
                title: Text(
                  appSetting,
                ),
                onTap: () async{
                  bool value=await checkInternetFromWithinWidgets();
                  if(value)
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>const SettingScreen())).then((value){
                      if (kDebugMode) {
                        if(!mounted)return;
                        setState(() {
                          if (kDebugMode) {
                            print("inside the settings");
                          }
                          viewProvider.changeView(true); ////In order to refresh the List so that Setting changes can be seen in List.
                          // _isLayoutIconVisisble=true;
                          // _titleAppbar=Strings.appname;
                          // _centerTitleEnable=true;
                          // currentTab = 0;
                          // currentScreen=const HomeLinearScreen();
                          // currentScreen=_isGridView?HomeGridScreen():const HomeLinearScreen();
                        });
                        checkSelectedLanguage();
                      }
                    });
                  }
                  hideDrawer();
                },
              ),
              ListTile(
                trailing: const Icon(
                  Icons.logout,
                ),
                title: Text(
                  logout,
                ),
                onTap: () async{
                  bool value=await checkInternetFromWithinWidgets();
                  if(value)
                  {
                    getCallSignout(authProvider,facebookLoginProvider);
                  }
                  hideDrawer();
                },
              ),
              // DrawerListTileView(itemName: Strings.profile_item, voidCallback: (){
              //
              // })
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              child: currentScreen,
            ),
            Visibility(
              child:const CircularProgressScreen(),
              visible: _isProgressBar,
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
        // ↓ Location: centerDocked positions notched FAB in center of BottomAppBar ↓
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: ()
          {
            Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context)=>
                    CategoryScreen(  //The parameter passes are empty as New Product is creating.In case of update these parameter have values form Existing Product.
                      ImageUrl: [],
                      productPrice: 0,
                      lookingFor:'',
                      productdetails: '',
                      subCategory: '',
                      productTitle: '',
                      category: '',
                      productID: 0,
                    )
            )
            ).then((value)
            {
              viewProvider.changeView(true); //In order to refresh the List so that New Item added can be seen in list.
            });
          },
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.white,
          elevation: 16.0,
          child: SizedBox(
            height: MediaQuery.of(context).size.height*0.10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () async
                      {
                        bool value=await checkInternetFromWithinWidgets();
                        if(value)
                        {
                          if(!mounted)return;
                          setState(()
                          {
                            _isMessageScreenEnabled=false;
                            _isLayoutIconVisisble=true;
                            //_titleAppbar=Strings.appname;
                            _centerTitleEnable=false;
                            currentTab = 0;
                            _isSearchIconEnabled=true;
                            currentScreen=const MarketScreen();
                          });
                          changeTitle_asLanguage(_titleAppbar,"appname");
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child:Icon(Icons.home,
                              size: 24.0,
                              color: currentTab == 0 ? ConstantColors.primaryColor : ConstantColors.primaryDarkColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              home_item,
                              style: TextStyle(
                                color:
                                currentTab == 0 ? ConstantColors.primaryColor : ConstantColors.primaryDarkColor,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () async{
                        bool value=await checkInternetFromWithinWidgets();
                        if(value)
                        {
                          if(!mounted)return;
                          setState(() {
                            _isMessageScreenEnabled=false;
                            _isSearchIconEnabled=false;
                            _isLayoutIconVisisble=false;
                            //_titleAppbar = Strings.myLikes;
                            _centerTitleEnable=false;
                            // _imageAppbar = 'assets/images/parkingIcon.png';
                            currentScreen =
                                LikedItemScreen(); // if user taps on this dashboard tab will be active
                            currentTab = 1;
                          });
                          changeTitle_asLanguage(_titleAppbar,"like_item");
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Icon(
                              Icons.favorite,
                              size: 24.0,
                              color: currentTab == 1 ? ConstantColors.primaryColor : ConstantColors.primaryDarkColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              myLikes,
                              style: TextStyle(
                                color:
                                currentTab == 1 ? ConstantColors.primaryColor : ConstantColors.primaryDarkColor,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

                // Right Tab bar icons

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () async
                      {
                        bool value=await checkInternetFromWithinWidgets();
                        if(value)
                        {
                          if(!mounted)return;
                          setState(() {
                            _isMessageScreenEnabled=true;
                            _isSearchIconEnabled=false;
                            _isLayoutIconVisisble=false;
                            // _titleAppbar = Strings.message_item;
                            _centerTitleEnable=false;
                            // _imageAppbar = 'assets/images/illegalIcon.png';
                            currentScreen =
                            const MessageScreen(); // if user taps on this dashboard tab will be active
                            currentTab = 2;
                          });
                          changeTitle_asLanguage(_titleAppbar,"message_item");
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Icon(
                              Icons.message,
                              size: 24.0,
                              color: currentTab == 2 ? ConstantColors.primaryColor : ConstantColors.primaryDarkColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              message_item,
                              style: TextStyle(
                                color:
                                currentTab == 2 ? ConstantColors.primaryColor : ConstantColors.primaryDarkColor,
                                fontSize: 11.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () async{
                        bool value=await checkInternetFromWithinWidgets();
                        if(value)
                        {
                          if(!mounted)return;
                          setState(()
                          {
                            _isMessageScreenEnabled=false;
                            _isSearchIconEnabled=false;
                            _isLayoutIconVisisble=false; //to hide the GridIcon and linear icon on AppBar
                            //_titleAppbar = Strings.profile_item;
                            _centerTitleEnable=false;
                            // _imageAppbar = 'assets/images/profilehead.png';
                            currentScreen =
                                ProfileScreen(isAppBarVisible: false,); // if user taps on this dashboard tab will be active
                            currentTab = 3;
                          });
                          changeTitle_asLanguage(_titleAppbar,"profile_item");
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Icon(Icons.person,
                              size: 24.0,
                              color: currentTab == 3 ? ConstantColors.primaryColor : ConstantColors.primaryDarkColor,),
                          ),
                          Expanded(
                            child: Text(
                              profile_item,
                              style: TextStyle(
                                color:
                                currentTab == 3 ? ConstantColors.primaryColor : ConstantColors.primaryDarkColor,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkFilter() async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    if(!mounted)return;
    setState(() {
      _isGridView=!_isGridView;
      print("The value of GridView in MainScreen is $_isGridView");
      viewProvider.changeGridView(_isGridView);
      prefs.setBool(Strings.isGridView, _isGridView);
      // if(_isGridView)
      //   {
      //     currentScreen=HomeGridScreen();
      //   }
      // else{
      //   currentScreen=const HomeLinearScreen();
      // }
    });
  }

  void getCall_MYITEMS(ViewProvider viewProvider) async{
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>const MyProductScreen())).then((value)
    {
      viewProvider.changeView(true);  //In order to refresh the List so that If Product Updated by User can be seen in list.
    });
  }

  void getCallSignout(AuthProvider authProvider, FacebookLoginProvider facebookLoginProvider) async
  {
    if(!mounted)return;
    setState(() {
      _isProgressBar=true;
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
          _isProgressBar=false;
        });
        SharedPreferences prefs=await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const LoginScreen()),
                (Route<dynamic>route) => false);
      }
      else{
        if (kDebugMode) {
          print("something went wrong");
        }
        if(!mounted)return;
        setState(() {
          _isProgressBar=false;
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
          _isProgressBar=false;
        });
        SharedPreferences prefs=await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const LoginScreen()),
                (Route<dynamic>route) => false);
        // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>LoginScreen()));
      }
      else{
        print("something went wrong");
        if(!mounted)return;
        setState(() {
          _isProgressBar=false;
        });
      }
    }



  }




  void getUserProfile() async {
    try
    {
      if(!mounted)return;
      setState(() {
        _isProgressBar=true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(Strings.google_token);
      API.getUserProfile(token).then((response)
      {
        int statusCode=response.statusCode;
        if (kDebugMode) {
          print("response marketplace user profile code is $statusCode "+"\n the response body is ${response.body}");
        }
        if(statusCode==200)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
          {
            ProfileModel model=ProfileModel.fromJson(json.decode(response.body));
            if(!mounted)return;
            setState(() {
              //_isProgressBar=false;
              //savecurrentLocality=model.user.location_locality;
              prefs.setString(Strings.location, model.user.location_locality);  //location_locality save locally for check if user logout and login again at a different location,i that case after getting its current location we can check with this locally saved value that if his location is different than call Update Profile API(locality_location,longitude,latitude)
              prefs.setString(Strings.uploadImageNumber, model.settings.add_images[0].value); // save the number of Images that can be uploaded at time of add product.
            });
            callLocationUpdate(model);
          }
          else if(body['status']=='unauthenticated')
          {
            if(!mounted)return;
            setState(() {
              _isProgressBar=false;
            });
            getCallSignout(authProvider, facebookLoginProvider);
          }else{
            if(!mounted)return;
            setState(() {
              _isProgressBar=false;
            });
            checkView();
          }

        }
        else
        {
          if(!mounted)return;
          setState(() {
            _isProgressBar=false;
          });
          checkView();
        }
      });
    }catch(e){
      checkView();
      if(!mounted)return;
      setState(() {
        _isProgressBar=false;
      });
      if(kDebugMode){
        print('exception in marketplace get profile is $e');
      }
    }
  }

  void callLocationUpdate(ProfileModel model) async
  {
    if (kDebugMode) {
      print("inside the callLocationUpdate");
    }
    Position position = await _getGeoLocationPosition();
    currentLatLng ='${position.latitude},${position.longitude}';
    GetAddressFromLatLong(position,model);
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isProgressBar=false; //as permission denied so progress bar hide
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        _isProgressBar=false; //as permission denied so progress bar hide
      });
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');

    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position, ProfileModel model)async {
    if (kDebugMode) {
      print("inside the GetAddressFromLatLong");
    }
    _userLocation = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (kDebugMode) {
      print("$_userLocation");
    }

    Placemark place = _userLocation[0];
    Placemark place1=_userLocation[1];
    Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    if(!mounted)return;
    setState(() {
      latitudeValue=position.latitude.toString();
      longitudeValue=position.longitude.toString();
      String locality=place.locality.toString();
      String countryName="";
      String pincodeValue='';
      String stateName="";
      String cityName='';
      if(place.isoCountryCode!.isNotEmpty)
      {
        countryName=place.isoCountryCode!;
      }
      else if(place1.isoCountryCode!.isNotEmpty)
      {
        countryName=place1.isoCountryCode!;
      }
      else
      {
        countryName="IN";
      }
      //for PinCode
      if(place.postalCode!.isNotEmpty)
      {
        pincodeValue=place.postalCode!.toString();

      }
      else if(place1.postalCode!.isNotEmpty)
      {
        pincodeValue=place1.postalCode!.toString();

      }
      else{
        pincodeValue="pincodeValue";

      }

      //for state
      if(place.administrativeArea!.isNotEmpty)
      {
        stateName=place.administrativeArea!;
      }
      else if(place1.administrativeArea!.isNotEmpty)
      {
        stateName=place1.administrativeArea!;
      }
      else{
        stateName="state";
      }


      //for City
      if(place.subAdministrativeArea!.isNotEmpty)
      {
        cityName=place.subAdministrativeArea!;
      }else if(place1.subAdministrativeArea!.isNotEmpty)
      {
        cityName=place1.subAdministrativeArea!;
      }
      else{
        cityName="city";
      }

      if(model.user.location_locality.isNotEmpty) //this will always be nonEmpty but in any case its empty
          {
        if(model.user.location_locality!=locality) // if current locality is not equal to server saved profile locality,then we update profile
            {
          print("locality not equal");
          getCallPostProfile(model,locality,latitudeValue,longitudeValue,countryName,stateName,cityName,pincodeValue);
        }
        else{
          checkView(); //set currentscreen for BottomNavigationBar
          if(!mounted)return;
          setState(() {
            _isProgressBar=false;// current location is equal to locality on server
          });
        }
      }
      else{
        checkView(); //set currentscreen for BottomNavigationBar
        if(!mounted)return;
        setState(() {
          _isProgressBar=false;
        });
      }
    });
  }




//Update the Profile as location locality,pincode,state,country etc. if locality is different.
  void getCallPostProfile(ProfileModel model, String locality, String latitudeValue, String longitudeValue, String countryName,String stateName,String cityName,String pincodeValue) async
  {
    print("Inside the MainScreen getCallPostProfile");
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(Strings.google_token);

      String url =
          Constant.baseurl + HttpParams.API_UPDATE_USER_PROFILE;

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['first_name'] = model.user.first_name;
      request.fields['last_name'] = model.user.last_name;
      request.fields['location_locality'] = locality;
      request.fields['longitude']=longitudeValue;
      request.fields['latitude']=latitudeValue;
      request.fields['country']=countryName;
      request.fields['state']=stateName;
      request.fields['city']=cityName;
      request.fields['pincode']=pincodeValue;
      request.fields['img_counter']='0';
      //request.fields['image_path']=model.user.image_path;


      var response = await request.send();
      if (kDebugMode) {
        print("requestResponse main screen request is ${response.statusCode}");
      }
      var requestResponse = await http.Response.fromStream(response);
      final result = jsonDecode(requestResponse.body) as Map<String, dynamic>;
      if (kDebugMode)
      {
        print("updateProduct result ${result['status']}");
      }
      if (response.statusCode == 200)
      {
        if(result['status']==true)
        {
          checkView();
          if (kDebugMode) {
            print("profile upload success");
          }
          prefs.setString(Strings.location, model.user.location_locality); // save the location of User
          if(!mounted)return;
          setState(() {
            _isProgressBar=false;
          });
        }else if(result['status']=='unauthenticated')
        {
          checkView();
          if (kDebugMode) {
            print("profile upload in location marketplace not success");
          }
          if(!mounted)return;
          setState(() {
            _isProgressBar=false;
          });
          getCallSignout(authProvider, facebookLoginProvider);
        }else{
          checkView();
          if (kDebugMode) {
            print("profile upload in location marketplace not success");
          }
          if(!mounted)return;
          setState(() {
            _isProgressBar=false;
          });
        }

      }
      else {
        checkView();
        if (kDebugMode) {
          print("profile upload in location marketplace not success");
        }
        if(!mounted)return;
        setState(() {
          _isProgressBar=false;
        });
      }
    }
    catch (e) {
      checkView();
      if(!mounted)return;
      setState(() {
        _isProgressBar = false;
      });
      if (kDebugMode) {
        print("exception in main screen is ${e.toString()}");
      }
      Fluttertoast.showToast(msg: "The exception in main screen update is $e");
    }

  }





}