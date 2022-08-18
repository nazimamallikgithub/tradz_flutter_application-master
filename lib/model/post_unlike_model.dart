import 'package:flutter/material.dart';
class PostUnlikeModel
{
  final int liked_product_id;

  PostUnlikeModel({required this.liked_product_id});
  factory PostUnlikeModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return PostUnlikeModel(
        liked_product_id: parsedJson['liked_product_id'] as int
    );
  }

  Map toMap()
  {
    var map= <String,dynamic>{};
    map['liked_product_id']=liked_product_id.toString();
    return map;
  }

}