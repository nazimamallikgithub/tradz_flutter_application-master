
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tradz/allConstants/FirestoreConstants.dart';
class  HomeProvider
{
  final FirebaseFirestore firebaseFirestore;
  HomeProvider({
    required this.firebaseFirestore
});

  Future<void> updateFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate)
  {
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  Future<void> deleteUserFireStore(String collectionPath,String currentUserID)
  {
    return firebaseFirestore.collection(collectionPath).doc(currentUserID).delete();
  }


  
  Future<void> deleteMessageFireStore(String collectionPath,String currentUserID)
  {
    return  firebaseFirestore.collection(collectionPath).get().then((value){
      print("The value get from $collectionPath collection is ${value.docs}");
      var deleteableItem='';
      for (var element in value.docs) {
        print("the id get is ${element.id}");
        if(element.id.contains(currentUserID))
          {
            deleteableItem=element.id;
            print("The id matched is $deleteableItem");
            break;
          }
      }
    });
  }

  Stream<QuerySnapshot> getStreamFireStore(String pathCollection, int limit, String? textSearch)
  {
    if(textSearch?.isNotEmpty==true)
    {
      return firebaseFirestore.collection(pathCollection).limit(limit)
          .where(FirestoreConstants.nickname, isEqualTo: textSearch).snapshots();
    }
    else
    {
      return firebaseFirestore.collection(pathCollection).limit(limit).snapshots();
    }
  }
}