import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'dart:io';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/chat_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/container_chat_message.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:tradz/allWidgets/loading_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/model/message_chat.dart';
import 'package:tradz/model/post_block_user_model.dart';
import 'package:tradz/utilities/CacheImageProvider.dart';

import 'login_screen.dart';
import 'notification_user_list_screen.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerImageAsset;
  final String peerImageBlob;
  final String peerNickname;
  final int UserID;

  const ChatScreen(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerImageAsset,
      required this.peerImageBlob,
      required this.peerNickname,
      required this.UserID})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<QueryDocumentSnapshot> listMessage = List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";
  late String currentUserId;
  bool _isUserBlocked = false;

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();
    facebookLoginProvider = context.read<FacebookLoginProvider>();

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      // Navigator.of(context).
      // pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>login_screen()),
      //       (Route<dynamic>route) => false,);
    }
    if (currentUserId.hashCode <= widget.peerId.hashCode) {
      groupChatId = '$currentUserId-${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId}-$currentUserId';
    }

    chatProvider.updateDataFirestore(FirestoreConstants.pathUserCollection,
        currentUserId, {FirestoreConstants.chattingWith: widget.peerId});
  }

  //Here we  Check message send is from Sender or receiver by using UserID

  //This is from sender i.e MySelf

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  //This is from Receiver

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  //send message to our Firebase Database
  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(
          content, type, groupChatId, currentUserId, widget.peerId,'');
      listScrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List imageByte=base64.decode(widget.peerImageBlob);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: GestureDetector(
          onTap: () {
            //User Products List
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        NotificationUserListScreen(
                            userID: widget.UserID,
                            userName: widget.peerNickname + " " + 'Product')));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                child: widget.peerImageAsset.isNotEmpty
                    ? Image.asset(
                        widget.peerImageAsset,
                        fit: BoxFit.cover,
                        height: 35.0,
                        width: 35.0,
                      )
                    : widget.peerImageBlob.isNotEmpty
                        ? Container(
        height: MediaQuery.of(context).size.height*0.05,
        width: MediaQuery.of(context).size.width*0.10,
        decoration: BoxDecoration(
            image: DecorationImage(
                image:
                CacheImageProvider(tag: widget.peerImageBlob, img: imageByte),
                //MemoryImage(base64.decode(productImageUrl)),
                fit: BoxFit.cover)
        ),
      )
                // Image.memory(base64Decode(widget.peerImageBlob),
                //             fit: BoxFit.cover, height: 35.0, width: 35.0)
                        : Image.network(
                            widget.peerAvatar,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, strackTrace) {
                              return const Icon(
                                Icons.account_circle,
                                size: 35.0,
                                color: Colors.grey,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(18.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              addHorizontalSpace(8.0),
              Text(
                widget.peerNickname,
                style: const TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          isLoading = true;
                        });
                        if (_isUserBlocked) {
                          getCallUnBlockUserAPI();
                        } else {
                          getCallBlockUserAPI();
                        }
                      },
                      child: _isUserBlocked
                          ? const Text("Unblock")
                          : const Text('Block'),
                    ),
                  ]),
          // IconButton(onPressed: (){
          //
          // },
          //     icon: const Icon(Icons.more_vert_sharp)),
        ],
      ),

      // AppBarView(
      //   titleText: widget.peerNickname,
      //   isAppBarVisible: true,
      // ),
      body: Stack(
        children: <Widget>[
          StreamBuilder(
              stream: chatProvider.getBlockedStream(currentUserId),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData)
                {
                  var data = snapshot.data!;
                  List<dynamic> blockedUser = data["blocked_user"];
                  List<dynamic> blockedBy = data["blocked_by"];
                  _isUserBlocked = blockedUser.contains(widget.peerId);
                  if (kDebugMode) {
                    print(
                        "userDetails are ${data["blocked_user"]}\n the value is ${blockedUser.contains(widget.peerId)}");
                  }
                  return Column(
                    children: <Widget>[
                      buildListMessage(),
                      blockedUser.contains(widget.peerId)
                          ? ContainerChatMessage(Strings.blockedUserChatToast)
                          : blockedBy.contains(widget.peerId)
                              ? ContainerChatMessage(Strings.blockedByChatToast)
                              : buildInput(),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressScreen(),
                  );
                }
              }),
          Visibility(
            child: const CircularProgressScreen(),
            visible: isLoading,
          )
          // buildLoading()
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const LoadingView() : const SizedBox.shrink(),
    );
  }

  // Here message type and send.
  Widget buildInput() {
    return Container(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(textEditingController.text, TypeMessage.text);
              },
              style: const TextStyle(
                color: ConstantColors.primaryColor,
                fontSize: 15.0,
              ),
              controller: textEditingController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type your Message...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              focusNode: focusNode,
            ),
          ),
          IconButton(
              onPressed: () {
                onSendMessage(textEditingController.text, TypeMessage.text);
              },
              color: Colors.white,
              icon: const Icon(Icons.send, color: ConstantColors.primaryColor)),
        ],
      ),
      width: double.infinity,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

