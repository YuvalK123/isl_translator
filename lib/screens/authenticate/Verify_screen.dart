import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// when needs to verify email, show this widget
class VerifyScreen extends StatefulWidget {
  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _auth = FirebaseAuth.instance;
  User user;
  Timer timer;

  @override
  void initState() {
    user = _auth.currentUser;
    user.sendEmailVerification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("An email has been sent to ${user.email}.\n please verify.",
        textAlign: TextAlign.center,),
      ),
    );
  }

  @override
  void dispose(){
    super.dispose();
  }

}
