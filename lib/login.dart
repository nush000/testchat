
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testchat/signUp.dart';

import 'chats.dart';


class Login extends StatefulWidget{
  @override
  _LoginState createState() => _LoginState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
bool canLogin;
class _LoginState extends State<Login> {


  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _emailc = TextEditingController();
  TextEditingController _passwordc = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Scaffold(
        body: Form(
            key: _key,
            child:SingleChildScrollView(
              child:Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    margin: EdgeInsets.fromLTRB(0, 90, 0, 50),
                    height: 70,
                    width: 250,
                    child: Text(
                      "Testchat", style: TextStyle(fontSize: 60, color: Colors.lightBlueAccent),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.fromLTRB(145, 5, 80, 20),
                    height: 50,
                    width: 250,
                    child: Text(
                      "Login", style: TextStyle(fontSize: 40),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(3.0),
                    height: 60,
                    width: 300,
                    child: TextFormField(
                      controller: _emailc,
                      style: TextStyle(
                        fontSize: 20
                      ),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Email",
                      ),
                      onEditingComplete: () => node.nextFocus(),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Container(
                    margin: EdgeInsets.all(3.0),
                    height: 60,
                    width: 300,
                    child: TextFormField(
                      controller: _passwordc,
                      style: TextStyle(
                          fontSize: 20
                      ),
                      autofocus: false,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Password",
                      ),
                      onFieldSubmitted: (_) => node.unfocus(),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },

                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  TextButton(onPressed: () async {
                    signIn(_emailc.text, _passwordc.text);
                    },
                    child: Text("Login", style: TextStyle(fontSize: 20),),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  Container(
                    height: 50,
                    width: 250,
                    child: TextButton(onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Signup()),
                      );
                    },
                    child: Text("Don't have an account? Sign up here"),
                    ),
                  ),
                ],

              ),
            )
        )
    );
  }

//Checks if user exists or not
  void signIn(emailS, passwordS)async{

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    final User user = (await _auth.signInWithEmailAndPassword(email: emailS, password: passwordS)).user;


    if (user.uid != null){
      setState((){
        canLogin = true;
      }
      );
    }
    else
      setState((){
        canLogin = false;
      });
    if(canLogin == true){
      _emailc.clear();
      _passwordc.clear();

      final result = (await FirebaseFirestore.instance.collection("users").where("id", isEqualTo: user.uid).get()).docs;
      if(result.length == 0){
        FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "id": user.uid,
          "name": FirebaseAuth.instance.currentUser.displayName,
          "email": user.email,
          "createdAt": DateTime.now().millisecondsSinceEpoch,
        });
      }

      sharedPreferences.setString("id", user.uid);
      sharedPreferences.setString("username", user.displayName);
      sharedPreferences.setString("email", user.email);

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          Chats()), (Route<dynamic> route) => false);
    }
  }

}


