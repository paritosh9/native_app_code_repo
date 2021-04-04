import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nativeapp/Screens/login_page.dart';

import '../constants.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          return Scaffold(
            body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Home Page",
                      style: Constants.regularHeading,
                    ),
                    SizedBox(height: 8),
                    CircleAvatar(
                      maxRadius: 25,
                      backgroundImage: NetworkImage(data['photoUrl']),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Name: ${data['Name']}",
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email: ' + user.email,
                      style: TextStyle(color: Colors.black),
                    ),
                    //SizedBox(height: 8),



                    FlatButton(
                      child: Text("Logout"),
                      onPressed: (){
                        googleSignIn.disconnect();
                        FirebaseAuth.instance.signOut();
                      },
                    )
                  ]
              ),
            ),
          );
          //return Text("Full Name: ${data['Name']} ${data['last_name']}");

        }

        return Scaffold();
      },
    );
  }
}
