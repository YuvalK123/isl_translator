import 'package:flutter/material.dart';
import 'package:isl_translator/screens/home/main_drawer.dart';

class Dictionary extends StatefulWidget {
  @override
  _DictionaryState createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("מילון"),),
        endDrawer: MainDrawer(currPage: pageButton.DICT,),
        body: Text("body"),
    );
  }
}

