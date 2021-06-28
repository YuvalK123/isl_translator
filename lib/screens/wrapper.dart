import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/authenticate/authenticate.dart';

import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';



bool hasLoaded = false;

class Wrapper extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    print("user wrapper $user");
    // print("user data is ${DatabaseUserService(uid: user.uid).users}");
    // return either home or authenticate widget
    // if (user != null){
    //   if (_auth.currentUser.emailVerified)
    // }
    if (user != null && (_auth.currentUser.emailVerified || _auth.currentUser.isAnonymous)){
      //saveTermsForShow();
      print("good save terms!!!!");
      return TranslationWrapper();
    }
    return Authenticate();
  }

  Future<void> saveTermsForShow() async{
    if (hasLoaded){
      return;
    }
    List<String> futureTerms = await findTermsDB();
    saveTerms = futureTerms;
    hasLoaded = true;
    print("finish saved terms");
  }
}
