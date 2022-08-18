import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Constant/Constant.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allProvider/view_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/linear_view_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/app_screens/product_details_screen.dart';
import 'package:tradz/dialogs/product_report_dialog.dart';
import 'package:tradz/app_screens/search_filter_screen.dart';
import 'package:tradz/dialogs/userMessage_dialog.dart';
import 'package:tradz/model/app_setting_model.dart';
import 'package:tradz/model/markertplace_product_model.dart';
import 'package:tradz/model/post_like_model.dart';
import 'package:tradz/model/post_unlike_model.dart';
import 'package:tradz/model/report_product_resposne_model.dart';
import 'package:tradz/model/search_model.dart';
import 'package:tradz/model/user_product_model.dart';

import 'category_screen.dart';
import 'login_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late ScrollController _controller;
  int page = 1;
  String myEmailID = '';
  bool _isFilterEnabled = false;
  List<Data> DataList = [];
  List<int> likedItemsList = [];
  List<int> messagedProductList =
      []; // this list store the number of product to whom the user messaged for initiate Chat.
  List<int> selectedCategory = [];
  List<int> selectedSubCategory = [];
  late UserProductModel userProductModel;
  List<UserProductData> myProductDataList = [];
  late MarketPlaceProductModel marketPlaceProductModel;
  bool _isprogressBar = false;
  var Controller = TextEditingController();
  String warningText='';
  String search='';
  String messageText='';
  String cancel='';
  String send='';
  String addProductToastMessage='';
  String chatInitiatedToast='';

  late String token;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;
  late String currentUserId;
  String noInternetMessage='';
  bool _isInternet = false;

  @override
  void initState() {
    checkSelectedLanguage();
    authProvider = context.read<AuthProvider>();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    }
    token = authProvider.getUserTokenID()!;
    _controller = ScrollController();
    getCallUSerProductAPI();
    _controller.addListener(() {
      _scrollListner();
      //HomeScreenListView.value(_listScrollValue);
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
        _isprogressBar = false;
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
        _isprogressBar = false;
        print("insternet becomes exception " + _isInternet.toString());
      });
      return false;
    }
  }

  void getCallSignout(AuthProvider authProvider, FacebookLoginProvider facebookLoginProvider) async
  {
    if(!mounted)return;
    setState(() {
      _isprogressBar=true;
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
          _isprogressBar=false;
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
          _isprogressBar=false;
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
          _isprogressBar=false;
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
          _isprogressBar=false;
        });
      }
    }



  }

  void checkSelectedLanguage()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? locale = prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale=='hi')
          {
            if(!mounted)return;
            setState(() {
              search=Strings.search_hi;
              warningText=Strings.warningText_hi;
              messageText=Strings.newlyChatMessage_hi;
              cancel=Strings.cancel_hi;
              send=Strings.sendButton_hi;
              addProductToastMessage=Strings.addProductToastMessage_hi;
              chatInitiatedToast=Strings.chatInitiatedToast_hi;
              noInternetMessage=Strings.noInternetMessage_hi;
            });
          }else if(locale=='bn')
            {
              if(!mounted)return;
              setState(() {
                search=Strings.search_bn;
                warningText=Strings.warningText_bn;
                messageText=Strings.newlyChatMessage_bn;
                cancel=Strings.cancel_bn;
                send=Strings.sendButton_bn;
                addProductToastMessage=Strings.addProductToastMessage_bn;
                chatInitiatedToast=Strings.chatInitiatedToast_bn;
                noInternetMessage=Strings.noInternetMessage_bn;
              });
            }else if(locale=='te')
              {
                if(!mounted)return;
                setState(() {
                  search=Strings.search_te;
                  warningText=Strings.warningText_te;
                  messageText=Strings.newlyChatMessage_te;
                  cancel=Strings.cancel_te;
                  send=Strings.sendButton_te;
                  addProductToastMessage=Strings.addProductToastMessage_bn;
                  chatInitiatedToast=Strings.chatInitiatedToast_bn;
                  noInternetMessage=Strings.noInternetMessage_te;
                });
              }else{
          if(!mounted)return;
          setState(() {
            search=Strings.search;
            warningText=Strings.warningText;
            messageText=Strings.newlyChatMessage;
            cancel=Strings.cancelButton;
            send=Strings.sendButton;
            addProductToastMessage=Strings.addProductToastMessage;
            chatInitiatedToast=Strings.chatInitiatedToast;
            noInternetMessage=Strings.noInternetMessage;
          });
        }
      }
    else{
      if(!mounted)return;
      setState(() {
        search=Strings.search;
        warningText=Strings.warningText;
        messageText=Strings.newlyChatMessage;
        cancel=Strings.cancelButton;
        send=Strings.sendButton;
        addProductToastMessage=Strings.addProductToastMessage;
        chatInitiatedToast=Strings.chatInitiatedToast;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
  }

  void getCallUSerProductAPI() async {
    int page = 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    API.getUserProduct(page, token).then((response) {
      var statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 201) {
        final body = json.decode(response.body);
        if(body['status']==true)
          {
            setState(() {
              userProductModel =
                  UserProductModel.fromJson(json.decode(response.body));
              myProductDataList.addAll(userProductModel.products.data);
              print(
                  "the myProduct list is ${myProductDataList.length}\n the bool is ${myProductDataList.isNotEmpty}");
            });
          }else if(body['status']=='unauthenticated')
            {
              getCallSignout(authProvider, facebookLoginProvider);
            }


      } else {
        setState(() {});
      }
    });
  }

  _scrollListner() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (!mounted) return;
      setState(() {
        String message = "reach the bottom";
        print(message);
        _isprogressBar = true;
        page = page + 1;
        //getLoadSearchData(page,Controller.text);
        //_progressVisibility=true;
      });
      getCallSearchPost(Controller.text, page);
    }
  }

  void getCallSearchPost(String text, int page) async {
    likedItemsList.clear();
    messagedProductList.clear();
    checkInternet();
    if (kDebugMode) {
      print("searchText called $page called \n the text is $text");
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    myEmailID = prefs.getString(FirestoreConstants.email)!;
    SearchModel model = SearchModel(
        string: text,
        sub_categories: selectedSubCategory,
        categories: selectedSubCategory);
    API.getSearchedItem(token, model.toMap(), page).then((response) {
      if (!mounted) return;
      setState(() {
        if (page == 1) {
          DataList.clear();
        }
        int statusCode = response.statusCode;
        if (statusCode == 200|| statusCode==201) {
          //_validateResponse=false;
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              _isprogressBar = false;
              if (!_isFilterEnabled) //if filterButton is not visible then only this condition works
                  {
                // _isFilterEnabled=true;
              }
              marketPlaceProductModel =
                  MarketPlaceProductModel.fromJson(json.decode(response.body));
              DataList.addAll(marketPlaceProductModel.items.data);
              likedItemsList.addAll(marketPlaceProductModel.liked_items);
              messagedProductList.addAll(marketPlaceProductModel.active_chats);
            }
          else if(body['status']=='unauthenticated')
            {
              _isprogressBar = false;
              getCallSignout(authProvider, facebookLoginProvider);
            }else {
            _isprogressBar=false;
          }

        } else {
          //_validateResponse=false;
          _isprogressBar = false;
          //_isNoInternet=true;
        }
      });
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
      _isprogressBar = true;
      // _isValidateResponse=true;
      DataList.clear();
      likedItemsList.clear();
      messagedProductList.clear();
      myProductDataList.clear();
      getCallUSerProductAPI();
      getCallSearchPost(Controller.text, page);
    }
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: ConstantColors.PrimaryColor,
        leading: InkWell(
          child: const Icon(
            Icons.arrow_back,
            //color: Colors.white,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.close,
              ),
              onPressed: () {
                Controller.clear();
                onSearchTextChanged("");
              })
        ],
        title: TextField(
          autofocus: true,
          controller: Controller,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: search,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          onChanged: onSearchTextChanged,
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
              padding: const EdgeInsets.all(8.0),
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemCount: DataList.isNotEmpty ? DataList.length : 0,
              itemBuilder: (BuildContext context, int index) {
                final model = DataList[index];

                if (likedItemsList.isNotEmpty)
                {
                  for (int i = 0; i < likedItemsList.length; i++) //check if product id falls in liked Items by User
                  {
                    int likedItem = likedItemsList[i];
                    if (likedItem == model.id)
                    {
                      model.is_liked = true; //if product id falls in user liked item we change heart to liked. By default from api bool value ids false.
                    }
                  }
                }

                if (messagedProductList.isNotEmpty) {
                  for (int i = 0; i < messagedProductList.length; i++)
                  {
                    int productID = messagedProductList[i];
                    if (productID == model.id)
                    {
                      model.is_active_chat = true;
                    }
                  }
                }
                return GestureDetector(
                  onTap: () async{
                    bool value=await checkInternetFromWithinWidgets();
                    if(value)
                      {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ProductDetailsScreen(
                                      productID: model.id,
                                      isMessageIconVisible: true,
                                    )));
                      }
                  },
                  child: LinearViewWidget(
                    productName: model.title,
                    distance: model.distance,
                    distanceUnit: model.user_details.distance_unit,
                    assetImage: model.user_details.image_avatar_path,
                    lookingFor: model.looking_for,
                    likedCallBack: () async
                    {
                      bool value=await checkInternetFromWithinWidgets();
                      if(value)
                        {

                          if (model.user_details.email !=
                              myEmailID) //check if same USer product not clicked
                              {
                            if (model.is_liked)
                            {
                              getCallPostUnlikeItem(model.id, model);
                            } else {
                              if (myProductDataList.isNotEmpty) {
                                // call liked API to post product for this user as liked and also send email and push notification.
                                getCallPostLikeItem(model.id,
                                    model.user_details.email, model.user_id, model);
                              } else {
                                Fluttertoast.showToast(
                                    msg: addProductToastMessage,
                                    toastLength: Toast.LENGTH_LONG);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CategoryScreen(
                                              //new Product creation with only productID(which need to Like Product once Product Added successfully.) is non empty,other items are empty.
                                              ImageUrl: [],
                                              productPrice: 0,
                                              lookingFor: '',
                                              productdetails: '',
                                              subCategory: '',
                                              productTitle: '',
                                              category: '',
                                              productID: model.id,
                                            )));
                              }
                            }
                          }
                          // if(model.is_liked)
                          // {
                          //   getCallPostUnlikeItem(model.id,model);
                          // }else{
                          //   // call liked API to post product for this user as liked and also send email and push notification.
                          //   getCallPostLikeItem(model.id,model.user_details.email,model.user_id,model);
                          // }
                        }

                    },
                    productOwnerName: model.user_details.first_name,
                    messageCallBack: () async
                    {
                      if (myProductDataList.isNotEmpty) {
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
                                      model.user_details.social_profile_id,
                                      token,
                                      model.user_details.first_name,
                                      model.id,warningText,messageText,cancel,send,model.base_64_images[0]);
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
                            msg: addProductToastMessage);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                     CategoryScreen(
                                      //new Product creation if User doesn't have Products.
                                      ImageUrl: [],
                                      productPrice: 0,
                                      lookingFor: '',
                                      productdetails: '',
                                      subCategory: '',
                                      productTitle: '',
                                      category: '',
                                      productID: 0,
                                    )));
                      }
                    },
                    productImageUrl: model.base_64_images.isNotEmpty
                        ? model.base_64_images[0]
                        : "",
                    isItemLiked: model.is_liked,
                    productDetails: model.description,
                    productOwnerUrl: model.user_details.image_b64,
                    isMarketPlaceView: true,
                    likes_count: model.likes_count,
                    isMessageIconVisible:
                        model.user_details.email != myEmailID ? true : false,
                    reportCallBack: () async{
                      bool value=await checkInternetFromWithinWidgets();
                      if(value)
                        {
                          if (model.user_details.email != myEmailID) {
                            getCallAppSettingAPI(model.id, context);
                          }
                        }
                    },
                    isOwnerItem:
                        model.user_details.email != myEmailID ? false : true,
                    isDeleteButtonEnabled:
                        false, // isDeleteButtonEnabled is only for the MyProductScreen to dete the product.
                  ),
                );
              }),
          Visibility(
            child: const CircularProgressScreen(),
            visible: _isprogressBar,
          ),
          NoInternetView(isInternet: _isInternet, noInternetMessage: noInternetMessage,),
        ],
      ),
      floatingActionButton: Visibility(
        visible: _isFilterEnabled,
        child: FloatingActionButton.small(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const SearchFilterScreen())).then((value) async {
              if (value != null) {
                //value null when pop by by backButton.
                String Navigatevalue =
                    value; //value came from the searchfilter and contains category and subcategory id's.
                var parts = Navigatevalue.split('|'); //if value="2,4";
                var category = parts[0].trim(); // category: "2"
                var subcategory = parts[1].trim();
                selectedCategory = json.decode(category).cast<
                    int>(); //cast the category get from the searchfilter as string on int list.
                selectedSubCategory = json.decode(subcategory).cast<int>();

                if (selectedCategory.isNotEmpty) {
                  if (!mounted) return;
                  setState(() {
                    _isprogressBar = true;
                    page = 1;
                    DataList.clear();
                    likedItemsList.clear();
                    messagedProductList.clear();
                    getCallSearchPost(Controller.text, page);
                    //getLoadSearchData(page,Controller.text);
                    //_progressVisibility=true;
                  });
                }
              }
            });
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: const Icon(
            Icons.filter_alt_sharp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    setState(() {
      _isprogressBar = true;
    });
    if (text.isEmpty) {
      setState(() {
        DataList.clear();
        _isprogressBar = false;
        _isFilterEnabled = false;
        selectedCategory.clear();
        selectedSubCategory.clear();
        // _validateResponse=false;
        print("searchText called clear");
      });
      return;
    } else {
      //checkInternet();
      print("The length of char in search is ${text.length}");
      if (text.length >= 3) {
        setState(() {
          _isprogressBar = true;
        });
        DataList.clear();
        getCallSearchPost(text, 1);
      } else {
        setState(() {
          DataList.clear();
          _isFilterEnabled = false;
          selectedSubCategory.clear();
          selectedCategory.clear();
          _isprogressBar = false;
        });
      }
    }
  }

  void getCallPostLikeItem(int productID, String productOwnerEmail,
      int productOwnerID, Data model) async {
    try {
      setState(() {
        _isprogressBar = true;
      });
      bool result = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(Strings.google_token);
      PostLikeModel map = PostLikeModel(
          liked_product_id: productID,
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
              result = true;
              if(!mounted)return;
              setState(() {
                model.is_liked = true;
                model.likes_count = model.likes_count + 1;
                _isprogressBar = false;
              });
            }else if(body['status']=='unauthenticated')
              {
                result = false;
                if(!mounted)return;
                setState(() {
                  model.is_liked = false;
                  _isprogressBar = false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }

        } else {
          result = false;
          setState(() {
            model.is_liked = false;
            _isprogressBar = false;
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("the exception in liked item is ${e.toString()}");
      }
      setState(() {
        model.is_liked = false;
        _isprogressBar = false;
      });
    }
  }

  void getCallPostUnlikeItem(int productID, Data model) async {
    setState(() {
      _isprogressBar = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    PostUnlikeModel map = PostUnlikeModel(liked_product_id: productID);
    try {
      API.postUnlike(map.toMap(), token).then((response) {
        int statusCode = response.statusCode;
        print("the resposne is $statusCode");
        if (statusCode == 200 || statusCode == 201) {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if(!mounted)return;
              setState(() {
                model.is_liked = false;
                model.likes_count = model.likes_count - 1;
                likedItemsList.clear();
                _isprogressBar = false;
              });
            }else if(body['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  //model.is_liked=false;
                  _isprogressBar = false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }else {
            if(!mounted)return;
            setState(() {
              //model.is_liked=false;
              _isprogressBar = false;
            });
          }

        } else {
          setState(() {
            //model.is_liked=false;
            _isprogressBar = false;
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        setState(() {
          model.is_liked = false;
          _isprogressBar = false;
        });
        print("throwing new error");
        throw Exception("Error on server");
        print("The exception is $e");
      }
    }
  }

  void getCallAppSettingAPI(int productID, BuildContext context) async {
    try {
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
          _isprogressBar = true;
        });
        page = 1;
        DataList.clear();
        likedItemsList.clear();
        messagedProductList.clear();
        getCallSearchPost(Controller.text, page);
        //getLoadSearchData(page,Controller.text);
        //_progressVisibility=true;
      });
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? token = prefs.getString(Strings.google_token);
      // setState(() {
      //   _isprogressBar = true;
      // });
      // API.getCallAppSetting(token).then((response) async {
      //   int statusCode = response.statusCode;
      //   if (kDebugMode) {
      //     print("the status is $statusCode\n the response is ${response.body}");
      //   }
      //   if (statusCode == 200 || statusCode == 201) {
      //     List<ReportRadioMessage> reportList = [];
      //     AppSettingModel model =
      //         AppSettingModel.fromJson(json.decode(response.body));
      //     reportList.addAll(model.settings.report_radio_message);
      //     setState(() {
      //       _isprogressBar = false;
      //     });
      //     await showDialog(
      //         context: context,
      //         barrierDismissible: false,
      //         builder: (BuildContext context) {
      //           return ProductReportDialog(productID);
      //         }).then((value) {
      //       ReportProductResponseModel model =
      //           ReportProductResponseModel.fromJson(json.decode(value));
      //       Fluttertoast.showToast(
      //         msg: model.message,
      //         toastLength: Toast.LENGTH_LONG,
      //         timeInSecForIosWeb: 2,
      //       );
      //       if (!mounted) return;
      //       setState(() {
      //         _isprogressBar = true;
      //       });
      //       page = 1;
      //       DataList.clear();
      //       likedItemsList.clear();
      //       messagedProductList.clear();
      //       getCallSearchPost(Controller.text, page);
      //       //getLoadSearchData(page,Controller.text);
      //       //_progressVisibility=true;
      //     });
      //   } else {
      //     setState(() {
      //       _isprogressBar = false;
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
