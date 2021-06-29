import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/auth.dart';
import 'models/user.dart';
import 'package:isl_translator/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:isl_translator/services/show_video.dart';
import 'dart:isolate';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final user = FirebaseAuth.instance.currentUser;
  final recievePort = ReceivePort();
  if (user != null && user.uid != null){
    // print("spawning from main!");
    final isolate = await Isolate.spawn(saveTermsFunc,recievePort.sendPort);
    recievePort.listen((message) {
      if (message is SendPort){

      }
      if (message is List<String>){
        saveTerms = message;
      }
    });
    isolate.kill();
    // print("user is $user ${user.uid}");
    List<String> futureTerms = await findTermsDB();
    saveTerms = futureTerms;
  }else{
    print("fail");
  }
  // get all terms
  // List<String> futureTerms = await findTermsDB();
  // saveTerms = futureTerms;
  // futureTerms.then((result) => saveTerms=  result)
  //     .catchError((e) => print('error in find terms'));
  runApp(MyApp());
}

void saveTermsFunc(SendPort msg) async{
  // print("user is $user ${user.uid}");
  // await Future.delayed(Duration(seconds: 10)); // not working
  print("loading.......");
  // recievePort is what im listening to
  // sendPort is what we use to send to the recieve

  List<String> futureTerms = await findTermsDB();
  saveTerms = futureTerms;
  msg.send(saveTerms);
  print("done saveTerms!");
}

// RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
      value: AuthService().user,
      child: MaterialApp(
        // navigatorObservers: [routeObserver],
        home: Wrapper(),
        // home: Home()
      ),
    );
  }
}

