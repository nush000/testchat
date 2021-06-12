import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testchat/login.dart';
import 'package:testchat/search.dart';

import 'chatPage.dart';



String userId;

class Chats extends StatefulWidget{
  _Chats createState() => _Chats();
}

class _Chats extends State<Chats> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Chats",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
          backgroundColor: Colors.black,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Search()));
                }
            ),

            IconButton(
                icon: Icon(Icons.camera_alt_outlined),
                onPressed: () {}
            )
          ],
        ),


        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "Hey, ${FirebaseAuth.instance.currentUser.displayName}",
                            style: TextStyle(fontSize: 30),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("View profile"),
                        ],
                      ),
                    ),
                  )
              ),
              ListTile(
                title: Text("Delete account"),
                onTap: () {
                  deleteAccount();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) =>
                          Login()), (Route<dynamic> route) => false);
                },
              ),
              ListTile(
                title: Text("Log out"),
                onTap: () {
                  logOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) =>
                          Login()), (Route<dynamic> route) => false);
                },
              )

            ],
          ),
        ),


        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("friends").doc(FirebaseAuth.instance.currentUser.uid).collection("friends").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView.builder(
                itemBuilder: (listContext, index) =>
                    buildItem(snapshot.data.docs[index]),
                itemCount: snapshot.data.docs.length,
              );
            }
            return Container();
          },
        ),
    );
  }

  buildItem(final doc) {
    return (userId != doc.data()['id'])
        ? GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(docs: doc)));
        },
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Container(
              color: Colors.black,
              height: 60,
              child: Center(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(doc['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      )
                  )
              ),
            ),
          ],
        )
    )
        : Container();
  }


  deleteAccount() async {
    await FirebaseFirestore.instance.collection("friends").doc(FirebaseAuth.instance.currentUser.uid).delete();
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).delete();
    await FirebaseAuth.instance.currentUser.delete();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  logOut()async{
    FirebaseAuth.instance.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  getName()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String username = sharedPreferences.getString("username").toString();
    return username;
  }
}