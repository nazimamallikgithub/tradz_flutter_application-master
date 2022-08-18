import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
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
import 'package:tradz/allProvider/view_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/empty_result_widget.dart';
import 'package:tradz/allWidgets/grid_view_widget.dart';
import 'package:tradz/allWidgets/linear_view_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/product_details_screen.dart';
import 'package:tradz/dialogs/product_report_dialog.dart';
import 'package:tradz/dialogs/userMessage_dialog.dart';
import 'package:tradz/model/app_setting_model.dart';
import 'package:tradz/model/liked_product_model.dart';
import 'package:tradz/model/post_unlike_model.dart';
import 'package:tradz/model/report_product_resposne_model.dart';

import 'login_screen.dart';

class LikedItemScreen extends StatefulWidget {
  const LikedItemScreen({Key? key}) : super(key: key);

  @override
  LikedItemState createState() => LikedItemState();
}

class LikedItemState extends State<LikedItemScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  bool _isGridView = true;
  bool _isProgressVisible = false;
  int page = 1;
  bool _isValidateResponse=true;
  late String token;
  String chatInitiatedToast='';
  String likeProductEmptyMessage='';
  ScrollController _controller = ScrollController();
  List<Data> DataList = [];
  List<int> messagedProductList=[];// this list store the number of product to whom the user messaged for initiate Chat.
  late LikedProductModel likedProductModel;
  late String currentUserId;
  late AuthProvider authProvider;
  String warningText='';
  String messageText='';
  String cancel='';
  String send='';
  String noInternetMessage='';
  bool _isInternet = false;
  late FacebookLoginProvider facebookLoginProvider;

  @override
  void initState() {
    checkSelectedLanguage();
    authProvider=context.read<AuthProvider>();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    if(authProvider.getUserFirebaseId()?.isNotEmpty==true)
    {
      currentUserId =authProvider.getUserFirebaseId()!;
    }
    token=authProvider.getUserTokenID()!;
    getCallPrefrence();
    getCallLikedProduct(page);
    _controller.addListener(() {
      _scrollListener();
    });
    super.initState();
  }

  void checkSelectedLanguage() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale=='hi')
          {
            if(!mounted)return;
            setState
              (() {
              chatInitiatedToast=Strings.chatInitiatedToast_hi;
              likeProductEmptyMessage=Strings.likeProductEmptyMessage_hi;
              warningText=Strings.warningText_hi;
              messageText=Strings.newlyChatMessage_hi;
              cancel=Strings.cancel_hi;
              send=Strings.sendButton_hi;
              noInternetMessage=Strings.noInternetMessage_hi;
            });
          }
        else if(locale=='bn')
          {
            if(!mounted)return;
            setState(() {
              chatInitiatedToast=Strings.chatInitiatedToast_bn;
              likeProductEmptyMessage=Strings.likeProductEmptyMessage_bn;
              warningText=Strings.warningText_bn;
              messageText=Strings.newlyChatMessage_bn;
              cancel=Strings.cancel_bn;
              send=Strings.sendButton_bn;
              noInternetMessage=Strings.noInternetMessage_bn;
            });
          }
        else if(locale=='te')
            {
              if(!mounted)return;
              setState(() {
                chatInitiatedToast=Strings.chatInitiatedToast_te;
                likeProductEmptyMessage=Strings.likeProductEmptyMessage_te;
                warningText=Strings.warningText_te;
                messageText=Strings.newlyChatMessage_te;
                cancel=Strings.cancel_te;
                send=Strings.sendButton_te;
                noInternetMessage=Strings.noInternetMessage_te;
              });
            }else{
          if(!mounted)return;
          setState(() {
            chatInitiatedToast=Strings.chatInitiatedToast;
            likeProductEmptyMessage=Strings.likeProductEmptyMessage;
            warningText=Strings.warningText;
            messageText=Strings.newlyChatMessage;
            cancel=Strings.cancelButton;
            send=Strings.sendButton;
            noInternetMessage=Strings.noInternetMessage;
          });
        }
      }
    else{
      if(!mounted)return;
      setState(() {
        chatInitiatedToast=Strings.chatInitiatedToast;
        likeProductEmptyMessage=Strings.likeProductEmptyMessage;
        warningText=Strings.warningText;
        messageText=Strings.newlyChatMessage;
        cancel=Strings.cancelButton;
        send=Strings.sendButton;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
  }

  void getCallPrefrence() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _isGridView = prefs.getBool(Strings.isGridView)!;
      });
    }catch(e){
      if(kDebugMode)
        {
          print("the xception is $e");
        }
    }
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
      else
      {
        print("something went wrong");
        if(!mounted)return;
        setState(() {
          _isProgressVisible=false;
        });
      }
    }



  }

  void getCallLikedProduct(int page) async {
    try {
      checkInternet();
      messagedProductList.clear();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(Strings.google_token);
      API.getUserLikedProduct(token, page).then((response) {
        int statusCode = response.statusCode;
        print("Response of getLiked is ${response.body}");
        if (statusCode == 200 || statusCode == 201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              setState(() {
                _isValidateResponse=false; //this check only when method calls first time.
                _isProgressVisible = false;
                likedProductModel =
                    LikedProductModel.fromJson(json.decode(response.body));
                DataList.addAll(likedProductModel.items.data);
                messagedProductList.addAll(likedProductModel.active_chats);
              });
            }else if(body['status']=='unauthenticated')
              {
                setState(() {
                  _isValidateResponse=false;
                  _isProgressVisible = false;
                  if(page!=1)
                  {
                    page--;
                  }
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }

        } else {

          setState(() {
            _isValidateResponse=false;
            _isProgressVisible = false;
            if(page!=1)
            {
              page--;
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        if (kDebugMode) {
          print("the exception in liked item is ${e.toString()}");
        }
        if(page!=1)
        {
          page--;
        }
        _isValidateResponse=false;
        _isProgressVisible = false;
      });
    }
  }

  void _scrollListener() {
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
      getCallLikedProduct(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewProvider viewProvider = Provider.of<ViewProvider>(context);
    if (viewProvider.changeApplied) {
      if (kDebugMode) {
        print("the change is ${viewProvider.changeApplied}");
      }
      viewProvider.changeView(false);

      if (kDebugMode) {
        print("the change is ${viewProvider.changeApplied}");
      }

      _isProgressVisible=false;
      DataList.clear();
      page = 1;
      // _isProgressVisible=true;
      _isValidateResponse = true;
      DataList.clear();
      getCallLikedProduct(page);
    }
    return Scaffold(
        body: _isValidateResponse
        ? const CircularProgressScreen()
        :DataList.isEmpty?EmptyResultWidget(likeProductEmptyMessage)
            :Stack(
      children: <Widget>[
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: refreshWidgets,
          child: Container(
            child: _isGridView
                ? GridView.builder(
                padding: const EdgeInsets.all(8.0),
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                controller: _controller,
                itemCount: DataList.isNotEmpty ? DataList.length : 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final model = DataList[index];
                  if(messagedProductList.isNotEmpty)  //messagedProductList is the list of product about whom User already initiated the chat.
                      {
                    for(int i=0;i<messagedProductList.length;i++)
                    {
                      int productID=messagedProductList[i];
                      if(productID==model.id)
                      {
                        model.is_active_chat=true;
                      }
                    }
                  }
                  return GestureDetector(
                    onTap: ()
                    {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => ProductDetailsScreen(
                                productID: model.id,
                                isMessageIconVisible: true
                              )
                          )
                      );
                    },
                    child: GridViewWidget
                      (
                      assetImage: model.user_details.image_avatar_path,
                      productName: model.title,
                      distance: model.distance,
                      //locale: locale!,
                      distanceUnit: model.user_details.distance_unit,
                      lookingFor: model.looking_for,
                      likedCallBack: () async
                      {
                        bool value=await checkInternetFromWithinWidgets();
                       if(value)
                         {
                           getCallPostUnlikeItem(model.id,model);
                         }
                      },
                      productOwnerName: model.user_details.first_name,
                      messageCallBack: () async {
                        if(model.is_active_chat)
                        {
                          Fluttertoast.showToast(msg: chatInitiatedToast);
                        }else
                        {
                         bool value=await checkInternetFromWithinWidgets();
                         if(value)
                           {
                             showDialog(context: context,
                                 builder: (BuildContext context){
                                   return UserMessageDialog
                                     (currentUserId,
                                       model.user_details.social_profile_id,
                                       token,
                                       model.user_details.first_name,
                                       model.id,
                                       warningText,messageText,cancel,send,model.base_64_images[0]);
                                 }).then((value)
                             {
                               if(!mounted)return;
                               setState(() {
                                 if(value)
                                 {
                                   model.is_active_chat=true;
                                 }

                               });
                             });
                           }
                        }

                      },
                      productImageUrl: model.base_64_images.isNotEmpty?model.base_64_images[0]:"",
                      isItemLiked: true,
                      isMarketPlaceView: true,
                      productOwnerUrl: model.user_details.image_b64,
                      // Constant.baseurl +
                      //     model.user_details.image_avatar_path,
                      like_count: model.likes_count,
                      isMessageIconVisible: true,
                      reportCallBack: () async{
                        bool value=await checkInternetFromWithinWidgets();
                        if(value)
                          {
                            getCallAppSettingAPI(model.id, context);
                          }

                      }
                      , isOwnerItem: false,
                      isDeleteButtonEnabled: false,//isDeleteButton is only for MyProductItem to delete the Item
                    ),
                  );
                })
                : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                controller: _controller,
                scrollDirection: Axis.vertical,
                itemCount: DataList.isNotEmpty ? DataList.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  final model = DataList[index];
                  if(messagedProductList.isNotEmpty)  //messagedProductList is the list of product about whom User already initiated the chat.
                      {
                    for(int i=0;i<messagedProductList.length;i++)
                    {
                      int productID=messagedProductList[i];
                      if(productID==model.id)
                      {
                        model.is_active_chat=true;
                      }
                    }
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => ProductDetailsScreen(
                                productID: model.id,
                                isMessageIconVisible: true)));
                    },
                    child: LinearViewWidget(
                      productName: model.title,
                      distance: model.distance,
                      distanceUnit: model.user_details.distance_unit,
                      assetImage: model.user_details.image_avatar_path,
                      lookingFor: model.looking_for,
                      likedCallBack: () async{
                        bool value=await checkInternetFromWithinWidgets();
                        if(value)
                          {
                            getCallPostUnlikeItem(model.id,model);
                          }

                      },
                      productOwnerName: model.user_details.first_name,
                      messageCallBack: () async {   //This will enable the one=one chat between two user,also save the list in Database.
                        if(model.is_active_chat)
                        {
                          Fluttertoast.showToast(msg: chatInitiatedToast);
                        }
                        else{
                          bool value=await checkInternetFromWithinWidgets();
                          if(value)
                            {
                              showDialog(context: context,
                                  builder: (BuildContext context)
                                  {
                                    return UserMessageDialog(currentUserId,
                                        model.user_details.social_profile_id,
                                        token,
                                        model.user_details.first_name,
                                        model.id,warningText,messageText,cancel,send,model.base_64_images[0]);
                                  }).then((value)
                              {
                                setState(() {
                                  model.is_active_chat=true;
                                });
                              });
                            }
                        }

                      },
                      productImageUrl: model.base_64_images.isNotEmpty?model.base_64_images[0]:"",
                      isItemLiked: true,
                      productDetails: model.description,
                      productOwnerUrl: model.user_details.image_b64,
                      isMarketPlaceView: true,
                      likes_count: model.likes_count,
                      isMessageIconVisible: true,
                      reportCallBack: () async{
                        bool value=await checkInternetFromWithinWidgets();
                        if(value)
                          {
                            getCallAppSettingAPI(model.id, context);
                          }
                      }, isOwnerItem: false,
                      isDeleteButtonEnabled: false, // isDeleteButtonEnabled is only for the MyProductScreen to dete the product.
                    ),
                  );
                }),
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
    )
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
      getCallLikedProduct(page);
    });
  }

  void getCallPostUnlikeItem(int productID,Data model) async
  {
    if (!mounted) return;
    setState(() {
      _isProgressVisible=true;
    });
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? token=prefs.getString(Strings.google_token);
    PostUnlikeModel map=PostUnlikeModel(liked_product_id: productID);
    try{
      API.postUnlike(map.toMap(), token).then((response)
      {
        int statusCode = response.statusCode;
        if (kDebugMode) {
          print("the resposne is $statusCode \n the product id was $productID");
        }
        if(kDebugMode)
        {
          print("the status is $statusCode\n the response is ${response.body}");
        }
        if (statusCode == 200 || statusCode == 201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if (!mounted) return;
              setState(() {
                _isProgressVisible=false;
                page=1;
                DataList.clear();
                //_isProgressVisible=true;
                _isValidateResponse=true;
              });
              getCallLikedProduct(page);
            }
          else if(body['status']=='unauthenticated')
            {
              if (!mounted) return;
              setState(() {
                //model.is_liked=false;
                _isProgressVisible=false;
              });
              getCallSignout(authProvider, facebookLoginProvider);
            }else{
            if (!mounted) return;
            setState(() {
              //model.is_liked=false;
              _isProgressVisible=false;
            });
          }

        }
        else{
          if (!mounted) return;
          setState(() {
            //model.is_liked=false;
            _isProgressVisible=false;
          });
        }
      });
    }
    catch(e)
    {
      if(kDebugMode)
      {
        if (!mounted) return;
        setState(() {
          //model.is_liked=false;
          _isProgressVisible=false;
        });
        print("throwing new error");
        throw Exception("Error on server");
        print("The exception is $e");
      }
    }
  }

  void getCallAppSettingAPI(int productID, BuildContext context) async{
    try{
      await showDialog(context: context,
          barrierDismissible: false,
          builder: (BuildContext context){
            return  ProductReportDialog(productID);
          }).then((value){
        ReportProductResponseModel model=ReportProductResponseModel.fromJson(json.decode(value));
        Fluttertoast.showToast(msg: model.message,toastLength: Toast.LENGTH_LONG,timeInSecForIosWeb: 2,);
        if (!mounted) return;
        setState(() {
          _isProgressVisible=false;
          page=1;
          DataList.clear();
          //_isProgressVisible=true;
          _isValidateResponse=true;
        });
        getCallLikedProduct(page);
      });
      // SharedPreferences prefs=await SharedPreferences.getInstance();
      // String? token=prefs.getString(Strings.google_token);
      // setState(() {
      //   _isProgressVisible=true;
      // });
      // API.getCallAppSetting(token).then((response) async {
      //   int statusCode = response.statusCode;
      //   if(kDebugMode)
      //   {
      //     print("the status is $statusCode\n the response is ${response.body}");
      //   }
      //   if (statusCode == 200 || statusCode == 201)
      //   {
      //     List<ReportRadioMessage> reportList=[];
      //     AppSettingModel model=AppSettingModel.fromJson(json.decode(response.body));
      //     reportList.addAll(model.settings.report_radio_message);
      //     setState(() {
      //       _isProgressVisible=false;
      //     });
      //     await showDialog(context: context,
      //         barrierDismissible: false,
      //         builder: (BuildContext context){
      //           return  ProductReportDialog(productID);
      //         }).then((value){
      //       ReportProductResponseModel model=ReportProductResponseModel.fromJson(json.decode(value));
      //       Fluttertoast.showToast(msg: model.message,toastLength: Toast.LENGTH_LONG,timeInSecForIosWeb: 2,);
      //       if (!mounted) return;
      //       setState(() {
      //         _isProgressVisible=false;
      //         page=1;
      //         DataList.clear();
      //         //_isProgressVisible=true;
      //         _isValidateResponse=true;
      //       });
      //       getCallLikedProduct(page);
      //     });
      //   }
      //   else{
      //     setState(() {
      //       _isProgressVisible=false;
      //     });
      //   }
      // });
    }
    catch(e)
    {
      if(kDebugMode)
      {
        print("the exception in AppSettingApi is $e");
      }
    }
  }
}
