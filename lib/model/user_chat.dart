import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
class UserChat
{
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;
  String phoneNumber;
  String email;
  String assetImage;
  String imageBlob;

  UserChat(
      { required this.id,required this.photoUrl,required this.nickname,required this.aboutMe,required this.phoneNumber, required this.email, required this.imageBlob, required this.assetImage});

  Map<String, String> toJson(){
    return
      {
      FirestoreConstants.photoUrl:photoUrl,
      FirestoreConstants.nickname:nickname,
      FirestoreConstants.aboutMe:aboutMe,
      FirestoreConstants.phoneNumber:phoneNumber,
      FirestoreConstants.email:email,
        FirestoreConstants.assetImage:assetImage,
        FirestoreConstants.imageBlob:imageBlob
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc)
  {
    String aboutMe="";
    String photoUrl="";
    String nickname="";
    String phoneNumber="";
    String email="";
    String imageBlob="";
    String assetImage="";
    try{
      aboutMe= doc.get(FirestoreConstants.aboutMe);
    }catch(e){
    }
    try{
      photoUrl= doc.get(FirestoreConstants.photoUrl);
    }catch(e){

    }
    try{
      nickname= doc.get(FirestoreConstants.nickname);
    }catch(e){}
    try{
      phoneNumber= doc.get(FirestoreConstants.phoneNumber);
    }catch(e){

    }

    try{
      imageBlob=doc.get(FirestoreConstants.imageBlob);
    }catch(e)
    {

    }

    try{
assetImage=doc.get(FirestoreConstants.assetImage);
    }catch(e)
    {

    }

    try{
      email=doc.get(FirestoreConstants.email);
    }catch(e){

    }
    return UserChat(id: doc.id, photoUrl: photoUrl, nickname: nickname, aboutMe: aboutMe, phoneNumber: phoneNumber,email: email, assetImage: assetImage, imageBlob: imageBlob);
  }
}