import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/auth.dart';
import 'package:isl_translator/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:isl_translator/services/handle_sentence.dart';

void main() async {
  // init connection with firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // get user
  runApp(MyApp()); // run app
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && user.uid != null && (user.emailVerified || user.isAnonymous)){
    // if user exists, and its a valid entrence
    await findTermsDB();
  }
}

class MyApp extends StatelessWidget {
  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      initialData: null,
      // value: SignIn.authService.user,
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}

