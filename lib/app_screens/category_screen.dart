import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/category_view_widget.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/subcategory_screen.dart';
import 'package:tradz/model/categories_model.dart';
import 'package:translator/translator.dart';

import 'login_screen.dart';

class CategoryScreen extends StatefulWidget {
  final int productID, productPrice;
  String category, subCategory, productdetails, productTitle, lookingFor;
  final List<String> ImageUrl;

  CategoryScreen(
      {Key? key,
      required this.productID,
      required this.productPrice,
      required this.lookingFor,
      required this.ImageUrl,
      required this.category,
      required this.subCategory,
      required this.productdetails,
      required this.productTitle})
      : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
{
  final translator = GoogleTranslator();
  bool _isProgressBar = true;
  late CategoriesModel categoriesModel;
  String titleSelected = 'Selected:';
  String titleOfferingText = 'What you are offering?';
  List<Categories> tradzCategory = [];
  bool _isInternet = false;
  String noInternetMessage='';
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;

  @override
  void initState() {
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    authProvider = context.read<AuthProvider>();
    checkSelectedLanguage();
    super.initState();
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
        _isProgressBar = false;
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

  void checkSelectedLanguage() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? locale = prefs.getString(Strings.selectedLanguage);
    if (locale != null) {
      if(locale=='hi')
        {
          if(!mounted)return;
          setState(() {
            noInternetMessage=Strings.noInternetMessage_hi;
          });
        }else if(locale=='bn')
          {
            if(!mounted)return;
            setState(() {
              noInternetMessage=Strings.noInternetMessage_bn;
            });
          }else if(locale=='te')
            {
              if(!mounted)return;
              setState(() {
                noInternetMessage=Strings.noInternetMessage_te;
              });
            }else{
        if(!mounted)return;
        setState(() {
          noInternetMessage=Strings.noInternetMessage;
        });
      }
      if (locale != "en") {
        try {
          await translator.translate(widget.category, to: locale).then((value) {
            print("The value after translate in Category is $value");
            if (!mounted) return;
            setState(() {
              widget.category = value.toString();
            });
          });
        } catch (e) {
          if (kDebugMode) {
            print(
                "the exception in translation widget.category in category is $e");
          }
        }
        try {
          await translator.translate(titleSelected, to: locale).then((value) {
            print(
                "The value after translate titleSelected in CategoryScreen is $value");
            if (!mounted) return;
            setState(() {
              titleSelected = value.toString();
            });
          });
        } catch (e) {
          if (kDebugMode) {
            print(
                "the exception in translation titleSelected in category is $e");
          }
        }

        try {
          await translator
              .translate(titleOfferingText, to: locale)
              .then((value) {
            print("The value after translate in titleOfferingText is $value");
            if (!mounted) return;
            setState(() {
              titleOfferingText = value.toString();
            });
          });
        } catch (e)
        {
          if (kDebugMode) {
            print("the exception in translation titleOfferingText in category is $e");
          }
        }
      }
    }
    else{
      if(!mounted)return;
      setState(() {
        noInternetMessage=Strings.noInternetMessage;
      });
    }

    getCallCategories();
  }

  void getCallCategories() async
  {
    checkInternet();
    tradzCategory.clear();
    // if(!mounted)return;
    // setState(() {
    //   _isProgressBar = true;
    // });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    if (kDebugMode) {
      print("token value is $token");
    }
    try {
      API.getCategories(token).then((response) {
        int statusCode = response.statusCode;
        if (kDebugMode) {
          print("the response is ${response.body}");
        }
        if (statusCode == 200) {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              categoriesModel =
                  CategoriesModel.fromJson(json.decode(response.body));
              tradzCategory = categoriesModel.categories;
              setState(() {
                _isProgressBar = false;
              });
            }
          else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isProgressBar = false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
          else{
            if(!mounted)return;
            setState(() {
              _isProgressBar = false;
            });
          }

        } else {
          if(!mounted)return;
          setState(() {
            _isProgressBar = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isProgressBar = false;
      });
      if (kDebugMode) {
        print("Exception in getCategories is $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(
          titleText: widget.category.isNotEmpty
              ? titleSelected + " " + widget.category
              : titleOfferingText,
          isAppBackBtnVisible: true),
      body: Stack(
        children: [
          GridView.builder(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: tradzCategory.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                final item = tradzCategory[index];
                return InkWell(
                    onTap: () async{
                      bool value=await checkInternetFromWithinWidgets();
                      if(value)
                        {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (Context) => SubCategoryScreen(
                                  //passsing parameter are empty in case new Product creation,in case Update product parameter value is passed from edit Product.
                                  category: item.text,
                                  categoryID: item.id,
                                  lookingFor: widget.lookingFor,
                                  productPrice: widget.productPrice,
                                  ImageUrl: widget.ImageUrl,
                                  productdetails: widget.productdetails,
                                  productTitle: widget.productTitle,
                                  productID: widget.productID,
                                ),
                              ));
                        }
                    },
                    child: CategoryViewWidget(
                      categoryText: item.text,
                      imageBlob: item.image_blob,
                    )
                    // Column(
                    //   children: [
                    //     item.image_blob.isNotEmpty?
                    //    Image.memory(base64Decode(item.image_blob),fit: BoxFit.cover,)
                    //     :SvgPicture.asset(
                    //       'assets/images/electric_motor_icon.svg',
                    //       height: 48.0,
                    //       width: 48.0,
                    //     ),
                    //     addVerticalSpace(
                    //       4.0
                    //     ),
                    //     Expanded(
                    //         child: Text(
                    //           item.text,
                    //           textAlign: TextAlign.center,
                    //           style: const TextStyle(
                    //               color: ConstantColors.primaryColor),
                    //         )),
                    //   ],
                    // ),
                    );
              }),
          Visibility(
            child: const CircularProgressScreen(),
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
          //             Icon(Icons.error_outline,color: ConstantColors.primaryColor,
          //               size: MediaQuery.of(context).size.height*0.10,),
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
