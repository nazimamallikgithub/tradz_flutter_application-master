class FirebaseUserDetails{
  final String email;
  final List<String> blocked_by;
  final List<String> blocked_user;
  final String nickName;

  FirebaseUserDetails(
      {required this.email,required this.blocked_by,required this.blocked_user,required this.nickName});

  factory FirebaseUserDetails.fromJson(Map<String, dynamic> parsedJSon)
  {
    return FirebaseUserDetails(email: parsedJSon['email']??'',
        blocked_by: parsedJSon['blocked_by'].cast??[],
        blocked_user: parsedJSon['blocked_user']??[],
        nickName: parsedJSon['nickName']??''
    );
  }
}