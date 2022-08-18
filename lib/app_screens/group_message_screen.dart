import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';

import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:tradz/allProvider/facebook_login_provider.dart';
import 'package:tradz/allProvider/home_provider.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/no_internet_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/model/active_chat_model.dart';
import 'package:tradz/model/user_chat.dart';
import 'package:tradz/utilities/debouncer.dart';
import 'package:provider/provider.dart';
import 'package:tradz/utilities/utilities.dart';

import '../create_group.dart';
import 'login_screen.dart';

 class GroupMessageScreen extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  GroupMessageScreen(
      {required this.name,
        required this.membersList,
        required this.groupChatId,
        Key? key})
      : super(key: key);


  @override
  MessageState createState() => MessageState();
}


class MessageState extends State<GroupMessageScreen> {


  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> membersList =[];

  Map<String, dynamic>? userMap;



  int _limit = 20;
  int _limitIncrement = 20;
  final ScrollController listScrollController = ScrollController();
  String _textSearch = "";
  bool isLoading = false;
  late String currentUserId;
  late String token;
  bool _isVisible = false;
  bool _isvariable = false;
  late ActiveChatModel activeChatModel;
  List<ActiveChat>? activeChatList;
  late AuthProvider authProvider;
  late FacebookLoginProvider facebookLoginProvider;
  late HomeProvider homeProvider;
  TextEditingController searchController = TextEditingController();

  String noInternetMessage = '';
   String group_name='';

  bool _isInternet = false;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> btnClearController = StreamController<bool>();

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      if (!mounted) return;
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    checkSelectedLanguage();
    super.initState();
    authProvider = context.read<AuthProvider>();
    facebookLoginProvider = context.read<FacebookLoginProvider>();
    homeProvider = context.read<HomeProvider>();
    token = authProvider.getUserTokenID()!;

    getCurrentUserDetails();

