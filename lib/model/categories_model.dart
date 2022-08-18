import 'package:flutter/material.dart';
class CategoriesModel
{
  final List<Categories> categories;

  CategoriesModel({required this.categories});
  factory CategoriesModel.fromJson(Map<String, dynamic> parsedJSon)
  {
    var list=parsedJSon['categories'] as List;
    List<Categories> categoriesList=list.map((i) => Categories.fromJson(i)).toList();
    return CategoriesModel(
        categories: categoriesList
    );
  }
}
class Categories
{
  int id;
  String text;
  String icon_path;
  String image_blob;

  Categories({required this.id, required this.text,required this.icon_path,required this.image_blob});

  factory Categories.fromJson(Map<String, dynamic> parsedJSon)
  {
    return Categories(
        id: parsedJSon['id'] as int,
        text: parsedJSon['text']??'',
        icon_path:parsedJSon['icon_path']??'',
        image_blob:parsedJSon['image_blob']??''
    );
  }

}
