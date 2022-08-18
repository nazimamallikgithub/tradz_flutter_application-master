
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class HomeProfile extends StatefulWidget {
  static const routeName="home";
  const HomeProfile({Key? key}) : super(key: key);

  @override
  State<HomeProfile> createState() => _HomeProfileState();
}

class _HomeProfileState extends State<HomeProfile> {
  double heightRow = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Members"),
        centerTitle: true,
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot>snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) =>
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child:
                        ListTile(

                            leading: Text(snapshot.data!.docs[index]["name"]),
                            title:Text(snapshot.data!.docs[index]["email"]),
                            trailing:OutlinedButton.icon(
                                onPressed: () async{
                                  await deleteRecord(
                                      snapshot.data!.docs[index].id);
                                },
                                icon: Icon(Icons.delete,
                                  color: Colors.black,
                                ),
                                label: Text("Delete")
                            )
                        ),

                      ),
                    ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),


    );
  }

  deleteRecord( id) async{
    FirebaseFirestore.instance.collection('users').doc(id).delete();

    Fluttertoast.showToast(msg: "Deleted");
  }
}