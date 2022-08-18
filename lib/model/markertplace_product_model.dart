import 'package:flutter/material.dart';
class MarketPlaceProductModel
{
  final Items items;
  final List<int> liked_items;
  final List<int> active_chats;

  MarketPlaceProductModel({required this.items,required this.liked_items,required this.active_chats});

  factory MarketPlaceProductModel.fromJson(Map<String, dynamic> parsedJson)
  {

    return MarketPlaceProductModel(
        items: Items.fromJson(parsedJson['items']),
        liked_items: parsedJson['liked_items'].cast<int>(),
        active_chats:parsedJson['active_chats'].cast<int>()
    );
  }
}

class Items {

  final List<Data> data;

  Items({required this.data});

  factory Items.fromJson(Map<String, dynamic> parsedJson)
  {
    var list=parsedJson['data'] as List;
    List<Data> dataList=list.map((i) => Data.fromJson(i)).toList();
    return Items(
        data: dataList
    );
  }
}

class Data {
  final int id;
  final int user_id;
   String title;
  final String description;
  final String looking_for;
  final int price;
  final int category_id;
  final int sub_category_id;
  final String status;
  final int is_visible;
  final int is_traded;
  int likes_count;
  final List<String> base_64_images;
  final List<String> original_images;
  final CategoryDetails? category_details;
  final SubCategoryDetails? sub_category_details;
  final UserDetails user_details;
  bool is_liked;
  bool is_active_chat;
  final int distance;

  Data(
      {
        required this.id,
        required this.user_id,
        required this.title,
        required this.description,
        required this.looking_for,
        required this.price,
        required this.category_id,
        required this.sub_category_id,
        required this.status,
        required this.is_visible,
        required this.is_traded,
        required this.likes_count,
        required this.base_64_images,
        required this.original_images,
        required this.category_details,
        required this.sub_category_details,
        required this.user_details,
        required this.is_liked,
        required this.is_active_chat,
        required this.distance
      }
      );

  factory Data.fromJson(Map<String, dynamic> parsedJson)
  {
    return Data(
        id: parsedJson['id'] as int,
        user_id: parsedJson['user_id'] as int,
        title: parsedJson['title']??'',
        description: parsedJson['description']??'',
        looking_for:parsedJson['looking_for']??'',
        price: parsedJson['price'] as int,
        category_id: parsedJson['category_id'] as int,
        sub_category_id: parsedJson['sub_category_id'] as int,
        status: parsedJson['status']??'',
        is_visible: parsedJson['is_visible'] as int,
        is_traded: parsedJson['is_traded'] as int,
        likes_count:parsedJson['likes_count']??0,
        base_64_images: parsedJson['base_64_images'].cast<String>(),
        original_images:parsedJson['original_images'].cast<String>(),
      category_details: CategoryDetails.fromJson(parsedJson['category_details']),
      sub_category_details: SubCategoryDetails.fromJson(parsedJson['sub_category_details']),
        user_details: UserDetails.fromJson(parsedJson['user_details']),
        is_liked: parsedJson['is_liked'] as bool,
      is_active_chat: parsedJson['is_active_chat'] as bool,
      distance: parsedJson['distance'] as int
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