// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:isl_translator/services/auth.dart';
import 'package:isl_translator/services/handle_sentence.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/shared/constant.dart';

/// sign in window
class SignIn extends StatefulWidget {

  // what to do when toggled
  final Function toggleView;
  static final AuthService authService = AuthService();
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _authService = SignIn.authService;
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String error = '';


  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        elevation: 0.0,
        title: Container(
            alignment: Alignment.centerRight,
            child: Text('התחברות')),
        actions: <Widget> [
          FlatButton.icon(
              onPressed: widget.toggleView,
              icon: Icon(Icons.person),
              label: Text("הרשמ/י")
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
                Container(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(child: Image.asset("assets/images/sign_in_flag1.jpg", width: 200, height: 70,)),
                        Container(
                          alignment: Alignment.topRight,
                            child: Text(
                              "ברוכים הבאים", style:
                            TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                fontStyle: FontStyle.italic
                            ),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.0,),
                Container(
                    alignment: Alignment.topRight,
                    child: Text(
                      "התחבר/י למשתמש שלך",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontStyle: FontStyle.italic
                      ),
                    )
                ),
                SizedBox(height: 20.0,),
                TextFormField( // email text field
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: textInputDecoration.copyWith(hintText: 'אימייל'),
                  //
                  // validator: (val) => val.isEmpty ? 'Enter an email' : null,
                  validator: (val) => emailValidation(val),
                  onChanged: (val) { // update email string
                    setState(() => email = val);
                  },
                ),
                SizedBox(height: 20.0,),
                TextFormField(
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: textInputDecoration.copyWith(hintText: 'סיסמה'),
                  validator: (val) =>
                  val.length < 6 ? 'Enter a password 6+ chars long' : null,
                  onChanged: (val) => setState(() => password = val) ,
                  obscureText: true,
                ),
                SizedBox(height: 10.0,),
                SizedBox(height: 10.0,),
                Row(
                  children: [
                    Expanded(
                      child: RaisedButton(
                          color: Colors.green[400],
                          child: Text("התחבר/י באופן אנונימי", textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)),
                          onPressed: logInAnon,
                      ),
                    ),
                    SizedBox(width: 20.0,),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.green[800],
                        child: Text("התחבר/י",
                            style: TextStyle(color: Colors.white)
                        ),
                        onPressed: logIn,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.0,),
                Text(
                  error,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.0
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,10,0,0),
                  child: Image.asset(
                    "assets/images/sign_in1.png",
                    width: 1000,
                    height: 150,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void logInAnon() async {
    dynamic result = await _authService.signInAnon();
    if (result == null) {
      setState(() {
        loading = false;
        error = 'Could not sign in';
      });
      return;
    }
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TranslationWrapper(),
        )
    );
  }


  void logIn() async{
    // true - valid form. false - invalid form
    if (_formKey.currentState.validate()){


      dynamic result = await _authService.
      signInUserWithEmailAndPassword(email, password);
      print("result sign in $result");
      if (result.runtimeType == String){
        print("result is string");
        setState(() {
          loading = false;
          error = 'Could not sign in\n${result.toString()}';
        });
        return;
      }
      if (_auth.currentUser.emailVerified){
        if (mounted){
          findTermsDB();
          setState(() {
            print("result verified");
            // loading = true;
          });
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TranslationWrapper(),
              )
          );
        }
      }else{
        print("user signin is ${_auth.currentUser}");
        setState(() {
          loading = false;
          error = 'Email not verified!';
        });
      }
    }
  }

  String emailValidation(String val){
    if (val.isEmpty){
      return "enter an email";
    } else if (!val.contains("@")){
      return "invalid email address";
    }
    return null;

  }

}
