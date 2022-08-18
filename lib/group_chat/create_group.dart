
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../allConstants/FirestoreConstants.dart';

import 'database.dart';
import 'package:tradz/allProvider/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:/flutter/src/widgets/framework.dart';


class CreateGroup extends StatefulWidget {
  const CreateGroup({ Key? key}) : super(key: key);
  @override
  State<CreateGroup> createState() => _CreateGroupState();
 }

class _CreateGroupState extends State<CreateGroup> {
 // FirebaseAuth _currentUser = Provider.of<FirebaseAuth.User>(context,listen:false);
  void _createGroup(BuildContext context, String groupName) async {
    CurrentUser  _currentUser = Provider.of<CurrentUser>(context,listen:false);
    String _returnString = await OurDatabase().createGroup(
        groupName, _currentUser.getCurrentUser.Uid);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CreateGroup(),
        ),
            (route) => false);
  }



  TextEditingController _groupNameController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Group Name"),
      ),
      body: isLoading
          ? Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          SizedBox(
            height: size.height / 10,
          ),
          Container(
            height: size.height / 14,
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              height: size.height / 14,
              width: size.width / 1.15,
              child: TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: "Enter Group Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: size.height / 50,
          ),
          ElevatedButton(
            onPressed: ()=>_createGroup(context,_groupNameController.text),
            child: Text("Create Group"),
          ),
        ],
      ),
    );
  }
}

class CurrentUser
{
  String id;

  CurrentUser(
      { required this.id});

  get getCurrentUser => id;



  Map<String, String> toJson(){
    return
      {
        FirestoreConstants.id:id,
      };
  }

  factory CurrentUser.fromDocument(DocumentSnapshot doc)
  {
    try{
       doc.get(FirestoreConstants.id);
    }catch(e){
    }

    return CurrentUser(id: doc.id);
  }
 }
