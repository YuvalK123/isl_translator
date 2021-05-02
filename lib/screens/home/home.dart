import 'package:flutter/material.dart';
import 'package:isl_translator/services/database.dart';
import 'package:isl_translator/shared/constant.dart';
import 'package:isl_translator/shared/loading.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  String key = '';
  String url = '';
  String desc = '';



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Isl translator - home"),
        backgroundColor: Colors.lightBlue[100],
      ),
      backgroundColor: Colors.brown[200],
      body: Form(
      key: _formKey,
      child: Column(
        children: <Widget> [
          SizedBox(height: 20.0,),
          TextFormField(
              decoration: textInputDecoration.copyWith(hintText: 'title'),
              validator: (val) => val.isEmpty ? '' : null,
            onChanged: (val) { // key
                setState(() {
                  key = val;
                });
               }),
          SizedBox(height: 20.0,),
          TextFormField( // password
            decoration: textInputDecoration.copyWith(hintText: 'url'),
            onChanged: (val) {
              setState(() {
                url = val;
              });
            },
          ),
          SizedBox(height: 20.0,),
          TextFormField( // description
            decoration: textInputDecoration.copyWith(hintText: 'description'),
            onChanged: (val) {
              setState(() {
                desc = val;
              });
            },
          ),
          SizedBox(height: 20.0,),
          RaisedButton(
            color: Colors.pink[400],
            child: Text("Add video",
                style: TextStyle(color: Colors.white)
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()){
                print("$key, $url, $desc");
                DatabaseService().updateVideo(key, url, desc);
              }
            },
          ),
          SizedBox(height: 12.0,),
          Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0),)
        ],
      ),
    ),
    );
  }
}
