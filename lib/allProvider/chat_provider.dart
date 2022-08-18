import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
import 'package:tradz/model/message_chat.dart';

class ChatProvider
{
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider({
   required this.firebaseFirestore,
   required this.prefs,
   required this.firebaseStorage
  });

  UploadTask uploadTask(File image, String filename)
  {
    Reference reference=firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath,
      String docPath, Map<String,dynamic> dataNeedUpdate)
  {
    return firebaseFirestore.collection(collectionPath).doc(docPath).update(dataNeedUpdate);
  }
  
  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit)
  {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }


  Stream<DocumentSnapshot> getBlockedStream(String currentUserID)
  {
    return firebaseFirestore
    .collection(FirestoreConstants.pathUserCollection).doc(currentUserID).snapshots();
  }
  void sendMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId,String imageblob)
  {
    DocumentReference documentReference=firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());
    MessageChat messageChat= MessageChat
      (
      idFrom: currentUserId,
      idTo:peerId,
      timestamp:DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
      imageBlob: imageblob
    );

    FirebaseFirestore.instance.runTransaction((transaction) async
    {
      transaction.set(
          documentReference,
          messageChat.toJson()
      );
    });
  }
}

class TypeMessage{
  static const text=0;
  static const image=1;
  static const sticker=2;
}