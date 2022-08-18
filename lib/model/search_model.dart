import 'package:flutter/material.dart';
class SearchModel
{
  final String string;
  final List<int> categories;
  final List<int> sub_categories;

  SearchModel({required this.string,required this.categories,required this.sub_categories});
  factory SearchModel.fromJson(Map<String, dynamic> parsedJson)
  {

    return SearchModel(
        string: parsedJson['string'],
      categories: parsedJson['categories'].cast<int>(),
      sub_categories: parsedJson['sub_categories'].cast<int>()
    );
  }

  Map toMap()
  {
    var map = <String, dynamic>{};
    map['string']=string;
    return map;
  }
}