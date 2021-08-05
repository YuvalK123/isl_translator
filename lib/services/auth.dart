import 'package:flutter/cupertino.dart';
import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/authenticate/authenticate.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// create [user] based on firebase user
  UserModel _userFromFirebase(User user){
    return user != null ? UserModel(
      uid: user.uid,
        emailVerified: user.emailVerified
    ) : null ;
  }

  /// auth change user stream
  Stream<User> get user{
    return _auth.authStateChanges();
  }


  /// sign in anon
  Future signInAnon() async {
    try{
      // user object
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebase(user);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  /// sign in with [email] and [password]
  Future signInUserWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email.replaceAll(' ', ''), password: password
      );
      User user = result.user;
      return _userFromFirebase(user);
    }catch(e){
      return e.toString().split("]")[1].replaceFirst(' ', '');
    }
  }

  /// register with [email] & [password]
  Future registerUserWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email.replaceAll(' ', ''), password: password
      );
      User user = result.user;
      // create a new document for the user with the uid
      await DatabaseUserService(uid: user.uid).updateUserData(
        username: "new user",
        gender: 'f', // default value
      );
      return _userFromFirebase(user);
    }catch(e){
      print(e.toString());
      return e.toString().split("]")[1].replaceFirst(' ', '');
    }
  }

  /// sign out
  Future signOut(BuildContext context) async {
    try{
      if (_auth.currentUser.isAnonymous){
        await _auth.currentUser.delete();
      }
      await _auth.signOut();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Authenticate(),
      ));

    }
    catch(e){
      print(e.toString());

    }
  }

}