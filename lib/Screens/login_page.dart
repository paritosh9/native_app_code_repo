import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nativeapp/Screens/home_page.dart';
import 'package:nativeapp/Screens/register_page.dart';
import 'package:nativeapp/Widgets/GoogleSignupButtonWidget.dart';
import 'package:nativeapp/Widgets/custom_btn.dart';
import 'package:nativeapp/Widgets/custom_input.dart';
import 'package:nativeapp/constants.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


FirebaseAuth auth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  FirebaseFirestore Firestore = FirebaseFirestore.instance;

  Future<void> _alertDialogBuilder(String error) async {
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
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  FacebookLogin facebookLogin = FacebookLogin();

  Future<void> handleLogin() async {
    final FacebookLoginResult result = await facebookLogin.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
      case FacebookLoginStatus.loggedIn:
        try {
          await loginWithfacebook(result);
        } catch (e) {
          print(e);
        }
        break;
    }
  }


  Future loginWithfacebook(FacebookLoginResult result) async {
    final FacebookAccessToken accessToken = result.accessToken;
    AuthCredential credential =
    FacebookAuthProvider.credential(accessToken.token);
    await _auth.signInWithCredential(credential)
        .then((currentUser) => Firestore
        .collection("users")
        .doc(currentUser.user.uid)
        .set({
      "uid": currentUser.user.uid,
      "Name": currentUser.user.displayName,
      "email": currentUser.user.email,
      "photoUrl": currentUser.user.photoURL
    }));

  }

  /*
  Future signInWithFacebook() async {
    // Trigger the sign-in flow
    final AccessToken result = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
    FacebookAuthProvider.credential(result.token);

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
  */


  Future googleSignInfn() async {
    bool isSigningIn = true;
    final user = await googleSignIn.signIn();
    if (user == null) {
      isSigningIn = false;
      return;
    } else {
      final googleAuth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential)
          .then((currentUser) => Firestore
          .collection("users")
          .doc(currentUser.user.uid)
          .set({
        "uid": currentUser.user.uid,
        "Name": currentUser.user.displayName,
        "email": currentUser.user.email,
        "photoUrl": currentUser.user.photoURL
      }));
      isSigningIn = false;
    }

  }







  // Create a new user account
  Future<String> _loginAccount() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _loginEmail, password: _loginPassword);
      return null;
    } on FirebaseAuthException catch(e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  void _submitForm() async {
    // Set the form to loading state
    setState(() {
      _loginFormLoading = true;
    });

    // Run the create account method
    String _loginFeedback = await _loginAccount();

    // If the string is not null, we got error while create account.
    if(_loginFeedback != null) {
      _alertDialogBuilder(_loginFeedback);

      // Set the form to regular state [not loading].
      setState(() {
        _loginFormLoading = false;
      });
    }
  }

  // Default Form Loading State
  bool _loginFormLoading = false;

  // Form Input Field Values
  String _loginEmail = "";
  String _loginPassword = "";

  // Focus Node for input fields
  FocusNode _passwordFocusNode;

  @override
  void initState() {
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
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
                  "Welcome User,\nLogin to your account",
                  textAlign: TextAlign.center,
                  style: Constants.boldHeading,
                ),
              ),
              Column(
                children: [
                  CustomInput(
                    hintText: "Email...",
                    onChanged: (value) {
                      _loginEmail = value;
                    },
                    onSubmitted: (value) {
                      _passwordFocusNode.requestFocus();
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  CustomInput(
                    hintText: "Password...",
                    onChanged: (value) {
                      _loginPassword = value;
                    },
                    focusNode: _passwordFocusNode,
                    isPasswordField: true,
                    onSubmitted: (value) {
                      _submitForm();
                    },
                  ),
                  CustomBtn(
                    text: "Login",
                    onPressed: () {
                      _submitForm();
                    },
                    isLoading: _loginFormLoading,
                  )
                ],
              ),
              Container(
                child: OutlineButton.icon(
                  label: Text(
                    'Sign In With Google',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  highlightedBorderColor: Colors.black,
                  borderSide: BorderSide(color: Colors.black),
                  textColor: Colors.black,
                  icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                  onPressed: googleSignInfn,
                ),
              ),
              Container(
                child: OutlineButton.icon(
                  label: Text(
                    'Sign In With Facebook',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  highlightedBorderColor: Colors.black,
                  borderSide: BorderSide(color: Colors.black),
                  textColor: Colors.black,
                  icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.red),
                  onPressed: handleLogin,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                ),
                child: CustomBtn(
                  text: "Create New Account",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterPage()
                      ),
                    );
                  },
                  outlineBtn: true,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}