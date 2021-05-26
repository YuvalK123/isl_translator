import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/auth.dart';
import 'models/user.dart';
import 'package:isl_translator/screens/wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
      value: AuthService().user,
      child: MaterialApp(
        home:Directionality( // add this
              textDirection: TextDirection.rtl, // set this property
              child: Wrapper()),
         // home: Home()
      ),
    );
  }
}
