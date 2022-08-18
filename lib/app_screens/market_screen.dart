import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Constant/Constant.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allMethods/Methods.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allProvider/view_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/empty_result_widget.dart';
import 'package:tradz/allWidgets/grid_view_widget.dart';
import 'package:tradz/allWidgets/linear_view_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/category_screen.dart';
import 'package:tradz/app_screens/product_details_screen.dart';
import 'package:tradz/app_screens/setting_screen.dart';
import 'package:tradz/dialogs/product_report_dialog.dart';
import 'package:tradz/dialogs/userMessage_dialog.dart';
import 'package:tradz/model/app_setting_model.dart';
import 'package:tradz/model/markertplace_product_model.dart';
import 'package:tradz/model/post_like_model.dart';
import 'package:tradz/model/post_unlike_model.dart';
import 'package:tradz/model/report_product_resposne_model.dart';
import 'package:tradz/model/user_product_model.dart';
import 'package:translator/translator.dart';

import 'login_screen.dart';

//unauthenticated
class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  MarketScreenState createState() => MarketScreenState();
}

class MarketScreenState extends State<MarketScreen> {
  final translator = GoogleTranslator();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  bool isLikedItem = false;
  ScrollController _controller = ScrollController();
  bool _isProgressVisible = false;
  int page = 1;
  String myEmailID = '';
  bool _isGridView = true;
  late String currentUserId;
  late String token;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;
  bool _isValidateResponse = true;
  late MarketPlaceProductModel marketPlaceProductModel;

  List<Data> DataList = [];
  List<int> likedItemsList = [];
  String warningText='';
  String messageText='';
  String cancel='';
  String send='';

  List<int> messagedProductList =
      []; // this list store the number of product to whom the user messaged for initiate Chat.
  late UserProductModel userProductModel;
  List<UserProductData> myProductDataList = [];

  String emptyResult='';
  String addProductToastMessage='';
  String chatInitiatedToast='';
  String noInternetMessage='';
  bool _isInternet = false;


