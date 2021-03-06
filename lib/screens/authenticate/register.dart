// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/authenticate/Verify_screen.dart';
import 'package:isl_translator/services/auth.dart';
import 'package:isl_translator/services/database.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/shared/constant.dart';


/// register page
class Register extends StatefulWidget {

  // what to do when toggled
  final Function toggleView;

  Register({ this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  // final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool verify = false;
  String email = '';
  String password = '';
  String error = '';
  String userName = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      //backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        elevation: 0.0,
        title: Container(
            alignment: Alignment.centerRight,
            child: Text('הרשמה')),
        actions: <Widget> [
          FlatButton.icon(
              onPressed: widget.toggleView,
              icon: Icon(Icons.person),
              label: Text("התחבר/י")
          )
        ],
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget> [
                SizedBox(height: 20.0,),
                Row(
                  children: [
                    Image.asset("assets/images/register.png",
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(width: 10.0,),
                    Container(
                        alignment: Alignment.topRight,
                        child: Text(
                          "הרשמה",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,fontStyle:
                          FontStyle.italic),
                        )
                    ),
                  ],
                ),
                SizedBox(height: 40.0,),
                // userName text field
                TextFormField(
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: textInputDecoration.copyWith(hintText: 'שם משתמש'),
                  validator: (val) => val.isEmpty ? 'הכנס/י שם משתמש' : null,
                  onChanged: (val) { // email
                    setState(() {
                      userName = val;
                    });
                  },
                ),
                SizedBox(height: 20.0,),
                // email text field
                TextFormField(
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: textInputDecoration.copyWith(hintText: 'אימייל'),
                  validator: (val) => val.isEmpty ? 'הכנס/י אימייל' : null,
                  onChanged: (val) { // email
                    setState(() {
                      email = val;
                    });
                  },
                ),
                SizedBox(height: 20.0,),
                // password text field
                TextFormField(
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: textInputDecoration.copyWith(hintText: 'סיסמה'),
                  validator: (val) =>
                  val.length < 6 ? 'הכנס/י סיסמה בעלת 6 תווים ומעלה' : null,
                  onChanged: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                  obscureText: true,
                ),
                SizedBox(height: 20.0,),
                RaisedButton(
                  color: Colors.grey[400],
                  child: Text("הרשמ/י",
                      style: TextStyle(color: Colors.white)
                  ),
                  onPressed: register,
                ),
                SizedBox(height: 12.0,),
                // error text
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
                this.verify ? VerifyScreen() : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// when click on register button, try to
  void register() async{
    /// if form is with valid values
    if (_formKey.currentState.validate()){
      // try to register
      dynamic result = await AuthService().
      registerUserWithEmailAndPassword(email, password);
      // if string then it's an error
      if (result.runtimeType == String){
        print("res == null");
        setState(() {
          loading = false;
          error = 'Failed to register\n$result';
        } );
        return;
      } else{ // not a string, so succeded to register
        DatabaseUserService(uid: FirebaseAuth.instance.currentUser.uid).updateUserData(
          username: userName,
          gender: "o",
          videoType: VideoType.ANIMATION,
        );
        // if user is with a verified mail
        if (_auth.currentUser.emailVerified) {
          setState(() {
            this.verify = false;
            loading = true;
          });
        } else{ // user's mail isnt verified
          setState(() {
            error = "";
            this.verify = true;
          });
        }
      }
    }
  }
}

class FormField extends StatelessWidget {

  final String title;
  final Function validator;
  final Function onChanged;

  FormField({ this.title, this.validator, this.onChanged });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: title,
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pink[300], width: 2.0)
        ),
      ),
      validator: this.validator,
      // (val) => val.isEmpty ? 'Enter an email' : null,
      onChanged: this.onChanged,
      // (val) { // email
      // setState(() {
      //   email = val;
      // });
    );
  }


}

