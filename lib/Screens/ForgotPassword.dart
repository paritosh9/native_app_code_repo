import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nativeapp/Widgets/custom_btn.dart';
import 'package:nativeapp/Widgets/custom_input.dart';

import '../constants.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  String _forgotEmail = "";
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
        child: Container(
        width: double.infinity,
        child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: 200.0,
                ),
                child: Text(
                  "Reset Password",
                  textAlign: TextAlign.center,
                  style: Constants.boldHeading,
                ),
              ),
              CustomInput(
                hintText: "Email...",
                onChanged: (value) {
                  _forgotEmail = value;
                }
              ),
              CustomBtn(
                text: "Reset Password",
                onPressed: () {
                  submit();
                  Navigator.of(context).pop();
                },
              ),
        ],
        ),


    ),
    ),
    );
  }

  void submit() async{
    await _firebaseAuth.sendPasswordResetEmail(email: _forgotEmail);
  }
}
