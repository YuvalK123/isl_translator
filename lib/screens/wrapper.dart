import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/authenticate/authenticate.dart';
import 'home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return user != null ? Home() : Authenticate();
    // return either home or authenticate widget
    // return Authenticate();
  }
}
