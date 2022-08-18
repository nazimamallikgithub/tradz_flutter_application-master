import 'package:flutter/material.dart';
class PostLikeModel
{
  final int liked_product_id;
  final String message_text;

  PostLikeModel({required this.liked_product_id,required this.message_text});

  factory PostLikeModel.fromjson(Map<String, dynamic> parsedJson)
  {
    return PostLikeModel(
      liked_product_id: parsedJson['liked_product_id'] as int,
      message_text: parsedJson['message_text']
    );
  }

  Map toMap()
  {
    var map = <String, dynamic>{};
    map['liked_product_id'] =liked_product_id.toString();
    map['message_text']=message_text;
    return map;
  }
}