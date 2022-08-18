import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/utilities/CacheImageProvider.dart';
import 'package:translator/translator.dart';
class NotificationView extends StatefulWidget
{
  String message,title;
  String productImage,userImage,userName;
  NotificationView({Key? key,required this.productImage,
    required this.userImage,
    required this.userName,required this.title,required this.message}) : super(key: key);

@override
  NotificationViewState createState()=>NotificationViewState();

}
class NotificationViewState extends State<NotificationView>
{
  final translator = GoogleTranslator();
  @override
  void initState() {
    checkSelectedLanguage();
    super.initState();
  }

  void checkSelectedLanguage() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale!='en')
          {
            await translator.translate(widget.userName,to:locale).then((value)
            {
              print("The value after translate in productName of GridView is $value");
              if(!mounted)return;
              setState(() {
                widget.userName=value.toString();
              });
            });
            await translator.translate(widget.title,to:locale).then((value)
            {
              print("The value after translate in productName of GridView is $value");
              if(!mounted)return;
              setState(() {
                widget.title=value.toString();
              });
            });
            await translator.translate(widget.message,to:locale).then((value)
            {
              print("The value after translate in productName of GridView is $value");
              if(!mounted)return;
              setState(() {
                widget.message=value.toString();
              });
            });
          }
      }
  }
  @override
  Widget build(BuildContext context)
  {
    final Uint8List imageByte=base64.decode(widget.productImage); //the bytes of image to cache
    //final productOwnerUrlByte=base64.decode(widget.userName);
    return Column(
      children: [
        ListTile(
            leading: Image(image: CacheImageProvider(tag: widget.productImage,img: imageByte)),
            // FadeInImage.assetNetwork(
            //     placeholder:
            //     'assets/images/placeholder_icon.png',
            //     image: CacheImageProvider(tag: productImage, img: imageByte),
            // ),
            title: Text(widget.userName+" "+widget.title,
              // textAlign: TextAlign.justify,
              style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500
              ),
            ),
            subtitle:  Text(
              widget.message,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
            //       Column(
            //         children: [
            //           Text(message,
            //           textAlign: TextAlign.justify,
            // style: const TextStyle(
            // fontSize: 16.0,
            // ),
            // ),
            //           addVerticalSpace(4.0),
            //           Row(
            //             children:  <Widget>[
            //               CircleAvatar(
            //                   radius: 10,
            //                   backgroundImage: NetworkImage(userImage)
            //               ),
            //               const SizedBox(width: 5,),
            //               Text(userName),
            //             ],
            //           ),
            //         ],
            //       ),
            trailing:  const SizedBox(
                height: double.infinity,
                child: Icon(Icons.arrow_forward_ios_sharp,color: Colors.black38,))
        ),
        const Divider(
          thickness: 2.0,
        )
      ],
    );
  }
}