  @override
  void initState() {
    checkSelectedLanguage();
    Provider.of<ViewProvider>(context, listen: false);
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    authProvider = context.read<AuthProvider>();
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true)
    {
      currentUserId = authProvider.getUserFirebaseId()!;
    }
    token = authProvider.getUserTokenID()!;
    checkView();
    getCallMarketPlaceProduct(page);
    getCallUSerProductAPI();
    _controller.addListener(() {
      _scrollListener();
    });
    super.initState();
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
    } on SocketException catch (_)
    {
      if(!mounted)return;
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
      else{
        print("something went wrong");
        if(!mounted)return;
        setState(() {
          _isProgressVisible=false;
        });
      }
    }
  }

  void checkSelectedLanguage() async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale=='hi')
          {
            if(!mounted)return;
            setState(() {
              emptyResult=Strings.emptyResult_hi;
              addProductToastMessage=Strings.addProductToastMessage_hi;
              chatInitiatedToast=Strings.chatInitiatedToast_hi;
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
              emptyResult=Strings.emptyResult_bn;
              addProductToastMessage=Strings.addProductToastMessage_bn;
              chatInitiatedToast=Strings.chatInitiatedToast_bn;
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
                emptyResult=Strings.emptyResult_te;
                addProductToastMessage=Strings.addProductToastMessage_te;
                chatInitiatedToast=Strings.chatInitiatedToast_te;
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
            emptyResult=Strings.emptyResult;
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
    else
    {
      if(!mounted)return;
      setState(() {
        emptyResult=Strings.emptyResult;
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




  void checkView() async
  {
    try{
      SharedPreferences prefs=await SharedPreferences.getInstance();
      if(!mounted)return;
      setState(() {
        _isGridView=prefs.getBool(Strings.isGridView)!;
      });
    }
    catch(e)
    {
      if(kDebugMode)
      {
        print("the exception in checkView of mainScreen is $e");
      }
    }
  }

  //getUser product to check if user have a Product,if not then user unable to like or message to other user product
  //and redirect to AddProduct Screen.
  void getCallUSerProductAPI() async {
    int page = 1;
    API.getUserProduct(page, token).then((response) {
      var statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 201) {
        setState(()
        {
          userProductModel =
              UserProductModel.fromJson(json.decode(response.body));
          myProductDataList.addAll(userProductModel.products.data);
          if (kDebugMode) {
            print(
                "the myProduct list is ${myProductDataList.length}\n the bool is ${myProductDataList.isNotEmpty}");
          }
        });
      } else {
        setState(() {});
      }
    });
  }

  void _scrollListener()
  {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange)
    {
      if (!mounted) return;
      setState(() {
        _isProgressVisible = true;
        page = page + 1;
        if (kDebugMode) {
          print("page value is $page");
        }
        getCallMarketPlaceProduct(page);
      });
    }
  }

  void getCallMarketPlaceProduct(int page) async {
    checkInternet();
    likedItemsList.clear();
    messagedProductList.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myEmailID = prefs.getString(FirestoreConstants.email)!;
    API.getMarketPlaceProduct(token, page).then((response)
    {
      int statusCode = response.statusCode;
      if (kDebugMode)
      {
        print('response code HomeGrid is $statusCode \n response is ${response.body}');
      }
      if (statusCode == 200 || statusCode == 201)
      {
        final body = json.decode(response.body);
        print("the market message status of marketPlace product is ${body['message']}");
        if(body['status']==true)
          {
            if (!mounted) return;
            setState(() {
              _isValidateResponse = false;
              _isProgressVisible = false;
              marketPlaceProductModel =
                  MarketPlaceProductModel.fromJson(json.decode(response.body));
              DataList.addAll(marketPlaceProductModel.items.data);
              likedItemsList.addAll(marketPlaceProductModel.liked_items);
              messagedProductList.addAll(marketPlaceProductModel.active_chats);
              if (kDebugMode) {
                print(
                    'the likeditem list is $likedItemsList \n the length is ${likedItemsList.length}');
              }
            });
          }
        else if(body['status']=='unauthenticated')
            {
              print("inside the User Not Found");
              if(!mounted)return;
              setState(() {
                _isValidateResponse = false;
                _isProgressVisible = false;
              });
              getCallSignout(authProvider, facebookLoginProvider);
            }

        //userList=marketPlaceProductModel.items.data.
      } else {
        if (!mounted) return;
        setState(() {
          _isValidateResponse = false;
          _isProgressVisible = false;
          if(page!=1)
          {
            page--;
          }
        });
      }
    });
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

      page = 1;
      // _isProgressVisible=true;
      _isValidateResponse = true;
      DataList.clear();
      likedItemsList.clear();
      messagedProductList.clear();
      myProductDataList.clear();
      getCallUSerProductAPI();
      getCallMarketPlaceProduct(page);
    }
    try{
      if (!viewProvider.changeViewApplied)
      {
        print("inside the linearView");
        _isGridView = false;
      }
      else {
        print("inside the GridView");
        _isGridView = true;
      }
    }
    catch(e)
    {
      print("Exception is $e");
      //_isGridView = true;
    }
    return Scaffold(
      body: _isValidateResponse
          ? const CircularProgressScreen()
          : DataList.isEmpty
              ? EmptyResultWidget(emptyResult)
              : Stack(
                  children: <Widget>[
                    RefreshIndicator(
                      onRefresh: refreshWidgets,
                      key: _refreshIndicatorKey,
                      child: Container(
                        child: _isGridView
                            ? GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            addAutomaticKeepAlives: true,
                            physics: const ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            controller: _controller,
                            itemCount:
                            DataList.isNotEmpty ? DataList.length : 0,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (BuildContext context, int index)
                            {
                              final model = DataList[index];
                             // if(locale!=null)
                             //   {
                             //     translator.translate(model.title,to:locale!).then((value)
                             //     {
                             //       print("The value after translate in product owner  is $value");
                             //       model.title=value.toString();
                             //     });
                             //   }
                              if (likedItemsList.isNotEmpty) {
                                for (int i = 0;
                                i < likedItemsList.length;
                                i++) //check if product id falls in liked Items by User
                                    {
                                  int likedItem = likedItemsList[i];
                                  if (likedItem == model.id)
                                  {
                                    if (kDebugMode)
                                    {
                                      print("the item inside lined is ${model.is_liked}");
                                    }
                                    model.is_liked =
                                    true; //if product id falls in user liked item we change heart to liked. By default from api bool value ids false.
                                  }
                                }
                              }
                              if (messagedProductList
                                  .isNotEmpty) //messagedProductList is the list of product about whom User already initiated the chat.
                                  {
                                for (int i = 0;
                                i < messagedProductList.length;
                                i++) {
                                  int productID = messagedProductList[i];
                                  if (productID == model.id) {
                                    model.is_active_chat = true;
                                  }
                                }
                              }
                              return GestureDetector(
                                onTap: ()
                                {
                                  String ownerImageUrl;
                                  if (model.user_details.image_avatar_path
                                      .isNotEmpty)
                                  {
                                    ownerImageUrl =
                                        model.user_details.image_avatar_path;
                                  } else {
                                    ownerImageUrl =
                                        model.user_details.image_b64;
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ProductDetailsScreen(
                                                productID: model.id,
                                                isMessageIconVisible: true,
                                              )));
                                },
                                child: GridViewWidget(
                                  productName: model.title,
                                  distance: model.distance,
                                  //locale:locale,
                                  distanceUnit: model.user_details.distance_unit,
                                  lookingFor: model.looking_for,
                                  assetImage:
                                  model.user_details.image_avatar_path,
                                  likedCallBack: () async
                                  {
                                    bool value= await checkInternetFromWithinWidgets();
                                    if(value)
                                      {
                                        if (model.user_details.email != myEmailID) {
                                          if (model
                                              .is_liked) //check If Product already liked by User
                                              {
                                            getCallPostUnlikeItem(model.id,
                                                model); //change product like to unlike.
                                          } else {
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
                                        }
                                        else {
                                          // Fluttertoast.showToast(msg: Strings.likeItemToastWarningMessage);
                                        }
                                      }
                                    if (kDebugMode) {
                                      print(
                                          "the email is ${model.user_details.email}\n the saved email is $myEmailID");
                                    }
                                  },

                                  messageCallBack: () async
                                  {
                                    if (model.user_details.email != myEmailID)
                                    {
                                      if (myProductDataList.isNotEmpty) //check if User Added product if not then take him/her to AddProduct
                                          {
                                        if (model.is_active_chat) //If chat already initiated between Users then Toast Message chat already initiated displayed.
                                        {
                                          Fluttertoast.showToast(
                                              msg: chatInitiatedToast);
                                        }
                                        else
                                        {
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
                                                        model.id,
                                                        warningText,messageText,cancel,send,model.base_64_images[0]);
                                                  }).then((value) {
                                                try{
                                                  print("The value is $value");
                                                  if(!mounted)return;
                                                  setState(() {
                                                    if (value) {
                                                      model.is_active_chat = true;
                                                    }
                                                  });
                                                }
                                                catch(e)
                                                {
                                                  if(kDebugMode)
                                                    {
                                                      print("exception in return value from Message dialog is $e");
                                                    }
                                                }
                                              });
                                            }
                                        }
                                      }
                                      else {
                                        Fluttertoast.showToast(
                                            msg:
                                            addProductToastMessage);
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
                                                  productID: 0,
                                                )));
                                      }
                                    } else {
                                      //Fluttertoast.showToast(msg: Strings.msgToastWarningMessage);
                                    }
                                  },
                                  productImageUrl:
                                  model.base_64_images.isNotEmpty
                                      ? model.base_64_images[0]
                                      : "",
                                  isItemLiked: model.is_liked,
                                  isMarketPlaceView: true,
                                  productOwnerName:
                                  model.user_details.first_name,
                                  productOwnerUrl: model.user_details.image_b64,
                                  like_count: model.likes_count,
                                  isMessageIconVisible:
                                  model.user_details.email != myEmailID
                                      ? true
                                      : false,
                                  reportCallBack: () async
                                  {
                                    if (model.user_details.email != myEmailID) {
                                      getCallAppSettingAPI(model.id, context);
                                    } else {
                                      //Fluttertoast.showToast(msg: Strings.reportToastMessage);
                                    }
                                    // bool value=await checkInternetFromWithinWidgets();
                                    // if(value)
                                    //   {
                                    //     if (model.user_details.email != myEmailID) {
                                    //       getCallAppSettingAPI(model.id, context);
                                    //     } else {
                                    //       //Fluttertoast.showToast(msg: Strings.reportToastMessage);
                                    //     }
                                    //   }

                                  },
                                  isOwnerItem:
                                  model.user_details.email != myEmailID
                                      ? false
                                      : true,
                                  isDeleteButtonEnabled:
                                  false, //isDeleteButton is only for MyProductItem to delete the Item
                                ),
                              );
                            })
                            : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            controller: _controller,
                            scrollDirection: Axis.vertical,
                            itemCount:
                            DataList.isNotEmpty ? DataList.length : 0,
                            itemBuilder: (BuildContext context, int index) {
                              final model = DataList[index];
                              if (likedItemsList.isNotEmpty) {
                                for (int i = 0;
                                i < likedItemsList.length;
                                i++) //check if product id falls in liked Items by User
                                    {
                                  int likedItem = likedItemsList[i];
                                  if (likedItem == model.id) {
                                    if (kDebugMode) {
                                      print(
                                          "the item inside lined is ${model.is_liked}");
                                    }
                                    model.is_liked =
                                    true; //if product id falls in user liked item we change heart to liked. By default from api bool value ids false.
                                  }
                                }
                              }
                              if (messagedProductList.isNotEmpty) {
                                for (int i = 0;
                                i < messagedProductList.length;
                                i++) {
                                  int productID = messagedProductList[i];
                                  if (productID == model.id) {
                                    model.is_active_chat = true;
                                  }
                                }
                              }
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ProductDetailsScreen(
                                                productID: model.id,
                                                isMessageIconVisible: true
                                              )));
                                },
                                child: LinearViewWidget(
                                  assetImage:
                                  model.user_details.image_avatar_path,
                                  distance: model.distance,
                                  distanceUnit: model.user_details.distance_unit,
                                  productName: model.title,
                                  lookingFor: model.looking_for,
                                  likedCallBack: () async
                                  {
                                    bool value=await checkInternetFromWithinWidgets();
                                    if(value)
                                      {
                                        if (model.user_details.email !=
                                            myEmailID) //this check is future If current user(my Own) Product Listed in MarketPlace.
                                            {
                                          if (model
                                              .is_liked) //check If Product already liked by User
                                              {
                                            getCallPostUnlikeItem(model.id,
                                                model); //change product like to unlike.
                                          }
                                          else {
                                            if (myProductDataList
                                                .isNotEmpty) //check If current User have Product Added only then he/she can like product.
                                                {
                                              // call liked API to post product for this user as liked and also send email and push notification.
                                              getCallPostLikeItem(
                                                  model.id,
                                                  model.user_details.email,
                                                  model.user_id,
                                                  model);
                                            }
                                            else {
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
                                        } else {
                                          //Fluttertoast.showToast(msg: Strings.likeItemToastWarningMessage);
                                        }
                                      }

                                  },
                                  productOwnerName:
                                  model.user_details.first_name,
                                  messageCallBack: () // onPressed Message Icon
                                  async {
                                    if (model.user_details.email != myEmailID) {
                                      if (myProductDataList
                                          .isNotEmpty) //check if User have product if yes only then he/she can Message to Product Owner.
                                          {
                                        if (model
                                            .is_active_chat) //check if chat active between User and ProductOwner if yes message pop of Chat already initiated.
                                            {
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
                                                       model.id,
                                                       warningText,messageText,cancel,send,model.base_64_images[0]);
                                                 }).then((value) {
                                               setState(() {
                                                 if (value) {
                                                   model.is_active_chat = true;
                                                 }
                                               });
                                             });
                                           }
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                            addProductToastMessage);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                 CategoryScreen(
                                                  //new Product creation if User doesn't have Products.
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
                                    } else {
                                      //Fluttertoast.showToast(msg: Strings.msgToastWarningMessage);
                                    }
                                  },
                                  productImageUrl:
                                  model.base_64_images.isNotEmpty
                                      ? model.base_64_images[0]
                                      : "",
                                  isItemLiked: model.is_liked,
                                  productDetails: model.description,
                                  productOwnerUrl: model.user_details.image_b64
                                  //Constant.baseurl + model.user_details.image_avatar_path
                                  ,
                                  isMarketPlaceView: true,
                                  likes_count: model.likes_count,
                                  isMessageIconVisible:
                                  model.user_details.email != myEmailID
                                      ? true
                                      : false,
                                  reportCallBack: () async {
                                    bool value=await checkInternetFromWithinWidgets();
                                    if(value)
                                      {
                                        if (model.user_details.email != myEmailID) {
                                          getCallAppSettingAPI(model.id, context);
                                        } else {
                                          //Fluttertoast.showToast(msg: Strings.reportToastMessage);
                                        }
                                      }

                                  },
                                  isOwnerItem:
                                  model.user_details.email != myEmailID
                                      ? false
                                      : true,
                                  isDeleteButtonEnabled:
                                  false, // isDeleteButtonEnabled is only for the MyProductScreen to dete the product.
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
      // floatingActionButton: FloatingActionButton.small(
      //   onPressed: (){},
      //   child: Icon(Icons.filter_alt_sharp),
      //   shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(10.0))
      //   ),
      // ),
    );
  }

  Future<void> refreshWidgets() async
  {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isProgressVisible=true;
      DataList.clear();
      page = 1;
      // _isProgressVisible=true;
      _isValidateResponse = true;
      DataList.clear();
      likedItemsList.clear();
      messagedProductList.clear();
      myProductDataList.clear();
      getCallUSerProductAPI();
      getCallMarketPlaceProduct(page);
    });
  }

  void getCallPostLikeItem(int productID, String productOwnerEmail,
      int productOwnerID, Data model) async {
    try {
      if (!mounted) return;
      setState(() {
        _isProgressVisible = true;
      });
      bool result = false;
      PostLikeModel map = PostLikeModel(
          liked_product_id: productID,
          message_text: Strings.postLikedItemMessage);
      API.postFirstLike(map.toMap(), token).then((response)
      {
        int statusCode = response.statusCode;
        if (kDebugMode) {
          print("the status in getCallPostLikeItem is $statusCode\n the response is ${response.body}");
        }

        if (statusCode == 200 || statusCode == 201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
          {
            result = true;
            if (!mounted) return;
            setState(()
            {
              model.is_liked = true;
              model.likes_count = model.likes_count + 1;
              _isProgressVisible = false;
            });
          }
          else if(body['status']=='unauthenticated')
            {
              result = false;
              if (!mounted) return;
              setState(() {
                model.is_liked = false;
                _isProgressVisible = false;
              });
              getCallSignout(authProvider, facebookLoginProvider);
            }
          else{
            result = false;
            if (!mounted) return;
            setState(() {
              model.is_liked = false;
              _isProgressVisible = false;
            });
          }

        } else
        {
          result = false;
          if (!mounted) return;
          setState(() {
            model.is_liked = false;
            _isProgressVisible = false;
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("the exception in liked item is ${e.toString()}");
      }
      if (!mounted) return;
      setState(() {
        model.is_liked = false;
        _isProgressVisible = false;
      });
    }
  }

  void getCallPostUnlikeItem(int productID, Data model) async {
    if (!mounted) return;
    setState(() {
      _isProgressVisible = true;
    });
    PostUnlikeModel map = PostUnlikeModel(liked_product_id: productID);
    try {
      API.postUnlike(map.toMap(), token).then((response) {
        int statusCode = response.statusCode;
        if (kDebugMode) {
          print("the resposne is $statusCode \n the product id was $productID");
        }
        if (kDebugMode) {
          print("the status is $statusCode\n the response is ${response.body}");
        }
        if (statusCode == 200 || statusCode == 201) {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if (!mounted) return;
              setState(() {
                _isProgressVisible = false;
                model.is_liked = false;
                model.likes_count = model.likes_count - 1;
                likedItemsList.clear();
              });
            }
          else if(body['status']=='unauthenticated')
              {
                if (!mounted) return;
                setState(() {
                  //model.is_liked=false;
                  _isProgressVisible = false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }

        } else {
          if (!mounted) return;
          setState(() {
            //model.is_liked=false;
            _isProgressVisible = false;
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        if (!mounted) return;
        setState(() {
          //model.is_liked=false;
          _isProgressVisible = false;
        });
        print("throwing new error");
        throw Exception("Error on server");
        print("The exception is $e");
      }
    }
  }

  void getCallAppSettingAPI(int productID, BuildContext context) async {
    try {
      // if(!mounted)return;
      // setState(() {
      //   _isProgressVisible = true;
      // });
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProductReportDialog(productID);
          }).then((value) {
        ReportProductResponseModel model =
        ReportProductResponseModel.fromJson(json.decode(value));
        Fluttertoast.showToast(
          msg: model.message,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 2,
        );
        if (!mounted) return;
        setState(() {
          page = 1;
          DataList.clear();
          _isProgressVisible = true;
          likedItemsList.clear();
          myProductDataList.clear();
          checkSelectedLanguage();
          getCallMarketPlaceProduct(page);
          getCallUSerProductAPI();
        });
      });
      // API.getCallAppSetting(token).then((response) async {
      //   int statusCode = response.statusCode;
      //   if (kDebugMode) {
      //     print("the status is $statusCode\n the response is ${response.body}");
      //   }
      //   if (statusCode == 200 || statusCode == 201)
      //   {
      //     List<ReportRadioMessage> reportList = [];
      //     AppSettingModel model =
      //         AppSettingModel.fromJson(json.decode(response.body));
      //     reportList.addAll(model.settings.report_radio_message);
      //     if(!mounted)return;
      //     setState(() {
      //       _isProgressVisible = false;
      //     });
      //
      //   } else {
      //     setState(() {
      //       _isProgressVisible = false;
      //     });
      //   }
      // });
    } catch (e) {
      if (kDebugMode) {
        print("the exception in AppSettingApi is $e");
      }
    }
  }


}
