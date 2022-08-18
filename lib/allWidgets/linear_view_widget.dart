import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/app_screens/product_details_screen.dart';
import 'package:tradz/dialogs/userMessage_dialog.dart';
import 'package:tradz/utilities/CacheImageProvider.dart';
import 'package:translator/translator.dart';

class LinearViewWidget extends StatefulWidget {
  final bool isItemLiked,isOwnerItem,isDeleteButtonEnabled;//isDeleteButtonEnabled is true only for MyProductScreen where delete item button enabled to delete the Product.
  final int likes_count;
  final String assetImage;
  final int distance;
  final String distanceUnit;
  final bool isMarketPlaceView;
  final bool isMessageIconVisible;
  String productImageUrl,lookingFor;
  final String productOwnerUrl;
  String productName, productOwnerName, productDetails;
  final VoidCallback messageCallBack, likedCallBack, reportCallBack;

   LinearViewWidget(
      {Key? key,
      required this.isItemLiked,
      required this.productImageUrl,
      required this.productName,
        required this.distance,
        required this.distanceUnit,
      required this.productOwnerName,
        required this.lookingFor,
      required this.messageCallBack,
      required this.likedCallBack,
      required this.productDetails,
      required this.productOwnerUrl,
      required this.isMarketPlaceView,
      required this.likes_count,
        required this.assetImage,
      required this.isMessageIconVisible,
      required this.reportCallBack,
      required this.isOwnerItem,
        required this.isDeleteButtonEnabled})
      : super(key: key);

 @override
  LinearWidgetState createState()=>LinearWidgetState();
}
class LinearWidgetState extends State<LinearViewWidget>
{
  final translator = GoogleTranslator();
  String away="";
  String LookingForText='';

