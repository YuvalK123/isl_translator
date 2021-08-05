import 'dart:async';

import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/authenticate/authenticate.dart';
import 'package:isl_translator/screens/authenticate/sign_in.dart';

import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/auth.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:isolate';


bool hasLoaded = false;

class Wrapper extends StatefulWidget {
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print("user from wrapper $user");
    bool cond = (user != null && ((user.emailVerified || _auth.currentUser.isAnonymous)));
    return cond ? TranslationWrapper() : Authenticate();
  }

}
