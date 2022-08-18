import 'package:flutter/material.dart';
class AddProductModel
{
  String title;
  String description;
  String price;
  String category_id;
  String sub_category_id;
  List<String> original_images;
  List<String>  thumbnail_images;

  AddProductModel(
      {
        required this.title,
        required this.description,
        required this.price,
        required this.category_id,
        required this.sub_category_id,
        required this.original_images,
        required this.thumbnail_images
      });

  factory AddProductModel.fromJson(Map<String, dynamic> parsedJSon){
    return AddProductModel(
        title: parsedJSon['title'],
        description: parsedJSon['description'],
        price: parsedJSon['price'],
        category_id: parsedJSon['category_id'],
        sub_category_id: parsedJSon['sub_category_id'],
        original_images: parsedJSon['original_images'],
        thumbnail_images: parsedJSon['thumbnail_images']
    );
  }

  Map toMap()
  {
    var map = <String, dynamic>{};
    map['title']=title;
   map['description']= description;
    map['price']=price;
    map['category_id']=category_id;
    map['sub_category_id']=sub_category_id;
    map['original_images']=original_images;
    map['thumbnail_images']=thumbnail_images;
    return map;
  }
}