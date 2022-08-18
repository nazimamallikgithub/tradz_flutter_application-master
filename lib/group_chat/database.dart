import 'package:cloud_firestore/cloud_firestore.dart';
class  OurDatabase{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> createGroup(String groupName,String userUid) async{
    String retVal= "error";
    List<String> members = [];

    try {
      members.add(userUid);
      DocumentReference _docRef =
      await _firestore.collection("group").add({
         'name':groupName,
        'leader':userUid,
        'members':members,
        'groupCreate': Timestamp.now(),
      });

      await _firestore.collection("users").doc(userUid).update({
       // 'groupId':_docRef.documentID,
        'groupId':_docRef.id,
       // 'groupId':groupName,
      });
      retVal= "success";
    }catch(e){
      print(e);
    }
    return retVal;
  }
}