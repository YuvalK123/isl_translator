import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Isl translator - home"),
        backgroundColor: Colors.lightBlue[100],
      ),
      backgroundColor: Colors.brown[200],
      body: Text("Hello. this is the home", style: TextStyle(fontSize: 30.0),),
    );
  }
}
