import 'package:flutter/material.dart';
class UserProductModel
{
  final Products products;

  UserProductModel({required this.products});

  factory UserProductModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return UserProductModel(
        products: Products.fromJson(parsedJson['products'])
    );
  }
}
class Products
{
  final List<UserProductData> data;

  Products({required this.data});

  factory Products.fromJson(Map<String, dynamic> parsedJson)
  {
    var list=parsedJson['data'] as List;
    List<UserProductData> dataList=list.map((i) => UserProductData.fromJson(i)).toList();
    return Products(
      data: dataList
    );
  }
}

class UserProductData
{
  final int id;
  final int user_id;
  final String title;
   final String description;
   final int price;
   final int category_id;
   final int sub_category_id;
   final String status;
   final String looking_for;
   final int is_visible;
   final int is_traded;
   final int likes_count;
   final CategoryDetails category_details;
   final SubCategoryDetails sub_category_details;
   final UserDetails user_details;
  final List<String> base_64_images;
  final List<String> original_images;

  UserProductData(
      {
        required this.id,
        required this.user_id,
        required this.title,
        required this.description,
        required this.price,
        required this.category_id,
        required this.sub_category_id,
        required this.status,
        required this.looking_for,
        required this.is_visible,
        required this.is_traded,
        required this.likes_count,
        required this.category_details,
        required this.sub_category_details,
        required this.user_details,
        required this.base_64_images,
        required this.original_images,
      }
      );
  factory UserProductData.fromJson(Map<String, dynamic> parsedJson)
  {
    return UserProductData(id: parsedJson['id'] as int,
        user_id: parsedJson['user_id'] as int,
        title: parsedJson['title']??'',
        description: parsedJson['description']??'',
        price: parsedJson['price'] as int,
        looking_for:parsedJson['looking_for']??'',
        category_id: parsedJson['category_id'] as int,
        sub_category_id: parsedJson['sub_category_id'] as int,
        status: parsedJson['status']??'',
        is_visible: parsedJson['is_visible'] as int,
        is_traded: parsedJson['is_traded'] as int,
        likes_count:parsedJson['likes_count'] as int,
        category_details: CategoryDetails.fromJson(parsedJson['category_details']),
        sub_category_details: SubCategoryDetails.fromJson(parsedJson['sub_category_details']),
        user_details: UserDetails.fromJson(parsedJson['user_details']),
        base_64_images: parsedJson['base_64_images'].cast<String>(),
      original_images:parsedJson['original_images'].cast<String>()
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
      image_b64: parsedJson['image_b64']??''
    );
  }
}