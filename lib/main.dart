import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
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


  // Completer completer = Completer();
  // completer.complete(FirebaseApp.getApps(context).isEmpty());

  runApp(MyApp());
  //bla();
  bla();
  print("after bla");
 // await Firebase.initializeApp().whenComplete(() => bla());
  //final recievePort = ReceivePort();
  //final _isolateReady = Completer<void>();
  // if (user != null && user.uid != null){
  //   print("spawning from main!");
  //   Worker();
    // recievePort.listen((dynamic message) {
    //   if (message is SendPort){
    //     print("hi");
    //     _isolateReady.complete();
    //     return;
    //   }
    //   if (message is List<String>){
    //     print("Bye");
    //     saveTerms = message;
    //     _isolateReady.complete();
    //     return;
    //   }
    // });
    // final isolate = await Isolate.spawn(saveTermsFunc,recievePort.sendPort);
    //
    // isolate.kill();
    // print("user is $user ${user.uid}");
    //  List<String> futureTerms = await findTermsDB();
    //  saveTerms = futureTerms;
  // }else{
  //   print("fail");
  // }
  // get all terms
  // List<String> futureTerms = await findTermsDB();
  // saveTerms = futureTerms;
  // futureTerms.then((result) => saveTerms=  result)
  //     .catchError((e) => print('error in find terms'));
  //runApp(MyApp());
}

void bla (){
  print("Bla!!!!");
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && user.uid != null){
    print("spawning from main!");
    //Worker(FirebaseStorage.instance);
    // recievePort.listen((dynamic message) {
    //   if (message is SendPort){
    //     print("hi");
    //     _isolateReady.complete();
    //     return;
    //   }
    //   if (message is List<String>){
    //     print("Bye");
    //     saveTerms = message;
    //     _isolateReady.complete();
    //     return;
    //   }
    // });
    // final isolate = await Isolate.spawn(saveTermsFunc,recievePort.sendPort);
    //
    // isolate.kill();
    // print("user is $user ${user.uid}");
    //  List<String> futureTerms = await findTermsDB();
    //  saveTerms = futureTerms;
  }else{
    print("fail");
  }
}
 void saveTermsFunc(dynamic msg) async{
  // print("user is $user ${user.uid}");
  // await Future.delayed(Duration(seconds: 10)); // not working
  print("loading.......");
  SendPort sendPort;
  // recievePort is what im listening to
  // sendPort is what we use to send to the recieve

  // List<String> futureTerms = await findTermsDB();
  // saveTerms = futureTerms;
  sendPort = msg;
  msg.send(saveTerms);
  print("done saveTerms!");
}

// RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("hi");
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

class Worker {
  SendPort _sendPort;
  Isolate _isolate;
  final _isolateReady = Completer<void>();

  Worker(FirebaseStorage firebaseStorage) {
    init(firebaseStorage);
  }

  Future<void> init(FirebaseStorage storage) async {
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
    final isolate = await Isolate.spawn(_isolateEntry, [recievePort.sendPort, storage]);
  }

  Future<void> get isolateReady => _isolateReady.future;

  void dispose() {
    _isolate.kill();
  }

  static Future<void> _isolateEntry(List<Object> args) async {
    dynamic message = args[0];
    FirebaseStorage storage = args[1];
    print("loading.......");
    SendPort sendPort;
    // recievePort is what im listening to
    // sendPort is what we use to send to the recieve
    //await Firebase.initializeApp();
    List<String> futureTerms = await findTermsDB(storage);
    saveTerms = futureTerms;
    sendPort = message;
    //msg.send(saveTerms);
    print("done saveTerms!");
  }
}
