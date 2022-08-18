import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:tradz/app_screens/add_product_details.dart';
import 'package:tradz/model/subcategories_model.dart';
import 'package:translator/translator.dart';

import 'login_screen.dart';
class SubCategoryScreen extends StatefulWidget {

  final int categoryID;
  String category;
  final int productID,productPrice;
  String  productdetails,productTitle,lookingFor;
  final List<String> ImageUrl;
   SubCategoryScreen(
      {Key? key,
        required this.category,
        required this.categoryID,
        required this.productID,
        required this.productPrice,
        required this.lookingFor,
        required this.ImageUrl,
        required this.productdetails,
        required this.productTitle,
      }) : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  final translator = GoogleTranslator();
  List<SubCategoriesTradz> tradzSubCategories = [];
  late SubCategoriesModel subCategoriesModel;
  bool _isProgressBar = true;
  bool _isInternet = false;
  String noInternetMessage='';
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;
  @override
  void initState() {
    authProvider= context.read<AuthProvider>();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
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
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? locale = prefs.getString(Strings.selectedLanguage);
      if(locale!=null)
        {
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
          if(locale!="en")
            {
              await translator.translate(widget.category,to:locale).then((value)
              {
                if(!mounted)return;
                setState(() {
                  widget.category=value.toString();
                });
              });
            }
        }
      else{
        if(!mounted)return;
        setState(() {
          noInternetMessage=Strings.noInternetMessage;
        });
      }
    }catch(e)
    {
      if(kDebugMode)
        {
          print("The exception is $e");
        }
    }
    getCallSubCategories(widget.categoryID.toString());
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
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>LoginScreen()));
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

  void getCallSubCategories(String? value) async
  {
    checkInternet();
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(Strings.google_token);
      API.getSubCategories(token, value.toString()).then((response) {
        int statusCode = response.statusCode;
        print("response of subcat is ${response.body}");
        if (statusCode == 200 || statusCode==201) {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if(!mounted)return;
              setState(() {
                _isProgressBar=false;
                subCategoriesModel =
                    SubCategoriesModel.fromJson(json.decode(response.body));
                tradzSubCategories=subCategoriesModel.sub_categories;
              });
            }
          else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isProgressBar = true;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
          else{
            if(!mounted)return;
            setState(() {
              _isProgressBar = true;
            });
          }
        }
        else{
          if(!mounted)return;
          setState(() {
            _isProgressBar = true;
          });
        }

      });
    }
    catch(e)
    {
      if (kDebugMode) {
        print('exception is $e');
      }
      setState(() {
        _isProgressBar = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBarView(
        isAppBackBtnVisible: true,
        titleText: widget.category,
      ),
      body: Stack(
        children: [
          GridView.builder(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: tradzSubCategories.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemBuilder: (BuildContext context, int index)
              {
                final model = tradzSubCategories[index];
                return InkWell(
                  onTap: () async{
                    bool value=await checkInternetFromWithinWidgets();
                    if(value)
                      {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  AddProductDetails( //parameter passed are empty in case new Product added and non empty in cas of Update Product.
                                    categoryId:widget.categoryID,
                                    categoryText:widget.category,
                                    lookingFor: widget.lookingFor,
                                    subcategoryId:model.id,
                                    subcategoryText:model.text,
                                    productPrice: widget.productPrice,
                                    productdetails: widget.productdetails,
                                    productID: widget.productID,
                                    ImageUrl: widget.ImageUrl,
                                    productTitle: widget.productTitle,
                                  ),
                            ));
                      }
                  },
                  child: CategoryViewWidget(categoryText: model.text, imageBlob: model.image_blob,)
                  // Column(
                  //   children: [
                  //     model.image_blob.isNotEmpty?
                  //     Image.memory(base64Decode(model.image_blob),fit: BoxFit.cover,)
                  //         :SvgPicture.asset(
                  //       'assets/images/electric_motor_icon.svg',
                  //       height: 48.0,
                  //       width: 48.0,
                  //     ),
                  //     addVerticalSpace(
                  //         4.0
                  //     ),
                  //     Expanded(
                  //         child: Text(
                  //           model.text,
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
