import 'package:flutter/material.dart';
import 'package:isl_translator/services/database.dart';
import 'package:isl_translator/shared/constant.dart';

class AddVideoPage extends StatefulWidget {
  @override
  _AddVideoPageState createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {

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
        title: Text("Add video"),
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
                // validator: (val) => val.isEmpty ? '' : null,
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

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                RaisedButton(
                  color: Colors.pink[400],
                  child: Text("Add video",
                      style: TextStyle(color: Colors.white)
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()){
                      await DatabaseVidService().updateVideo(key, url, desc);
                    }
                  },
                ),
                SizedBox(width: 10.0,),
                RaisedButton(
                  color: Colors.pink[400],
                  child: Text("Delete video",
                      style: TextStyle(color: Colors.white)
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()){
                      await DatabaseVidService().deleteVideo(key);
                    }
                  },
                ),
                SizedBox(height: 10.0,),
              ],
            ),

            RaisedButton(
              color: Colors.pink[400],
              child: Text("Print Data",
                  style: TextStyle(color: Colors.white)
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  print("______");
                  dynamic vids = DatabaseVidService().vids;
                  print("vids is $vids");
                  if (vids != null){
                    vids.forEach((e) => print("e = $e;"));
                    // print(vids.forEach((element) => element));
                    print("______");
                  }else{
                    print("vids == null");
                  }
                  // vids.toString();

                }
                // if (_formKey.currentState.validate()){
                //   print("validated");
                //   print(DatabaseService().videos.forEach((element) {print(element);}));
                // }
                // print("after if");
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
