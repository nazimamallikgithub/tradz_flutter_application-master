import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/button_view.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/allWidgets/textfield_view.dart';
import 'package:tradz/app_screens/update_image_screen.dart';
import 'package:tradz/app_screens/upload_image_screen.dart';
import 'package:translator/translator.dart';
class AddProductDetails extends StatefulWidget {
  final int categoryId,subcategoryId;
  final String categoryText,subcategoryText,lookingFor;
  final int productID,productPrice;
  final String  productdetails,productTitle;
  final List<String> ImageUrl;
  const AddProductDetails(
      {Key? key,
        required this.categoryId,
        required this.categoryText,
        required this.lookingFor,
        required this.subcategoryId,
        required this.subcategoryText,
        required this.productPrice,
        required this.productID,
        required this.ImageUrl,
        required this.productdetails,
        required this.productTitle,
      }) : super(key: key);

  @override
  State<AddProductDetails> createState() => _AddProductDetailsState();
}

class _AddProductDetailsState extends State<AddProductDetails> {
  final translator = GoogleTranslator();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController lookingForController;
  late TextEditingController titleController;
  late String appBarTitle=''; String title='';
  String description='';
      String LookingFor='';String estValue='';String nextButton='';String itemLookingForHint='';
      String errorTitleMsg='';
      String errorDescriptionMsg='';String errorLookingForMsg='';
      String errorPriceMsg='';
  bool _isInternet = false;
  String noInternetMessage='';
  @override
  void initState() {
    checkSelectedLanguage();
    print("the widget is ${widget.ImageUrl}");
    if(widget.ImageUrl.isNotEmpty)
      {
        descriptionController=TextEditingController(text: widget.productdetails);
        titleController=TextEditingController(text: widget.productTitle);
        priceController=TextEditingController(text:widget.productPrice.toString());
        lookingForController=TextEditingController(text:widget.lookingFor);
      }
    else
    {
      descriptionController=TextEditingController();
      titleController=TextEditingController();
      priceController=TextEditingController();
      lookingForController=TextEditingController();
    }
    super.initState();
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
        //_isProgressBar = false;
        print("checkInternetFromWithinWidgets internet becomes exception " + _isInternet.toString());
      });
      return false;
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
              appBarTitle=Strings.itemDetails_hi;
              title=Strings.title_hi;
              description=Strings.description_hi;
              LookingFor=Strings.LookingFor_hi;
              estValue=Strings.estValue_hi;
              nextButton=Strings.nextButton_hi;
              itemLookingForHint=Strings.itemLookingForHint_hi;
              errorTitleMsg=Strings.errorTitleMsg_hi;
              errorDescriptionMsg=Strings.errorDescriptionMsg_hi;
              errorLookingForMsg=Strings.errorLookingForMsg_hi;
              errorPriceMsg=Strings.errorPriceMsg_hi;
              noInternetMessage=Strings.noInternetMessage_hi;
            });
          }else if(locale=='bn')
            {
              if(!mounted)return;
              setState(() {
                appBarTitle=Strings.itemDetails_bn;
                title=Strings.title_bn;
                description=Strings.description_bn;
                LookingFor=Strings.LookingFor_bn;
                estValue=Strings.estValue_bn;
                nextButton=Strings.nextButton_bn;
                itemLookingForHint=Strings.itemLookingForHint_bn;
                errorTitleMsg=Strings.errorTitleMsg_bn;
                errorDescriptionMsg=Strings.errorDescriptionMsg_bn;
                errorLookingForMsg=Strings.errorLookingForMsg_bn;
                errorPriceMsg=Strings.errorPriceMsg_bn;
                noInternetMessage=Strings.noInternetMessage_bn;
              });
            }else if(locale=='te')
              {
                if(!mounted)return;
                setState(() {
                  appBarTitle=Strings.itemDetails_te;
                  title=Strings.title_te;
                  description=Strings.description_te;
                  LookingFor=Strings.LookingFor_te;
                  estValue=Strings.estValue_te;
                  nextButton=Strings.nextButton_te;
                  itemLookingForHint=Strings.itemLookingForHint_te;
                  errorTitleMsg=Strings.errorTitleMsg_te;
                  errorDescriptionMsg=Strings.errorDescriptionMsg_te;
                  errorLookingForMsg=Strings.errorLookingForMsg_te;
                  errorPriceMsg=Strings.errorPriceMsg_te;
                  noInternetMessage=Strings.noInternetMessage_te;
                });
              }else{
          if(!mounted)return;
          setState(() {
            appBarTitle=Strings.itemDetails;
            title=Strings.title;
            description=Strings.description;
            LookingFor=Strings.LookingFor;
            estValue=Strings.estValue;
            nextButton=Strings.nextButton;
            itemLookingForHint=Strings.itemLookingForHint;
            errorTitleMsg=Strings.errorTitleMsg;
            errorDescriptionMsg=Strings.errorDescriptionMsg;
            errorLookingForMsg=Strings.errorLookingForMsg;
            errorPriceMsg=Strings.errorPriceMsg;
            noInternetMessage=Strings.noInternetMessage;
          });
        }
      }else{
      if(!mounted)return;
      setState(() {
        appBarTitle=Strings.itemDetails;
        title=Strings.title;
        description=Strings.description;
        LookingFor=Strings.LookingFor;
        estValue=Strings.estValue;
        nextButton=Strings.nextButton;
        itemLookingForHint=Strings.itemLookingForHint;
        errorTitleMsg=Strings.errorTitleMsg;
        errorDescriptionMsg=Strings.errorDescriptionMsg;
        errorLookingForMsg=Strings.errorLookingForMsg;
        errorPriceMsg=Strings.errorPriceMsg;
        noInternetMessage=Strings.noInternetMessage;
      });
    }
  }

  void validateForm() async {
    final FormState? form = _formKey.currentState;
    if (form?.validate() ?? true) {
      if(widget.ImageUrl.isNotEmpty)
        {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
              UpdateImageScreen(
                title:titleController.text,
                description:descriptionController.text,
                lookingFor: lookingForController.text,
                estimatePrice:priceController.text,
                categoryId:widget.categoryId.toString(),
                subcategoryId:widget.subcategoryId.toString(),
                productID: widget.productID,
                ImageUrl: widget.ImageUrl,
              )));
        }else{

        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
            UploadImageScreen(
              title:titleController.text,
              description:descriptionController.text,
              lookingFor: lookingForController.text,
              estimatePrice:priceController.text,
              categoryId:widget.categoryId.toString(),
              subcategoryId:widget.subcategoryId.toString(),
              productID: widget.productID
            )));
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarView(
            titleText: appBarTitle,
            isAppBackBtnVisible: true),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title),
                        addVerticalSpace(8.0),
                        TextFieldView(
                            controller: titleController,
                            validator: (value){
                          if(value?.isEmpty??true)
                            {
                              return errorTitleMsg;
                            }
                            },
                            keyboardType: TextInputType.text,
                            boolValue: true,
                            maxLinesValue: 1,
                            isPrefixText: false,
                            isSuffixIcon: false, hintText: '',),
                        addVerticalSpace(8.0),
                        Text(description),
                        addVerticalSpace(8.0),
                        TextFieldView(
                          controller: descriptionController,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return errorDescriptionMsg;
                            }
                          },
                          boolValue: true,
                          maxLinesValue: 6,
                          isPrefixText: false,
                          isSuffixIcon: false, hintText: '',
                        ),
                        addVerticalSpace(8.0),
                        Text(LookingFor),
                        addVerticalSpace(8.0),
                        TextFieldView(
                          controller: lookingForController,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return errorLookingForMsg;
                            }
                          },
                          boolValue: true,
                          maxLinesValue: 1,
                          isPrefixText: false,
                          isSuffixIcon: false,
                          hintText: itemLookingForHint,
                        ),
                        addVerticalSpace(8.0),
                        Text(estValue),
                        addVerticalSpace(8.0),
                        TextFieldView(
                          controller: priceController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return errorPriceMsg;
                            }
                          },
                          keyboardType: TextInputType.number,
                          boolValue: true,
                          maxLinesValue: 1,
                          isPrefixText: true,
                          isSuffixIcon: false, hintText: '',
                        ),
                        addVerticalSpace(8.0),
                        Center(
                          child: ButtonView(
                            text: nextButton,
                            clickButton: () async{
                             bool value=await checkInternetFromWithinWidgets();
                             if(value)
                               {
                                 validateForm();
                               }
                            },
                            isButtonEnabled: true,
                          ),
                        )
                      ],
                    ),
                  ))
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
}
