import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Constant/Constant.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allMethods/Methods.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allProvider/view_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/allWidgets/text_button_column.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:tradz/allWidgets/text_button_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/api/http_parameter.dart';
import 'package:tradz/model/post_like_model.dart';
import 'package:translator/translator.dart';

import 'login_screen.dart';

class UploadImageScreen extends StatefulWidget {
  final String title,description,estimatePrice,lookingFor,categoryId,subcategoryId;
  final int productID;
  const UploadImageScreen({Key? key,
   required this.title,
    required this.description,
    required this.lookingFor,
    required this.estimatePrice,
    required this.categoryId,
    required this.subcategoryId, required this.productID ,
  }) : super(key: key);

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> with SingleTickerProviderStateMixin{
  final translator = GoogleTranslator();
  final _formKey = GlobalKey<FormState>();
  var categoryController = TextEditingController();
  bool _isProductLiked = false;
  bool _isGalleryImageSelected = false;
  bool _isCameraImageSelected = false;
  bool _isUsePhotoSelected = false;
  int _currentPage = 0;
  int maxImage = 3;
  final imagePicker = ImagePicker();
  List<File>? images = [];
  List<File>? thumbnail=[];

  String uploadImage='';String retake='';String usePhoto='';String addMore='';String removeBackground='';
  String gallery='';String camera='';String productAddedSuccessToast='';
  String selectImageFirstToast='';

  Future<File> customCompressed(
      {
  required File imagePathToCompress,
    quality=100,
    percentage=10,
  }) async
  {
    var path=await FlutterNativeImage.compressImage(
      imagePathToCompress.absolute.path,
      quality:100,
      percentage:10,
    );
    return path;
  }

  final PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 1.0,
  );

  var subCategoryController = TextEditingController();
  var estimateController = TextEditingController();
  var descriptionController = TextEditingController();
  bool _isProgressBar=false;
  var _animatedController;
  bool _isInternet = false;
  String noInternetMessage='';
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;

