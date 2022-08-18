import 'dart:convert';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/src/provider.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/empty_result_widget.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/category_screen.dart';
import 'package:tradz/dialogs/userMessage_dialog.dart';
import 'package:tradz/dialogs/zoomable_dialog.dart';
import 'package:tradz/model/post_like_model.dart';
import 'package:tradz/model/post_unlike_model.dart';
import 'package:tradz/model/product_details_model.dart';
import 'package:tradz/model/share_product_model.dart';
import 'package:tradz/model/successModel.dart';
import 'package:tradz/model/user_product_model.dart';
import 'package:tradz/utilities/CacheImageProvider.dart';
import 'package:translator/translator.dart';

import 'login_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productID;
  final bool isMessageIconVisible;

  const ProductDetailsScreen
      (
      {
        Key? key,
      required this.productID,
      required this.isMessageIconVisible})
      : super(key: key);

  @override
  ProductDetailsState createState() => ProductDetailsState();
}

class ProductDetailsState extends State<ProductDetailsScreen> {
  final translator = GoogleTranslator();
  bool _isProductLiked = false;
  bool _isProductChangesApply =
      false; //this bool value true only if there is any change in the PostDetails
  bool isItemTraded = false;
  bool _isOwnerItem = false;
  bool _isProgressVisible = false;
  bool _isValidatedResponse = true;
  bool _isProductNotAvailable = false; //check if PostDetails Product available.
  bool _isInternet = true;
  bool productAlreadyMessaged=false;
  int _currentPage = 0;
  int productPrice=0;
  int distance=0;
  int likedCount = 0;
  String myEmail = '';
  String productOwnerFirebaseID='';
  String category='';
  String subCategory='';
  String productOwner='';
  String assetImage='';
  String productdetails='';
  String distanceUnit='';
  String productOwnerUrl='';
  String lookingFor='';
  String productTitle='';
  String productOwnerEmail='';
  late ProductDetailsModel productDetailsModel;
  late ShareProductModel shareProductModel;
  List<String> imageURl = [];
  List<UserProductData> myProductDataList = [];
  late String currentUserId;
  late String token;
  late UserProductModel userProductModel;
  late AuthProvider authProvider;
  late ViewProvider viewProvider;
  late FacebookLoginProvider facebookLoginProvider;
  final PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 1.0,
  );

  String productDetailsTitle='';String noInternetMessage='';
  String postLikedItemMessage='';
      String errorInProductMessage='';
      String LookingFor='';
      String itemTradedText='';
      String addProductToastMessage='';
      String toastOwnItemLikeMsg='';
      String toastOwnItemMessageMsg='';
      String chatInitiatedToast='';
      String away='';

  // List<String> featuredcontent = widget.ImageUrl;

  List<Widget> indicators(imagesLength, currentIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: const EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: currentIndex == index ? Colors.black : Colors.black26,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 5.0,
              ),
            ]),
      );
    });
  }
  String warningText='';
  String messageText='';
  String cancel='';
  String send='';

  @override
  void initState() {
    checkSelectedLanguage();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    authProvider = context.read<AuthProvider>();
    viewProvider = context.read<ViewProvider>();
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true)
    {
      currentUserId = authProvider.getUserFirebaseId()!;
    }
    token = authProvider.getUserTokenID()!;
    getCallUSerProductAPI();
    getCallPostDetailsAPI();
    getEmailFromPref();
   // likedCount = widget.likeCount;
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
        _isProgressVisible = false;
        _isValidatedResponse=false;
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
        _isProgressVisible = false;
        _isValidatedResponse=false;
        print("checkInternetFromWithinWidgets internet becomes exception " + _isInternet.toString());
      });
      return false;
    }
  }
  void checkSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? locale = prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale=='hi')
          {
            if(!mounted)return;
            setState(() {
              productDetailsTitle=Strings.productDetailsTitle_hi;
              noInternetMessage=Strings.noInternetMessage_hi;
              postLikedItemMessage=Strings.postLikedItemMessage_hi;
              errorInProductMessage=Strings.errorInProductMessage_hi;
              addProductToastMessage=Strings.addProductToastMessage_hi;
              LookingFor=Strings.LookingFor_hi;
              itemTradedText=Strings.itemTradedText_hi;
              toastOwnItemLikeMsg=Strings.toastOwnItemLikeMsg_hi;
              toastOwnItemMessageMsg=Strings.toastOwnItemMessageMsg_hi;
              chatInitiatedToast= Strings.chatInitiatedToast_hi;
              away=Strings.away_hi;
              warningText=Strings.warningText_hi;
              messageText=Strings.newlyChatMessage_hi;
              cancel=Strings.cancel_hi;
              send=Strings.sendButton_hi;
            });
          }else if(locale=='bn')
            {
              if(!mounted)return;
              setState(() {
                productDetailsTitle=Strings.productDetailsTitle_bn;
                noInternetMessage=Strings.noInternetMessage_bn;
                postLikedItemMessage=Strings.postLikedItemMessage_bn;
                errorInProductMessage=Strings.errorInProductMessage_bn;
                addProductToastMessage=Strings.addProductToastMessage_bn;
                LookingFor=Strings.LookingFor_bn;
                itemTradedText=Strings.itemTradedText_bn;
                toastOwnItemLikeMsg=Strings.toastOwnItemLikeMsg_bn;
                toastOwnItemMessageMsg=Strings.toastOwnItemMessageMsg_bn;
                chatInitiatedToast= Strings.chatInitiatedToast_bn;
                away=Strings.away_bn;
                warningText=Strings.warningText_bn;
                messageText=Strings.newlyChatMessage_bn;
                cancel=Strings.cancel_bn;
                send=Strings.sendButton_bn;
              });
            }
        else if(locale=='te')
          {
            if(!mounted)return;
            setState(() {
              productDetailsTitle=Strings.productDetailsTitle_te;
              noInternetMessage=Strings.noInternetMessage_te;
              postLikedItemMessage=Strings.postLikedItemMessage_te;
              errorInProductMessage=Strings.errorInProductMessage_te;
              addProductToastMessage=Strings.addProductToastMessage_te;
              LookingFor=Strings.LookingFor_te;
              itemTradedText=Strings.itemTradedText_te;
              toastOwnItemLikeMsg=Strings.toastOwnItemLikeMsg_te;
              toastOwnItemMessageMsg=Strings.toastOwnItemMessageMsg_te;
              chatInitiatedToast= Strings.chatInitiatedToast_te;
              away=Strings.away_te;
              warningText=Strings.warningText_te;
              messageText=Strings.newlyChatMessage_te;
              cancel=Strings.cancel_te;
              send=Strings.sendButton_te;
            });
          }
        else
          {
            if(!mounted)return;
            setState(() {
              productDetailsTitle=Strings.productDetailsTitle;
              noInternetMessage=Strings.noInternetMessage;
              postLikedItemMessage=Strings.postLikedItemMessage;
             errorInProductMessage=Strings.errorInProductMessage;
              addProductToastMessage=Strings.addProductToastMessage;
              LookingFor=Strings.LookingFor;
              itemTradedText=Strings.itemTradedText;
              toastOwnItemLikeMsg=Strings.toastOwnItemLikeMsg;
              toastOwnItemMessageMsg=Strings.toastOwnItemMessageMsg;
              chatInitiatedToast= Strings.chatInitiatedToast;
              away=Strings.away;
              warningText=Strings.warningText;
              messageText=Strings.newlyChatMessage;
              cancel=Strings.cancelButton;
              send=Strings.sendButton;
            });
          }
        // else
        // {
        //   productDetailsTitle=await getTranslation(productDetailsTitle, locale);
        //   LookingFor=await getTranslation(LookingFor, locale);
        //   noInternetMessage=await getTranslation(noInternetMessage, locale);
        //   addProductToastMessage=await getTranslation(addProductToastMessage, locale);
        //   postLikedItemMessage=await getTranslation(postLikedItemMessage, locale);
        //   errorInProductMessage=await getTranslation(errorInProductMessage, locale);
        //   itemTradedText=await getTranslation(itemTradedText, locale);
        //   toastOwnItemLikeMsg=await getTranslation(toastOwnItemLikeMsg, locale);
        //   toastOwnItemMessageMsg=await getTranslation(toastOwnItemMessageMsg, locale);
        //   chatInitiatedToast=await getTranslation(chatInitiatedToast, locale);
        //   away=await getTranslation(away, locale);
        //   // await translator.translate(productDetailsTitle,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     productDetailsTitle=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(LookingFor,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     LookingFor=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(noInternetMessage,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     noInternetMessage=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(addProductToastMessage,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     addProductToastMessage=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(postLikedItemMessage,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     postLikedItemMessage=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(errorInProductMessage,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     errorInProductMessage=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(itemTradedText,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     itemTradedText=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(toastOwnItemLikeMsg,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     toastOwnItemLikeMsg=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(toastOwnItemMessageMsg,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     toastOwnItemMessageMsg=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(chatInitiatedToast,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     chatInitiatedToast=value.toString();
        //   //   });
        //   // });
        //   // await translator.translate(away,to:locale).then((value){
        //   //   print("The value after translate is $value");
        //   //   if(!mounted)return;
        //   //   setState(() {
        //   //     away=value.toString();
        //   //   });
        //   // });
        // }
      }
    else
    {
      if(!mounted)return;
      setState(() {
        productDetailsTitle=Strings.productDetailsTitle;
        noInternetMessage=Strings.noInternetMessage;
        postLikedItemMessage=Strings.postLikedItemMessage;
        errorInProductMessage=Strings.errorInProductMessage;
        addProductToastMessage=Strings.addProductToastMessage;
        LookingFor=Strings.LookingFor;
        itemTradedText=Strings.itemTradedText;
        toastOwnItemLikeMsg=Strings.toastOwnItemLikeMsg;
        toastOwnItemMessageMsg=Strings.toastOwnItemMessageMsg;
        chatInitiatedToast= Strings.chatInitiatedToast;
        away=Strings.away;
        warningText=Strings.warningText;
        messageText=Strings.newlyChatMessage;
        cancel=Strings.cancelButton;
        send=Strings.sendButton;
      });
    }
  }

  //getUser product to check if user have a Product,if not then user unable to like or message to other user product
  //and redirect to AddProduct Screen.
  void getCallUSerProductAPI() async {
    int page = 1;
    try{
      API.getUserProduct(page, token).then((response) {
        var statusCode = response.statusCode;

        if (statusCode == 200 || statusCode == 201)
        {
          setState(() {
            userProductModel =
                UserProductModel.fromJson(json.decode(response.body));
            myProductDataList.addAll(userProductModel.products.data);
            print(
                "the myProduct list is ${myProductDataList.length}\n the bool is ${myProductDataList.isNotEmpty}");
          });
        }
        else {
          setState(() {});
        }
      });
    }catch(e)
    {
      if(kDebugMode)
        {
          print("The exception is $e");
        }
    }
  }

  //Product/Item Details API gets call.
  void getCallPostDetailsAPI() async
  {
   checkInternet();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? locale = prefs.getString(Strings.selectedLanguage);
    try {
      API.getUserProductDetails(token, widget.productID).then((response) async {
        int statusCode = response.statusCode;
        if (kDebugMode) {
          print(
              "The response code is $statusCode\n the response of PostDetails is ${response.body}");
        }
        if (statusCode == 200 || statusCode == 201)
        {
          final body = json.decode(response.body);
          print("response body is " + body['status'].toString());
          if (body['status'] ==
              true) //check If message success then only data loaded.
          {
            productDetailsModel =
                ProductDetailsModel.fromJson(json.decode(response.body));
            if(locale!=null)
              {
                if(locale=='en')
                  {
                    if(!mounted)return;
                    setState(() {
                      category=productDetailsModel.data.category_details!.text;
                      subCategory=productDetailsModel.data.sub_category_details!.text;
                      productdetails=productDetailsModel.data.description;
                      lookingFor=productDetailsModel.data.looking_for;
                      productOwner=productDetailsModel.data.user_details.first_name;
                      productTitle=productDetailsModel.data.title;
                    });
                  }
                else
                {

                  category=await getTranslation(productDetailsModel.data.category_details!.text,locale);
                  subCategory=await getTranslation(productDetailsModel.data.sub_category_details!.text, locale);
                  productdetails=await getTranslation(productDetailsModel.data.description, locale);
                  lookingFor=await getTranslation(productDetailsModel.data.looking_for, locale);
                  productOwner=await getTranslation(productDetailsModel.data.user_details.first_name, locale);
                  productTitle=await getTranslation(productDetailsModel.data.title, locale);
        //           try{
        //
        //
        //             await translator.translate(productDetailsModel.data.category_details!.text,to:locale).then((value){
        //               print("The value after translate is $value");
        //               if(!mounted)return;
        //               setState(() {
        //                 category=value.toString();
        //               });
        //             });
        //             await translator.translate(productDetailsModel.data.sub_category_details!.text,to:locale).then((value){
        //               print("The value after translate is $value");
        //               if(!mounted)return;
        //               setState(() {
        //                 subCategory=value.toString();
        //               });
        //             });
        //             await translator.translate(productDetailsModel.data.description,to:locale).then((value){
        //               print("The value after translate is $value");
        //               if(!mounted)return;
        //               setState(() {
        //                 productdetails=value.toString();
        //               });
        //             });
        //             await translator.translate(productDetailsModel.data.looking_for,to:locale).then((value){
        //               print("The value after translate is $value");
        //               if(!mounted)return;
        //               setState(() {
        //                 lookingFor=value.toString();
        //               });
        //             });
        //             await translator.translate(productDetailsModel.data.user_details.first_name,to:locale).then((value){
        //               print("The value after translate in product owner  is $value");
        //               if(!mounted)return;
        //               setState(() {
        //                 productOwner=value.toString();
        //               });
        //             });
        //             await translator.translate(productDetailsModel.data.title,to:locale).then((value){
        //               print("The value after translate is $value");
        //               if(!mounted)return;
        //               setState(() {
        //                 productTitle=value.toString();
        //               });
        //             });
        //             await translator.translate(productDetailsModel.data.user_details.distance_unit,to:locale).then((value){
        //               print("The value after translate distance margin is $value");
        //               if(!mounted)return;
        //               setState(() {
        //                 distanceUnit=value.toString();
        //               });
        //             });
        //           }catch(e)
        // {
        //   print("exception is $e");
        // }

                }
              }
            else{
              if(!mounted)return;
              setState(() {
                category=productDetailsModel.data.category_details!.text;
                subCategory=productDetailsModel.data.sub_category_details!.text;
                productdetails=productDetailsModel.data.description;
                lookingFor=productDetailsModel.data.looking_for;
                productOwner=productDetailsModel.data.user_details.first_name;
                productTitle=productDetailsModel.data.title;
              });
            }
            if(!mounted)return;
            setState(()
            {
              _isProgressVisible = false;
              _isValidatedResponse = false;
              imageURl = productDetailsModel.data.base_64_images;
              likedCount=productDetailsModel.total_likes;
              distanceUnit=productDetailsModel.data.user_details.distance_unit;
              distance=productDetailsModel.data.distance;
              productPrice=productDetailsModel.data.price;
              productOwnerUrl=productDetailsModel.data.image_b64;
              assetImage=productDetailsModel.data.user_details.image_avatar_path;
              productOwnerEmail=productDetailsModel.data.user_details.email;
              productOwnerFirebaseID=productDetailsModel.data.user_details.social_profile_id;
              if(productDetailsModel.is_active_chat==1)
                {
                  productAlreadyMessaged=true;
                }else{
                productAlreadyMessaged=false;
              }
              if(productDetailsModel.is_liked==1)
                {
                  _isProductLiked=true;
                }
              else{
                _isProductLiked=false;
              }
              if (productDetailsModel.data.is_traded == 1) {
                isItemTraded = true;
              } else {
                isItemTraded = false;
              }
              if (productOwnerEmail == myEmail) {
                _isOwnerItem = true;
              }
            });
          }
          else if(body['status']=='unauthenticated')
          {
            if(!mounted)return;
            setState(() {
              _isProgressVisible = false;
              _isValidatedResponse = false;
            });
            getCallSignout(authProvider,facebookLoginProvider);
          }
          else if(body['message'] =="Out Of Reach")
            {
              setState(() {
                print("inside the else if part");
                _isProgressVisible = false;
                _isValidatedResponse = false;
                _isProductNotAvailable =
                true; //this case only when product is not available i.e Product Owner deleted the Product.

              });
            }

          else
          {
            if(!mounted)return;
            setState(() {
              _isProductNotAvailable =
                  true;
              _isProgressVisible = false;
              _isValidatedResponse = false;
            });
          }
        } else {
          if(!mounted)return;
          setState(() {
            _isProgressVisible = false;
            _isValidatedResponse = false;
          });
        }
      });
    } catch (e) {
      if(!mounted)return;
      setState(() {
        _isProgressVisible = false;
        _isValidatedResponse = false;
      });
      if (kDebugMode) {
        print("The exception in the PostDetails Screen is $e");
      }
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
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>LoginScreen()));
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


  Future<String> getTranslation(String text, String locale)async{
    String returnValue='';
   try{
     await translator.translate(text,to:locale).then((value)
     {
       print("The value after translate in product owner  is $value");
       returnValue=value.toString();
     });
     return returnValue;
   }
   catch(e)
    {
      if(kDebugMode)
        {
          print("The exception in postDetails translation is $e");
        }
      return returnValue;
    }
   // return returnValue;
  }

  //get current User email ID for checking on Like and Message Icon,if same user try to like or Message [As of now from marketPlace current user product hidden but for future if current user product listed on Marketplace than same user unable to like or message himself.]
  void getEmailFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myEmail = prefs.getString(FirestoreConstants.email)!;
  }

  //on click heartIcon for Unlike Product getCallPostUnlikeItem method gets called.
  void getCallPostUnlikeItem() async {
    if(!mounted)return;
    setState(() {
      _isProgressVisible = true;
    });
    PostUnlikeModel map = PostUnlikeModel(liked_product_id: widget.productID);
    API.postUnlike(map.toMap(), token).then((response) {
      int statusCode = response.statusCode;
      if (kDebugMode) {
        print("the status is $statusCode\n the response is ${response.body}");
      }
      if (statusCode == 200 || statusCode == 201) {
        final body = json.decode(response.body);
        if(body['status']==true)
          {
            if(!mounted)return;
            setState(() {
              _isProductChangesApply =
              true; //this bool value true only if there is any chenge in the PostDetails
              _isProductLiked = false;
              likedCount = likedCount - 1;
              _isProgressVisible = false;
            });
          }else if(body['success']=='unauthenticated')
            {
              if(!mounted)return;
              setState(() {
                _isProgressVisible = false;
              });
              getCallSignout(authProvider, facebookLoginProvider);
            }
        else {
          if(!mounted)return;
          setState(() {
            _isProgressVisible = false;
          });
        }
      } else {
        if(!mounted)return;
        setState(() {
          _isProgressVisible = false;
        });
      }
    });
  }


  //on click heartIcon for like Product getCallPostLikeItem method gets called.
  void getCallPostLikeItem() async {
    if(!mounted)return;
    setState(() {
      _isProgressVisible = true;
    });
    PostLikeModel map = PostLikeModel(
        liked_product_id: widget.productID,
        message_text: Strings.postLikedItemMessage);
    API.postFirstLike(map.toMap(), token).then((response) {
      int statusCode = response.statusCode;
      if (kDebugMode) {
        print("the status is $statusCode\n the response is ${response.body}");
      }
      if (statusCode == 200 || statusCode == 201) {
        final body = json.decode(response.body);
        if(body['status']==true)
          {
            if(!mounted)return;
            setState(() {
              _isProductChangesApply =
              true; //this bool value true only if there is any change in the PostDetails
              _isProductLiked = true;
              likedCount = likedCount + 1;
              _isProgressVisible = false;
            });
          }
        else if(body['status']=='unauthenticated')
            {
              if(!mounted)return;
              setState(() {
                _isProductLiked = false;
                _isProgressVisible = false;
              });
              getCallSignout(authProvider, facebookLoginProvider);
            }
        else
        {
          if(!mounted)return;
          setState(() {
            _isProductLiked = false;
            _isProgressVisible = false;
          });
        }

      } else {
        if(!mounted)return;
        setState(() {
          _isProductLiked = false;
          _isProgressVisible = false;
        });
      }
    });
  }


  _onPageChanged(int page) {
    if (kDebugMode) {
      print("the page no is " + page.toString());
    }
    if(!mounted)return;
    setState(() {
      _currentPage = page;
    });
  }

  Future<bool> getCallNavigatorPop() async {
    if (_isProductChangesApply) {
      viewProvider.changeView(true);
    }
    Navigator.of(context).pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return getCallNavigatorPop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              getCallNavigatorPop();
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(productDetailsTitle),
          centerTitle: false,
          actions: [
            // IconButton(onPressed: () {}, icon: const Icon(Icons.report)),
            IconButton(
                onPressed: (){

                  getCallShareProductAPI(widget.productID,productDetailsModel.data.title);

                  // Share.share('check out my website https://example.com',
                  //     subject: 'Look what I made!');
                },
                icon: const Icon(Icons.share)),
            !widget.isMessageIconVisible
                ? IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => CategoryScreen(
                                    ImageUrl: imageURl,
                                    productPrice: productPrice,
                                    productdetails: productdetails,
                                    subCategory: subCategory,
                                    productTitle: productTitle,
                                    category: category,
                                    productID: widget.productID,
                                    lookingFor: lookingFor,
                                  )));
                    },
                    icon: const Icon(Icons.edit_outlined))
                : const SizedBox.shrink()
          ],
        ),
        body: _isValidatedResponse
            ?
        Container(
                child: const Center(
                        child: CircularProgressScreen(),
                      )
              )
            : Stack(
              children: [
                SingleChildScrollView(
                    child: Stack(
                      children: [
                        _isProductNotAvailable
                            ? EmptyResultWidget(errorInProductMessage)
                            : Column(
                                children: <Widget>[
                                  SizedBox(
                                    width: MediaQuery.of(context)
                                        .size
                                        .width
                                        .toDouble(),
                                    height:
                                        MediaQuery.of(context).size.height * 0.35,
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                            reverse: false,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
//                              pageSnapping: false,
                                            controller: _pageController,
                                            onPageChanged: _onPageChanged,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: imageURl.isNotEmpty
                                                ? imageURl.length
                                                : 0,
                                            //widget.ImageUrl.isNotEmpty?widget.ImageUrl.length:0,
                                            itemBuilder:
                                                (BuildContext context, int index)
                                            {
                                              final item = imageURl[index];
                                              return GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
//                                  barrierDismissible:true,
                                                    builder: (BuildContext
                                                            context) =>
                                                        ZoomableDialog(
                                                            assetImage: '',
                                                            //empty string is assetImage as it is used in ProfileScreen
                                                            networkImage: item),
                                                  );
                                                },
                                                child: Image.memory(
                                                  base64Decode(item),
                                                  fit: BoxFit.contain,
                                                  gaplessPlayback: true,
                                                ),
                                              );
                                              // return Image.network(
                                              //   Constant.baseurl+item,
                                              //   fit: BoxFit.cover,
                                              // );
                                            }),
                                        Visibility(
                                          visible: !_isInternet, //if no Internet then like and message icon hide.
                                          child: Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0, right: 4.0),
                                              child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5.0),
                                                        color: Colors.black26,
                                                      ),
                                                      child: _isOwnerItem
                                                          ? const IconButton(
                                                              onPressed: null,
                                                              icon: Icon(
                                                                  Icons.favorite))
                                                          : IconButton(
                                                              icon: _isProductLiked
                                                                  ? const Icon(
                                                                      Icons.favorite,
                                                                      color: Colors
                                                                          .redAccent,
                                                                    )
                                                                  : const Icon(
                                                                      Icons
                                                                          .favorite_border,
                                                                      color: Colors
                                                                          .redAccent,
                                                                    ),
                                                              onPressed: () async{
                                                                if (productOwnerEmail !=
                                                                    myEmail) //check if its current user Product,if true He/She unable to like his own Product.
                                                                {
                                                                  if (_isProductLiked) {
                                                                    bool value=await checkInternetFromWithinWidgets();
                                                                    if(value)
                                                                      {
                                                                        getCallPostUnlikeItem();
                                                                      }

                                                                  } else {
                                                                    if (myProductDataList
                                                                        .isNotEmpty) //condition true means user don't have a single Product in its list so He/She not able to like product and redirect him to Add New Product
                                                                    {
                                                                      bool value=await checkInternetFromWithinWidgets();
                                                                      if(value)
                                                                        {
                                                                          getCallPostLikeItem();
                                                                        }
                                                                    } else {
                                                                      Fluttertoast.showToast(
                                                                          msg: addProductToastMessage);
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (BuildContext
                                                                                      context) =>
                                                                                  CategoryScreen(
                                                                                    //new Product creation with only productID(which need to Like Product once Product Added successfully.) is non empty,other items are empty.
                                                                                    ImageUrl: [],
                                                                                    productPrice: 0,
                                                                                    lookingFor: '',
                                                                                    productdetails: '',
                                                                                    subCategory: '',
                                                                                    productTitle: '',
                                                                                    category: '',
                                                                                    productID: widget.productID,
                                                                                  )));
                                                                    }
                                                                  }
                                                                } else {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          toastOwnItemLikeMsg);
                                                                }
                                                              },
                                                            ),
                                                    ),
                                                    addHorizontalSpace(4.0),
                                                    Text(
                                                      likedCount.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: 'Libre Franklin',
                                                        fontSize: 24.0,
                                                        shadows: <Shadow>[
                                                          Shadow(
                                                            blurRadius: 5.0,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    addHorizontalSpace(4.0),
                                                    Visibility(
                                                      visible:
                                                          widget.isMessageIconVisible,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  5.0),
                                                          color: Colors.black26,
                                                        ),
                                                        child: IconButton(
                                                          icon: const Icon(
                                                              Icons.message),
                                                          color: Colors.white,
                                                          onPressed: () async{
                                                            if (productAlreadyMessaged)
                                                            {
                                                              Fluttertoast.showToast(
                                                                  msg: chatInitiatedToast);
                                                            } else {
                                                              if (productOwnerEmail !=
                                                                  myEmail) //Check if current user same of Product Owner
                                                              {
                                                                if (myProductDataList
                                                                    .isNotEmpty) {
                                                                  bool value=await checkInternetFromWithinWidgets();
                                                                  if(value)
                                                                    {
                                                                      showDialog(
                                                                          context:
                                                                          context,
                                                                          builder:
                                                                              (BuildContext
                                                                          context) {
                                                                            //TODO model.user_details_social_profile_id and model.user_details.first_name
                                                                            return UserMessageDialog(
                                                                                currentUserId,
                                                                                productOwnerFirebaseID,
                                                                                token,
                                                                                productOwner,
                                                                                widget
                                                                                    .productID,
                                                                                warningText,messageText,cancel,send,imageURl[0]);
                                                                          });
                                                                    }
                                                                }
                                                                else {
                                                                  Fluttertoast.showToast(
                                                                      msg: addProductToastMessage);
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (BuildContext
                                                                                  context) =>
                                                                               CategoryScreen //new Product creation with only productID(which need to Like Product once Product Added successfully.) is non empty,other items are empty.
                                                                                  (
                                                                                ImageUrl: [],
                                                                                productPrice:
                                                                                    0,
                                                                                lookingFor:
                                                                                    '',
                                                                                productdetails:
                                                                                    '',
                                                                                subCategory:
                                                                                    '',
                                                                                productTitle:
                                                                                    '',
                                                                                category:
                                                                                    '',
                                                                                productID:
                                                                                    0,
                                                                              )));
                                                                }
                                                              } else {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        toastOwnItemMessageMsg);
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          bottom: 0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4, left: 4),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  category.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 24.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                        blurRadius: 5.0,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  subCategory,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                        blurRadius: 5.0,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        imageURl.isNotEmpty && imageURl.length > 1
                                            ? Positioned(
                                                bottom: 0,
                                                right: 0,
                                                left: 0,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 4.0),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                      children: indicators(
                                                          imageURl.length,
                                                          _currentPage)),
                                                ),
                                              )
                                            : Container(),
                                        imageURl.isNotEmpty && imageURl.length > 1
                                            ? Positioned(
                                                top: 0,
                                                bottom: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _pageController.previousPage(
                                                        duration: const Duration(
                                                            milliseconds: 1000),
                                                        curve: Curves.ease);
                                                  },
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.only(left: 4.0),
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.black26,
                                                      child: Icon(
                                                        Icons.keyboard_arrow_left,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                            : Container(),
                                        imageURl.isNotEmpty && imageURl.length > 1
                                            ? Positioned(
                                                top: 0,
                                                bottom: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _pageController.nextPage(
                                                        duration: const Duration(
                                                            milliseconds: 1000),
                                                        curve: Curves.ease);
                                                    // if(_currentPage==featuredcontent.length-1)
                                                    // {
                                                    //   setState(() {
                                                    //     print("hello i am at last");
                                                    //     _currentPage=0;
                                                    //   });
                                                    //
                                                    // }
                                                  },
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.only(right: 4.0),
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.black26,
                                                      child: Icon(
                                                        Icons.keyboard_arrow_right,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 8.0,
                                        bottom: 8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.topLeft,
                                          margin: const EdgeInsets.only(
                                              right: 4.0, left: 4.0),
                                          child: Text(
                                            productTitle,
//                          textDirection: TextDirection.rtl,
                                            style: const TextStyle(
                                              //fontFamily: 'Merriweather',
                                              //fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                            ),
                                            //textAlign: TextAlign.center,
                                            //textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                        addVerticalSpace(8.0),
                                        Visibility(
                                          visible: !_isInternet,
                                          child: Row(
                                            children: <Widget>[
                                              assetImage.isNotEmpty
                                                  ? CircleAvatar(
                                                      radius: 10,
                                                      backgroundImage: AssetImage(
                                                          assetImage),
                                                    )
                                                  : CircleAvatar(
                                                      radius: 10,
                                                      backgroundImage:
                                                          CacheImageProvider(
                                                              tag: productOwnerUrl,
                                                              img: base64.decode(productOwnerUrl)),
                                                      //MemoryImage(base64Decode(widget.productOwnerUrl))
                                                      //NetworkImage(productOwnerUrl)
                                                    ),
                                              addHorizontalSpace(4.0),
                                              Expanded(
                                                  child: Text(
                                                productOwner,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: lookingFor.isNotEmpty
                                              ? true
                                              : false,
                                          child: Column(
                                            children: [
                                              addVerticalSpace(4.0),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    LookingFor,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      ' $lookingFor',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        addVerticalSpace(8.0),
                                        Visibility(
                                          visible: !widget.isMessageIconVisible,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    itemTradedText,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Switch(
                                                    value: isItemTraded,
                                                    onChanged: (value) {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        isItemTraded = value;
                                                        if (isItemTraded) {
                                                          getCallProductTradedAPI();
                                                        } else {
                                                          getCallProductUnTradedAPI();
                                                        }
                                                      });
                                                    },
                                                    activeTrackColor: ConstantColors
                                                        .primaryDarkColor,
                                                    activeColor:
                                                        ConstantColors.primaryColor,
                                                  ),
                                                ],
                                              ),
                                              addVerticalSpace(8.0),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: productdetails.isNotEmpty,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width
                                                    .toDouble(),
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  productdetails,
                                                  // textAlign: TextAlign.justify,
                                                ),
                                              ),
                                              addVerticalSpace(8.0),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: distance != 0,
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                              distance.toString() +
                                                  " " +
                                                  distanceUnit +" "+
                                                  away,
                                              //textAlign: TextAlign.justify,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),

                      ],
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
      ),
    );
  }

  void getCallProductTradedAPI() async {
    if (!mounted) return;
    setState(() {
      _isProgressVisible = true;
    });
    API.getUserProductTraded(token, widget.productID).then((response) {
      int statusCode = response.statusCode;
      if (kDebugMode) {
        print(
            "the response  getUserProductTraded code is $statusCode\n the response body is ${response.body}");
      }
      if (statusCode == 200 || statusCode == 201) {
        final body = json.decode(response.body);
        if(body['status']==true)
          {
            SuccessModel model = SuccessModel.fromJson(json.decode(response.body));
            Fluttertoast.showToast(msg: model.message);
            if (!mounted) return;
            setState(() {
              _isProgressVisible = false;
            });
          }
        else if(body['status']=='unauthenticated')
            {
              if (!mounted) return;
              setState(() {
                _isProgressVisible = false;
              });
            }else {
          if (!mounted) return;
          setState(() {
            _isProgressVisible = false;
          });
        }

      } else {
        if (!mounted) return;
        setState(() {
          _isProgressVisible = false;
        });
      }
    });
  }

  void getCallProductUnTradedAPI() async {
    if (!mounted) return;
    setState(() {
      _isProgressVisible = true;
    });
    API.getUserProductUnTraded(token, widget.productID).then((response) {
      int statusCode = response.statusCode;
      if (kDebugMode) {
        print(
            "the resposne getCallProductUnTradedAPI code is $statusCode\n the response body is ${response.body}");
      }
      if (statusCode == 200 || statusCode == 201) {
        final body = json.decode(response.body);
        if(body['status']==true)
          {
            SuccessModel model = SuccessModel.fromJson(json.decode(response.body));
            Fluttertoast.showToast(msg: model.message);
            if (!mounted) return;
            setState(() {
              _isProgressVisible = false;
            });
          }else if(body['status']=='unauthenticated')
            {
              if (!mounted) return;
              setState(() {
                _isProgressVisible = false;
              });
              getCallSignout(authProvider, facebookLoginProvider);
            }

      } else {
        if (!mounted) return;
        setState(() {
          _isProgressVisible = false;
        });
      }
    });
  }

  buildDynamicLinks(String title,String image,String docId) async {
    print("The doc id is $docId");
    String url = Constant.FirebaseDynamicLinkUrl;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      link: Uri.parse('$url/tradzDetails?id=$docId'),
      androidParameters: AndroidParameters(
        packageName: "com.bcit.tradz",
        minimumVersion: 0,
      ),
      iosParameters: IosParameters
        (
        bundleId: "com.bcit.tradz",
        appStoreId: "123456789",
        minimumVersion: '1.0.1',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          description: '',
          imageUrl:
          Uri.parse("$image"),
          title: title),
    );
    final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();

    String? desc = '${dynamicUrl.shortUrl.toString()}';
    print("the dynamicShortlink is $dynamicUrl\n the description is $desc \n before shortcut its ${parameters.buildUrl()}");
    if(!mounted)return;
    setState(() {
      _isProgressVisible=false;
    });
    await Share.share(desc.toString(), subject: title,);
  }

  void getCallShareProductAPI(int productID,String title) {
    if(!mounted)return;
    setState(() {
      _isProgressVisible=true;
    });
    API.getCallProductShare(token, productID).then((response){
      int statusCode=response.statusCode;
      print("response of api call status  is $statusCode\n the response body is  ${response.body}");
      if(statusCode==200||statusCode==201)
        {
          final body = json.decode(response.body);
         if(kDebugMode)
           {
             print("response body in getSharedProduct is  " + body['status'].toString());
           }
          if(body['status']==true)
            {
              shareProductModel=ShareProductModel.fromJson(json.decode(response.body));
              buildDynamicLinks(title,Constant.baseurl+shareProductModel.image_path,widget.productID.toString());
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

        }else{
        if(!mounted)return;
        setState(() {
          _isProgressVisible=false;
        });
      }
    });
  }
}
