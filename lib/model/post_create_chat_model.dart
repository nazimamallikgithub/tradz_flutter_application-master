class PostCreateChatModel
{
  final String first_user;
  final String second_user;
  final int product_id;

  PostCreateChatModel({required this.first_user,required this.second_user,required this.product_id});

  factory PostCreateChatModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return PostCreateChatModel(
        first_user: parsedJson['first_user'],
        second_user: parsedJson['second_user'],
        product_id:parsedJson['product_id']
    );
  }

  Map toMap()
  {
    var map=<String,dynamic>{};
    map['first_user']=first_user;
    map['second_user']=second_user;
    map['product_id']=product_id.toString();
    return map;
  }

}