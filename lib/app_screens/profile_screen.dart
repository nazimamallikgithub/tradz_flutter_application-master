import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Constant/Constant.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allMethods/Methods.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allProvider/home_provider.dart';
import 'package:tradz/allProvider/view_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/button_view.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/allWidgets/text_button_view.dart';
import 'package:tradz/allWidgets/textfield_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/api/http_parameter.dart';
import 'package:tradz/app_screens/avatars_images_screen.dart';
import 'package:tradz/app_screens/main_screen.dart';
import 'package:tradz/dialogs/zoomable_dialog.dart';
import 'package:tradz/model/profile_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tradz/model/update_profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:tradz/utilities/CacheImageProvider.dart';
import 'package:translator/translator.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isAppBarVisible;

  const ProfileScreen({Key? key, required this.isAppBarVisible})
      : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final translator = GoogleTranslator();
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
  bool _isProgressBar = false;
  bool _isSharedPrefImage=false;
  bool _isEmailTextFieldVisible=false;
  final _formKey = GlobalKey<FormState>();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var currentLocationController = TextEditingController();
  final imagePicker = ImagePicker();
  File ? _localStorageImage;
  String assetImage="";
  String? token;
  bool _isInternet = false;
  String noInternetMessage='';
  bool _isAssetImageSelected=false;

  String? networkAvailableImage;
  bool _isSubmitButtonEnabled = false;
  late bool _serviceEnabled;
  List<Placemark>  _userLocation=[];
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;
  late HomeProvider homeProvider;
  late String currentUserId;
  late String latitudeValue,longitudeValue,pincodeValue,cityName,stateName,countryName;

  String? currentLatLng="";
  String Address = 'search';
  String profileAppbarTitle='';
 String upload_photo=''; String first_name='';String last_name='';
 String email="";
 String current_location=''; String submit_button='';String update_button='';
 String errorTextFirstName='';
   String   errorTextLastName='';String gallery='';String dialogAvatarTextTitle='';
   String errorEmail='';
   String profileDialogTitle='';String profileUpdateMessage='';
  String emailAlreadyUsed='';

  @override
  void initState() {
    checkSelectedLanguage();
    super.initState();
    authProvider= context.read<AuthProvider>();
    facebookLoginProvider=context.read<FacebookLoginProvider>();
    homeProvider=context.read<HomeProvider>();
    readLocal();
    if(widget.isAppBarVisible)
      {
        getPreferenceValue();
      }
    else
    {
      getUserProfile();
    }
    
  }

  void checkSelectedLanguage() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
    {
      if(locale=='hi')
      {
        if(!mounted) return;
        setState(() {
          profileAppbarTitle=Strings.profileAppbarTitle_hi;
          upload_photo=Strings.upload_photo_hi;
          first_name=Strings.first_name_hi;
          last_name=Strings.last_name_hi;
          email=Strings.email_hi;
          current_location=Strings.current_location_hi;
          submit_button=Strings.submit_button_hi.toUpperCase();
          update_button=Strings.update_button_hi.toUpperCase();
          errorTextFirstName=Strings.errorTextFirstName_hi;
          errorTextLastName=Strings.errorTextLastName_hi;
          errorEmail=Strings.errorEmail_hi;
          gallery=Strings.gallery_hi;
          dialogAvatarTextTitle=Strings.dialogAvatarTextTitle_hi;
          profileDialogTitle=Strings.profileDialogTitle_hi;
          profileUpdateMessage=Strings.profileUpdateMessage_hi;
          noInternetMessage=Strings.noInternetMessage_hi;
          emailAlreadyUsed=Strings.emailAlreadyUsed_hi;
        });
      }
      else if(locale=='bn')
        {
          if(!mounted) return;
          setState(() {
            profileAppbarTitle=Strings.profileAppbarTitle_bn;
            upload_photo=Strings.upload_photo_bn;
            first_name=Strings.first_name_bn;
            last_name=Strings.last_name_bn;
            email=Strings.email_bn;
            errorEmail=Strings.errorEmail_bn;
            current_location=Strings.current_location_bn;
            submit_button=Strings.submit_button_bn.toUpperCase();
            update_button=Strings.update_button_bn.toUpperCase();
            errorTextFirstName=Strings.errorTextFirstName_bn;
            errorTextLastName=Strings.errorTextLastName_bn;
            gallery=Strings.gallery_bn;
            dialogAvatarTextTitle=Strings.dialogAvatarTextTitle_bn;
            profileDialogTitle=Strings.profileDialogTitle_bn;
            profileUpdateMessage=Strings.profileUpdateMessage_bn;
            noInternetMessage=Strings.noInternetMessage_bn;
            emailAlreadyUsed=Strings.emailAlreadyUsed_bn;
          });
        }
      else if(locale=='te')
        {
          if(!mounted) return;
          setState(() {
            profileAppbarTitle=Strings.profileAppbarTitle_te;
            upload_photo=Strings.upload_photo_te;
            first_name=Strings.first_name_te;
            last_name=Strings.last_name_te;
            email=Strings.email_te;
            errorEmail=Strings.errorEmail_te;
            current_location=Strings.current_location_te;
            submit_button=Strings.submit_button_te.toUpperCase();
            update_button=Strings.update_button_te.toUpperCase();
            errorTextFirstName=Strings.errorTextFirstName_te;
            errorTextLastName=Strings.errorTextLastName_te;
            gallery=Strings.gallery_te;
            dialogAvatarTextTitle=Strings.dialogAvatarTextTitle_te;
            profileDialogTitle=Strings.profileDialogTitle_te;
            profileUpdateMessage=Strings.profileUpdateMessage_te;
            noInternetMessage=Strings.noInternetMessage_te;
            emailAlreadyUsed=Strings.emailAlreadyUsed_te;
          });
        }
      else{
        if(!mounted) return;
        setState(() {
          profileAppbarTitle=Strings.profileAppbarTitle;
          upload_photo=Strings.upload_photo;
          first_name=Strings.first_name;
          last_name=Strings.last_name;
          email=Strings.email;
          errorEmail=Strings.errorEmail;
          current_location=Strings.current_location;
          submit_button=Strings.submit_button.toUpperCase();
          update_button=Strings.update_button.toUpperCase();
          errorTextFirstName=Strings.errorTextFirstName;
          errorTextLastName=Strings.errorTextLastName;
          gallery=Strings.gallery;
          dialogAvatarTextTitle=Strings.dialogAvatarTextTitle;
          profileDialogTitle=Strings.profileDialogTitle;
          profileUpdateMessage=Strings.profileUpdateMessage;
          noInternetMessage=Strings.noInternetMessage;
          emailAlreadyUsed=Strings.emailAlreadyUsed;
        });

      }
    }
    else
    {
      if(!mounted) return;
      setState(() {
        profileAppbarTitle=Strings.profileAppbarTitle;
        upload_photo=Strings.upload_photo;
        first_name=Strings.first_name;
        last_name=Strings.last_name;
        email=Strings.email;
        errorEmail=Strings.errorEmail;
        current_location=Strings.current_location;
        submit_button=Strings.submit_button.toUpperCase();
        update_button=Strings.update_button.toUpperCase();
        errorTextFirstName=Strings.errorTextFirstName;
        errorTextLastName=Strings.errorTextLastName;
        gallery=Strings.gallery;
        dialogAvatarTextTitle=Strings.dialogAvatarTextTitle;
        profileDialogTitle=Strings.profileDialogTitle;
        profileUpdateMessage=Strings.profileUpdateMessage;
        noInternetMessage=Strings.noInternetMessage;
        emailAlreadyUsed=Strings.emailAlreadyUsed;
      });
    }
  }

  void readLocal()
  {
    if(authProvider.getUserFirebaseId()?.isNotEmpty==true)
    {
      currentUserId=authProvider.getUserFirebaseId()!;
      print("the current User id is $currentUserId");
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.clear();
    currentLocationController.dispose();
    super.dispose();
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position)async
  {
     _userLocation = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (kDebugMode) {
      print("the location address array is $_userLocation");
    }
    Placemark place = _userLocation[0];
    Placemark place1=_userLocation[1];
    Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(()
    {
      latitudeValue=position.latitude.toString();
      longitudeValue=position.longitude.toString();
      if(place.isoCountryCode!.isNotEmpty)
        {
          countryName=place.isoCountryCode!;
        }
      else if(place1.isoCountryCode!.isNotEmpty)
        {
          countryName=place1.isoCountryCode!;
        }
      else
      {
        countryName="IN";
      }

      //if(place.)

      if(place.postalCode!.isNotEmpty)
        {
          pincodeValue=place.postalCode!.toString();
          // stateName="state";
          // cityName="city";
        }
      else if(place1.postalCode!.isNotEmpty)
        {
          pincodeValue=place1.postalCode!.toString();
          // stateName="state";
          // cityName="city";
        }
      else{
        pincodeValue="pincodeValue";
        // stateName="state";
        // cityName="city";
      }

      if(place.administrativeArea!.isNotEmpty)
        {
          stateName=place.administrativeArea!;
        }
      else if(place1.administrativeArea!.isNotEmpty)
        {
          stateName=place1.administrativeArea!;
        }
      else{
        stateName="state";
      }

      if(place.subAdministrativeArea!.isNotEmpty)
        {
          cityName=place.subAdministrativeArea!;
        }else if(place1.subAdministrativeArea!.isNotEmpty)
          {
            cityName=place1.subAdministrativeArea!;
          }
      else{
        cityName="city";
      }



      currentLocationController.text=place.locality.toString();
      //if there is network/local image then submit button enabled.
      if (networkAvailableImage != null) {  // check if Google auth gmail Image
        _isSubmitButtonEnabled = true;
      }
      else if (_localStorageImage != null) {   //check if local storage Image captured or not
        _isSubmitButtonEnabled = true;
      }
      else if(assetImage.isNotEmpty)
        {
          _isSubmitButtonEnabled=true;
        }
    });
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
    } on SocketException catch (_)
    {
      setState(() {
        _isInternet = true;
        _isProgressBar = false;
        print("checkInternetFromWithinWidgets internet becomes exception " + _isInternet.toString());
      });
      return false;
    }
  }

  //In case of MainScreen BottomNavigation Profile
  void getUserProfile() async {
    setState(() {
      _isProgressBar=true;
    });
    checkInternet();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString(Strings.google_token);

    String? locale=prefs.getString(Strings.selectedLanguage);
    API.getUserProfile(token).then((response) async {
  int statusCode=response.statusCode;
  print("response code is $statusCode "+"\n the response getUserProfile body is ${response.body}");
    if(statusCode==200)
      {
        ProfileModel model=ProfileModel.fromJson(json.decode(response.body));
        if(!mounted)return;
        setState(()
        {
          _isProgressBar=false;
          _isSharedPrefImage=false;
          networkAvailableImage=model.user.image_blob;
          assetImage=model.user.image_avatar_path;
          longitudeValue=model.user.longitude.toString();
          latitudeValue=model.user.latitude.toString();
          countryName=model.user.country.toString();
          stateName=model.user.state.toString();
          cityName=model.user.city.toString();
          pincodeValue=model.user.pincode.toString();
         if (kDebugMode) {
           print("the longitude value is $longitudeValue and latitude is $latitudeValue");
         }
          if (networkAvailableImage != null)
          {
            _isSubmitButtonEnabled = true;
          }
        });
        if(locale!=null)
          {
            if(locale=='en')
            {
              if(!mounted)return;
              setState(() {
                firstNameController.text=model.user.first_name;
                lastNameController.text=model.user.last_name;
                emailController.text=model.user.email;
                currentLocationController.text=model.user.location_locality;
              });
            }
            else
            {
              firstNameController.text=await getTranslation(model.user.first_name, locale);
              lastNameController.text=await getTranslation(model.user.last_name, locale);
              emailController.text=model.user.email;
              currentLocationController.text=await getTranslation(model.user.location_locality, locale);
              // await translator.translate(model.user.first_name,to:locale).then((value){
              //   print("The value after translate is $value");
              //   if(!mounted)return;
              //   setState(() {
              //     firstNameController.text=value.toString();
              //   });
              // });
              // await translator.translate(model.user.last_name,to:locale).then((value){
              //   print("The value after translate is $value");
              //   if(!mounted)return;
              //   setState(() {
              //     lastNameController.text=value.toString();
              //   });
              // });
              // await translator.translate(model.user.location_locality,to:locale).then((value){
              //   print("The value after translate is $value");
              //   if(!mounted)return;
              //   setState(() {
              //     currentLocationController.text=value.toString();
              //   });
              // });
            }
          }
        else{
          if(!mounted)return;
          setState(() {
            firstNameController.text=model.user.first_name;
            lastNameController.text=model.user.last_name;
            emailController.text=model.user.email;
            currentLocationController.text=model.user.location_locality;
          });
        }
      }
    });
  }
