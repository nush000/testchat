import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chats.dart';



class Signup extends StatefulWidget{
  @override
  _SignupState createState() => _SignupState();
}



class _SignupState extends State<Signup>{


  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController emailc = TextEditingController();
  TextEditingController passwordc = TextEditingController();
  TextEditingController usernamec = TextEditingController();


  @override
  Widget build(BuildContext context) {

    final node = FocusScope.of(context);
    return Scaffold(
        body: Form(
            key: _key,
            child:SingleChildScrollView (
              child:Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 50, 350, 10),
                    height: 50,
                    width: 50,
                    child: Center(
                        child:IconButton(
                          iconSize: 35,
                          icon: Icon(Icons.arrow_back),
                          color: Colors.blue,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                    ),
                  ),

                  Container(
                    height: 50,
                    width: 250,
                    child: Center(
                      child: Text(
                        "Sign up", style: TextStyle(fontSize: 40),
                      ),
                    )
                  ),

                  SizedBox(
                    height: 50,
                  ),

                  Container(
                    height: 60,
                    width: 300,
                    child: TextFormField(
                      style: TextStyle(
                          fontSize: 20
                      ),
                      controller: emailc,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Email"
                      ),
                      onEditingComplete: () => node.nextFocus(),

                      validator: (String value) {
                        if (value.isEmpty) {
                          return ;
                        }
                        return null;
                      },

                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  Container(
                    height: 60,
                    width: 300,
                    child: TextFormField(
                      style: TextStyle(
                          fontSize: 20
                      ),
                      controller: usernamec,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "User Name"
                      ),
                      inputFormatters: [LowerCaseTextFormatter()],
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
                    height: 60,
                    width: 300,
                    child: TextFormField(
                      style: TextStyle(
                          fontSize: 20
                      ),
                      controller: passwordc,
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
                    register(emailc.text, usernamec.text, passwordc.text);
                  }, child: Text("Register", style: TextStyle(fontSize: 20),),
                  ),
                ],

              ),
            )
        )

    );

  }


//Registers new user
  void register(emailR, usernameR, passwordR) async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    final User user = (await
    _auth.createUserWithEmailAndPassword(
      email: emailR,
      password: passwordR,
    )
    ).user;
    await user.updateProfile(displayName: usernameR);

    emailc.clear();
    passwordc.clear();
    usernamec.clear();


      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "id": user.uid,
        "name": usernameR,
        "email": user.email,
        "created_at": DateTime.now().millisecondsSinceEpoch,
      });


    sharedPreferences.setString("id", "");
    sharedPreferences.setString("username", usernameR);
    sharedPreferences.setString("email", user.email);


    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        Chats()), (Route<dynamic> route) => false);
  }


  @override
  void dispose() {
    emailc.dispose();
    passwordc.dispose();
    super.dispose();
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

