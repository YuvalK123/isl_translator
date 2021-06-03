import 'package:flutter/material.dart';
import 'package:isl_translator/screens/home/main_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isl_translator/models/user.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("פרופיל"),

      ),
      backgroundColor: Theme.of(context).backgroundColor,
      endDrawer: MainDrawer(currPage: pageButton.PROFILE,),
      body: Container(
        child: Column(
          children: <Widget>[

          ],
        ),
      ),
    );
  }
}
