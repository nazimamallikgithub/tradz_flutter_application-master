class NotificationModel
{
  final bool status;
  final String Message;
  final Notifications notifications;

  NotificationModel({required this.status,required this.Message,required this.notifications});

  factory NotificationModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return NotificationModel(
      status: parsedJson['status']??false,
      Message: parsedJson['Message']??'',
      notifications: Notifications.fromJson(parsedJson['notifications'])
    );
  }
}
class Notifications
{
  final List<Data> data;

  Notifications({required this.data});
  factory Notifications.fromJson(Map<String, dynamic> parsedJSon)
  {
    var list=parsedJSon['data'] as List;
    List<Data> dataList=list.map((i) => Data.fromJson(i)).toList();
    return Notifications(
        data: dataList
    );
  }
}

class Data {
  final int id;
  final String like_type;
  final int first_like_id;
  final String message_text;
  final int send_by_user_id;
  final int liked_product_id;
  final String created_at;
  final String updated_at;
  final List<String> base64_images;
  final List<String> original_images;
  final UserDetails user_details;
  final MyProductDetails my_product_details;

  Data(
      {required this.id,
        required this.like_type,
        required this.first_like_id,
        required this.message_text,
        required this.send_by_user_id,
        required this.liked_product_id,
        required this.created_at,
        required this.updated_at,
        required this.base64_images,
        required this.original_images,
        required this.user_details,
        required this.my_product_details
      }
      );

  factory Data.fromJson(Map<String, dynamic> parsedJson)
  {
    return Data(
        id: parsedJson['id'],
        like_type: parsedJson['like_type']??'',
        first_like_id: parsedJson['first_like_id'],
        message_text:parsedJson['message_text']??'',
        send_by_user_id: parsedJson['send_by_user_id'],
        liked_product_id: parsedJson['liked_product_id'],
        created_at: parsedJson['created_at']??'',
        updated_at: parsedJson['updated_at']??'',
        base64_images: parsedJson['base64_images'].cast<String>(),
        original_images:parsedJson['original_images'].cast<String>(),
      user_details: UserDetails.fromJson(parsedJson['user_details']),
        my_product_details:MyProductDetails.fromJson(parsedJson['my_product_details'])
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
  final String image_blob;

  UserDetails(
      {required this.id,
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
        required this.image_blob
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
        image_blob:parsedJson['image_blob']??''
    );
  }
}

class MyProductDetails{
  final int id;
  final user_id;
  final String title;
  final String description;
  final int price;
  final int category_id;
  final int sub_category_id;
  final String status;
  final int is_visible;
  final int is_traded;
  final String created_at;
  final String updated_at;

  MyProductDetails(
      {
        required this.id,
        required this.user_id,
        required this.title,
        required this.description,
        required this.price,
        required this.category_id,
        required this.sub_category_id,
        required this.status,
        required this.is_visible,
        required this.is_traded,
        required this.created_at,
        required this.updated_at
      }
      );
  factory MyProductDetails.fromJson(Map<String, dynamic> parsedJson)
  {
    return MyProductDetails(
        id: parsedJson['id']as int,
        user_id: parsedJson['user_id']as int,
        title: parsedJson['title']??'',
        description: parsedJson['description']??'',
        price: parsedJson['price'] as int,
        category_id: parsedJson['category_id']as int,
        sub_category_id: parsedJson['sub_category_id']as int,
        status: parsedJson['status']??'',
        is_visible: parsedJson['is_visible']as int,
        is_traded: parsedJson['is_traded']as int,
        created_at: parsedJson['created_at']??'',
        updated_at: parsedJson['updated_at']??'');
  }
}