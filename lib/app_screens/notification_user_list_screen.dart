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
import 'package:tradz/allWidgets/grid_view_widget.dart';
import 'package:tradz/allWidgets/linear_view_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/product_details_screen.dart';
import 'package:tradz/dialogs/product_report_dialog.dart';
import 'package:tradz/dialogs/userMessage_dialog.dart';
import 'package:tradz/model/app_setting_model.dart';
import 'package:tradz/model/markertplace_product_model.dart';
import 'package:tradz/model/post_like_model.dart';
import 'package:tradz/model/post_unlike_model.dart';
import 'package:tradz/model/report_product_resposne_model.dart';
import 'package:tradz/model/user_product_model.dart';
import 'package:translator/translator.dart';

import 'category_screen.dart';
import 'login_screen.dart';
class NotificationUserListScreen extends StatefulWidget {
  final int userID;
  String userName;
  NotificationUserListScreen({Key? key, required this.userID,required this.userName}) : super(key: key);

  @override
  State<NotificationUserListScreen> createState() => _NotificationUserListScreenState();
}

class _NotificationUserListScreenState extends State<NotificationUserListScreen> {
  final translator = GoogleTranslator();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  bool _isGridView = true;
  bool _isProgressView=false;
  int page=1;
  late String token;
  late String currentUserId;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;
  String appbarTitle="";
  String addProductToastMessage='';
  String chatInitiatedToast='';
  late UserProductModel userProductModel;
  List<UserProductData> myProductDataList=[];
  List<Data> DataList=[];
  List<int> likedItemsList=[];
  List<int> messagedProductList=[];// this list store the number of product to whom the user messaged for initiate Chat.

