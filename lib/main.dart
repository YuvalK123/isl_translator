import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/screens/authenticate/sign_in.dart';
import 'package:isl_translator/services/auth.dart';
import 'models/user.dart';
import 'package:isl_translator/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:isl_translator/services/show_video.dart';

int i = 0;
bool isLoading = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final user = FirebaseAuth.instance.currentUser;
  runApp(MyApp());
  if (user != null && user.uid != null){
    await findTermsDB();
    isLoading = false;
  }else{
    print("fail");
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

