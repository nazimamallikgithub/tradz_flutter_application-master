import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allProvider/view_provider.dart';
import 'package:tradz/allProvider/chat_provider.dart';
import 'package:tradz/allProvider/home_provider.dart';
import 'app_screens/splash_screen.dart';
import 'config/config.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  final configurations = Configurations();
  try {
    // if(kIsWeb)
    //   {
    //     await FacebookAuth.i.webInitialize(
    //       appId: "359860432804020",
    //       cookie: true,
    //       xfbml: true,
    //       version: "v13.0",
    //     );
    //   }
    if (kIsWeb)
    {
      print("inside kWeb");
      // initialiaze the facebook javascript SDK
      await Firebase.initializeApp(
          name: Strings.appname,
          options:
          FirebaseOptions(
              apiKey: configurations.apiKey,
              appId: configurations.appId,
              messagingSenderId: configurations.messagingSenderId,
              storageBucket: configurations.storageBucket,
              projectId: configurations.projectId,
            measurementId: configurations.measurementId
          ),
      );
    }
    else
    {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print("the Exception in firebase is $e");
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget
{
  SharedPreferences prefs;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(
    //         statusBarColor: Color(0xff022744)
    //     ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(   //this provider is used for Google Auth
            firebaseFirestore: this.firebaseFirestore,
            prefs: this.prefs,
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
          ),
        ),
        Provider<HomeProvider>(
          create: (_) =>
              HomeProvider(firebaseFirestore: this.firebaseFirestore),
        ),
        Provider<ChatProvider>(  //this Provider is for FireStore chat
            create: (_) => ChatProvider(
                firebaseFirestore: this.firebaseFirestore,
                prefs: this.prefs,
                firebaseStorage: this.firebaseStorage)),
        ChangeNotifierProvider<FacebookLoginProvider>(
            create: (_) => FacebookLoginProvider(
              firebaseAuth: FirebaseAuth.instance,
              prefs: this.prefs,
              firebaseFirestore: this.firebaseFirestore,
            )),
        ChangeNotifierProvider<ViewProvider>(create: (_) => ViewProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: Strings.appname,
        home: const SplashScreen(),
        //_isLoggedIn? main_screen(): const login_screen(),
        theme: ThemeData(
          fontFamily: 'Roboto-Regular',
          primaryColor: ConstantColors.primaryColor,
          primaryColorDark: ConstantColors.primaryDarkColor,
          iconTheme: const IconThemeData(color: Colors.white),
          appBarTheme: const AppBarTheme(
            color: ConstantColors.primaryColor,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            primary: ConstantColors.primaryColor,
          )),
          scaffoldBackgroundColor: ConstantColors.backgroundColor,
          colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: ConstantColors.primaryColor,
              primary: ConstantColors.primaryColor,
              brightness: Brightness.light),
        ),
      ),
    );
  }
}
