class PostBlockUserModel
{
  final String social_profile_id;
  final String reason;

  PostBlockUserModel({required this.social_profile_id,required this.reason});

  factory PostBlockUserModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return PostBlockUserModel
      (
        social_profile_id: parsedJson['social_profile_id'],
        reason: parsedJson['reason']
    );
  }

  Map toMap()
  {
    var map = <String, dynamic>{};
    map['social_profile_id']=social_profile_id;
    map['reason']=reason;
    return map;
  }

}