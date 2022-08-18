import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allMethods/Methods.dart';
import 'package:tradz/app_screens/product_details_screen.dart';
import 'package:tradz/dialogs/product_report_dialog.dart';
import 'package:tradz/dialogs/userMessage_dialog.dart';
import 'package:tradz/utilities/CacheImageProvider.dart';
import 'package:translator/translator.dart';

import 'helper_widget.dart';
// class GridViewWidget extends StatelessWidget
// {
//   final translator = GoogleTranslator();
//   final bool isItemLiked,
//       isOwnerItem,
//       isDeleteButtonEnabled; //isDeleteButtonEnabled is true only for MyProductScreen where delete item button enabled to delete the Product.
//   final int like_count;
//   final int distance;
//   final String distanceUnit;
//   final String locale;
//   final bool
//   isMarketPlaceView; //it is false in case of my items screen to hide message and like item icon.
//   final bool isMessageIconVisible; //it is false in case of likedItem screen
//   String productImageUrl, lookingFor;
//   final String assetImage;
//   String productName, productOwnerName;
//   final String productOwnerUrl;
//   final VoidCallback messageCallBack, likedCallBack, reportCallBack;
//   GridViewWidget(
//       {Key? key,
//         required this.productImageUrl,
//         required this.productName,
//         required this.productOwnerName,
//         required this.messageCallBack,
//         required this.locale,
//         required this.lookingFor,
//         required this.likedCallBack,
//         required this.isItemLiked,
//         required this.distance,
//         required this.distanceUnit,
//         required this.isMarketPlaceView,
//         required this.assetImage,
//         required this.productOwnerUrl,
//         required this.like_count,
//         required this.isMessageIconVisible,
//         required this.reportCallBack,
//         required this.isOwnerItem,
//         required this.isDeleteButtonEnabled})
//   {
//     if(locale.isNotEmpty)
//       {
//         getUrl= translator.translate(productName,to:locale).then((value){
//           return productName=value.toString();
//         });
//
//         getUrl= translator.translate(productOwnerName,to:locale).then((value){
//           return productOwnerName=value.toString();
//         });
//       }
//     else{
//       getUrl=Future.delayed(const Duration(seconds: 0)).then((value){
//         return productOwnerName;
//       });
//     }
//
//   }
//   late Future<String> getUrl;
//
//   @override
//   Widget build(BuildContext context) {
//     print("the itemLiked is ${isItemLiked}");
//     print("the locale is $locale");
//     final Uint8List imageByte=base64.decode(productImageUrl); //the bytes of image to cache
//     final productOwnerUrlByte=base64.decode(productOwnerUrl);
//     return FutureBuilder<String>(
//         future: getUrl,
//         builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//           if(!snapshot.hasData) return Text('getting profile url');
//           return  Card(
//             elevation: 8.0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   Container(
//                     decoration: BoxDecoration(
//                       image: productImageUrl.isNotEmpty
//                           ? DecorationImage(
//                         //colorFilter: ColorFilter.mode(Colors.grey.withOpacity(1.0), BlendMode.color),
//                           image:
//                           CacheImageProvider(tag: productImageUrl, img: imageByte),
//                           //MemoryImage(base64.decode(productImageUrl)),
//                           fit: BoxFit.cover)
//                           : const DecorationImage(
//                         //colorFilter: ColorFilter.mode(Colors.grey.withOpacity(1.0), BlendMode.color),
//                           image: AssetImage('assets/images/error_image.jpeg'),
//                           fit: BoxFit.contain),
//                     ),
//                     height: MediaQuery.of(context).size.height * 0.20,
//                     width: MediaQuery.of(context).size.width.toDouble(),
//                     child: Visibility(
//                       visible: isMarketPlaceView,
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 4.0, right: 4.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Visibility(
//                               visible: isMessageIconVisible,
//                               child: Container(
//                                 height: 24.0,
//                                 width: 24.0,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(5.0),
//                                   color: Colors.black26,
//                                 ),
//                                 child: IconButton(
//                                   padding: const EdgeInsets.all(0.0),
//                                   icon: const Icon(
//                                     Icons.message,
//                                     size: 18.0,
//                                     color: Colors.white,
//                                   ),
//                                   onPressed: messageCallBack,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 4.0,
//                             ),
//                             Container(
//                               height: 24.0,
//                               width: 24.0,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(5.0),
//                                 color: Colors.black26,
//                               ),
//                               child: isOwnerItem
//                                   ? IconButton(
//                                 padding: const EdgeInsets.all(0.0),
//                                 icon: const Icon(
//                                   Icons.favorite,
//                                   size: 18.0,
//                                   color: Colors.grey,
//                                 ),
//                                 onPressed: likedCallBack,
//                               )
//                                   : IconButton(
//                                 padding: const EdgeInsets.all(0.0),
//                                 icon: isItemLiked
//                                     ? const Icon(
//                                   Icons.favorite,
//                                   size: 18.0,
//                                   color: Colors.redAccent,
//                                 )
//                                     : const Icon(
//                                   Icons.favorite_border,
//                                   size: 18.0,
//                                   color: Colors.redAccent,
//                                 ),
//                                 onPressed: likedCallBack,
//                               ),
//                             ),
//                             addHorizontalSpace(4.0),
//                             Text(
//                               like_count.toString(),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontFamily: 'Libre Franklin',
//                                 fontSize: 18.0,
//                                 shadows: <Shadow>[
//                                   Shadow(
//                                     blurRadius: 5.0,
//                                     color: Colors.black,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
//                     child: Column(
//                       //mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             Expanded(
//                               child: Text(
//                                 productName,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18.0),
//                               ),
//                             ),
//                             Visibility(
//                               visible: isMarketPlaceView,
//                               child: SizedBox(
//                                 height: 24.0,
//                                 width: 24.0,
//                                 child: IconButton(
//                                   padding: const EdgeInsets.all(0.0),
//                                   icon:isDeleteButtonEnabled
//                                       ? Icon(
//                                     Icons.delete_rounded,
//                                     color: Colors.red,
//                                   )
//                                       : Icon(
//                                     Icons.report,
//                                     color: Colors.red,
//                                   ),
//                                   onPressed: reportCallBack,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         //addVerticalSpace(4.0),
//                         Column(
//                           children: [
//                             Row(
//                               children: <Widget>[
//                                 assetImage.isNotEmpty
//                                     ? CircleAvatar(
//                                     radius: 10,
//                                     backgroundImage: AssetImage(
//                                         assetImage
//                                     )
//                                 )
//                                     : CircleAvatar(
//                                   radius: 10,
//                                   backgroundImage:  CacheImageProvider(tag: productOwnerUrl, img: productOwnerUrlByte),
//                                   // MemoryImage(
//                                   //   base64Decode(productOwnerUrl),
//                                   // )
//                                   //NetworkImage(productOwnerUrl)
//                                 ),
//                                 addHorizontalSpace(4.0),
//                                 Expanded(
//                                     child: Text(
//                                       productOwnerName,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     )),
//                                 Visibility(
//                                   visible: distanceUnit.isNotEmpty,
//                                   child: Align(
//                                     alignment: Alignment.centerRight,
//                                     child: Text(
//                                       distance.toString() +
//                                           "" +
//                                           distanceUnit +" "+ 'away',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                             Visibility(
//                               visible: lookingFor.isNotEmpty ? true : false,
//                               child:
//                               Column // this column required so that  addVerticalSpace(4.0) enable only when lookingFor is not empty
//                                 (
//                                 children: [
//                                   addVerticalSpace(4.0),
//                                   Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: <Widget>[
//                                       Text(
//                                         'LookingForText',
//                                         style: const TextStyle(
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Text(
//                                           " ${lookingFor}",
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: const TextStyle(
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
// }
class GridViewWidget extends StatefulWidget {
  final bool isItemLiked,
      isOwnerItem,
      isDeleteButtonEnabled; //isDeleteButtonEnabled is true only for MyProductScreen where delete item button enabled to delete the Product.
  final int like_count;
  final int distance;
  final String distanceUnit;
  final bool
      isMarketPlaceView; //it is false in case of my items screen to hide message and like item icon.
  final bool isMessageIconVisible; //it is false in case of likedItem screen
   String productImageUrl, lookingFor;
  final String assetImage;
   String productName, productOwnerName;
  final String productOwnerUrl;
  final VoidCallback messageCallBack, likedCallBack, reportCallBack;

   GridViewWidget(
      {Key? key,
      required this.productImageUrl,
      required this.productName,
      required this.productOwnerName,
      required this.messageCallBack,
      required this.lookingFor,
      required this.likedCallBack,
      required this.isItemLiked,
        required this.distance,
        required this.distanceUnit,
      required this.isMarketPlaceView,
      required this.assetImage,
      required this.productOwnerUrl,
      required this.like_count,
      required this.isMessageIconVisible,
      required this.reportCallBack,
      required this.isOwnerItem,
      required this.isDeleteButtonEnabled})
      : super(key: key);

  @override
  GridViewWidgetState createState()=>GridViewWidgetState();
}

class GridViewWidgetState extends State<GridViewWidget>
{
  final translator = GoogleTranslator();
  String away="";
  String LookingForText='';

  @override
  void initState()
  {
    checkSelectedLanguage();
    print("INITSTATE OF GRIDVIEW CALLED");
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
            }
        else if (locale == 'ta') {
          if (!mounted) return;
          setState(() {
            away = Strings.away_ta;
            LookingForText = Strings.LookingFor_ta;
          });
        }
        else if (locale == 'mr') {
          if (!mounted) return;
          setState(() {
            away = Strings.away_mr;
            LookingForText = Strings.LookingFor_mr;
          });
        }

        else if (locale == 'gu') {
          if (!mounted) return;
          setState(() {
            away = Strings.away_gu;
            LookingForText = Strings.LookingFor_gu;
          });
        }
        else if (locale == 'kn') {
          if (!mounted) return;
          setState(() {
            away = Strings.away_kn;
            LookingForText = Strings.LookingFor_kn;
          });
        }
        else if (locale == 'ur') {
          if (!mounted) return;
          setState(() {
            away = Strings.away_ur;
            LookingForText = Strings.LookingFor_ur;
          });
        }
        else if (locale == 'or') {
          if (!mounted) return;
          setState(() {
            away = Strings.away_or;
            LookingForText = Strings.LookingFor_or;
          });
        }
        else if (locale == 'te') {
          if (!mounted) return;
          setState(() {
            away = Strings.away_te;
            LookingForText = Strings.LookingFor_te;
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
    print("the itemLiked is ${widget.isItemLiked}");
    final Uint8List imageByte=base64.decode(widget.productImageUrl); //the bytes of image to cache
    final productOwnerUrlByte=base64.decode(widget.productOwnerUrl);
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: widget.productImageUrl.isNotEmpty
                    ? DecorationImage(
                  //colorFilter: ColorFilter.mode(Colors.grey.withOpacity(1.0), BlendMode.color),
                    image:
                    CacheImageProvider(tag: widget.productImageUrl, img: imageByte),
                    //MemoryImage(base64.decode(productImageUrl)),
                    fit: BoxFit.cover)
                    : const DecorationImage(
                  //colorFilter: ColorFilter.mode(Colors.grey.withOpacity(1.0), BlendMode.color),
                    image: AssetImage('assets/images/error_image.jpeg'),
                    fit: BoxFit.contain),
              ),
              height: MediaQuery.of(context).size.height * 0.20,
              width: MediaQuery.of(context).size.width.toDouble(),
              child: Visibility(
                visible: widget.isMarketPlaceView,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, right: 4.0),
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
                            ? IconButton(
                          padding: const EdgeInsets.all(0.0),
                          icon: const Icon(
                            Icons.favorite,
                            size: 18.0,
                            color: Colors.grey,
                          ),
                          onPressed: widget.likedCallBack,
                        )
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
                        widget.like_count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                        ),
                        Visibility(
                          visible: widget.isMarketPlaceView,
                          child: SizedBox(
                            height: 24.0,
                            width: 24.0,
                            child: IconButton(
                              padding: const EdgeInsets.all(0.0),
                              icon: widget.isDeleteButtonEnabled
                                  ? Icon(
                                Icons.delete_rounded,
                                color: Colors.red,
                              )
                                  : Icon(
                                Icons.report,
                                color: Colors.red,
                              ),
                              onPressed: widget.reportCallBack,
                            ),
                          ),
                        ),
                      ],
                    ),
                    //addVerticalSpace(4.0),
                    Column(
                      children: [
                        Row(
                          children: <Widget>[
                            widget.assetImage.isNotEmpty
                                ? CircleAvatar(
                                radius: 10,
                                backgroundImage: AssetImage(
                                    widget.assetImage
                                )
                            )
                                : CircleAvatar(
                              radius: 10,
                              backgroundImage:  CacheImageProvider(tag: widget.productOwnerUrl, img: productOwnerUrlByte),
                              // MemoryImage(
                              //   base64Decode(productOwnerUrl),
                              // )
                              //NetworkImage(productOwnerUrl)
                            ),
                            addHorizontalSpace(4.0),
                            Expanded(
                                child: Text(
                                  widget.productOwnerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            Visibility(
                              visible: widget.distanceUnit.isNotEmpty,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  widget.distance.toString() +
                                      "" +
                                      widget.distanceUnit +" "+ away,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ),
                        Visibility(
                          visible: widget.lookingFor.isNotEmpty ? true : false,
                          child:
                          Column // this column required so that  addVerticalSpace(4.0) enable only when lookingFor is not empty
                            (
                            children: [
                              addVerticalSpace(4.0),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    LookingForText,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      " ${widget.lookingFor}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
