import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/models/video.dart';

class DatabaseVidService {

  final String uid;

  DatabaseVidService({ this.uid });

  // collection reference
  final CollectionReference videosCollection =
  Firestore.instance.collection('videosUrls');




  Future updateVideo(String key, String url, String desc) async {
    print("inserting $key, $url, $desc");
    return await videosCollection.document(key).setData({
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
    return snapshot.documents.map((doc) =>
        Vid(title: doc.data['title'] ?? 'no title available',
            url: doc.data['url'] ?? 'no url available',
            desc: doc.data['description'] ?? 'no desc available')
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
  Firestore.instance.collection('users');

  Future updateUserData(String name, String age, int gender) async {
    return await usersCollection.document(uid).setData({
      'name' : name,
      'age' : age,
      'gender' : gender
    });
  }

  List<User> _brewListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc) =>
        User(name: doc.data['name'] ?? '',
            age: doc.data['age'] ?? 0,
            gender: doc.data['gender'] ?? "f")
    ).toList();
  }

  // get brews stream
  Stream<List<User>> get users {
    return usersCollection.snapshots().map(_brewListFromSnapshot);
  }
}