//In case of first Time User after Login
  void getPreferenceValue() async { //here value is getting from Firebase Google auth and saved in SharedPreference

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString(FirestoreConstants.firstName);
    String? lastName = prefs.getString(FirestoreConstants.lastName);
    String? email = prefs.getString(FirestoreConstants.email);
    String? profileType = Strings.google;
    String? profileID = prefs.getString(FirestoreConstants.id);
    String? location = prefs.getString(Strings.location); //location always null when user first time registered and come to Profile screen.
    if(kDebugMode)
      {
        print("the email is $email\n the profile id is $profileID");
      }
    if(email=="$profileID@gmail.com" ||email!.isEmpty)
      {
        print("the email is $profileID@gmail.com");
        if(!mounted)return;
        setState(() {
          _isEmailTextFieldVisible=true;
          emailController.text="";
        });
      }
    else
      {
      setState(() {
        emailController.text=email;
      });
    }
    print("The location in getPreferenceValue is $location");
    if(!mounted) return;
     setState(() {
       _isProgressBar=true;
       _isSharedPrefImage=true;
       networkAvailableImage = prefs.getString(FirestoreConstants.photoUrl);
       if (kDebugMode) {
         print("path is $networkAvailableImage");
       }
       firstNameController.text = firstName!;

       lastNameController.text = lastName!;

       _isProgressBar=false;
     });
      if (location != null) {
        if (networkAvailableImage != null) {
          _isSubmitButtonEnabled = true;
        }
        if(!mounted) return;
       setState(() {
         currentLocationController.text = location;
       });
      }
      else {
        Position position = await _getGeoLocationPosition(); //here the GPS enable check and get user current location
        currentLatLng ='${position.latitude},${position.longitude}';
        print("latlng is $currentLatLng");
        GetAddressFromLatLong(position); // here the user locality and other details extract
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

  void getGalleryImage() async {
    XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100
    );
    if (kDebugMode) {
      print("the image is ${image}\n the prefstorage is $networkAvailableImage");
    }
    // final bytes = (await _image?.readAsBytes())?.lengthInBytes;
    // print("the size of image is $bytes");
    if(image!=null)
      {
        final size=File(image.path).lengthSync()/1024;
        if(kDebugMode)
        {
          print("before compression is $size");
        }
        if(size>100)
        {
          File compressedImage=await customCompressed(imagePathToCompress: File(image.path));
          final sizeinKb=compressedImage.lengthSync()/1024;
          print("Image after compression is $sizeinKb");
          setState(() {
            networkAvailableImage = null;
            assetImage='';
            _isSharedPrefImage=false;//this condition only for first time when user comes after registered from login and we have google/facebook User Image url and when user choose gallery Image then this value false;
            _localStorageImage = File(compressedImage.path);
            if (_userLocation.isNotEmpty || currentLocationController.text.isNotEmpty) {
              _isSubmitButtonEnabled = true;
            }
          });
        }
        else{
          setState(() {
            networkAvailableImage = null;
            assetImage='';
            _isSharedPrefImage=false;//this condition only for first time when user comes after registered from login and we have google/facebook User Image url and when user choose gallery Image then this value false;
            _localStorageImage = File(image.path);
            if (_userLocation.isNotEmpty || currentLocationController.text.isNotEmpty) {
              _isSubmitButtonEnabled = true;
            }
          });
        }
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

      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      currentLocationController.clear();
      checkSelectedLanguage();
      getUserProfile();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isAppBarVisible
          ? AppBarView(
          titleText: profileAppbarTitle, isAppBackBtnVisible: false)
          : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  assetImage.isNotEmpty?
                  InkWell(
                    onTap: (){
                      showDialog(
                        context: context,
//                                  barrierDismissible:true,
                        builder: (BuildContext context) =>
                            ZoomableDialog(
                                assetImage:assetImage,
                                networkImage: ''),
                      );
                    },
                    child: CircleAvatar(
                        radius: MediaQuery
                            .of(context)
                            .size
                            .width * 0.20,
                        backgroundImage: AssetImage(assetImage)
                    ),
                  ):
                  networkAvailableImage != null ?
                    (  _isSharedPrefImage? //Case when user first registered and come to Profile Screen, pref value contains Google/Facebook url,in this case _sharedprefImage true
                      CircleAvatar(
                        radius: MediaQuery
                            .of(context)
                            .size
                            .width * 0.20,
                        backgroundImage: NetworkImage(networkAvailableImage!),
                      ):
                  InkWell(
                    onTap: ()
                    {
                      showDialog(
                        context: context,
//                                  barrierDismissible:true,
                        builder: (BuildContext context) =>
                            ZoomableDialog(
                              assetImage:'',
                                networkImage:networkAvailableImage!),
                      );
                    },
                    child: CircleAvatar(
                      radius: MediaQuery
                          .of(context)
                          .size
                          .width * 0.20,
                      backgroundImage: CacheImageProvider(tag: networkAvailableImage!, img: base64Decode(networkAvailableImage!)),
                      //MemoryImage(base64Decode(networkAvailableImage!)),
                    ),
                  )
                    )
                      :
                  ( _localStorageImage != null ?
                  CircleAvatar(
                      radius: MediaQuery
                          .of(context)
                          .size
                          .width * 0.20,
                      backgroundImage: FileImage(_localStorageImage!)
                  )
                      : CircleAvatar(
                    radius: MediaQuery
                        .of(context)
                        .size
                        .width * 0.20,
                    child: SizedBox.fromSize(
                      size: Size.fromRadius(MediaQuery
                          .of(context)
                          .size
                          .width * 0.15),
                      child: const FittedBox(
                        child: Icon(Icons.person),
                      ),
                    ),
                  )
                  ),
                  TextButtonView(
                      text: upload_photo,
                      voidCallback: () async {
                        bool value=await checkInternetFromWithinWidgets();
                        if(value)
                          {
                            showAlertDialog(context);
                          }

                      }
                  ),
                  // TextButtonView(text: Strings.upload_avatar,
                  //     voidCallback: () {
                  //       Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>AvatarImageScreen())).then((value)
                  //       async {
                  //         if(value!=null)
                  //           {
                  //             setState(() {
                  //               networkAvailableImage=null;
                  //               _localStorageImage=null;
                  //               assetImage=value;
                  //               _isSubmitButtonEnabled=true;
                  //             });
                  //           }
                  //       });
                  //     }
                  // ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(first_name),
                        addVerticalSpace(8.0),
                        TextFieldView(
                          controller: firstNameController,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return errorTextFirstName;
                            }
                          }, boolValue: false,
                          maxLinesValue: 1,
                          isSuffixIcon: false,
                          isPrefixText: false, hintText: '',
                        ),
                        addVerticalSpace(8.0),
                        Text(last_name),
                        addVerticalSpace(8.0),
                        TextFieldView(
                          controller: lastNameController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return errorTextLastName;
                            }
                          },
                          keyboardType: TextInputType.name,
                          boolValue: false,
                          maxLinesValue: 1,
                          isPrefixText: false,
                          isSuffixIcon: false, hintText: '',
                        ),
                        addVerticalSpace(8.0),
                        Visibility(
                          visible: _isEmailTextFieldVisible,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(email),
                              addVerticalSpace(8.0),
                              TextFieldView(
                                controller: emailController,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return errorEmail;
                                  }
                                },
                                keyboardType: TextInputType.emailAddress,
                                boolValue: true,
                                maxLinesValue: 1,
                                isPrefixText: false,
                                isSuffixIcon: false, hintText: '',
                              ),
                              addVerticalSpace(8.0),
                            ],
                          ),
                        ),
                        Text(current_location),
                        addVerticalSpace(8.0),
                        TextFieldView(
                            controller: currentLocationController,
                            validator:  (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter location';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            boolValue: false,
                            maxLinesValue: 1,
                            isPrefixText: false,
                            isSuffixIcon: true, hintText: '',
                        ),
                        addVerticalSpace(8.0),
                        SizedBox(
                            width: double.infinity,
                            child: ButtonView(
                              text: widget.isAppBarVisible == true ? submit_button : update_button,
                              clickButton: () async
                              {
                                bool value=await checkInternetFromWithinWidgets();
                                if(value)
                                  {
                                   validateForm();
                                  }
                              },
                              isButtonEnabled: _isSubmitButtonEnabled,
                            )
                          // ElevatedButton(
                          //     onPressed: () {
                          //       Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //               builder: (BuildContext) => MainScreen()));
                          //     },
                          //     child: Text(widget.isAppBarVisible == true
                          //         ? Strings.submit_button.toUpperCase()
                          //         : Strings.update_button.toUpperCase())),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Visibility(
              child: const CircularProgressScreen(),
          visible: _isProgressBar,),
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


  void validateForm()
  {
    final FormState? form = _formKey.currentState;
    if (form?.validate() ?? true)
      {
        getCallPostProfile();
      }

  }

  void getCallPostProfile() async
  {
    try{
      print("inside the getCallPostProfile\n the avatar image is $assetImage");
      setState(() {
        _isProgressBar=true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(Strings.google_token);

      String url =
          Constant.baseurl + HttpParams.API_UPDATE_USER_PROFILE;

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['first_name'] = firstNameController.text;
      request.fields['last_name'] = lastNameController.text;
      request.fields['email']=emailController.text;
      request.fields['location_locality'] = currentLocationController.text;
      request.fields['longitude']=longitudeValue;
      request.fields['latitude']=latitudeValue;
      request.fields['country']=countryName;
      request.fields['state']=stateName;
      request.fields['city']=cityName;
      request.fields['pincode']=pincodeValue;
      request.fields['image_avatar_path']=assetImage;
      if(networkAvailableImage!=null)
      {
        request.fields['img_counter']='0';
        request.fields['image_path']=networkAvailableImage!;
      }
      else if(assetImage.isNotEmpty)
      {
        request.fields['img_counter']='0';
      }
      else
      {
        request.fields['img_counter']='1';
        request.files.add(await http.MultipartFile.fromPath('image_path', _localStorageImage!.path));
      }

      if (kDebugMode) {
        print("the firstname is ${firstNameController.text}\n The countryName is $countryName \n The stateName is $stateName \n the cityName is $cityName \n The pin is $pincodeValue \n the lastName is ${lastNameController.text}\n the email is ${emailController.text} \n the location_locality is ${currentLocationController.text}\n the latitude ${latitudeValue} \n the longitude is ${longitudeValue} \n the assetImage is $assetImage");
      }

      var response = await request.send();

      if (kDebugMode) {
        print("the response is ${response.statusCode}");
      }

      var res = await http.Response.fromStream(response);
      final result = jsonDecode(res.body) as Map<String, dynamic>;

      if (kDebugMode)
      {
        print("the response updateProduct result is $result");
      }

      if (response.statusCode == 200|| response.statusCode==201)
      {
        if(result['status']==true)
        {
          getCallUserProfile(prefs);
          if (kDebugMode) {
            print("profile upload success");
          }
        }
        else if(result['status']=='unauthenticated')
        {
          if(!mounted)return;
          setState(() {
            _isProgressBar=false;
          });
          getCallSignout(authProvider, facebookLoginProvider);
        }
        else
        {
          if(!mounted)return;
          setState(() {
            _isProgressBar=false;
          });
        }
      }
      else {
        print("profile upload not success");
        if(!mounted)return;
        setState(() {
          _isProgressBar=false;
        });
      }
    }on FormatException {
      if(!mounted)return;
      setState(() {
        _isProgressBar=false;
      });
      Fluttertoast.showToast(msg: emailAlreadyUsed,toastLength: Toast.LENGTH_LONG);
    }
    catch(e)
    {
     if(kDebugMode)
       {
         print("The exception in getCallPostProfile is $e");
       }
      if(!mounted)return;
      setState(() {
        _isProgressBar=false;
      });
    }
  }
  showAlertDialog(BuildContext context)
  {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(
          child: Text(profileDialogTitle)),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: (){
              getGalleryImage();
              Navigator.of(context).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo,
                  color: ConstantColors.primaryDarkColor,
                  size: 32.0,
                ),
                Text(gallery)
              ],
            ),
          ),
          InkWell(
            onTap: (){
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>AvatarImageScreen())).then((value)
              async {
                if(value!=null)
                {
                  setState(() {
                    networkAvailableImage=null;
                    _localStorageImage=null;
                    assetImage=value;
                    _isSubmitButtonEnabled=true;
                    if(kDebugMode)
                      {
                        print("The value get from avatar is $assetImage");
                      }
                  });
                }
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person,
                  color: ConstantColors.primaryDarkColor,
                  size: 32.0,),
                Text(dialogAvatarTextTitle)
              ],
            ),
          )
        ],
      )
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void getCallUserProfile(SharedPreferences prefs) async
  {
    print("inside the getCallUserProfile");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString(Strings.google_token);
    API.getUserProfile(token).then((response)
    {
      if(kDebugMode)
      {
        print("The profile model is ${response.body}\n the status code is ${response.statusCode}");
      }
      int statusCode=response.statusCode;

      if(statusCode==200|| statusCode==201)
        {
          final body = json.decode(response.body);
          if(body['status']==true)
            {
              ProfileModel model=ProfileModel.fromJson(json.decode(response.body));

              if(_isEmailTextFieldVisible)
                {
                  homeProvider.updateFirestore(FirestoreConstants.pathUserCollection, currentUserId,
                      {FirestoreConstants.email:emailController.text}).catchError((error) => print('Email to Firebase error: $error'));
                }


              if(model.user.image_avatar_path.isNotEmpty)
              {
                homeProvider.updateFirestore(FirestoreConstants.pathUserCollection, currentUserId,
                    {FirestoreConstants.imageBlob:''}).whenComplete((){
                  homeProvider.updateFirestore(
                      FirestoreConstants.pathUserCollection,
                      currentUserId,
                      {FirestoreConstants.assetImage:model.user.image_avatar_path}).whenComplete(  //empty imageBlob from Firebase
                          ()
                      {
                        prefs.setString(Strings.location, currentLocationController.text);
                        setState(()
                        {
                          _isProgressBar=false;
                        });
                        if(widget.isAppBarVisible)
                        {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext buildContext) =>const MainScreen()));
                        }
                        else
                        {
                          Fluttertoast.showToast(msg: profileUpdateMessage);
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const MainScreen()),
                                  (Route<dynamic>route) => false);
                        }
                      })
                      .catchError((error) => print('Failed: $error'));
                }).catchError((error)=>print("Failed update is :$error"));
              }
              else if(model.user.image_blob.isNotEmpty)
              {
                homeProvider.updateFirestore(FirestoreConstants.pathUserCollection, currentUserId, //empty assetImage from Firebase
                    {FirestoreConstants.assetImage:''}).whenComplete(() {
                  homeProvider.updateFirestore(
                      FirestoreConstants.pathUserCollection,
                      currentUserId,
                      {FirestoreConstants.imageBlob:model.user.image_blob}).whenComplete((){
                    prefs.setString(Strings.location, currentLocationController.text);
                    setState(() {
                      _isProgressBar=false;
                    });
                    if(widget.isAppBarVisible)
                    {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext buildContext) =>const MainScreen()));
                    }
                    else
                    {
                      Fluttertoast.showToast(msg: profileUpdateMessage);
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const MainScreen()),
                              (Route<dynamic>route) => false);
                    }
                  })
                      .catchError((error) => print('Failed updateFirebase: $error'));
                }).catchError((error) => print('Failed: $error'));

              }
            }
          else if(body['status']=='unauthenticated')
              {
                getCallSignout(authProvider, facebookLoginProvider);
              }

        }
      else{

      }
    });
  }

}
