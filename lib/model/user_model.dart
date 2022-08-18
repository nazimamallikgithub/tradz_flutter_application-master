import 'package:flutter/material.dart';

class UserModel {
  final String first_name;
  final String last_name;
  final String email;
  final String image_path;
  final String profile_type;
  final String profile_id;
  final String location_locality;
  final String latitude;
  final String longitude;
  final String country;
  final String state;
  final String city;
  final String pincode;

  UserModel(
      {required this.first_name,
      required this.last_name,
      required this.email,
      required this.image_path,
      required this.profile_type,
      required this.profile_id,
      required this.location_locality,
      required this.latitude,
      required this.longitude,
      required this.country,
        required this.state,
        required this.pincode,
        required this.city
      });

  factory UserModel.fromJson(Map<String, dynamic> parsedJson) {
    return UserModel(
        first_name: parsedJson['first_name'],
        last_name: parsedJson['last_name'],
        email: parsedJson['email'],
        image_path: parsedJson['image_path'],
      profile_type: parsedJson['profile_type'],
      profile_id: parsedJson['profile_id'],
      location_locality: parsedJson['location'],
        longitude: parsedJson['latitude'],
        latitude: parsedJson['longitude'],
        city: parsedJson['city'],
        pincode: parsedJson['pincode'],
        state: parsedJson['state'],
        country: parsedJson['country']
    );
  }

  Map toMap(){
    var map = <String, dynamic>{};
    map['first_name']=first_name;
    map['last_name']=last_name;
    map['email']=email;
    map['image_path']=image_path;
    map['profile_type']=profile_type;
    map['profile_id']=profile_id;
    map['location']=location_locality;
    map['latitude'] =latitude;
    map['longitude'] =longitude;
    map['country']=country;
    map['city']=city;
    map['state']=state;
    map['pincode']=pincode;
    return map;
  }
}
