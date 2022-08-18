import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user_model.dart';

class OurGroup{
  String id;
  String name;
  String leader;
   List <String> members;
  Timestamp groupCreated;
  //final UserModel currentUser;

OurGroup({
  required this.id,
  required this.name,
  required   this.leader,
  required this.members,
  required this.groupCreated,
  //required this.currentUser,

 });
 }