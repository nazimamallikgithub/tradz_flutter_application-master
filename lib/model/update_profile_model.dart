import 'package:flutter/material.dart';
class UpdateProfileModel
{
  final String first_name;
  final String last_name;
  final  image_path;
  final String location;

  UpdateProfileModel(
      {required this.first_name,required this.last_name,required this.image_path,required this.location});

  factory UpdateProfileModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return UpdateProfileModel(
        first_name: parsedJson['first_name'],
        last_name: parsedJson['last_name'],
        image_path: parsedJson['image_path'],
        location: parsedJson['location']
    );
  }
  Map toMap(){
    var map = <String, dynamic>{};
    map['first_name']=first_name;
    map['last_name']=last_name;
    map['image_path']=image_path;
    map['location']=location;
    return map;
  }
}