  @override
  void initState() {
    checkSelectedLanguage();
    getTranslation();
    super.initState();
  }
  void checkSelectedLanguage()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
    {
      if(locale=='hi')
      {
        if(!mounted)return;
        setState(() {
          away=Strings.away_hi;
          LookingForText=Strings.LookingFor_hi;
        });
      }else if(locale=='bn')
      {
        if(!mounted)return;
        setState(() {
          away=Strings.away_bn;
          LookingForText=Strings.LookingFor_bn;
        });
      }else if(locale=='te')
      {
        if(!mounted)return;
        setState(() {
          away=Strings.away_te;
          LookingForText=Strings.LookingFor_te;
        });
      }else{
        if(!mounted)return;
        setState(() {
          away=Strings.away;
          LookingForText=Strings.LookingFor;
        });
      }
    }else{
      if(!mounted)return;
      setState(() {
        away=Strings.away;
        LookingForText=Strings.LookingFor;
      });
    }
  }
  void getTranslation()async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    try{
      if(locale!=null)
      {
        if(locale!="en")
        {
          // await translator.translate(away,to:locale).then((value)
          // {
          //   print("The value after translate in productName of GridView is $value");
          //   if(!mounted)return;
          //   setState(() {
          //     away=value.toString();
          //   });
          // });
          await translator.translate(widget.productName,to:locale).then((value)
          {
            print("The value after translate in productName of GridView is $value");
            if(!mounted)return;
            setState(() {
              widget.productName=value.toString();
            });
          });
          await translator.translate(widget.productOwnerName,to:locale).then((value)
          {
            print("The value after translate in productName of GridView is $value");
            if(!mounted)return;
            setState(() {
              widget.productOwnerName=value.toString();
            });
          });
          await translator.translate(widget.productDetails,to:locale).then((value)
          {
            print("The value after translate in productName of GridView is $value");
            if(!mounted)return;
            setState(() {
              widget.productDetails=value.toString();
            });
          });
          // await translator.translate(LookingForText,to:locale).then((value)
          // {
          //   print("The value after translate in productName of GridView is $value");
          //   if(!mounted)return;
          //   setState(() {
          //     LookingForText=value.toString();
          //   });
          // });
          await translator.translate(widget.lookingFor,to:locale).then((value)
          {
            print("The value after translate in productName of GridView is $value");
            if(!mounted)return;
            setState(() {
              widget.lookingFor=value.toString();
            });
          });
        }
      }
    }
    catch(e)
    {
      if(kDebugMode)
      {
        print("The exception in GridView translation is $e");
      }
    }
    // return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List imageByte=base64.decode(widget.productImageUrl); //the bytes of image to cache
    final productOwnerUrlByte=base64.decode(widget.productOwnerUrl);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.only(
              top: 8.0, right: 8.0, bottom: 8.0, left: 8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: widget.productImageUrl.isNotEmpty
                        ? BoxDecoration(
                        image: DecorationImage(
                          image:  CacheImageProvider(tag: widget.productImageUrl, img: imageByte),
                          //MemoryImage(base64Decode(productImageUrl)),
                          fit: BoxFit.cover,
                        ))
                        : const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/error_image.jpeg'))),
                    width: MediaQuery.of(context).size.width.toDouble(),
                    height: MediaQuery.of(context).size.height.toDouble(),
                    child: Visibility(
                      visible: widget.isMarketPlaceView,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Visibility(
                              visible: widget.isMessageIconVisible,
                              child: Container(
                                height: 24.0,
                                width: 24.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.black26,
                                ),
                                child: IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  icon: const Icon(
                                    Icons.message,
                                    size: 18.0,
                                    color: Colors.white,
                                  ),
                                  onPressed: widget.messageCallBack,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            Container(
                              height: 24.0,
                              width: 24.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.black26,
                              ),
                              child: widget.isOwnerItem
                                  ? //check if User own Product, if true then Heart icon with white radius
                              IconButton(
                                padding: const EdgeInsets.all(0.0),
                                onPressed: widget.likedCallBack,
                                icon: const Icon(
                                  Icons.favorite,
                                  size: 18.0,
                                  color: Colors.grey,
                                ),)
                                  : IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: widget.isItemLiked
                                    ? const Icon(
                                  Icons.favorite,
                                  size: 18.0,
                                  color: Colors.redAccent,
                                )
                                    : const Icon(
                                  Icons.favorite_border,
                                  size: 18.0,
                                  color: Colors.redAccent,
                                ),
                                onPressed: widget.likedCallBack,
                              ),
                            ),
                            addHorizontalSpace(4.0),
                            Text(
                              widget.likes_count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Libre Franklin',
                                fontSize: 18.0,
                                shadows: <Shadow>[
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 0.0, bottom: 0.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                widget.productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                widget.productDetails,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              //mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    widget.assetImage.isNotEmpty?
                                    CircleAvatar(
                                        radius: 10,
                                        backgroundImage: AssetImage(widget.assetImage
                                        )
                                    )
                                        :CircleAvatar(
                                      radius: 10,
                                      backgroundImage:
                                      CacheImageProvider(tag: widget.productOwnerUrl,img: productOwnerUrlByte),
                                      // MemoryImage(base64Decode(productOwnerUrl))
                                    ),
                                    addHorizontalSpace(4.0),
                                    Text(widget.productOwnerName,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,),
                                  ],
                                ),
                                Visibility(
                                  visible: widget.isMarketPlaceView,
                                  child: SizedBox(
                                    height: 24.0,
                                    width: 24.0,
                                    child: IconButton(
                                      padding: const EdgeInsets.all(0.0),
                                      icon: widget.isDeleteButtonEnabled?
                                      Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,)
                                          :Icon(
                                        Icons.report,
                                        color: Colors.red,
                                      ),
                                      onPressed: widget.reportCallBack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: widget.lookingFor.isNotEmpty?true:false,
                              child: Column(
                                children: [
                                  addVerticalSpace(4.0),
                                  // RichText(text: TextSpan(
                                  //   children: [
                                  //     TextSpan(
                                  //       text: Strings.lookingFor,style: const TextStyle(
                                  //       color: Colors.grey,
                                  //     ),
                                  //     ),
                                  //     TextSpan(
                                  //       text: lookingFor,
                                  //       style: const TextStyle(
                                  //         color: Colors.black,
                                  //       ),
                                  //     )
                                  //   ]
                                  // ),
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>
                                    [
                                      Text(LookingForText,style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' ${widget.lookingFor}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: widget.distanceUnit.isNotEmpty,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            widget.distance.toString() +
                                                "" +
                                                widget.distanceUnit +" "+
                                                away,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        )

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
