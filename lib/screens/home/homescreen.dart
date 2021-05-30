import 'package:flutter/material.dart';
import 'package:isl_translator/screens/home/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page",
          style: TextStyle(),
        ),
      ),
      // drawer: MainDrawer(),
      endDrawer: MainDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Text("We are in the homepage now."),
          ],
        ),
      ),
    );
  }
}
