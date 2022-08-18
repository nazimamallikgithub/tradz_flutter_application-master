import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/model/user_chat.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;
  Status _status = Status.uninitialized;
//final Fire firebaseAuth;
  Status get status => _status;

  AuthProvider(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseAuth,
      required this.googleSignIn});

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }

  String? getUserTokenID() {
    return prefs.getString(Strings.google_token);
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn
        .signIn(); //using this the pop up with all gmail account shown up
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;
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
          }else{
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
            ).then((value) {
              print("ADDED IMAGEBLOB AND IMAGEASSET");
            });
          }
        }



        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        print("the document in authProvider is  ${document.isEmpty}");
        if (document.isEmpty)
        {
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.nickname: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            FirestoreConstants.email: firebaseUser.email,
            'createdAt': DateTime.now().microsecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null,
            FirestoreConstants.blockedUser: [],
            FirestoreConstants.blockedBy: [],
            FirestoreConstants.assetImage:null,
            FirestoreConstants.imageBlob:null
          });
          Map<String, dynamic>? idMap = parseJwt(googleAuth
              .idToken); //In order to return firstname and lastname using idToken as firstname and last name not returns normally.
          final String firstName = idMap!["given_name"];
          final String lastName = idMap["family_name"];
          await prefs.setString(FirestoreConstants.firstName, firstName);
          await prefs.setString(FirestoreConstants.lastName, lastName);
          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.email, currentUser.email ?? "");
          // await prefs.setString(
          //     FirestoreConstants.nickname, currentUser.displayName ?? "");

          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");

          await prefs.setString(
              FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
        }
        else
        {
          DocumentSnapshot documentSnapshot = document[0];
          UserChat? userChat = UserChat.fromDocument(documentSnapshot);
          Map<String, dynamic>? idMap = parseJwt(googleAuth
              .idToken); //In order to return firstname and lastname using idToken as firstname and last name not returns normally.
          final String firstName = idMap!["given_name"];
          final String lastName = idMap["family_name"];
          await prefs.setString(FirestoreConstants.firstName, firstName);
          await prefs.setString(FirestoreConstants.lastName, lastName);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.email, userChat.email);
          await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
          await prefs.setString(
              FirestoreConstants.phoneNumber, userChat.phoneNumber);
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      }
      else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    }
    else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleSignout() async
  {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    return true;
  }

  //retrieve first name and last name from Google auth with the help of google idToken.
  static Map<String, dynamic>? parseJwt(String? token) {
    // validate token
    if (token == null) return null;
    final List<String> parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    // retrieve token payload
    final String payload = parts[1];
    final String normalized = base64Url.normalize(payload);
    final String resp = utf8.decode(base64Url.decode(normalized));
    // convert to Map
    final payloadMap = json.decode(resp);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }
    return payloadMap;
  }
}
