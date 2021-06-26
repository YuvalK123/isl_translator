import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/services/auth.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/shared/constant.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;

  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String error = '';


  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign in to ISL-Translator'),
        actions: <Widget> [
          FlatButton.icon(
              onPressed: widget.toggleView,
              icon: Icon(Icons.person),
              label: Text("Register")
          )
        ],
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          // ignore: deprecated_member_use
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget> [
                SizedBox(height: 20.0,),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Email'),
                  validator: (val) => val.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) { // email
                    setState(() => email = val);
                  },
                ),
                SizedBox(height: 20.0,),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Password'),
                  validator: (val) =>
                  val.length < 6 ? 'Enter a password 6+ chars long' : null,
                  onChanged: (val) => setState(() => password = val) ,
                  obscureText: true,
                ),
                SizedBox(height: 20.0,),
                RaisedButton(
                  color: Colors.pink[400],
                  child: Text("Sign in",
                      style: TextStyle(color: Colors.white)
                  ),
                  onPressed: () async {
                    // true - valid form. false - invalid form
                    if (_formKey.currentState.validate()){


                      dynamic result = await _authService.
                      signInUserWithEmailAndPassword(email, password);
                      print("result sign in $result");
                      if (result.runtimeType == String){
                        setState(() {
                          loading = false;
                          error = '${result.toString()}\nCould not sign in';
                        });
                      }
                      if (_auth.currentUser.emailVerified){
                        // get all terms

                        setState(() => loading = true
                        );
                        // futureTerms.then((result) => saveTerms=  result)
                        // .catchError((e) => print('error in find terms'));
                      }
                    }
                  },
                ),
                SizedBox(height: 20.0,),
                RaisedButton(
                  color: Colors.pink[400],
                  child: Text("Sign in anonymously",
                      style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                    dynamic result = await _authService.signInAnon();
                    if (result == null){
                      setState(() {
                        loading = false;
                        error = 'Could not sign in';
                      });
                    }
                    }
                ),
                SizedBox(height: 12.0,),
                Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0),)
              ],
            ),
          ),
        ),
      ),
    );
  }



}
