import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/auth.dart';
import 'models/user.dart';
import 'package:isl_translator/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:isl_translator/services/show_video.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // get all terms
  // List<String> futureTerms = await findTermsDB();
  // saveTerms = futureTerms;
  // futureTerms.then((result) => saveTerms=  result)
  //     .catchError((e) => print('error in find terms'));
  runApp(MyApp());
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