    if (token.isNotEmpty) {
      getCallActiveChatUser(token);
    }
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
    }
    listScrollController.addListener(scrollListener);
  }

  void checkSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? locale = prefs.getString(Strings.selectedLanguage);
    if (locale != null) {
      if (locale == 'hi') {
        if (!mounted) return;
        setState(() {
          noInternetMessage = Strings.noInternetMessage_hi;
          group_name=Strings.group_name_hi;

        });
      } else if (locale == 'bn') {
        if (!mounted) return;
        setState(() {
          noInternetMessage = Strings.noInternetMessage_bn;
          group_name=Strings.group_name_bn;
        });
      } else if (locale == 'te') {
        if (!mounted) return;
        setState(() {
          noInternetMessage = Strings.noInternetMessage_te;
          group_name=Strings.group_name_te;
        });
      }else {
        if (!mounted) return;
        setState(() {
          noInternetMessage = Strings.noInternetMessage;
          group_name=Strings.group_name;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        noInternetMessage = Strings.noInternetMessage;group_name=Strings.group_name;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
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
        isLoading = false;
        print("insternet becomes exception " + _isInternet.toString());
      });
    }
  }

  Future<bool> checkInternetFromWithinWidgets() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _isInternet = false;
          print("insternet becomes if " + _isInternet.toString());
        });
      }
      return true;
    } on SocketException catch (_) {
      setState(() {
        _isInternet = true;
        isLoading = false;
        print("insternet becomes exception " + _isInternet.toString());
      });
      return false;
    }
  }



  void onAddMembers() async {
    membersList.add(userMap!);

    await _firestore.collection('groups').doc(widget.groupChatId).update({
      "members": membersList,
    });

    await _firestore
        .collection('users')
        .doc(userMap!['id'])
        .collection('groups')
        .doc(widget.groupChatId)
        .set({"name": widget.name, "id": widget.groupChatId});
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['id'] == userMap!['id']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "name": userMap!['nickname'],
          "email": userMap!['Email'],
          "uid": userMap!['id'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
  }


  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "name": map['nickname'],
          "email": map['Email'],
          "uid": map['id'],
          "isAdmin": true,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(group_name),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              activeChatList != null
                  ? Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: homeProvider.getStreamFireStore(
                            FirestoreConstants.pathUserCollection,
                            _limit,
                            _textSearch),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          print("the length is ${snapshot.data?.docs.length}");
                          if (snapshot.hasData) {
                            if ((snapshot.data?.docs.length ?? 0) > 0) {
                              return ListView.builder(
                                padding: const EdgeInsets.all(10.0),
                                itemBuilder: (context, index) {
                                  return buildItem(
                                      context, snapshot.data?.docs[index]);
                                },
                                itemCount: snapshot.data?.docs.length,
                                controller: listScrollController,
                              );
                            } else {
                              return const Center(
                                child: Text("No user found...",
                                    style: TextStyle(color: Colors.grey)),
                              );
                            }
                          } else {
                            return const Center(
                              child: CircularProgressScreen(),
                            );
                          }
                        },
                      ),
                    )
                  : const LinearProgressIndicator(),
            ],
          ),
          Positioned(
              child: isLoading
                  ? const CircularProgressScreen()
                  : const SizedBox.shrink()),
          NoInternetView(
            isInternet: _isInternet,
            noInternetMessage: noInternetMessage,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,MaterialPageRoute(
                builder:(context)=>CreateGroup(membersList: [],
              ),
            ));
          },
        backgroundColor: ConstantColors.primaryColor,
        child: Icon(
          Icons.arrow_forward_outlined,
          color: Colors.white,
        ),
      ),
    );
  }


  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      for (int i = 0; i < activeChatList!.length; i++) {
        print(
            "The activeChat userID is ${activeChatList![i].social_profile_id}\n the userID is ${userChat.id}");
        if (userChat.id == activeChatList![i].social_profile_id) {
          print("socialID true");
          return GestureDetector(


              // print("the long press works");
              // setState(() {
              //   if (_isvariable) {
              //     _isvariable = false;
              //   } else {
              //     _isvariable = true;
              //   }
              // });

            child: Container(
              child: Row(
                children: <Widget>[
                  Visibility(
                    visible: true,
                    child: Checkbox(
                      value: _isVisible,
                      onChanged: (bool ? newValue){
                        print("the value of _isVisible is $newValue");
                        setState(() {
                          _isVisible = newValue!;
                        });

                        if (_isVisible) {
                          print("the value after selected is ${userChat.id}");
                        }
                      },
                    ),
                  ),
                  Material(
                    child: userChat.assetImage.isNotEmpty
                        ? Image.asset(
                            userChat.assetImage,
                            fit: BoxFit.cover,
                            width: 50.0,
                            height: 50.0,
                          )
                        : userChat.imageBlob.isNotEmpty
                            ? Image.memory(
                                base64Decode(userChat.imageBlob),
                                fit: BoxFit.cover,
                                width: 50.0,
                                height: 50.0,
                              )
                            : userChat.photoUrl.isNotEmpty
                                ? Image.network(
                                    userChat.photoUrl,
                                    fit: BoxFit.cover,
                                    width: 50.0,
                                    height: 50.0,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          color: Colors.grey,
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
                                      );
                                    },
                                    errorBuilder:
                                        (conetxt, object, stackTrace) {
                                      return const Icon(
                                        Icons.account_circle,
                                        size: 50,
                                        color: Colors.grey,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.account_circle,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '${userChat.nickname}',
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                          ),
                          // Container(
                          //   child: Text(
                          //     '${userChat.nickname}',
                          //     maxLines: 1,
                          //     style: TextStyle(
                          //       color: Colors.grey[600],
                          //       fontWeight: FontWeight.bold,
                          //       fontSize: 18.0,
                          //     ),
                          //   ),
                          //   alignment: Alignment.centerLeft,
                          //   margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                          // )
                        ],
                      ),
                    ),
                  )
                ],
              ),

          ),

          );
        }
      }
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      }
      // else if(userChat.id==socialID)
      // {
      //   print("socialID true");
      //   return Container(
      //     child: TextButton(
      //       child: Row(
      //         children: <Widget>[
      //           Material(
      //             child: userChat.photoUrl.isNotEmpty
      //                 ? Image.network(
      //               userChat.photoUrl,
      //               fit: BoxFit.cover,
      //               width: 50.0,
      //               height: 50.0,
      //               loadingBuilder:
      //                   (BuildContext context, Widget child,
      //                   ImageChunkEvent? loadingProgress)
      //               {
      //                 if (loadingProgress == null) return child;
      //                 return SizedBox(
      //                   width: 50,
      //                   height: 50,
      //                   child: CircularProgressIndicator(
      //                     color: Colors.grey,
      //                     value: loadingProgress.expectedTotalBytes !=
      //                         null &&
      //                         loadingProgress.expectedTotalBytes !=
      //                             null
      //                         ? loadingProgress.cumulativeBytesLoaded /
      //                         loadingProgress.expectedTotalBytes!
      //                         : null,
      //                   ),
      //                 );
      //               },
      //               errorBuilder: (conetxt, object, stackTrace) {
      //                 return const Icon(
      //                   Icons.account_circle,
      //                   size: 50,
      //                   color: Colors.grey,
      //                 );
      //               },
      //             )
      //                 : const Icon(
      //               Icons.account_circle,
      //               size: 50,
      //               color: Colors.grey,
      //             ),
      //             borderRadius: const BorderRadius.all(Radius.circular(25)),
      //             clipBehavior: Clip.hardEdge,
      //           ),
      //           Flexible(
      //             child: Container(
      //               child: Column(
      //                 children: <Widget>[
      //                   Container(
      //                     child: Text(
      //                       '${userChat.nickname}',
      //                       maxLines: 1,
      //                       style: TextStyle(
      //                         color: Colors.grey[600],
      //                         fontWeight: FontWeight.bold,
      //                         fontSize: 18.0,
      //                       ),
      //                     ),
      //                     alignment: Alignment.centerLeft,
      //                     margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
      //                   ),
      //                   // Container(
      //                   //   child: Text(
      //                   //     '${userChat.nickname}',
      //                   //     maxLines: 1,
      //                   //     style: TextStyle(
      //                   //       color: Colors.grey[600],
      //                   //       fontWeight: FontWeight.bold,
      //                   //       fontSize: 18.0,
      //                   //     ),
      //                   //   ),
      //                   //   alignment: Alignment.centerLeft,
      //                   //   margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
      //                   // )
      //                 ],
      //               ),
      //             ),
      //           )
      //         ],
      //       ),
      //       onPressed: () {
      //         if (Utilities.isKeyboardShowing()) {
      //           Utilities.closeKeyboard(context);
      //         }
      //         Navigator.push(context,
      //             MaterialPageRoute(builder: (context) =>  ChatScreen(
      //               peerId: userChat.id,
      //               peerAvatar: userChat.photoUrl,
      //               peerNickname: userChat.nickname,
      //             )
      //             )
      //         );
      //       },
      //       style: ButtonStyle(
      //           backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.withOpacity(.2)),
      //           shape: MaterialStateProperty.all<OutlinedBorder>(
      //             const RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.all(Radius.circular(10),)
      //             ),
      //           )
      //       ),
      //     ),
      //     margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
      //
      //   );
      // }
      else {
        print("inside else of buildItem");
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
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

      } else {
        print("something went wrong");
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void getCallActiveChatUser(String token) {
    API.getCallActiveChat(token).then((response) {
      setState(() {
        isLoading = true;
      });
      int statusCode = response.statusCode;
      if (kDebugMode) {
        print(
            "The response getCallActiveChatUser status is $statusCode\n the getCallActiveChatUser response body is ${response.body}");
      }
      if (statusCode == 200 || statusCode == 201) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          setState(() {
            isLoading = false;
            activeChatModel =
                ActiveChatModel.fromJson(json.decode(response.body));
            activeChatList = activeChatModel.active_chats;
            //socialProfileIDList=activeChatModel.active_chats;
            print("the profileID array is $activeChatList");
          });
        } else if (body['status'] == 'unauthenticated') {
          setState(() {
            activeChatList = [];
            isLoading = false;
          });
          getCallSignout(authProvider, facebookLoginProvider);
        } else {
          setState(() {
            activeChatList = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          activeChatList = [];
          isLoading = false;
        });
      }
    });
  }
}
