import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

    timer = Timer.periodic(Duration(seconds: 5), (timer) {

    });

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
    if (timer.isActive) timer.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerify() async {
    var user = _auth.currentUser;
    await user.reload();
    if (user.emailVerified){
      timer.cancel();
      // verified
    }
  }

}
