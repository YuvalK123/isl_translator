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
    return await videosCollection.document(key).delete();
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

  Future updateUserData(String name, String age, int gender) async {
    return await usersCollection.doc(uid).set({
      'name' : name,
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
        UserModel(userName: doc.data()['name'] ?? '',
            age: doc.data()['age'] ?? 0,
            gender: doc.data()['gender'] ?? "f")
    ).toList();
  }

  // get brews stream
  Stream<List<UserModel>> get users {
    return usersCollection.snapshots().map(_userListFromSnapshot);
  }
}