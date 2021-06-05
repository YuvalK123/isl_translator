import 'package:isl_translator/models/user.dart';
import 'database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user based on firebase user
  UserModel _userFromFirebase(User user){
    var dbs = DatabaseUserService(uid: user.uid);
    return user != null ? UserModel(
      uid: user.uid,
    ) : null ;
  }

  // auth change user stream
  Stream<UserModel> get user{
    return _auth.authStateChanges().map(_userFromFirebase);
    // .map((FirebaseUser user) => _userFromFirebase(user));
  }

  // sign in anon
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

  // sign in with email and password
  Future signInUserWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password
      );
      User user = result.user;
      return _userFromFirebase(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerUserWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password
      );
      User user = result.user;
      // create a new document for the user with the uid
      await DatabaseUserService(uid: user.uid).updateUserData(
        username: "new user",
        age: 100,
        gender: 'f',
      );
      return _userFromFirebase(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    }
    catch(e){
      print(e.toString());

    }
  }

}