import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/login_screen.dart';
import 'package:tradz/model/app_setting_model.dart';
import 'package:tradz/model/report_product_model.dart';

import '../allConstants/Colors/ConstantColors.dart';
import '../allConstants/Strings/Strings.dart';
import '../allWidgets/helper_widget.dart';

class ProductReportDialog extends StatefulWidget {
  final int productID;
  //final List<ReportRadioMessage> reportList;

  const ProductReportDialog(this.productID, {Key? key})
      : super(key: key);

  @override
  State<ProductReportDialog> createState() => _ProductReportDialogState();
}

class _ProductReportDialogState extends State<ProductReportDialog> {
  final _formKey = GlobalKey<FormState>();
  int value = 0;
  int reportID = 0;
  String reportMessage = '';
  bool _isTextFieldNotEmpty = false;
  bool _isProgressBar = false;
  ScrollController _controller = ScrollController();
  TextEditingController _textFieldController = TextEditingController();
  List<ReportRadioMessage> reportList = [];
  String reportUser='';
  String noInternetMessage='';
  bool _isInternet = false;
  String cancel='';
  String send='';
  late String token;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;

  @override
  void initState()
  {
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    authProvider = context.read<AuthProvider>();
    token = authProvider.getUserTokenID()!;
    checkSelectedLanguage();
    getCallAppSettingAPI(widget.productID);
    if (kDebugMode) {
      print("the product id is ${widget.productID}");
    }
    super.initState();
  }
  getCallAppSettingAPI(int productID)
  {
    try {
      if(!mounted)return;
      setState(() {
        _isProgressBar = true;
      });
      API.getCallAppSetting(token).then((response) async {
        int statusCode = response.statusCode;
        if (kDebugMode) {
          print("the status is $statusCode\n the response is ${response.body}");
        }
        if (statusCode == 200 || statusCode == 201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              AppSettingModel model =
              AppSettingModel.fromJson(json.decode(response.body));
              if(!mounted)return;
              setState(() {
                _isProgressBar = false;
                reportList.addAll(model.settings.report_radio_message);
              });
            }else if(body['status']=='unauthenticated')
              {
                setState(() {
                  _isProgressBar = false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
        } else {
          setState(() {
            _isProgressBar = false;
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("the exception in AppSettingApi is $e");
      }
    }
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
        Fluttertoast.showToast(msg: "Account already deleted");
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

  void checkSelectedLanguage()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale=='hi')
          {
            if(!mounted)return;
            setState(() {
              reportUser=Strings.reportUser_hi;
              cancel=Strings.cancel_hi;
              send=Strings.sendButton_hi;
              noInternetMessage=Strings.noInternetMessage_hi;
            });
          }else if(locale=='bn')
            {
              if(!mounted)return;
              setState(() {
                reportUser=Strings.reportUser_bn;
                cancel=Strings.cancel_bn;
                send=Strings.sendButton_bn;
                noInternetMessage=Strings.noInternetMessage_bn;
              });
            }else if(locale=='te')
              {
                if(!mounted)return;
                setState(() {
                  reportUser=Strings.reportUser_te;
                  cancel=Strings.cancel_te;
                  send=Strings.sendButton_te;
                  noInternetMessage=Strings.noInternetMessage_te;
                });
              }else{
          if(!mounted)return;
          setState(() {
            reportUser=Strings.reportUser;
            cancel=Strings.cancelButton;
            send=Strings.sendButton;
            noInternetMessage=Strings.noInternetMessage;
          });
        }
      }else{
      if(!mounted)return;
      setState(() {
        reportUser=Strings.reportUser;
        cancel=Strings.cancelButton;
        send=Strings.sendButton;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 40, 8, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reportUser,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    addVerticalSpace(5.0),
                    ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        controller: _controller,
                        scrollDirection: Axis.vertical,
                        itemCount: reportList.isNotEmpty
                            ? reportList.length
                            : 0,
                        itemBuilder: (BuildContext context, int index) {
                          final model = reportList[index];
                          reportID = reportList[0].id;
                          reportMessage = reportList[0].message;
                          return RadioListTile
                            (
                            value: index,
                            groupValue: value,
                            onChanged: (int? val) {
                              setState(() {
                                value = val!;
                                reportID = model.id;
                                reportMessage = model.message;
                                if (kDebugMode) {
                                  print(
                                      "the index is ${model.id} \n the message is ${model.message}");
                                }
                              });
                            },
                            title: Text(model.message),
                          );
                        }),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              _isTextFieldNotEmpty = true;
                            });
                          } else {
                            setState(() {
                              _isTextFieldNotEmpty = false;
                            });
                          }
                        },
                        controller: _textFieldController,
                        maxLength: 50,
                        maxLines: 2,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(
                          hintText: "Enter report reason",
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    addVerticalSpace(20.0),
                    Visibility(
                      visible: reportList.isNotEmpty,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              cancel,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          addHorizontalSpace(10.0),
                          ElevatedButton(
                            onPressed: () {
                              getCallProductReporting();
                            },
                            child: Text(
                              send+" ",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Visibility(
                child: const CircularProgressScreen(),
                visible: _isProgressBar,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.width * -0.10,
              child: SvgPicture.asset(
                'assets/images/stop_sign.svg',
                height: MediaQuery.of(context).size.height * 0.10,
                width: MediaQuery.of(context).size.width * 0.10,
              ),
              // CircleAvatar(
              //   backgroundColor: Colors.red,
              //   radius: 40,
              //   child:
              //   Center(child: SvgPicture.asset('assets/images/stop_sign.svg',height: 48.0,width: 48.0,color: Colors.white,)),
              // )
            ),
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: NoInternetView(isInternet: _isInternet, noInternetMessage: noInternetMessage,)),
          ],
        ));
  }

  getCallProductReporting() async {
    if (kDebugMode) {
      print(
          'texfield is ${_textFieldController.text.isEmpty} the report id is $reportID');
    }
    if (!mounted) return;
    setState(() {
      _isProgressBar = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    ReportProductModel model = ReportProductModel(
        product_id: widget.productID,
        reason: _textFieldController.text,
        radio_message_id: reportID);
    API.postReportUserProduct(model.toMap(), token).then((response) {
      int statusCode = response.statusCode;
      if (kDebugMode) {
        print(
            "the status code is $statusCode\n the response of reportProduct is ${response.body}");
      }
      if (statusCode == 200 || statusCode == 201)
      {

        final body = json.decode(response.body);
        if(body['status']==true)
          {
            if (!mounted) return;
            setState(() {
              _isProgressBar = false;
              Navigator.of(context).pop(response.body);
            });
          }else if(body['status']=='unauthenticated'){
          if (!mounted) return;
          setState(() {
            _isProgressBar = false;
          });
          getCallSignout(authProvider, facebookLoginProvider);
        }

      }
      else {
        if (!mounted) return;
        setState(() {
          _isProgressBar = false;
          Navigator.of(context).pop();
        });
      }
    });
  }
}
