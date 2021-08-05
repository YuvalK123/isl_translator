import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/screens/add_video/add_video.dart';


class InstructionsPage extends StatelessWidget {
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('הנחיות לצילום', textDirection: TextDirection.rtl),
        backgroundColor: Colors.cyan[800],
        actions: [],
      ),
      body: Align(
        alignment: Alignment.center,
        child: Text('הנחיות לצילום', textDirection: TextDirection.rtl),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
        backgroundColor: Colors.cyan[800],
        onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddVideoPage())
        ),
      ),
    );
  }
}