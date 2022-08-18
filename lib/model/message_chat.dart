import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';

class MessageChat {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  String imageBlob;
  int type;

  MessageChat(
      {required this.idFrom,
      required this.idTo,
      required this.timestamp,
      required this.content,
        required this.imageBlob,
      required this.type});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: this.idFrom,
      FirestoreConstants.idTo: this.idTo,
      FirestoreConstants.timestamp: this.timestamp,
      FirestoreConstants.content: this.content,
      FirestoreConstants.type: this.type,
      FirestoreConstants.imageBlob:this.imageBlob
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get(FirestoreConstants.idFrom);
    String idTo = doc.get(FirestoreConstants.idTo);
    String timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    int type = doc.get(FirestoreConstants.type);
    String imageBlob=doc.get(FirestoreConstants.imageBlob);
    return MessageChat(
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        content: content,
        type: type,
      imageBlob: imageBlob
    );
  }
}