  late MarketPlaceProductModel marketPlaceProductModel;
  ScrollController _controller= ScrollController();
  String warningText='';
  String messageText='';
  String cancel='';
  String send='';
  String noInternetMessage='';
  bool _isInternet = false;
  @override
  void initState()
  {
    checkSelectedLanguage();
    authProvider=context.read<AuthProvider>();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    if(authProvider.getUserFirebaseId()?.isNotEmpty==true)
    {
      currentUserId =authProvider.getUserFirebaseId()!;
    }
    token=authProvider.getUserTokenID()!;
    appbarTitle=widget.userName;
    getCallPrefrence();
    getCallUSerProductAPI();
    getCallNotificationUserList(widget.userID,page);
    _controller.addListener(()
    {
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
        _isProgressView = false;
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
        _isProgressView = false;
        print("insternet becomes exception " + _isInternet.toString());
      });
      return false;
    }
  }

  void checkSelectedLanguage() async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String?locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale!='en')
          {
            translator.translate(widget.userName,to: locale).then((value){
              if(!mounted)return;
              setState(() {
                appbarTitle=value.toString();
              });
            });
          }
        if(locale=='hi')
        {
          if(!mounted)return;
          setState(() {
            addProductToastMessage=Strings.addProductToastMessage_hi;
            chatInitiatedToast=Strings.chatInitiatedToast_hi;
            warningText=Strings.warningText_hi;
            messageText=Strings.newlyChatMessage_hi;
            cancel=Strings.cancel_hi;
            send=Strings.sendButton_hi;
            noInternetMessage=Strings.noInternetMessage_hi;
          });


        }else if(locale=='bn')
        {
          if(!mounted)return;
          setState(() {
            addProductToastMessage=Strings.addProductToastMessage_hi;
            chatInitiatedToast=Strings.chatInitiatedToast_hi;
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
            addProductToastMessage=Strings.addProductToastMessage_bn;
            chatInitiatedToast=Strings.chatInitiatedToast_bn;
            warningText=Strings.warningText_te;
            messageText=Strings.newlyChatMessage_te;
            cancel=Strings.cancel_te;
            send=Strings.sendButton_te;
            noInternetMessage=Strings.noInternetMessage_te;
          });
        }
        else{
          if(!mounted)return;
          setState(() {
            addProductToastMessage=Strings.addProductToastMessage;
            chatInitiatedToast=Strings.chatInitiatedToast;
            warningText=Strings.warningText;
            messageText=Strings.newlyChatMessage;
            cancel=Strings.cancelButton;
            send=Strings.sendButton;
            noInternetMessage=Strings.noInternetMessage;
          });
        }
      }else{
      if(!mounted)return;
      setState(() {
        addProductToastMessage=Strings.addProductToastMessage;
        chatInitiatedToast=Strings.chatInitiatedToast;
        warningText=Strings.warningText;
        messageText=Strings.newlyChatMessage;
        cancel=Strings.cancelButton;
        send=Strings.sendButton;
        noInternetMessage=Strings.noInternetMessage;
      });
    }


  }

  //getUser product to check if user have a Product,if not then user unable to like or message to other user product
  //and redirect to AddProduct Screen.
  void getCallUSerProductAPI() async
  {
    int page=1;
    API.getUserProduct(page,token).then((response){
      var statusCode=response.statusCode;

      if(statusCode==200|| statusCode==201)
      {
        final body = json.decode(response.body);
        if(body['status']==true)
          {
            setState(() {
              userProductModel=UserProductModel.fromJson(json.decode(response.body));
              myProductDataList.addAll(userProductModel.products.data);
              if (kDebugMode) {
                print("the myProduct list is ${myProductDataList.length}\n the bool is ${myProductDataList.isNotEmpty}");
              }
            });
          }
        else if(body['status']=='unauthenticated')
          {
            getCallSignout(authProvider, facebookLoginProvider);
          }

      }
      else
      {
        setState(() {
        });
      }
    });

  }
  //getUser product to check if user have a Product,if not then user unable to like or message to other user product
  //and redirect to AddProduct Screen.

  void _scrollListener() {
    if(_controller.offset>=_controller.position.maxScrollExtent
        && !_controller.position.outOfRange
    )
    {
      if(!mounted) return;
      setState(() {
        _isProgressView=true;
        page=page+1;
        if (kDebugMode) {
          print("page value is $page");
        }
        getCallNotificationUserList(widget.userID,page);
      });
    }
  }

  void getCallNotificationUserList(int userID, int page) async
  {

    setState(() {
      _isProgressView=true;
    });
    checkInternet();
    try{
      likedItemsList.clear();
      messagedProductList.clear();
      API.getCALLNOTIFICATIONUSER(token, userID, page).then((response)
      {
        int statusCode = response.statusCode;
        if(kDebugMode)
        {
          print('getCallNotificationUserList response code  $statusCode \n response is ${response.body}');
        }
        if (statusCode == 200 || statusCode == 201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
          {
            if(!mounted)return;
            setState(() {
              _isProgressView=false;
              marketPlaceProductModel =
                  MarketPlaceProductModel.fromJson(json.decode(response.body));
              DataList.addAll(marketPlaceProductModel.items.data);
              likedItemsList.addAll(marketPlaceProductModel.liked_items);
              messagedProductList.addAll(marketPlaceProductModel.active_chats);
            });
          }else if(body['status']=='unauthenticated')
          {
            if(!mounted)return;
            setState(() {
              _isProgressView=false;
            });
            getCallSignout(authProvider, facebookLoginProvider);
          }
          else{
            if(!mounted)return;
            setState(() {
              _isProgressView=false;
            });
          }

        }
        else{
          setState(() {
            _isProgressView=false;
          });
        }
      });
    }
    on Exception catch (exception)
    {
    if (kDebugMode) {
      print("exception is $exception");
    }// only executed if error is of type Exception
  }
    catch(e)
    {
      setState(() {
        _isProgressView=false;
      });
      if(kDebugMode)
        {
          print("the exception in getNotificationUserList is $e");
        }
    }
  }

  void getCallPrefrence() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _isGridView = prefs.getBool(Strings.isGridView)!;
        print("the value in notificationUser list is $_isGridView");
      });
    }
    catch(e)
    {
      if(kDebugMode)
      {
        print("the xception is $e");
      }
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBarView(
          titleText: appbarTitle,
          isAppBackBtnVisible: true),
      body: Stack(
        children: [
          RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: refreshWidgets,
            child: Container(
              child: _isGridView?
              GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  controller: _controller,
                  itemCount: DataList.isNotEmpty?DataList.length:0,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder:(BuildContext context, int index) {
                    final model = DataList[index];
                    for(int i=0;i<likedItemsList.length;i++)  //check if product id falls in liked Items by User
                        {
                      int likedItem=likedItemsList[i];
                      if(likedItem==model.id)
                      {
                        model.is_liked=true; //if product id falls in user liked item we change heart to liked. By default from api bool value ids false.
                      }
                    }
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
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext)=>
                            ProductDetailsScreen(
                              productID: model.id,
                              isMessageIconVisible: true,)));
                      },
                      child: GridViewWidget(
                        assetImage: model.user_details.image_avatar_path,
                        productName: model.title,
                        //locale: locale!,
                        distanceUnit: model.user_details.distance_unit,
                        distance: model.distance,
                        lookingFor: model.looking_for,
                        likedCallBack: () {
                          checkInternetFromWithinWidgets();
                          if(model.is_liked)
                            {
                              getCallPostUnlikeItem(model.id,
                                  model); //change product like to unlike.
                            }else{
                            if (myProductDataList
                                .isNotEmpty) //check If current User have Product Added only then he/she can like product.
                                {
                              // call liked API to post product for this user as liked and also send email and push notification.
                              getCallPostLikeItem(
                                  model.id,
                                  model.user_details.email,
                                  model.user_id,
                                  model);
                            } else {
                              Fluttertoast.showToast(
                                  msg: addProductToastMessage);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder:
                                          (BuildContext context) =>
                                          CategoryScreen(
                                            //new Product creation with only productID(which need to Like Product once Product Added successfully.) is non empty,other items are empty.
                                            ImageUrl: [],
                                            lookingFor: '',
                                            productPrice: 0,
                                            productdetails: '',
                                            subCategory: '',
                                            productTitle: '',
                                            category: '',
                                            productID: model.id,
                                          )));
                            }
                          }
                          //getCallLikedCallBack(model);
                        },
                        productOwnerName: model.user_details.first_name,
                        messageCallBack: () async {

                          if (myProductDataList
                              .isNotEmpty) //check if User Added product if not then take him/her to AddProduct
                            {
                            if (model.is_active_chat) {
                              Fluttertoast.showToast(
                                  msg: chatInitiatedToast);
                            } else {
                              bool value = await checkInternetFromWithinWidgets();
                              if(value)
                                {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return UserMessageDialog(
                                            currentUserId,
                                            model.user_details
                                                .social_profile_id,
                                            token,
                                            model.user_details
                                                .first_name,
                                            model.id,warningText,messageText,cancel,send,model.base_64_images[0]);
                                      }).then((value) {
                                    print("The value is $value");
                                    setState(() {
                                      if (value) {
                                        model.is_active_chat = true;
                                      }
                                    });
                                  });
                                }
                            }
                          } else{
                            Fluttertoast.showToast(msg:addProductToastMessage);
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
                                CategoryScreen(  //new Product creation with only productID(which need to Like Product once Product Added successfully.) is non empty,other items are empty.
                                  ImageUrl: [],
                                  lookingFor: '',
                                  productPrice: 0,
                                  productdetails: '',
                                  subCategory: '',
                                  productTitle: '',
                                  category: '',
                                  productID: 0,
                                )));
                          }
                          //getCallMessageCallBack(model);
                        },
                        productImageUrl: model.base_64_images.isNotEmpty?model.base_64_images[0]:"",
                        isItemLiked: model.is_liked,
                        isMarketPlaceView: true,
                        productOwnerUrl: model.user_details.image_b64,
                        like_count: model.likes_count,
                        isMessageIconVisible: true,
                        reportCallBack: () async
                        {
                          getCallAppSettingAPI(model.id, context);
                        },
                        isOwnerItem: false,
                        isDeleteButtonEnabled: false,//isDeleteButton is only for MyProductScreen to delete the Item
                      ),
                    );
                  }

              )
                  : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  itemCount:DataList.isNotEmpty?DataList.length:0,
                  itemBuilder: (BuildContext context, int index)
                  {
                    final model = DataList[index];
                    for(int i=0;i<likedItemsList.length;i++)  //check if product id falls in liked Items by User
                        {
                      int likedItem=likedItemsList[i];
                      if(likedItem==model.id)
                      {
                        model.is_liked=true; //if product id falls in user liked item we change heart to liked. By default from api bool value ids false.
                      }
                    }
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
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext)=>
                            ProductDetailsScreen(
                              productID: model.id,
                              isMessageIconVisible: true,)));
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
                              if(model.is_liked)
                              {
                                getCallPostUnlikeItem(model.id,model);
                              }
                              else {
                                if(myProductDataList.isNotEmpty)
                                {
                                  // call liked API to post product for this user as liked and also send email and push notification.
                                  getCallPostLikeItem(
                                      model.id, model.user_details.email, model.user_id,
                                      model);
                                }else
                                {
                                  Fluttertoast.showToast(
                                      msg: addProductToastMessage);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              CategoryScreen(
                                                //new Product creation with only productID(which need to Like Product once Product Added successfully.) is non empty,other items are empty.
                                                ImageUrl: [],
                                                lookingFor: '',
                                                productPrice: 0,
                                                productdetails: '',
                                                subCategory: '',
                                                productTitle: '',
                                                category: '',
                                                productID: model.id,
                                              )));
                                }
                              }
                            }

                        },
                        productOwnerName: model.user_details.first_name,
                        messageCallBack: () async {

                          if (myProductDataList
                              .isNotEmpty) //check if User Added product if not then take him/her to AddProduct
                              {
                            if (model.is_active_chat) {
                              Fluttertoast.showToast(
                                  msg: chatInitiatedToast);
                            } else {
                              bool value=await checkInternetFromWithinWidgets();
                              if(value)
                                {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return UserMessageDialog(
                                            currentUserId,
                                            model.user_details
                                                .social_profile_id,
                                            token,
                                            model.user_details
                                                .first_name,
                                            model.id,warningText,messageText,cancel,send,model.base_64_images[0]);
                                      }).then((value) {
                                    print("The value is $value");
                                    setState(() {
                                      if (value) {
                                        model.is_active_chat = true;
                                      }
                                    });
                                  });
                                }
                            }
                          } else{
                            Fluttertoast.showToast(msg:addProductToastMessage);
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
                                CategoryScreen(  //new Product creation with only productID(which need to Like Product once Product Added successfully.) is non empty,other items are empty.
                                  ImageUrl: [],
                                  lookingFor: '',
                                  productPrice: 0,
                                  productdetails: '',
                                  subCategory: '',
                                  productTitle: '',
                                  category: '',
                                  productID: 0,
                                )));
                          }
                          //getCallMessageCallBack(model);
                        },
                        productImageUrl: model.base_64_images.isNotEmpty?model.base_64_images[0]:"",
                        isItemLiked: model.is_liked,
                        productDetails: model.description,
                        productOwnerUrl:
                        model.user_details.image_b64, isMarketPlaceView: true, likes_count: model.likes_count,
                        isMessageIconVisible: true,
                        reportCallBack: () async{
                          bool value=await checkInternetFromWithinWidgets();
                          if(value)
                            {
                              getCallAppSettingAPI(model.id, context);
                            }

                      }, isOwnerItem: false, //check if owner of product Item , if true then he's not able to click the heart icon and icon color is white
                        isDeleteButtonEnabled: false, // isDeleteButtonEnabled is only for the MyProductScreen to dete the product.
                      ),
                    );
                  }),
            ),
          ),
          Visibility(child: const CircularProgressScreen(),visible: _isProgressView,),
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

  Future<void> refreshWidgets() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isProgressView=true;
      DataList.clear();
      page = 1;
      DataList.clear();
      likedItemsList.clear();
      messagedProductList.clear();
      myProductDataList.clear();
    });
    getCallUSerProductAPI();
    getCallNotificationUserList(widget.userID,page);
  }

  void getCallPostLikeItem(int productID, String productOwnerEmail, int productOwnerID, Data model) async
  {
    try{
      setState(() {
        _isProgressView=true;
      });
      bool result=false;
      SharedPreferences prefs=await SharedPreferences.getInstance();
      String? token=prefs.getString(Strings.google_token);
      PostLikeModel map=PostLikeModel(
          liked_product_id: productID,
          message_text: Strings.postLikedItemMessage);
      API.postFirstLike(map.toMap(), token).then((response)
      {
        int statusCode = response.statusCode;
        if(kDebugMode)
        {
          print("the status is $statusCode\n the response is ${response.body}");
        }
        if (statusCode == 200 || statusCode == 201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              result=true;
              setState(() {
                model.is_liked=true;
                model.likes_count=model.likes_count+1;
                _isProgressView=false;
              });
            }else if(body['status']=='unauthenticated')
              {
                result=false;
                if(!mounted)return;
                setState(() {
                  model.is_liked=false;
                  _isProgressView=false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }else{
            result=false;
            if(!mounted)return;
            setState(() {
              model.is_liked=false;
              _isProgressView=false;
            });
          }

        }
        else{
          result=false;
          setState(() {
            model.is_liked=false;
            _isProgressView=false;
          });
        }
      });
    }
    catch(e)
    {
      if(kDebugMode)
      {
        print("the exception in liked item is ${e.toString()}");
      }
      setState(() {
        model.is_liked=false;
        _isProgressView=false;
      });
    }
  }

  void getCallPostUnlikeItem(int productID,Data model) async{

    setState(() {
      _isProgressView=true;
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
              setState(() {
                model.likes_count=model.likes_count-1;
                model.is_liked=false;
                _isProgressView=false;
              });
            }
          else if(body['status']=='unauthenticated')
            {
              setState(() {
                //model.is_liked=false;
                _isProgressView=false;
              });
              getCallSignout(authProvider, facebookLoginProvider);
            }else{
            setState(() {
              //model.is_liked=false;
              _isProgressView=false;
            });
          }

        }
        else{
          setState(() {
            //model.is_liked=false;
            _isProgressView=false;
          });
        }
      });
    }
    catch(e)
    {
      if(kDebugMode)
      {
        setState(() {
          //model.is_liked=false;
          _isProgressView=false;
        });
        print("throwing new error");
        throw Exception("Error on server");
        print("The exception is $e");
      }
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
        Fluttertoast.showToast(msg: "Account already deleted");
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

  void getCallAppSettingAPI(int productID, BuildContext context) async{
    try{
      await showDialog(context: context,
          barrierDismissible: false,
          builder: (BuildContext context)
          {
            return  ProductReportDialog(productID);
          }).then((value)
      {
        ReportProductResponseModel model=ReportProductResponseModel.fromJson(json.decode(value));
        Fluttertoast.showToast(msg: model.message,toastLength: Toast.LENGTH_LONG,timeInSecForIosWeb: 2,);
        if(!mounted)return;
        setState(() {
          _isProgressView=true;
          page=1;
          DataList.clear();
          likedItemsList.clear();
          getCallNotificationUserList(widget.userID,page);
        });
      });
      // SharedPreferences prefs=await SharedPreferences.getInstance();
      // String? token=prefs.getString(Strings.google_token);
      // setState(() {
      //   _isProgressView=true;
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
      //       _isProgressView=false;
      //     });
      //     await showDialog(context: context,
      //         barrierDismissible: false,
      //         builder: (BuildContext context){
      //           return  ProductReportDialog(productID);
      //         }).then((value){
      //       ReportProductResponseModel model=ReportProductResponseModel.fromJson(json.decode(value));
      //       Fluttertoast.showToast(msg: model.message,toastLength: Toast.LENGTH_LONG,timeInSecForIosWeb: 2,);
      //       if(!mounted)return;
      //       setState(() {
      //         _isProgressView=true;
      //         page=1;
      //         DataList.clear();
      //         likedItemsList.clear();
      //         getCallNotificationUserList(widget.userID,page);
      //       });
      //     });
      //   }
      //   else{
      //     setState(() {
      //       _isProgressView=false;
      //     });
      //   }
      // });
    }catch(e)
    {
      if(kDebugMode)
      {
        print("the exception in AppSettingApi is $e");
      }
    }
  }

  void getCallMessageCallBack(Data model) {
    if(messagedProductList.isNotEmpty)//check if User Added product if not then take him/her to AddProduct
        {
      if(model.is_active_chat)
      {
        Fluttertoast.showToast(msg: chatInitiatedToast);
      }
      else{
        showDialog(context: context,
            builder: (BuildContext context){
              return UserMessageDialog(
                  currentUserId,
                  model.user_details.social_profile_id,
                  token,
                  model.user_details.first_name,
                  model.id,warningText,messageText,cancel,send,
                  model.base_64_images[0]
              );
            }).then((value)
        {
          print("The value is $value");
          setState(() {
            if(value)
            {
              model.is_active_chat=true;
            }

          });
        });
      }
    }
    else{
      Fluttertoast.showToast(msg:addProductToastMessage);
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
       CategoryScreen(  //new Product creation with only productID(which need to Like Product once Product Added successfully.) is non empty,other items are empty.
        ImageUrl: [],
        lookingFor: '',
        productPrice: 0,
        productdetails: '',
        subCategory: '',
        productTitle: '',
        category: '',
        productID: 0,
      )));
    }
  }

  void getCallLikedCallBack(Data model) {
    if(model.is_liked)
    {
      getCallPostUnlikeItem(model.id,model);
    }
    else {
      if(messagedProductList.isNotEmpty)
      {
        // call liked API to post product for this user as liked and also send email and push notification.
        getCallPostLikeItem(
            model.id, model.user_details.email, model.user_id,
            model);
      }else
      {
        Fluttertoast.showToast(
            msg: addProductToastMessage);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    CategoryScreen(
                      //new Product creation with only productID(which need to Like Product once Product Added successfully.) is non empty,other items are empty.
                      ImageUrl: [],
                      lookingFor: '',
                      productPrice: 0,
                      productdetails: '',
                      subCategory: '',
                      productTitle: '',
                      category: '',
                      productID: model.id,
                    )));
      }
    }
  }
}
