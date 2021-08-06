import 'sign_in.dart';
import 'register.dart';
import 'package:flutter/material.dart';

/// authenticate pages wrapper
class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  // if in signIn page, show true
  bool showSignIn = true;

  /// toggle between signIn to register pages
  void toggleView(){
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn ?
    SignIn(toggleView: toggleView) : Register(toggleView: toggleView);
  }
}
