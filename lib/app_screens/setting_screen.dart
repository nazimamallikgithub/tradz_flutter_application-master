import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allProvider/home_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/button_view.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/dialogs/language_selection_dialog.dart';
import 'package:tradz/model/profile_model.dart';
import 'package:translator/translator.dart';

import 'login_screen.dart';
class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final translator = GoogleTranslator();
  double _value = 5.0;
  double minSliderValue=2.0;
  double maxSliderValue=10.0;
  int sliderDivisonValue=8;
  bool applyValue=false;
  bool _isValidateResponse=false;
  String  warningMessage='';
  String alertDeleteMessage='';
  String ok='';String cancel='';
  String apply='';
  String titleText='';String distanceMargin='';
  String goInvisible='';
     String deleteUserAccount='';String selectLanguage='';
     String toastMarginMessage='';
      String toastErrorMsg='';String toastGoInvisibleMsg='';String toastGoVisibleMsg='';
      String toastLogoutMsg='';
  bool _isProgressView=false;
  late String currentUserId;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;
  bool isGoInvisible = false;
  bool isUnlistCollection = false;
  var textValue = 'Switch is OFF';
  String selectableDropDownValue="km";
  late final HomeProvider homeProvider;
  bool _isInternet = true;
  String noInternetMessage='';
  @override
  void initState() {
    checkSelectedLanguage();
    getUserProfile();
    authProvider= context.read<AuthProvider>();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    homeProvider=context.read<HomeProvider>();
    super.initState();
    readLocal();
  }

  checkInternet() async
  {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty)
      {
        setState(()
        {
          _isInternet = false;
          print("internet becomes if " + _isInternet.toString());
        });
      }
    } on SocketException catch (_)
    {
      setState(() {
        _isInternet = true;
        _isProgressView = false;
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
    } on SocketException catch (_)
    {
      setState(() {
        _isInternet = true;
        _isProgressView = false;
        print("checkInternetFromWithinWidgets internet becomes exception " + _isInternet.toString());
      });
      return false;
    }
  }

  void checkSelectedLanguage() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    print("the value of locale is $locale");
    if(locale!=null)
      {
        getCallLanguageTranslate(locale);
      }else{
      if(!mounted)return;
      setState(() {
        warningMessage=Strings.warningMessage;
        alertDeleteMessage=Strings.alertDeleteMessage;
        ok=Strings.ok;
        cancel=Strings.cancel;
        apply=Strings.apply;
        titleText=Strings.appSetting;
        distanceMargin=Strings.distanceMargin;
        goInvisible=Strings.goInvisible;
        deleteUserAccount=Strings.deleteUserAccount;
        selectLanguage=Strings.selectLanguage;
        toastMarginMessage=Strings.toastMarginMessage;
        toastErrorMsg=Strings.toastErrorMsg;
        toastGoInvisibleMsg=Strings.toastGoInvisibleMsg;
        toastGoVisibleMsg=Strings.toastGoVisibleMsg;
        toastLogoutMsg=Strings.toastLogoutMsg;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
  }

  Future<void> getCallLanguageTranslate(String locale) async
  {
    if(locale=='hi')
      {
        if(!mounted)return;
        setState(() {
          warningMessage=Strings.warningMessage_hi;
          alertDeleteMessage=Strings.alertDeleteMessage_hi;
          ok=Strings.ok_hi;
          cancel=Strings.cancel_hi;
          apply=Strings.apply_hi;
          titleText=Strings.appSetting_hi;
          distanceMargin=Strings.distanceMargin_hi;
          goInvisible=Strings.goInvisible_hi;
          deleteUserAccount=Strings.deleteUserAccount_hi;
          selectLanguage=Strings.selectLanguage_hi;
          toastMarginMessage=Strings.toastMarginMessage_hi;
          toastErrorMsg=Strings.toastErrorMsg_hi;
          toastGoInvisibleMsg=Strings.toastGoInvisibleMsg_hi;
          toastGoVisibleMsg=Strings.toastGoVisibleMsg_hi;
          toastLogoutMsg=Strings.toastLogoutMsg_hi;
          noInternetMessage=Strings.noInternetMessage_hi;
        });
      }else if(locale=='bn')
        {
          if(!mounted)return;
          setState(() {
            warningMessage=Strings.warningMessage_bn;
            alertDeleteMessage=Strings.alertDeleteMessage_bn;
            ok=Strings.ok_bn;
            cancel=Strings.cancel_bn;
            apply=Strings.apply_bn;
            titleText=Strings.appSetting_bn;
            distanceMargin=Strings.distanceMargin_bn;
            goInvisible=Strings.goInvisible_bn;
            deleteUserAccount=Strings.deleteUserAccount_bn;
            selectLanguage=Strings.selectLanguage_bn;
            toastMarginMessage=Strings.toastMarginMessage_bn;
            toastErrorMsg=Strings.toastErrorMsg_bn;
            toastGoInvisibleMsg=Strings.toastGoInvisibleMsg_bn;
            toastGoVisibleMsg=Strings.toastGoVisibleMsg_bn;
            toastLogoutMsg=Strings.toastLogoutMsg_bn;
            noInternetMessage=Strings.noInternetMessage_bn;
          });
        }else if(locale=='te')
          {
            if(!mounted)return;
            setState(() {
              warningMessage=Strings.warningMessage_te;
              alertDeleteMessage=Strings.alertDeleteMessage_te;
              ok=Strings.ok_te;
              cancel=Strings.cancel_te;
              apply=Strings.apply_te;
              titleText=Strings.appSetting_te;
              distanceMargin=Strings.distanceMargin_te;
              goInvisible=Strings.goInvisible_te;
              deleteUserAccount=Strings.deleteUserAccount_te;
              selectLanguage=Strings.selectLanguage_te;
              toastMarginMessage=Strings.toastMarginMessage_te;
              toastErrorMsg=Strings.toastErrorMsg_te;
              toastGoInvisibleMsg=Strings.toastGoInvisibleMsg_te;
              toastGoVisibleMsg=Strings.toastGoVisibleMsg_te;
              toastLogoutMsg=Strings.toastLogoutMsg_te;
              noInternetMessage=Strings.noInternetMessage_te;
            });
          }
    else
    {
      if(!mounted)return;
      setState(() {
        warningMessage=Strings.warningMessage;
        alertDeleteMessage=Strings.alertDeleteMessage;
        ok=Strings.ok;
        cancel=Strings.cancel;
        apply=Strings.apply;
        titleText=Strings.appSetting;
        distanceMargin=Strings.distanceMargin;
        goInvisible=Strings.goInvisible;
        deleteUserAccount=Strings.deleteUserAccount;
        selectLanguage=Strings.selectedLanguage;
        toastMarginMessage=Strings.toastMarginMessage;
        toastErrorMsg=Strings.toastErrorMsg;
        toastGoInvisibleMsg=Strings.toastGoInvisibleMsg;
        toastGoVisibleMsg=Strings.toastGoVisibleMsg;
        toastLogoutMsg=Strings.toastLogoutMsg;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
      // await translator.translate(titleText,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     titleText=value.toString();
      //   });
      // });
      // await translator.translate(distanceMargin,to:locale).then((value){
      //   if(!mounted)return;
      //   setState(() {
      //     distanceMargin=value.toString();
      //   });
      // });
      // await translator.translate(goInvisible,to:locale).then((value){
      //   if(!mounted)return;
      //   setState(() {
      //     goInvisible=value.toString();
      //   });
      // });
      // await translator.translate(deleteUserAccount,to:locale).then((value) {
      //   if(!mounted)return;
      //   setState(() {
      //     deleteUserAccount=value.toString();
      //   });
      // });
      //
      // await translator.translate(selectLanguage,to:locale).then((value) {
      //   if(!mounted)return;
      //   setState(() {
      //     selectLanguage=value.toString();
      //   });
      // });
      //
      // await translator.translate(warningMessage,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     warningMessage=value.toString();
      //   });
      // });
      // await translator.translate(alertDeleteMessage,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     alertDeleteMessage=value.toString();
      //   });
      // });
      // await translator.translate(ok,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     ok=value.toString();
      //   });
      // });
      // await translator.translate(cancel,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     cancel=value.toString();
      //   });
      // });
      // await translator.translate(apply,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     apply=value.toString();
      //   });
      // });
      // await translator.translate(toastMarginMessage,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     toastMarginMessage=value.toString();
      //   });
      // });
      // await translator.translate(toastErrorMsg,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     toastErrorMsg=value.toString();
      //   });
      // });
      // await translator.translate(toastGoInvisibleMsg,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     toastGoInvisibleMsg=value.toString();
      //   });
      // });
      // await translator.translate(toastGoVisibleMsg,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     toastGoVisibleMsg=value.toString();
      //   });
      // });
      // await translator.translate(toastLogoutMsg,to:locale).then((value){
      //   print("The value after translate is $value");
      //   if(!mounted)return;
      //   setState(() {
      //     toastLogoutMsg=value.toString();
      //   });
      // });
  }

  void readLocal()
  {
    if(authProvider.getUserFirebaseId()?.isNotEmpty==true){
      currentUserId=authProvider.getUserFirebaseId()!;
    }
  }

  void getCallSignout(AuthProvider authProvider, FacebookLoginProvider facebookLoginProvider) async
  {
    if(!mounted)return;
    setState(() {
      _isProgressView=true;
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
          _isProgressView=false;
        });
        SharedPreferences prefs=await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>LoginScreen()));
      }
      else{
        if (kDebugMode) {
          print("something went wrong");
        }
        if(!mounted)return;
        setState(() {
          _isProgressView=false;
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
          _isProgressView=false;
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
          _isProgressView=false;
        });
      }
    }



  }

  void getUserProfile() async {
    checkInternet();
    try{
      if(!mounted)return;
      setState(() {
        _isValidateResponse=true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(Strings.google_token);
      API.getUserProfile(token).then((response) {
        int statusCode=response.statusCode;
        if (kDebugMode) {
          print("response marketplace user profile code is $statusCode "+"\n the response body is ${response.body}");
        }
        if(statusCode==200 || statusCode==201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              ProfileModel model=ProfileModel.fromJson(json.decode(response.body));
              if(!mounted)return;
              setState(() {
                _isValidateResponse=false;
                selectableDropDownValue=model.user.distance_unit;
                _value=model.user.distance_margin.toDouble();
                String sliderValue=model.settings.slider_min_max[0].value;
                var parts = sliderValue.split(','); //if slidervalue="2,4";
                var min = parts[0].trim();                 // min: "2"
                var max = parts[1].trim(); //max:4
                minSliderValue=double.parse(min);
                maxSliderValue=double.parse(max);

                sliderDivisonValue= maxSliderValue.toInt()-minSliderValue.toInt();

                if(kDebugMode)
                {
                  print("the min value is $min\n the max is $max");
                }

                if(model.user.is_visible==0)
                {
                  isGoInvisible=true;
                }
                else{
                  isGoInvisible=false;
                }
              });
            }
          else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isValidateResponse=false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
          else{
            if(!mounted)return;
            setState(() {
              _isValidateResponse=false;
            });
          }

        }else{
          if(!mounted)return;
          setState(() {
            _isValidateResponse=false;
          });
        }
      });
    }catch(e){
      if(!mounted)return;
      setState(() {
        _isValidateResponse=false;
      });
      if(kDebugMode){
        print('exception in marketplace get profile is $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider= Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarView(isAppBackBtnVisible: true,titleText: titleText,),
      body: SafeArea(
        child: _isValidateResponse?const CircularProgressScreen()
        :Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:<Widget> [
                  Text(
                    distanceMargin,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  //addVerticalSpace(2.0),
                  Slider(
                    min: minSliderValue,
                    max: maxSliderValue,
                    //divisions: 3,
                    value: _value,
                    label: _value.round().toString(),
                    divisions: sliderDivisonValue,
                    onChanged: (value) {
                      if(!mounted) return;
                      setState(()
                      {
                        applyValue=true;
                        _value = value;
                        if (kDebugMode) {
                          print("value is ${_value.toInt()}");
                        }
                      });
                    },
                  ),
                 // addVerticalSpace(2.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${_value.toInt()}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        //fontWeight: FontWeight.w500,
                      ),
                      ),
                      addHorizontalSpace(4.0),
                      DropdownButton<String>(
                       // hint: Text("Select Value"),
                        underline: SizedBox.shrink(),
                        value: selectableDropDownValue,
                        items: <String>['km', 'mi'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if(!mounted) return;
                          setState(() {
                            applyValue=true;
                            selectableDropDownValue=value!;
                          });
                        },
                      )
                    ],
                  ),
                  //addVerticalSpace(2.0),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ButtonView(
                        text: apply,
                        clickButton: () async {
                      bool value=await checkInternetFromWithinWidgets();
                      if(value)
                        {
                          getCallSetDistancePostAPI(selectableDropDownValue,_value.round().toString());
                        }
                        },
                        isButtonEnabled: applyValue
                    ),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        goInvisible,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: isGoInvisible,
                        onChanged: (value) {
                          if(!mounted) return;
                          setState(()  async {
                            isGoInvisible = value;
                            if(isGoInvisible){
                              bool value=await checkInternetFromWithinWidgets();
                              if(value)
                                {
                                  getCallGOINVISIBLEAPI();
                                }else{
                                isGoInvisible =false;
                              }

                            }else{
                              bool value=await checkInternetFromWithinWidgets();
                              if(value)
                              {
                                getCallGOVISIBLEAPI();
                              }else{
                                isGoInvisible =true;
                              }
                            }
                          });
                        },
                        activeTrackColor: ConstantColors.primaryColor,
                        activeColor: ConstantColors.primaryColor,
                      )

                    ],
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  InkWell(
                    onTap:()async{
                      bool value=await checkInternetFromWithinWidgets();
                      if(value)
                        {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return languageSelectionDialog();
                              }).then((value) async
                          {
                            print("The return value in slect language is $value");
                            if(value.toString().isNotEmpty)
                            {
                              SharedPreferences prefs=await SharedPreferences.getInstance();
                              prefs.setString(Strings.selectedLanguage, value);
                              getCallLanguageTranslate(value);
                            }
                          }
                          );
                        }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                      child: Text(selectLanguage,
                        style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black),),
                    ),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Visibility(
                    visible: false,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Strings.unListCollection,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Switch(
                              value: isUnlistCollection,
                              onChanged: (value) {
                                if(!mounted) return;
                                setState(() {
                                  isUnlistCollection = value;
                                  if(isUnlistCollection){

                                  }else{

                                  }
                                });
                              },
                              activeColor: Colors.grey,
                            )
                          ],
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap:()async{
                      bool value=await checkInternetFromWithinWidgets();
                      if(value)
                        {
                          showAlertDialog(context,authProvider,facebookLoginProvider);
                        }
                      //getCallDeactiveAccountAPI();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(deleteUserAccount,
                      style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.red),),
                    ),
                  )
                  // TextButton(
                  //   style: TextButton.styleFrom(
                  //     textStyle: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
                  //   ),
                  //   onPressed: () {
                  //
                  //   },
                  //   child: Text(Strings.deactiveAccount),
                  // ),

                ],
              ),
            ),
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Visibility(
                  child:const CircularProgressScreen(),
                visible: _isProgressView,
              ),
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
      ),
    );
  }

  void getCallSetDistancePostAPI(String selectableDropDownValue, String sliderValue) async{
    if(!mounted) return;
    setState(() {
      _isProgressView=true;
    });
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? token=prefs.getString(Strings.google_token);
    API.getCallDistanceAPI(token,selectableDropDownValue,sliderValue).then((response)
    {
      int statusCode = response.statusCode;
      if (kDebugMode) {
        print("response status in distance is $statusCode\n the response body is ${response.body}");
      }
      if(statusCode==200|| statusCode==201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if(!mounted)return;
              setState(() {
                _isProgressView=false;
                Fluttertoast.showToast(msg: toastMarginMessage);
                applyValue=false;
              });
            }else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isProgressView=false;
                  Fluttertoast.showToast(msg: toastErrorMsg);
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }else{
            if(!mounted)return;
            setState(() {
              _isProgressView=false;
              Fluttertoast.showToast(msg: toastErrorMsg);
            });
          }

        }
      else{
        if(!mounted)return;
        setState(() {
          _isProgressView=false;
          Fluttertoast.showToast(msg: toastErrorMsg);
        });
      }

    });
  }

  void getCallGOINVISIBLEAPI() async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? token=prefs.getString(Strings.google_token);
    if(!mounted)return;
    setState(() {
      _isProgressView=true;
    });
    API.getCallGOInvisible(token).then((response)
    {
      int statusCode=response.statusCode;
      if (kDebugMode) {
        print("response status in GOINVISIBLE is $statusCode\n the response body is ${response.body}");
      }
      if(statusCode==200||statusCode==201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if(!mounted)return;
              setState(() {
                _isProgressView=false;
                Fluttertoast.showToast(msg: toastGoInvisibleMsg);
              });
            }else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isProgressView=false;
                  Fluttertoast.showToast(msg: toastErrorMsg);
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
          else{
            if(!mounted)return;
            setState(() {
              _isProgressView=false;
              Fluttertoast.showToast(msg: toastErrorMsg);
            });
          }

        }
      else{
        if(!mounted)return;
        setState(() {
          _isProgressView=false;
          Fluttertoast.showToast(msg: toastErrorMsg);
        });
      }

    });
  }

  void getCallGOVISIBLEAPI() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? token=prefs.getString(Strings.google_token);
    if(!mounted)return;
    setState(() {
      _isProgressView=true;
    });
    API.getCallGOVisible(token).then((response)
    {
      int statusCode=response.statusCode;
      if (kDebugMode) {
        print("response status in GO VISIBLE is $statusCode\n the response body is ${response.body}");
      }
      if(statusCode==200||statusCode==201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if(!mounted)return;
              setState(() {
                _isProgressView=false;
                Fluttertoast.showToast(msg: toastGoVisibleMsg);
              });
            }else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isProgressView=false;
                  Fluttertoast.showToast(msg: toastErrorMsg);
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }else{
            if(!mounted)return;
            setState(() {
              _isProgressView=false;
              Fluttertoast.showToast(msg: toastErrorMsg);
            });
          }

        }else{
        if(!mounted)return;
        setState(() {
          _isProgressView=false;
          Fluttertoast.showToast(msg: toastErrorMsg);
        });
      }
    });
  }

  void getCallDeActiveAccountAPI(AuthProvider authProvider, FacebookLoginProvider facebookLoginProvider) async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? token=prefs.getString(Strings.google_token);
    String? loginProfileType=prefs.getString(Strings.loginProfileType);
    if(!mounted)return;
    setState(() {
      _isProgressView=true;
    });
    homeProvider.deleteMessageFireStore(FirestoreConstants.pathMessageCollection, currentUserId).whenComplete((){
      homeProvider.deleteUserFireStore(FirestoreConstants.pathUserCollection, currentUserId).whenComplete(()
      {
        if (kDebugMode) {
          print("delete USer doc id $currentUserId completed");
        }
      });
    });

    API.getCallDeActivateAccount(token).then((response)
    async {
      int statusCode=response.statusCode;
      if (kDebugMode) {
        print("response status in deactivate account  is $statusCode\n the response body is ${response.body}");
      }
      if(statusCode==200||statusCode==201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if(loginProfileType==Strings.facebook)
                {
                  bool isSuccess=await facebookLoginProvider.allowUserToSignOut();
                  if(isSuccess)
                    {
                      if(!mounted)return;
                      setState(() {
                        _isProgressView=false;
                      });
                      SharedPreferences prefs=await SharedPreferences.getInstance();
                      prefs.clear();
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const LoginScreen()),
                              (Route<dynamic>route) => false);
                      Fluttertoast.showToast(msg: toastLogoutMsg);
                    }
                }
              else{
                bool isSuccess= await authProvider.handleSignout(); //Logout the User after his/her account deleted.
                if(isSuccess)
                {
                  if (kDebugMode) {
                    print("success in logout");
                  }
                  setState(() {
                    _isProgressView=false;
                  });
                  SharedPreferences prefs=await SharedPreferences.getInstance();
                  prefs.clear();
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const LoginScreen()),
                          (Route<dynamic>route) => false);
                  Fluttertoast.showToast(msg: toastLogoutMsg);
                  // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>LoginScreen()));
                }
                else{
                  print("something went wrong");
                  if(!mounted)return;
                  setState(() {
                    _isProgressView=false;
                  });
                }
              }
            }
          else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(()
                {
                  _isProgressView=false;
                  Fluttertoast.showToast(msg: toastErrorMsg);
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
          else{
            if(!mounted)return;
            setState(()
            {
              _isProgressView=false;
              Fluttertoast.showToast(msg: toastErrorMsg);
            });
          }

        }else{
        if(!mounted)return;
        setState(()
        {
          _isProgressView=false;
          Fluttertoast.showToast(msg: toastErrorMsg);
        });
      }
    });
  }

  showAlertDialog(BuildContext context, AuthProvider authProvider, FacebookLoginProvider facebookLoginProvider)
  {
    // set up the button
    Widget okButton = TextButton(
      child: Text(ok),
      onPressed: () async{
        bool value=await checkInternetFromWithinWidgets();
        if(value)
          {
            getCallDeActiveAccountAPI(authProvider,facebookLoginProvider);
          }
        Navigator.of(context).pop();
      },
    );

    Widget cancelButton = TextButton
      (
      child: Text(cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(child: Text(warningMessage)),
      content: Text(alertDeleteMessage),
      actions: [
        cancelButton,
        okButton
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }




}