//Sender Message Area
  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        print("the image url is ${messageChat.imageBlob}");
        final Uint8List imageByte=base64.decode(messageChat.imageBlob);
        return Row(
          children: <Widget>[
            messageChat.type == TypeMessage.text
                ? Column(
              mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: messageChat.imageBlob.isNotEmpty,
                      child:
                      Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height*0.20,
                            width: MediaQuery.of(context).size.width*0.40,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                    CacheImageProvider(tag: messageChat.imageBlob, img: imageByte),
                                    //MemoryImage(base64.decode(productImageUrl)),
                                    fit: BoxFit.cover)
                            ),
                          ),
                          addVerticalSpace(8.0),
                        ],
                      )
                  ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        //width: 200,
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Text(
                          messageChat.content,
                          style: const TextStyle(
                            color: ConstantColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: ConstantColors.primaryDarkColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 8.0),
                      ),
                  ],
                )
                : messageChat.type == TypeMessage.image
                    ? Container(
                        child: OutlinedButton(
                          child: Material(
                            child: Image.network(
                              messageChat.content,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      )),
                                  width: 200.0,
                                  height: 200.0,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                      null &&
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Material(
                                  child: Image.asset(
                                    'assets/images/error_image.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                );
                              },
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {},
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(0))),
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      )
                    : Container(
                        child: Image.asset('image/${messageChat.content}.gif',
                            width: 100.0, height: 100.0, fit: BoxFit.cover),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      }
      else {
        final Uint8List imageByte=base64.decode(messageChat.imageBlob);
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  // isLastMessageLeft(index)
                  //     ? Material(
                  //   child: Image.network(
                  //     widget.peerAvatar,
                  //     loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent ? loadingProgress){
                  //       if(loadingProgress==null ) return child;
                  //       return  Center(
                  //         child: CircularProgressIndicator(
                  //           color: Colors.black,
                  //           value: loadingProgress.expectedTotalBytes !=null &&
                  //               loadingProgress.expectedTotalBytes!=null
                  //               ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  //               :null,
                  //         ),
                  //       );
                  //
                  //     },
                  //     errorBuilder: (context, object, strackTrace){
                  //       return const Icon(
                  //         Icons.account_circle,
                  //         size: 35.0,
                  //         color: Colors.grey,
                  //
                  //       );
                  //     },
                  //     width: 35,
                  //     height: 35,
                  //     fit: BoxFit.cover,
                  //   ),
                  //   borderRadius: const BorderRadius.all(
                  //     Radius.circular(18.0),
                  //   ),
                  //   clipBehavior: Clip.hardEdge,
                  // )
                  //     : Container(
                  //   width: 35.0,
                  // ),
                  messageChat.type == TypeMessage.text
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                        children: [
                         Visibility(
                           visible: messageChat.imageBlob.isNotEmpty,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.20,
                    width: MediaQuery.of(context).size.width*0.40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image:
                          CacheImageProvider(tag: messageChat.imageBlob, img: imageByte),
                          //MemoryImage(base64.decode(productImageUrl)),
                          fit: BoxFit.cover)
                    ),
                  ),
                  addVerticalSpace(8.0),
                ],
              )
                         ),
                          Container(
                              child: Text(
                                messageChat.content,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                              width: MediaQuery.of(context).size.width * 0.50,
                              decoration: BoxDecoration(
                                color: ConstantColors.primaryColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: const EdgeInsets.only(left: 10.0),
                            ),
                        ],
                      )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              child: TextButton(
                                child: Material(
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            )),
                                        width: 200.0,
                                        height: 200.0,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null &&
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) =>
                                            Material(
                                      child: Image.asset(
                                        'assets/images/error_image.jpeg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: () {},
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.all(0))),
                              ),
                              //margin: EdgeInsets.only(bottom: isLastMessageRight(index)?20.0:10.0, right: 10.0),
                              margin: const EdgeInsets.only(left: 10.0),
                            )
                          : Container(
                              child: Image.asset(
                                  'image/${messageChat.content}.gif',
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover),
                              margin: EdgeInsets.only(
                                  bottom:
                                      isLastMessageRight(index) ? 20.0 : 10.0,
                                  right: 10.0),
                            )
                ],
              ),
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM, hh:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(messageChat.timestamp))),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      margin: const EdgeInsets.only(
                          left: 50.0, top: 5.0, bottom: 5.0),
                    )
                  : const SizedBox.shrink()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: const EdgeInsets.only(bottom: 10.0),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildListMessage() {
    return Flexible(
        child: groupChatId.isNotEmpty
            ? StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getChatStream(groupChatId, _limit),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    listMessage.addAll(snapshot.data!.docs);
                    return ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressScreen(),
                    );
                  }
                })
            : const Center(
                child: CircularProgressScreen(),
              ));
  }

  void getCallBlockUserAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    PostBlockUserModel map =
        PostBlockUserModel(social_profile_id: widget.peerId, reason: 'reason');
    API.getCallBlockUser(map.toMap(), token).then((response) {
      int statusCode = response.statusCode;
      print("user blocked response is ${response.body}");
      if (statusCode == 200 || statusCode == 201) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          chatProvider.updateDataFirestore(
              FirestoreConstants.pathUserCollection, currentUserId, {
            FirestoreConstants.blockedUser:
                FieldValue.arrayUnion([widget.peerId])
          }); //block the user to whom currentUser chat with.
          chatProvider.updateDataFirestore(
              FirestoreConstants.pathUserCollection, widget.peerId, {
            FirestoreConstants.blockedBy: FieldValue.arrayUnion([currentUserId])
          }); //In Blocked user Item details listed blocked_by the current_User(Firebase_ID)
          setState(() {
            _isUserBlocked = true;
            isLoading = false;
          });
        } else if (body['status'] == 'unauthenticated') {
          getCallSignout(authProvider, facebookLoginProvider);
        }
      }
    });
  }

  void getCallSignout(AuthProvider authProvider,
      FacebookLoginProvider facebookLoginProvider) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginProfileType = prefs.getString(Strings.loginProfileType);
    if (loginProfileType == Strings.facebook) {
      bool isSuccess = await facebookLoginProvider.allowUserToSignOut();
      if (isSuccess) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Fluttertoast.showToast(msg: "Account already deleted");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false);
      } else {
        if (kDebugMode) {
          print("something went wrong");
        }
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } else {
      bool isSuccess = await authProvider.handleSignout();
      if (isSuccess) {
        print("success in logout");
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Fluttertoast.showToast(msg: "Account already deleted");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false);
        // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>LoginScreen()));
      } else {
        print("something went wrong");
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void getCallUnBlockUserAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    String userID = widget.peerId;
    API.getCallUnBlockUser(token, userID).then((response) {
      int statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          print("user unblocked response is ${response.body}");
          chatProvider.updateDataFirestore(
              FirestoreConstants.pathUserCollection, currentUserId, {
            FirestoreConstants.blockedUser:
                FieldValue.arrayRemove([widget.peerId])
          });
          chatProvider.updateDataFirestore(
              FirestoreConstants.pathUserCollection, widget.peerId, {
            FirestoreConstants.blockedBy:
                FieldValue.arrayRemove([currentUserId])
          });
          setState(() {
            _isUserBlocked = false;
            isLoading = false;
          });
        } else if (body['status'] == 'unauthenticated') {
          getCallSignout(authProvider, facebookLoginProvider);
        }
      }
    });
  }
}
