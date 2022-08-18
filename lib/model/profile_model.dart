import 'package:flutter/material.dart';

class ProfileModel {
  final User user;
  final UserSettings settings;

  ProfileModel({required this.user, required this.settings});

  factory ProfileModel.fromJson(Map<String, dynamic> parsedJson) {
    return ProfileModel(
        user: User.fromJSon(parsedJson['user']),
        settings: UserSettings.fromJson(parsedJson['settings'])
    );
  }
}
class User {
  final int id;
  final String first_name;
  final String last_name;
  final String email;
  final String location_locality;
  final int is_visible;
  final String country;
  final String state;
  final String city;
  final String pincode;
  final String image_path;
  final String image_avatar_path;
  final String image_blob;
  final String latitude;
  final String longitude;
  final int distance_margin;
  final String distance_unit;

  User(
      {required this.id,
        required this.first_name,
        required this.last_name,
        required this.email,
        required this.location_locality,
        required this.is_visible,
        required this.image_path,
        required this.image_avatar_path,
        required this.image_blob,
        required this.latitude,
        required this.longitude,
        required this.distance_margin,
        required this.distance_unit,
        required this.country,
        required this.state,
        required this.city,
        required this.pincode
      });

  factory User.fromJSon(Map<String, dynamic> parsedJson) {
    return User(
        id: parsedJson['id']?? 0,
        first_name: parsedJson['first_name']??'',
        last_name: parsedJson['last_name']??'',
        email: parsedJson['email']??'',
        location_locality: parsedJson['location_locality']??'',
        is_visible: parsedJson['is_visible'] ?? 1,
        image_path: parsedJson['image_path']??'',
        image_avatar_path:parsedJson['image_avatar_path']??'',
        longitude: parsedJson['longitude']??'',
        latitude: parsedJson['latitude']??'',
        distance_margin: parsedJson['distance_margin']??0,
        distance_unit: parsedJson['distance_unit']??'',
        city: parsedJson['city']??'', //The ‘??’ can replace the null check.
        state: parsedJson['state']??'',
        pincode: parsedJson['pincode']??'',
        country: parsedJson['country']??'',
        image_blob:parsedJson['image_blob']??''
    );
  }
}
class UserSettings {
  final List<ReportRadioMessage> report_radio_message;
  final List<SliderMinMax> slider_min_max;
  final List<AddImages> add_images;


  UserSettings({required this.report_radio_message,required this.slider_min_max,required this.add_images});

  factory UserSettings.fromJson(Map<String, dynamic> parsedJson)
  {
    var sliderlist=parsedJson['slider_min_max'] as List;
    List<SliderMinMax> sliderMinMaxList=sliderlist.map((i) => SliderMinMax.fromJson(i)).toList();
    var list=parsedJson['report_radio_message'] as List;
    List<ReportRadioMessage> reportRadioList=list.map((i) => ReportRadioMessage.fromJson(i)).toList();
    var addImages=parsedJson['add_images'] as List;
    List<AddImages> addImagesList=addImages.map((i) => AddImages.fromJson(i)).toList();
    return UserSettings(
        report_radio_message: reportRadioList,
        slider_min_max: sliderMinMaxList,
        add_images: addImagesList
    );
  }
}

class AddImages
{
  final String value;

  AddImages({required this.value});

  factory AddImages.fromJson(Map<String, dynamic> parsedjson)
  {
    return AddImages(value: parsedjson['value']);
  }
}

class ReportRadioMessage {
 // final int report_msg_id;
  final String message;

  ReportRadioMessage({required this.message});

  factory ReportRadioMessage.fromJson(Map<String, dynamic> parsedJson)
  {
    return ReportRadioMessage(
        message: parsedJson['message']
    );
  }
}
class SliderMinMax
{
  final String value;

  SliderMinMax({required this.value});

  factory SliderMinMax.fromJson(Map<String, dynamic> parsedJson)
  {
    return SliderMinMax(
        value: parsedJson['value']
    );
  }
}

