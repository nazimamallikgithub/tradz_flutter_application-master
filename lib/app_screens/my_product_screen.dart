import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Constant/Constant.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/empty_result_widget.dart';
import 'package:tradz/allWidgets/grid_view_widget.dart';
import 'package:tradz/allWidgets/linear_view_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/product_details_screen.dart';
import 'package:tradz/dialogs/product_report_dialog.dart';
import 'package:tradz/model/user_product_model.dart';
import 'package:translator/translator.dart';

import 'login_screen.dart';
class MyProductScreen extends StatefulWidget {
  const MyProductScreen({Key? key}) : super(key: key);
  @override
  State<MyProductScreen> createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> {
  final translator = GoogleTranslator();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  late UserProductModel userProductModel;
  bool _isValidateResponse=true;
  bool _isProgressVisible=false;
  bool _isGridView=true;
  int page=1;
  String myEmailID='';
  ScrollController _controller=ScrollController();
  List<UserProductData> DataList=[];
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;

  String my_items='';String emptyResult='';
  String alertDeleteProductMessage='';
   String    warningMessage='';
   String toastErrorMsg='';
  String productDeletedToast='';
  String ok='';
  String cancel='';
  String? locale;
  String noInternetMessage='';
  bool _isInternet = false;

  @override
  void initState() {
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    authProvider = context.read<AuthProvider>();
    checkSelectedLanguage();
    checkView();
    getCallUSerProductAPI(page);
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

  void checkSelectedLanguage() async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
    {
      if(locale=='hi')
        {
          if(!mounted) return;
          setState(() {
            productDeletedToast=Strings.productDeletedToast_hi;
            ok=Strings.ok_hi;
            cancel=Strings.cancel_hi;
            my_items=Strings.my_items_hi;
            emptyResult=Strings.emptyResult_hi;
            alertDeleteProductMessage=Strings.alertDeleteProductMessage_hi;
            warningMessage=Strings.warningMessage_hi;
            toastErrorMsg=Strings.toastErrorMsg_hi;
            noInternetMessage=Strings.noInternetMessage_hi;
          });
        }
      else if(locale=='bn')
        {
          if(!mounted) return;
          setState(() {
            productDeletedToast=Strings.productDeletedToast_bn;
            ok=Strings.ok_bn;
            cancel=Strings.cancel_bn;
            my_items=Strings.my_items_bn;
            emptyResult=Strings.emptyResult_bn;
            alertDeleteProductMessage=Strings.alertDeleteProductMessage_bn;
            warningMessage=Strings.warningMessage_bn;
            toastErrorMsg=Strings.toastErrorMsg_bn;
            noInternetMessage=Strings.noInternetMessage_bn;
          });
        }
      else if(locale=='te')
        {
          if(!mounted) return;
          setState(() {
            productDeletedToast=Strings.productDeletedToast_te;
            ok=Strings.ok_te;
            cancel=Strings.cancel_te;
            my_items=Strings.my_items_te;
            emptyResult=Strings.emptyResult_te;
            alertDeleteProductMessage=Strings.alertDeleteProductMessage_te;
            warningMessage=Strings.warningMessage_te;
            toastErrorMsg=Strings.toastErrorMsg_te;
            noInternetMessage=Strings.noInternetMessage_te;
          });
        }
      else
      {
        if(!mounted) return;
        setState(() {
          productDeletedToast=Strings.productDeletedToast;
          ok=Strings.ok;
          cancel=Strings.cancel;
          my_items=Strings.my_items;
          emptyResult=Strings.emptyResult;
          alertDeleteProductMessage=Strings.alertDeleteProductMessage;
          warningMessage=Strings.warningMessage;
          toastErrorMsg=Strings.toastErrorMsg;
          noInternetMessage=Strings.noInternetMessage;
        });
      }
      // else{
      //   await translator.translate(my_items,to:locale).then((value){
      //     print("The value after translate is $value");
      //     if(!mounted)return;
      //     setState(() {
      //       my_items=value.toString();
      //     });
      //   });
      //   await translator.translate(my_items,to:locale).then((value){
      //     print("The value after translate is $value");
      //     if(!mounted)return;
      //     setState(() {
      //       my_items=value.toString();
      //     });
      //   });
      //   await translator.translate(emptyResult,to:locale).then((value){
      //     print("The value after translate is $value");
      //     if(!mounted)return;
      //     setState(() {
      //       emptyResult=value.toString();
      //     });
      //   });
      //   await translator.translate(alertDeleteProductMessage,to:locale).then((value){
      //     print("The value after translate is $value");
      //     if(!mounted)return;
      //     setState(() {
      //       alertDeleteProductMessage=value.toString();
      //     });
      //   });
      //   await translator.translate(warningMessage,to:locale).then((value){
      //     print("The value after translate is $value");
      //     if(!mounted)return;
      //     setState(() {
      //       warningMessage=value.toString();
      //     });
      //   });
      //
      // }
    }
    else{
      if(!mounted)return;
      setState(() {
        productDeletedToast=Strings.productDeletedToast;
        ok=Strings.ok;
        cancel=Strings.cancel;
        my_items=Strings.my_items;
        emptyResult=Strings.emptyResult;
        alertDeleteProductMessage=Strings.alertDeleteProductMessage;
        warningMessage=Strings.warningMessage;
        toastErrorMsg=Strings.toastErrorMsg;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
  }


  void checkView()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    if(prefs.getBool(Strings.isGridView)!=null)
      {
        _isGridView=prefs.getBool(Strings.isGridView)!;
      }
  }

  void _scrollListener() {
    if(_controller.offset>=_controller.position.maxScrollExtent
    && !_controller.position.outOfRange
    )
      {
        if(!mounted) return;
        setState(() {
          _isProgressVisible=true;
          page=page+1;
          if (kDebugMode) {
            print("page value is $page");
          }
          getCallUSerProductAPI(page);
        });
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

  void getCallUSerProductAPI(int page) async
  {
    checkInternet();
    try{
      SharedPreferences prefs= await SharedPreferences.getInstance();
      String? token= prefs.getString(Strings.google_token);
      myEmailID=prefs.getString(FirestoreConstants.email)!;
      API.getUserProduct(page,token).then((response){
        var statusCode=response.statusCode;

        if(statusCode==200|| statusCode==201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if(!mounted)return;
              setState(()
              {
                _isValidateResponse=false;
                _isProgressVisible=false;
                userProductModel=UserProductModel.fromJson(json.decode(response.body));
                DataList.addAll(userProductModel.products.data);
              });
            }
          else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isValidateResponse=false;
                  _isProgressVisible=false;
                  if(page!=1)
                  {
                    page--;
                  }
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
          else{
            if(!mounted)return;
            setState(() {
              _isValidateResponse=false;
              _isProgressVisible=false;
              if(page!=1)
              {
                page--;
              }
            });
            Fluttertoast.showToast(msg: toastErrorMsg);
          }
        }
        else
        {
          if(!mounted)return;
          setState(() {
            _isValidateResponse=false;
            _isProgressVisible=false;
            if(page!=1)
            {
              page--;
            }
          });
          Fluttertoast.showToast(msg: toastErrorMsg);
        }
      });
    }
    catch(e)
    {
      if(!mounted)return;
      setState(() {
        _isProgressVisible=false;
        _isValidateResponse=false;
        if(page!=1)
        {
          page--;
        }
      });
    }

  }

  void getCallDeleteProduct(int productID) async
  {
    if(!mounted)return;
    setState(() {
      _isProgressVisible=true;
    });
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? token=prefs.getString(Strings.google_token);
    API.getCallDeleteProduct(token, productID).then((response)
    {
      var statusCode=response.statusCode;
      if(kDebugMode)
        {
          print("The response status is $statusCode and \n body  of getCallDeleteProduct is ${response.body}");
        }
      if(statusCode==200|| statusCode==201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              Fluttertoast.showToast(msg: productDeletedToast);
              if(!mounted)return;
              setState(() {
                DataList.clear();
                _isProgressVisible=false;
                _isValidateResponse=true;
                page=1;
              });
              getCallUSerProductAPI(page);
            }
          else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isProgressVisible=false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
          else
          {
            if(!mounted)return;
            setState(() {
              _isProgressVisible=false;
            });
          }
        }
      else{
        if(!mounted)return;
        setState(() {
          _isProgressVisible=false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBarView(isAppBackBtnVisible: true, titleText: my_items,),
      body: _isValidateResponse
          ? const CircularProgressScreen()
          :DataList.isEmpty?EmptyResultWidget(emptyResult)
      :Stack(
            children: [
             RefreshIndicator(
               key: _refreshIndicatorKey,
               onRefresh: refreshWidgets,
               child: Container(
                 child:  _isGridView?
                 GridView.builder(
                     padding: const EdgeInsets.all(8.0),
                     physics: const ClampingScrollPhysics(),
                     scrollDirection: Axis.vertical,
                     shrinkWrap: true,
                     controller: _controller,
                     itemCount: DataList.isNotEmpty?DataList.length:0,
                     //userProductModel.products.data.isNotEmpty?userProductModel.products.data.length:0,
                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                       crossAxisCount: 2,
                       mainAxisSpacing: 4.0,
                       crossAxisSpacing: 4.0,
                       childAspectRatio: 0.7,
                     ),
                     itemBuilder:(BuildContext context, int index) {
                       final model = DataList[index];
                       return GestureDetector(
                         onTap: () async
                         {
                          bool value=await checkInternetFromWithinWidgets();
                          if(value)
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
                                  ProductDetailsScreen
                                    (
                                      productID: model.id,
                                      isMessageIconVisible: false)
                              )
                              );
                            }
                         },
                         child: GridViewWidget(
                           productName: model.title,
                           distance: 0,
                          // locale: locale!,
                           distanceUnit: '',
                           assetImage: model.user_details.image_avatar_path,
                           lookingFor: model.looking_for,
                           likedCallBack: () {
                             setState(() {
                               // isLikedItem=!isLikedItem;

                               // product['isProductLiked']=isLikedItem;
                             });
                           },
                           productOwnerName: model.user_details.first_name,
                           messageCallBack: () {

                           },
                           productImageUrl: model.base_64_images.isNotEmpty?model.base_64_images[0]:"",
                           isItemLiked: false,
                           isMarketPlaceView: true,
                           productOwnerUrl: model.user_details.image_b64,
                           //Constant.baseurl + model.user_details.image_avatar_path,
                           like_count: model.likes_count,
                           isMessageIconVisible: false,
                           reportCallBack: () async{
                             bool value=await checkInternetFromWithinWidgets();
                             if(value)
                               {
                                 showAlertDialog(context,model.id);
                               }
                           },
                           isOwnerItem: model.user_details.email!=myEmailID?false:true,
                           isDeleteButtonEnabled: true,  //this will replace report button with delete button to delete the Product.
                         ),
                       );
                     }

                 )
                     :ListView.builder(
                     padding: const EdgeInsets.all(8.0),
                     physics: const ClampingScrollPhysics(),
                     shrinkWrap: true,
                     scrollDirection: Axis.vertical,
                     itemCount:  DataList.isNotEmpty?DataList.length:0,
                     itemBuilder: (BuildContext context, int index){
                       final model=DataList[index];
                       return GestureDetector(
                         onTap: ()
                         {
                           Navigator.push(context,
                               MaterialPageRoute(builder: (BuildContext context)
                               =>ProductDetailsScreen(
                                 productID: model.id,
                                 isMessageIconVisible: false)
                               )
                           );
                         },
                         child: LinearViewWidget(
                           isItemLiked: false,
                           distance: 0,
                           distanceUnit: '',
                           assetImage: model.user_details.image_avatar_path,
                           lookingFor: model.looking_for,
                           productImageUrl: model.base_64_images.isNotEmpty?model.base_64_images[0]:"",
                           productName: model.title,
                           productOwnerName: model.user_details.first_name,
                           messageCallBack: (){
                           },
                           likedCallBack:(){

                           },
                           productDetails: model.description,
                           productOwnerUrl: model.user_details.image_b64,
                           isMarketPlaceView: true, likes_count: model.likes_count,
                           isMessageIconVisible: false,
                           reportCallBack: () async{
                             bool value=await checkInternetFromWithinWidgets();
                             if(value)
                               {
                                 showAlertDialog(context,model.id);
                               }
                           }, isOwnerItem: true,
                           isDeleteButtonEnabled: true,  // isDeleteButtonEnabled is only for the MyProductScreen to dete the product.
                         ),
                       );
                     }
                 ),
               ),
             ),
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

  Future<void> refreshWidgets() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isProgressVisible=false;
      DataList.clear();
      page = 1;
      // _isProgressVisible=true;
      _isValidateResponse = true;
      DataList.clear();
    });
    getCallUSerProductAPI(page);
  }


  showAlertDialog(BuildContext context, int productID) {

    // set up the button
    Widget okButton = TextButton(
      child: Text(ok),
      onPressed: () {
        getCallDeleteProduct(productID);
        Navigator.of(context).pop();
      },
    );

    Widget cancelButton = TextButton(
      child: Text(cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(child: Text(warningMessage)),
      content: Text(alertDeleteProductMessage),
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
