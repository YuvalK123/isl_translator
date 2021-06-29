import 'dart:async';

import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/authenticate/authenticate.dart';

import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:isolate';


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
      // Worker();
      print("good save terms!!!!");
      return TranslationWrapper();
    }
    return Authenticate();
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

class Worker {
  SendPort _sendPort;
  Isolate _isolate;
  final _isolateReady = Completer<void>();

  Worker() {
    init();
  }

  Future<void> init() async {
    final recievePort = ReceivePort();
    recievePort.listen((dynamic message) {
      if (message is SendPort) {
        print("hi");
        _isolateReady.complete();
        return;
      }
      if (message is List<String>) {
        print("Bye");
        saveTerms = message;
        _isolateReady.complete();
        return;
      }
    });
    final isolate = await Isolate.spawn(_isolateEntry, recievePort.sendPort);
  }

  Future<void> get isolateReady => _isolateReady.future;

  void dispose() {
    _isolate.kill();
  }

  static Future<void> _isolateEntry(dynamic message) async {
    print("loading.......");
    SendPort sendPort;
    // recievePort is what im listening to
    // sendPort is what we use to send to the recieve

    // List<String> futureTerms = await findTermsDB();
    // saveTerms = futureTerms;
    sendPort = message;
    //msg.send(saveTerms);
    print("done saveTerms!");
  }
}