  @override
  void initState() {
    authProvider= context.read<AuthProvider>();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    checkSelectedLanguage();
    getNumberofImage();
    _animatedController= AnimationController(vsync: this,duration: const Duration(milliseconds: 450));
    super.initState();
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
  void checkSelectedLanguage()async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? locale = prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale=='hi')
          {
            if(!mounted)return;
            setState(() {
              uploadImage=Strings.uploadImage_hi;
              retake=Strings.retake_hi;
              usePhoto=Strings.usePhoto_hi;
              addMore=Strings.addMore_hi;
              removeBackground=Strings.removeBackground_hi;
              gallery=Strings.gallery_hi;
              camera=Strings.camera_hi;
              productAddedSuccessToast=Strings.productAddedSuccessToast_hi;
              selectImageFirstToast=Strings.selectImageFirstToast_hi;
              noInternetMessage=Strings.noInternetMessage_hi;
            });
          }else if(locale=='bn')
            {
              if(!mounted)return;
              setState(() {
                uploadImage=Strings.uploadImage_bn;
                retake=Strings.retake_bn;
                usePhoto=Strings.usePhoto_bn;
                addMore=Strings.addMore_bn;
                removeBackground=Strings.removeBackground_bn;
                gallery=Strings.gallery_bn;
                camera=Strings.camera_bn;
                productAddedSuccessToast=Strings.productAddedSuccessToast_bn;
                selectImageFirstToast=Strings.selectImageFirstToast_bn;
                noInternetMessage=Strings.noInternetMessage_bn;
              });
            }else if(locale=='te')
              {
                if(!mounted)return;
                setState(() {
                  uploadImage=Strings.uploadImage_te;
                  retake=Strings.retake_te;
                  usePhoto=Strings.usePhoto_te;
                  addMore=Strings.addMore_te;
                  removeBackground=Strings.removeBackground_te;
                  gallery=Strings.gallery_te;
                  camera=Strings.camera_te;
                  productAddedSuccessToast=Strings.productAddedSuccessToast_te;
                  selectImageFirstToast=Strings.selectImageFirstToast_te;
                  noInternetMessage=Strings.noInternetMessage_te;
                });
              }else{
          if(!mounted)return;
          setState(() {
            uploadImage=Strings.uploadImage;
            retake=Strings.retake;
            usePhoto=Strings.usePhoto;
            addMore=Strings.addMore;
            removeBackground=Strings.removeBackground;
            gallery=Strings.gallery;
            camera=Strings.camera;
            productAddedSuccessToast=Strings.productAddedSuccessToast;
            selectImageFirstToast=Strings.selectImageFirstToast;
            noInternetMessage=Strings.noInternetMessage;
          });
        }
      }else{
      if(!mounted)return;
      setState(() {
        uploadImage=Strings.uploadImage;
        retake=Strings.retake;
        usePhoto=Strings.usePhoto;
        addMore=Strings.addMore;
        removeBackground=Strings.removeBackground;
        gallery=Strings.gallery;
        camera=Strings.camera;
        productAddedSuccessToast=Strings.productAddedSuccessToast;
        selectImageFirstToast=Strings.selectImageFirstToast;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
  }

  void getNumberofImage() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String value=prefs.getString(Strings.uploadImageNumber)!;
    if(kDebugMode)
    {
      print("max allowed images are $value");
    }
   setState(() {
     maxImage=int.parse(value);
   });
  }

  List<Widget> indicators(imagesLength, currentIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return imagesLength == 1
          ? Container()
          : Container(
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

  _onPageChanged(int page) {
    print("the page no is " + page.toString());
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    ViewProvider viewProvider=Provider.of<ViewProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarView(titleText: uploadImage, isAppBackBtnVisible: true),
      body: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  images!.isNotEmpty
                      ? SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width
                        .toDouble(),
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.35,
                    child: Stack(
                      children: [
                        PageView.builder(
                            reverse: false,
                            physics: const AlwaysScrollableScrollPhysics(),
//                              pageSnapping: false,
                            controller: _pageController,
                            onPageChanged: _onPageChanged,
                            scrollDirection: Axis.horizontal,
                            itemCount: images!.length,
                            itemBuilder: (BuildContext context, int index) {
                              //final item = images![index];
                              return Image.file(
                                File(images![index].path),
                                fit: BoxFit.contain,
                              );
                            }),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                  indicators(images!.length, _currentPage)),
                            )),
                        images != null && images!.length > 1
                            ? Positioned(
                            top: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                _pageController.previousPage(
                                    duration:
                                    const Duration(milliseconds: 1000),
                                    curve: Curves.ease);
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black26,
                                  child: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ))
                            : Container(),
                        images != null && images!.length > 1
                            ? Positioned(
                            top: 0,
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                _pageController.nextPage(
                                    duration:
                                    const Duration(milliseconds: 1000),
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
                                padding: EdgeInsets.only(right: 4.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black26,
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
                  )
                      : Container(
                    color: Colors.grey,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.35,
                  ),
                  Column(
                    children: <Widget>[
                      const Divider(
                        height: 2.0,
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _isGalleryImageSelected
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButtonView(
                                text: retake,
                                voidCallback: () async{
                                  bool value=await checkInternetFromWithinWidgets();
                                  if(value)
                                    {
                                      getImageFromGallery(Strings.retake);
                                    }

                                }),
                            TextButtonView(
                                text: usePhoto,
                                voidCallback: () async{
                                  // getCallUsePhoto();
                                  //_openCustomDialog();
                                  bool value=await checkInternetFromWithinWidgets();
                                  if(value)
                                    {
                                      getCallAddProductAPI(viewProvider);
                                    }

                                }),
                          ],
                        )
                            : _isCameraImageSelected
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButtonView(
                                text: retake,
                                voidCallback: () async{
                                  bool value=await checkInternetFromWithinWidgets();
                                  if(value)
                                    {
                                      getImageFromCamera(Strings.retake);
                                    }

                                }),
                            Visibility(
                              visible:
                              images!.length >= maxImage ? false : true,
                              child: TextButtonView(
                                  text: addMore,
                                  voidCallback: () async{
                                    bool value=await checkInternetFromWithinWidgets();
                                    if(value)
                                      {
                                        getImageFromCamera(Strings.addMore);
                                      }
                                  }),
                            ),
                            TextButtonView(
                                text: usePhoto,
                                voidCallback: () async{
                                  bool value=await checkInternetFromWithinWidgets();
                                  if(value)
                                    {
                                      getCallAddProductAPI(viewProvider);
                                    }
                                  //getCallUsePhoto();
                                  // _openCustomDialog();
                                }),
                          ],
                        )
                            : _isUsePhotoSelected
                            ? TextButtonView(
                          text: removeBackground,
                          voidCallback: () {},
                        )
                            : Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButtonColumn(
                                voidCallback: () async{
                                  bool value=await checkInternetFromWithinWidgets();
                                  if(value)
                                    {
                                      getImageFromGallery(Strings.gallery);
                                    }

                                },
                                icon: const Icon(Icons.photo),
                                text: gallery),
                            TextButtonColumn(
                                voidCallback: () async
                                {
                                  bool value=await checkInternetFromWithinWidgets();
                                  if(value)
                                    {
                                      getImageFromCamera(Strings.camera);
                                    }
                                },
                                icon: const Icon(Icons.camera_alt),
                                text: camera)
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
              Visibility(
                  visible: _isProgressBar,
                  child: const CircularProgressScreen()
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
          )),
    );
  }

  // void _openCustomDialog() {
  //   showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
  //       transitionBuilder: (context, a1, a2, widget) {
  //         return Transform.scale(
  //           scale: a1.value,
  //           child: Opacity(
  //             opacity: a1.value,
  //             child: AlertDialog(
  //               shape: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(16.0)),
  //               title: IconButton(onPressed: (){},
  //                 iconSize: 24.0,color: ConstantColors.primaryColor,
  //                   icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow,
  //                       progress: _animatedController),
  //               ),
  //               content: const Text('How are you?'),
  //             ),
  //           ),
  //         );
  //       },
  //       transitionDuration: const Duration(milliseconds: 200),
  //       barrierDismissible: true,
  //       barrierLabel: '',
  //       context: context,
  //       pageBuilder: (context, animation1, animation2) {
  //         return const Text('PAGE BUILDER');
  //       });
  // }

  Future getImageFromGallery(String imageClickFrom) async {
    try {
      final List<XFile>? selectedImages = await imagePicker.pickMultiImage(
          imageQuality: 100);
        if (imageClickFrom == Strings.retake && selectedImages != null)
        {
          setState(() {
            images!.clear();
            thumbnail!.clear();
          });
        }
        if (selectedImages!.isNotEmpty && selectedImages.length < maxImage)
        {
          for(int i=0;i<selectedImages.length;i++)
          {
            print("Image before compression is ${File(selectedImages[i].path).lengthSync()/1024}");
            final size=File(selectedImages[i].path).lengthSync()/1024;
            if(size>100)
              {
                File compressedImage=await customCompressed(imagePathToCompress: File(selectedImages[i].path));
                final sizeinKb=compressedImage.lengthSync()/1024;
                print("Image after compression is $sizeinKb");
                setState(() {
                  images!.add(compressedImage);
                  thumbnail!.add(compressedImage);
                });
              }
            else{
              File compressedImage=File(selectedImages[i].path);
              setState(() {
                images!.add(compressedImage);
                thumbnail!.add(compressedImage);
              });
            }


          }
          // images!.addAll(selectedImages);
          // thumbnail!.addAll(selectedImages);
        setState(() {
          _isGalleryImageSelected = true;
        });
        }
        else
        {
          setState(() {
            images!.clear();
            thumbnail!.clear();
          });
          for(int i=0;i<maxImage;i++)
          {
            print("Th total images  inside maxImage are ${selectedImages.length}");

            print("Image before compression is ${File(selectedImages[i].path).lengthSync()}");
            File compressedImage=await customCompressed(imagePathToCompress: File(selectedImages[i].path));
            final sizeinKb=compressedImage.lengthSync()/1024;
            print("Image after compression is $sizeinKb");
           // Fluttertoast.showToast(msg: "The before image ${selectedImages.length} and after image $sizeinKb",timeInSecForIosWeb: 5);
            setState(() {
              images!.add(compressedImage);
              thumbnail!.add(compressedImage);
              // images!.add(selectedImages[i]);
              // thumbnail!.add(selectedImages[i]);
              _isGalleryImageSelected = true;
            });
          }
        }
    } catch (e) {
      if (kDebugMode) {
        print("The Exception in gallery is $e");
      }
    }
  }

  Future getImageFromCamera(String imageClickFrom) async {
    try {
      final XFile? photo =
      await imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
          imageQuality: 100
      );
        if (imageClickFrom == Strings.retake && photo != null) {
         setState(() {
           images!.clear();
           thumbnail!.clear();
         });
        }
        print("Image before compression is ${File(photo!.path).lengthSync()}");
        File compressedImage=await customCompressed(imagePathToCompress: File(photo.path));
        final sizeinKb=compressedImage.lengthSync()/1024;
      //Fluttertoast.showToast(msg: "The before image ${photo.length} and after image $sizeinKb",timeInSecForIosWeb: 5);

      print("Image after compression is $sizeinKb");
        setState(() {
          images!.add(compressedImage);
          thumbnail!.add(compressedImage);
          if (!_isCameraImageSelected && images!.isNotEmpty) {
            _isCameraImageSelected = true;
          }
        });
    } catch (e) {
      if (kDebugMode) {
        print("Exception in camera open is  $e");
      }
    }
  }

  void getCallUsePhoto() {
    Navigator.pop(context, images);
  }

  void getCallAddProductAPI(ViewProvider viewProvider) async{
    File? _storageImage;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    setState(() {
      _isProgressBar = true;
    });
    try {
      print("the title is ${widget.title} \n the description is ${widget.description}  \n the estimate is ${widget.estimatePrice} \n the categoryid is ${widget.categoryId} \n the subcat is ${widget.subcategoryId}");
      String url = Constant.baseurl + HttpParams.API_ADD_PRODUCT;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = widget.title;
      request.fields['description'] = widget.description;
      request.fields['looking_for']=widget.lookingFor;
      request.fields['price'] = widget.estimatePrice;
      request.fields['category_id'] = widget.categoryId;
      request.fields['sub_category_id'] = widget.subcategoryId;
      List<MultipartFile> originalImageList = [];
      List<MultipartFile> thumbnailImageList = [];
      for (int i = 0; i < images!.length; i++)
      {
        _storageImage = File(images![i].path);
        print("the image size is ${_storageImage.length()}");
        var originalFile = await http.MultipartFile.fromPath(
            'original_images[$i]', _storageImage.path);
        var thumbfile = await http.MultipartFile.fromPath(
            'thumbnail_images[$i]', _storageImage.path);
        originalImageList.add(originalFile);
        thumbnailImageList.add(thumbfile);
      }

      print("the items send are $originalImageList" +
          "\n thumbnail is $thumbnailImageList");
      if (originalImageList.isNotEmpty) {
        request.files.addAll(originalImageList);
        request.files.addAll(thumbnailImageList);
        var requestResponse = await request.send();
        print("requestResponse is ${requestResponse.statusCode}");
        var response = await http.Response.fromStream(requestResponse);
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        print("the response result is $result");
        if (requestResponse.statusCode == 200 ||
            requestResponse.statusCode == 201) {
          if(result['status']==true)
            {
              print("the productID is ${widget.productID}");
              if(widget.productID!=0)
              {
                getCallPostLikeItem(widget.productID,viewProvider); // this method calls when user first time try to like item and redirected to add item after He/She added Product successfully the item he/she tried to like will be liked.
              }
              else
              {
                if(!mounted)return;
                setState(() {
                  _isProgressBar = false;
                });
                Fluttertoast.showToast(
                    msg:
                    productAddedSuccessToast);
                viewProvider.changeView(true);
                int count=0;
                Navigator.of(context).popUntil((route){
                  return count++==4;
                });
              }
            }
          else if(result['status']=='unauthenticated')
              {
                if(!mounted)return;
                setState(() {
                  _isProgressBar = false;
                });
                getCallSignout(authProvider, facebookLoginProvider);
              }
          else {
            if(!mounted)return;
            setState(() {
              _isProgressBar = false;
            });
          }

        }
        else {
          Fluttertoast.showToast(
              msg:
              "response code is ${response.statusCode} Something went wrong, Please try again");
          if(!mounted)return;
          setState(() {
            _isProgressBar = false;
          });
        }
      } else {
        setState(() {
          _isProgressBar=false;
          Fluttertoast.showToast(
              msg:
              selectImageFirstToast);
        });
        if (kDebugMode) {
          print("the original Image empty");
        }
      }
    } catch (e) {
      setState(() {
        _isProgressBar = false;
      });
      if (kDebugMode) {
        print("exception is $e");
      }
      Fluttertoast.showToast(msg: "The exception generated is $e");
    }
  }

  //getCallPostLikeItem called once the Product uploaded successful.
  void getCallPostLikeItem(int productID, ViewProvider viewProvider) async
  {
    try{
      if (!mounted) return;
      setState(() {
        _isProgressBar=true;
      });
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
          print("the status in uploadImageScreen makeLike Product $statusCode\n the response is ${response.body}");
        }
        if (statusCode == 200 || statusCode == 201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              if(!mounted)return;
              setState(()
              {
                _isProgressBar = false;
              });
              Fluttertoast.showToast(
                  msg:
                  productAddedSuccessToast);
              viewProvider.changeView(true);
              int count=0;
              Navigator.of(context).popUntil((route)
              {
                return count++==4;
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
          else
          {
            if(!mounted)return;
            setState(() {
              _isProgressBar = false;
            });
          }

        }
        else
        {
          if(!mounted)return;
          setState(() {
            _isProgressBar = false;
          });
        }
      });
    }
    catch(e)
    {
      if(kDebugMode)
      {
        print("the exception in UploadImageScreen liked item is ${e.toString()}");
      }
      if (!mounted) return;
      setState(() {
        _isProgressBar=false;
      });
    }
  }
}
