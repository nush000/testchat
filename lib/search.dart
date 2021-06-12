import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget{
  _Search createState() => _Search();
}

double w;
String userId;

class _Search extends State<Search>{
  Widget appBarTitle = new Text("Search");
  Icon actionIcon = new Icon(Icons.search);

  getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userId = sharedPreferences.getString('id');
  }

  @override
  Widget build(BuildContext context) {

    w = MediaQuery.of(context).size.width;

    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title:appBarTitle,
          actions: <Widget>[
            new IconButton(icon: actionIcon,
              onPressed:(){
                setState(() {
                  if (this.actionIcon.icon == Icons.search){
                    this.actionIcon = new Icon(Icons.close);
                    this.appBarTitle = new TextField(
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),
                      decoration: new InputDecoration(
                          prefixIcon: new Icon(Icons.search,color: Colors.white),
                          hintText: "Search username...",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: new TextStyle(color: Colors.white),

                      ),
                    );}
                  else {
                    this.actionIcon = new Icon(Icons.search);
                    this.appBarTitle = new Text("Search");
                  }
                });
              },
            ),
          ]
      ),


      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots().where((event) => true),
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

  buildItem(doc) {
    return (userId != doc.data()['id'])
        ? GestureDetector(
        onTap: () {

        },
        child: Column(
          children: [
            SizedBox(
              height: 1,
            ),
            Row(
              children: [
                Container(
                    color: Colors.black,
                    width: w * 0.85,
                    height: 60,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text(doc['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        )
                    ),
                ),
                Container(
                  color: Colors.black,
                  height: 60,
                  child: IconButton(
                    splashColor: Colors.black,
                    iconSize: 40,
                    icon: Icon(Icons.add_box_rounded),
                    color: Colors.white,
                    onPressed: (){
                      FirebaseFirestore.instance
                          .collection("friends")
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .collection("friends")
                          .doc(doc['id']).set({
                        "name" : doc['name'],
                        "id" : doc['id'],
                      });
                    },
                  ),
                ),
              ],
            )
          ],
        )
    )
        : Container();
  }

}

