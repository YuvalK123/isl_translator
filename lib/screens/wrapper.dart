import 'dart:async';
import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/authenticate/authenticate.dart';
import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Check if terms is loaded
bool hasLoaded = false;

/// Wrapper class
class Wrapper extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: authService.user,
        builder: (BuildContext context, AsyncSnapshot snapShot) {
          if (snapShot.hasData && (!snapShot.hasError)) {
            UserModel currUser = snapShot.data;
            if (currUser != null &&
                (currUser.emailVerified || _auth.currentUser.isAnonymous)) {
              return TranslationWrapper();
            }
          }
          return Authenticate();
        }
    );
  }

  /// Load terms from firebase
  Future<void> saveTermsForShow() async{
    if (hasLoaded){
      return;
    }
    hasLoaded = true;
  }
}
