import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nativeapp/Screens/home_page.dart';
import 'package:nativeapp/Widgets/custom_btn.dart';
import 'package:nativeapp/Widgets/custom_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  FirebaseFirestore Firestore = FirebaseFirestore.instance;

  //Default Loading State
  bool _registerFormLoading = false;

  //Input Fields Values
  String _registerName = "";
  String _registerEmail = "";
  String _registerPassword = "";

  FocusNode _passwordFocusNode;

  //Todo: Create Focus Node for email too
  @override
  void initState(){
    super.initState();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose(){
    super.dispose();
    _passwordFocusNode.dispose();
  }

  //Alert Dialog to display Errors
  Future<void> _alertDialogueBuilder(String error) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Container(
            child: Text(error),
          ),
          actions: [
            FlatButton(
              child: Text("Close Dialog"),
              onPressed: (){
              Navigator.pop(context);
            }
        )
        ],
        );
        }
        );
      }

  Future<String> _createAccount() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _registerEmail, password: _registerPassword)
          .then((currentUser) => Firestore
          .collection("users")
          .doc(currentUser.user.uid)
          .set({
        "uid": currentUser.user.uid,
        "Name": _registerName,
        "email": _registerEmail,
        "photoUrl": "https://i.pinimg.com/736x/3f/94/70/3f9470b34a8e3f526dbdb022f9f19cf7.jpg"
      }));
      //


      await FirebaseAuth.instance.currentUser.updateProfile(displayName: _registerName,photoURL: "https://i.pinimg.com/736x/3f/94/70/3f9470b34a8e3f526dbdb022f9f19cf7.jpg");
      return null;
    } on FirebaseAuthException catch (e){
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message;
    }
    catch(e){
      print(e.toString());
    }
  }

  void _submitForm() async
  {
      setState(() {
        //Create Account is in loading state
        _registerFormLoading = true;
      });
      String _createAccountFeedback = await _createAccount();
      if(_createAccountFeedback != null){
        _alertDialogueBuilder(_createAccountFeedback);

        setState(() {
          //Stop loading and set form to regular state
          _registerFormLoading = false;
        });

      }else{
        //If feedback was null, user account created, head back to landingPage

        Navigator.pop(context);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Container(
                  padding: EdgeInsets.only(
                    top: 24.0,
                  ),
                  child: Text(
                    "Create New Account",
                    textAlign: TextAlign.center,
                    style: Constants.boldHeading,
                  )
              ),

              Column(
                children: [
                  CustomInput(
                    hintText: "Enter Full Name",
                    onChanged: (value){
                      _registerName = value;
                    },

                  ),
                  CustomInput(
                    hintText: "Enter Email",
                    onChanged: (value){
                      _registerEmail = value;
                    },
                    onSubmitted: (value){
                      _passwordFocusNode.requestFocus();
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  CustomInput(
                    hintText: "Enter Password",
                    onChanged: (value){
                      _registerPassword = value;
                    },
                    focusNode: _passwordFocusNode,
                    isPasswordField: true,
                    onSubmitted: (value){
                      _submitForm();
                    },
                  ),
                  CustomBtn(
                    text: "Create Account",
                    onPressed: (){
                      //_alertDialogueBuilder();
                      _submitForm();
                    },
                    isLoading: _registerFormLoading,
                  )
                ],
              ),
              CustomBtn(text:"Back to Login",
                onPressed: () {
                  Navigator.pop(context);
                },
                outlineBtn: true,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
