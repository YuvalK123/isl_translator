import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/models/video.dart';

class DatabaseUserService{
  final String uid;

  DatabaseUserService({ this.uid });

  // collection reference
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future updateUserData({String username, String gender}) async {
    return await usersCollection.doc(uid).set({
      'username' : username,
      // 'age' : age,
      'gender' : gender

    });
  }

  Future updateUserData2({String username, String gender,VideoType videoType}) async {
    return await usersCollection.doc(uid).set({
      'username' : username,
      'gender' : gender,
      'videoType': videoType.toString()
    });
  }


  Future getUserData() async{
    if (this.uid == null){
      return null;
    }
    return await usersCollection.doc(this.uid).get();
  }

  List<UserModel> _userListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc) =>
        UserModel(username: doc.data()['username'] ?? 'Anon user',
            age: doc.data()['age'] ?? 0,
            gender: doc.data()['gender'] ?? "")
    ).toList();
  }

  UserModel _userModelFromSnapshot(DocumentSnapshot documentSnapshot){
    return UserModel(
      uid: this.uid,
      username: documentSnapshot.data()["username"] ?? "anon user",
      gender: documentSnapshot.data()["gender"],
      age: documentSnapshot.data()["age"],
    );
  }

  // get brews stream
  Stream<UserModel> get users {
    print("uid is $uid");
    return usersCollection.doc(this.uid).snapshots()
        .map(_userModelFromSnapshot);
  }
}