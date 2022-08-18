import 'package:flutter/material.dart';
class ProductDetailsModel
{
  final bool status;
  final String message;
  final Data data;
  final int is_liked;
  final int is_active_chat;
  final int total_likes;


  ProductDetailsModel({required this.status,required this.message,required this.data,required this.is_liked,required this.is_active_chat,required this.total_likes});

  factory ProductDetailsModel.fromJson(Map<String,dynamic> parsedJson)
  {
    return ProductDetailsModel(
        status: parsedJson['status']??false,
        message: parsedJson['message']??'',
        data: Data.fromJSon(parsedJson['data']),
        is_liked: parsedJson['is_liked']??0,
        is_active_chat: parsedJson['is_active_chat']??0,
        total_likes: parsedJson['total_likes']??0
    );
  }
}
class Data
{
  final int id;
  final user_id;
  final String title;
  final String description;
  final String looking_for;
  final int price;
  final int category_id;
  final int sub_category_id;
  final String status;
  final int is_traded;
  final List<String> base_64_images;
  final List<String> original_images;
  final UserDetails user_details;
  final CategoryDetails? category_details;
  final SubCategoryDetails? sub_category_details;
  final int distance;
  final String image_b64;

  Data(
      {required this.id,
        required this.user_id,
        required this.title,
        required this.description,
        required this.looking_for,
        required this.price,
        required this.category_id,
        required this.sub_category_id,
        required this.status,
        required this.is_traded,
        required this.base_64_images,
        required this.user_details,
        required this.category_details,
        required this.sub_category_details,
        required this.distance,
        required this.image_b64,
        required this.original_images

      }
      );
  factory Data.fromJSon(Map<String, dynamic> parsedJson)
  {
    return Data(
        id: parsedJson['id'],
        user_id: parsedJson['user_id'],
        title: parsedJson['title']??'',
        looking_for:parsedJson['looking_for']??'',
        description: parsedJson['description']??'',
        price: parsedJson['price']??0,
        category_id: parsedJson['category_id']??0,
        sub_category_id: parsedJson['sub_category_id']??0,
        status: parsedJson['status']??'',
        is_traded: parsedJson['is_traded']??0,
        base_64_images: parsedJson['base_64_images'].cast<String>(),
      original_images: parsedJson['original_images'].cast<String>(),
      user_details: UserDetails.fromJson(parsedJson['user_details']),
      category_details: CategoryDetails.fromJson(parsedJson['category_details']),
      sub_category_details: SubCategoryDetails.fromJson(parsedJson['sub_category_details']),
        distance: parsedJson['distance'] ??0,
        image_b64:parsedJson['image_b64']??''
    );
  }
}
class UserDetails
{
  final int id;
  final String first_name;
  final String last_name;
  final String email;
  final String location_locality;
  final String mobile_no;
  final int is_visible;
  final String image_path;
  final String image_avatar_path;
  final String status;
  final String profile_type;
  final String social_profile_id;
  final String distance_unit;
  final int distance_margin;
  final String image_b64;

  UserDetails(
      {
        required this.id,
        required this.first_name,
        required this.last_name,
        required this.email,
        required this.location_locality,
        required this.mobile_no,
        required this.is_visible,
        required this.image_path,
        required this.image_avatar_path,
        required this.status,
        required this.profile_type,
        required this.social_profile_id,
        required this.distance_unit,
        required this.distance_margin,
        required this.image_b64
      });

  factory UserDetails.fromJson(Map<String, dynamic> parsedJson)
  {
    return UserDetails(
        id: parsedJson['id'] as int,
        first_name: parsedJson['first_name']??'',
        last_name: parsedJson['last_name']??'',
        email: parsedJson['email']??'',
        location_locality: parsedJson['location_locality']??'',
        mobile_no: parsedJson['mobile_no']??'',
        is_visible: parsedJson['is_visible'] as int,
        image_path: parsedJson['image_path']??'',
        image_avatar_path: parsedJson['image_avatar_path']??'',
        status: parsedJson['status']??'',
        profile_type: parsedJson['profile_type']??'',
        social_profile_id: parsedJson['social_profile_id']??'',
        distance_unit: parsedJson['distance_unit']??'',
        distance_margin:parsedJson['distance_margin'] as int,
        image_b64:parsedJson['image_b64']??''
    );
  }
}

class CategoryDetails
{
  final int id;
  final String text;

  CategoryDetails({
    required this.id,
    required this.text
  });

  factory CategoryDetails.fromJson(Map<String, dynamic> parsedJson)
  {
    return CategoryDetails(
        id: parsedJson['id'] as int,
        text: parsedJson['text']??''
    );
  }
}

class SubCategoryDetails
{
  final int id;
  final String text;

  SubCategoryDetails(
      {
        required this.id,
        required this.text
      }
      );

  factory SubCategoryDetails.fromJson(Map<String, dynamic> parsedJson)
  {
    return SubCategoryDetails(
        id: parsedJson['id'] as int,
        text: parsedJson['text']??''
    );
  }
}