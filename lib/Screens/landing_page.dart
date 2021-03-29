import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nativeapp/Screens/home_page.dart';
import 'package:nativeapp/Screens/login_page.dart';
import 'package:nativeapp/constants.dart';

class LandingPage extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Container(
                child: Center(
                  child: Text("Error: ${snapshot.error}"),
                )
            ),
          );
        }

        // Connection Initialized - Firebase App is running
        if (snapshot.connectionState == ConnectionState.done) {

          // StreamBuilder can check the login state live
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, streamSnapshot){
              //If Stream Snapshot has Error
              if(streamSnapshot.hasError)
                {
                  return Scaffold(
                    body: Container(
                        child: Center(
                          child: Text("Error: ${streamSnapshot.error}"),
                        )
                    ),
                  );

                }

              //Connection State Active - Do the user login check inside the
              //if Statement
              if(streamSnapshot.connectionState == ConnectionState.active){

                //Get the User
                User _user =streamSnapshot.data;
                //print(_user.)
                //If the user is null, User is not logged in
                if(_user == null){
                  return LoginPage();
                } else {
                  return HomePage();

                }

                }

              //checking the Auth State - Loading
              return Scaffold(
                body: Container(
                    child: Center(
                      child: Text("Checking Auth", style: Constants.regularHeading,),
                    )
                ),
              );

            },
          );
        }

        // Connecting to firebase, show something whilst waiting for initialization to complete
        return Scaffold(
          body: Container(
              child: Center(
                child: Text("Initializing App...."),
              )
          ),
        );
      },
    );
  }

}