import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/models/video.dart';

class DatabaseVidService {

  final String uid;

  DatabaseVidService({ this.uid });

  // collection reference
  final CollectionReference videosCollection =
  FirebaseFirestore.instance.collection('videosUrls');




  Future updateVideo(String key, String url, String desc) async {
    print("inserting $key, $url, $desc");
    return await videosCollection.doc(key).set({
      "title": key,
      "url": url,
      "description": desc
    });
  }

  Future deleteVideo(String key) async {
    print("deleting $key");
    return await videosCollection.doc(key).delete();
  }

  List<Vid> _videoFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) =>
        Vid(title: doc.data()['title'] ?? 'no title available',
            url: doc.data()['url'] ?? 'no url available',
            desc: doc.data()['description'] ?? 'no desc available')
    ).toList();
  }

  Stream<List<Vid>> get vids {
    Stream<List<Vid>> x = videosCollection.snapshots().map(_videoFromSnapshot);
    print("x is $x");
    return x;
  }

}

class DatabaseUserService{
  final String uid;

  DatabaseUserService({ this.uid });

  // collection reference
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future updateUserData({String username, int age, String gender}) async {
    return await usersCollection.doc(uid).set({
      'name' : username,
      'age' : age,
      'gender' : gender
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