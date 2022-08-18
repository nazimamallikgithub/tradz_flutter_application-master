import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/src/provider.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allProvider/chat_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/model/post_create_chat_model.dart';
import 'package:tradz/model/successModel.dart';

class UserMessageDialog extends StatefulWidget {
  final String currentUserFirebaseID,productUserFirebaseID,token,productUserName,warningText,messageText,cancel,send,imageBlob;
  final int productID;
  const UserMessageDialog(this.currentUserFirebaseID,this.productUserFirebaseID,this.token,this.productUserName,this.productID,this.warningText,this.messageText,this.cancel,this.send,this.imageBlob,{Key? key}) : super(key: key);

  @override
  State<UserMessageDialog> createState() => _UserMessageDialogState();
}

class _UserMessageDialogState extends State<UserMessageDialog>
{
  bool _isProgressBar=false;
  String groupChatId="";
  late ChatProvider chatProvider;

  @override
  void initState() {
    chatProvider= context.read<ChatProvider>();
    print("the product ID ${widget.productID}");
    readLocal();
    super.initState();
  }

  void readLocal(){

    if(widget.currentUserFirebaseID.hashCode<=widget.productUserFirebaseID.hashCode)
    {
      groupChatId='${widget.currentUserFirebaseID}-${widget.productUserFirebaseID}';
    }
    else
    {
      groupChatId='${widget.productUserFirebaseID}-${widget.currentUserFirebaseID}';
    }

    chatProvider.updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        widget.currentUserFirebaseID,
        {FirestoreConstants.chattingWith: widget.productUserFirebaseID});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.warningText,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  addVerticalSpace(5.0),
                  Text(
                    widget.messageText,
                    style: const TextStyle(fontSize: 16),
                  ),
                  addVerticalSpace(20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          widget.cancel,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      addHorizontalSpace(10.0),
                      ElevatedButton(
                        onPressed: () {
                          getCallCreateChatAPI(context);
                          //Navigator.of(context).pop();
                        },
                        child:  Text(
                          widget.send+' ',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Visibility(
                child: const CircularProgressScreen(),
                visible: _isProgressBar,
              ),
            ),
            Positioned(
                top: -40,
                child: CircleAvatar(
                  backgroundColor: ConstantColors.primaryColor,
                  radius: 40,
                  child: Image.asset('assets/images/ic_app_icon.png',width: MediaQuery.of(context).size.width*0.15,)
                )
            ),
          ],
        ));
  }

  void getCallCreateChatAPI(BuildContext context)
  {
    setState(() {
      _isProgressBar=true;
    });
    PostCreateChatModel map=PostCreateChatModel(
        first_user: widget.currentUserFirebaseID,
        second_user: widget.productUserFirebaseID,
        product_id: widget.productID
    );
    API.postCreateChatAPICall(map.toMap(), widget.token).then((response)
    {
      int statusCode=response.statusCode;
      if(kDebugMode)
      {
        print("The response code is $statusCode\n the response is ${response.body}");
      }
      // SuccessModel model=SuccessModel.fromJson(json.decode(response.body));
      if(statusCode==200|| statusCode==201)
      {
        chatProvider.sendMessage(Strings.newlyChatMessage, TypeMessage.text, groupChatId, widget.currentUserFirebaseID, widget.productUserFirebaseID,widget.imageBlob);// send message directly to Firestore
        setState(()
        {
          _isProgressBar=false;
        });
        Fluttertoast.showToast(msg: "You can now chat to Trade your Product with ${widget.productUserName}",toastLength: Toast.LENGTH_LONG,timeInSecForIosWeb: 1);
        Navigator.of(context).pop(true);
      }
      else
      {
        setState(()
        {
          _isProgressBar=false;
          if(kDebugMode)
            {
              print('something wrong on CreateChatAPICall');
            }
        });
      }
    }
    );
  }
}

