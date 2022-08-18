import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/model/user_chat.dart';
class FacebookLoginProvider with ChangeNotifier
{
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;


  FacebookLoginProvider({required this.firebaseAuth,required this.prefs,required this.firebaseFirestore});

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }


  Future<bool>allowUserToSignInwithFb() async{
    try{
      SharedPreferences prefs=await SharedPreferences.getInstance();

      var result=await FacebookAuth.i.login(
        permissions: ['public_profile','email'],
      );


      //check the status of our login
      if(result.status==LoginStatus.success)
      {
        final AuthCredential facebookCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);
        User? firebaseUser  =
            (await firebaseAuth.signInWithCredential(facebookCredential)).user;
        if (firebaseUser != null)
        {
          CollectionReference users = firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection);
          var blockedDoc = await users.doc(firebaseUser.uid).get();
          if(blockedDoc.exists)
          {
            Map<String, dynamic> map= blockedDoc.data() as Map<String, dynamic>;
            if(map.containsKey(FirestoreConstants.blockedUser))
            {// Replace field by the field you want to check.
              print("BlockedUser exist");
            }
            else
            {
              firebaseFirestore.collection(FirestoreConstants.pathUserCollection)
                  .doc(firebaseUser.uid)
                  .set(
                  {
                    FirestoreConstants.blockedUser: [],
                    FirestoreConstants.blockedBy: [],
                  },SetOptions(merge: true)
              ).then((value) {
                print("ADDED BLOCKEDUSER AND BLOCKEDBY");
              });
            }

            if(map.containsKey(FirestoreConstants.assetImage))
            {
              print("AssetImage exist");
            }else{
              firebaseFirestore.collection(FirestoreConstants.pathUserCollection)
                  .doc(firebaseUser.uid)
                  .set(
                  {
                    FirestoreConstants.assetImage:null,
                    FirestoreConstants.imageBlob:null
                  },SetOptions(merge: true)
              ).then((value)
              {
                print("ADDED IMAGEBLOB AND IMAGEASSET");
              });
            }
          }

          final QuerySnapshot result = await firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
              .get();
          final List<DocumentSnapshot> document = result.docs;
          print("the document in fbProvider is ${document.isEmpty}");
          if (document.isEmpty)
          {
            final requestData=await FacebookAuth.i.getUserData(
              // fields:"id,email,first_name,last_name,picture.type(large)",
              fields: "id,email,name,first_name,last_name,picture",
            );

            firebaseFirestore
                .collection(FirestoreConstants.pathUserCollection)
                .doc(firebaseUser.uid)
                .set({
              FirestoreConstants.nickname: firebaseUser.displayName,
              FirestoreConstants.photoUrl: firebaseUser.photoURL,
              FirestoreConstants.id: firebaseUser.uid,
              FirestoreConstants.email: requestData['email']??"",
              'createdAt': DateTime.now().microsecondsSinceEpoch.toString(),
              FirestoreConstants.chattingWith: null,
              FirestoreConstants.blockedUser: [],
              FirestoreConstants.blockedBy: [],
              FirestoreConstants.assetImage:null,
              FirestoreConstants.imageBlob:null
            });


            if (kDebugMode)
            {
              print("the id in FirebaseUser is uID is ${firebaseUser.uid}\n the email is ${firebaseUser.email}"
                  "\n the Name is ${firebaseUser.displayName}\n "
                  "the image is ${firebaseUser.photoURL}");


              print("the id is ${requestData['id']}\n the email is ${requestData['email']}"
                  "\n the firstName is ${requestData['first_name']}\n "
                  "the lastName is ${requestData['last_name']}\n "
                  "the image is ${requestData['picture']['data']['url']}");
            }
            await prefs.setString(FirestoreConstants.firstName, requestData['first_name']);
            await prefs.setString(FirestoreConstants.lastName, requestData['last_name']);
            //User? currentUser = firebaseUser;
            await prefs.setString(FirestoreConstants.id, firebaseUser.uid);
            await prefs.setString(FirestoreConstants.email, requestData['email'] ??"");
            // await prefs.setString(
            //     FirestoreConstants.nickname, currentUser.displayName ?? "");
            await prefs.setString(
                FirestoreConstants.photoUrl, firebaseUser.photoURL ?? "");
            await prefs.setString(
                FirestoreConstants.phoneNumber,  "");
            notifyListeners();
            return true;
          }
          else
          {
            DocumentSnapshot documentSnapshot = document[0];
            print("the user data is ${document[0]}");
            UserChat? userChat = UserChat.fromDocument(documentSnapshot);
            final requestData=await FacebookAuth.i.getUserData(
              // fields:"id,email,first_name,last_name,picture.type(large)",
              fields: "id,email,name,first_name,last_name,picture",
            );
            await prefs.setString(FirestoreConstants.firstName, requestData['first_name']);
            await prefs.setString(FirestoreConstants.lastName, requestData['last_name']);
            await prefs.setString(FirestoreConstants.id, userChat.id);
            await prefs.setString(FirestoreConstants.email, userChat.email);
            await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
            await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
            await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
            await prefs.setString(
                FirestoreConstants.phoneNumber, userChat.phoneNumber);
            notifyListeners();
            return true;
          }
        }
        else
        {
          notifyListeners();
          return false;
        }


      }

      else if(result.status==LoginStatus.cancelled)
      {
        if (kDebugMode){
          print("cancelled called");
        }
        notifyListeners();
        return false;
      }
      else if(result.status==LoginStatus.failed)
      {
        if (kDebugMode)
        {
          print("failed called");
        }
        notifyListeners();
        return false;
      }
      else{
        if (kDebugMode)
        {
          print("else part something gone wrong");
        }
        notifyListeners();
        return false;
      }
    }catch(e)
    {
      print("The exception in facebook login is $e");
     // Fluttertoast.showToast(msg: "Email associated with Facebook account already logged in by Google Authentication");
      notifyListeners();
      return false;
    }
  }

  Future<bool>allowUserToSignOut() async{
    await FacebookAuth.i.logOut();
    notifyListeners();
    return true;
  }
}