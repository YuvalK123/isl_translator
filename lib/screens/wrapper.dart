import 'dart:async';

import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/authenticate/authenticate.dart';

import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/auth.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:isolate';


bool hasLoaded = false;

class Wrapper extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final authService = AuthService();

  // @override
  // Widget build(BuildContext context) {
  //   final user = Provider.of<UserModel>(context);
  //   if (user != null && ((user.emailVerified || _auth.currentUser.isAnonymous))){
  //     print("user not null from wrapper $user");
  //     // if (user.emailVerified || _auth.currentUser.isAnonymous){
  //       print("from _auth ${_auth.currentUser}");
  //       // print("good save terms!!!!");
  //       return TranslationWrapper();
  //   }
  //   return Authenticate();
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    return StreamBuilder<UserModel>(
      stream: authService.user,
        builder: (BuildContext context, AsyncSnapshot snapShot) {
          // if (!snapShot.hasData || snapShot.hasError){
          //   return Authenticate();
          // }
          if (snapShot.hasData && (!snapShot.hasError)) {
            UserModel currUser = snapShot.data;
            print("currUser $currUser");
            print("_auth.currentUser ${_auth.currentUser}");
            if (currUser != null &&
                (currUser.emailVerified || _auth.currentUser.isAnonymous)) {
              print("yay!");
              return TranslationWrapper();
            }
          }
          return Authenticate();;
        }
    );
  }

  Future<void> saveTermsForShow() async{
    if (hasLoaded){
      return;
    }
    // List<String> futureTerms = await findTermsDB();
    // saveTerms = futureTerms;
    hasLoaded = true;
    print("finish saved terms");
  }
}
