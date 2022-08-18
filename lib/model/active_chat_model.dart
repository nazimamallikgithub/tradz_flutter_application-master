class ActiveChatModel
{
  final bool status;
  final List<ActiveChat> active_chats;

  ActiveChatModel({required this.status,required this.active_chats});

  factory ActiveChatModel.fromJson(Map<String, dynamic> parsedJson)
  {
    var list=parsedJson['active_chats'] as List;
    List<ActiveChat> activeChatList=list.map((i) => ActiveChat.fromJson(i)).toList();
    return ActiveChatModel
      (
        status: parsedJson['status']??false,
        active_chats: activeChatList
      );
  }
}

class ActiveChat
{
  final String social_profile_id;
  final int id;

  ActiveChat({required this.social_profile_id, required this.id});
  factory ActiveChat.fromJson(Map<String, dynamic> parsedJson)
  {
    return ActiveChat(
        social_profile_id: parsedJson["social_profile_id"]??'',
        id: parsedJson["id"]??0
    );
  }
}
