import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isl_translator/models/user.dart';


/// DatabaseUserService class
/// class receives [uid] of user, and manipulates it in firebase
class DatabaseUserService{
  final String uid;

  DatabaseUserService({ this.uid });

  // collection reference
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  /// function updates the user's collection of [username], [gender] and
  /// [videoType] to play
  Future updateUserData({String username, String gender, VideoType videoType}) async {
    Map<String, String> map = {
      'username' : username,
      'gender' : gender,
    };
    if (videoType != null){
      map['videoType'] = videoType.toString();
    }
    return await usersCollection.doc(uid).set(map);
  }


  /// returns user data
  Future<DocumentSnapshot> getUserData() async{
    if (this.uid == null){
      return null;
    }
    return await usersCollection.doc(this.uid).get();
  }

  /// creates a UserModel from [documentSnapshot]
  UserModel _userModelFromSnapshot(DocumentSnapshot documentSnapshot){
    return UserModel(
      uid: this.uid,
      username: documentSnapshot.data()["username"] ?? "anon user",
      videoTypeStr: documentSnapshot.data()["videoType"] ?? VideoType.ANIMATION.toString(),
      gender: documentSnapshot.data()["gender"] ?? "",
    );
  }

  /// userModel stream of user data from collection
  Stream<UserModel> get users {
    return usersCollection.doc(this.uid).snapshots()
        .map(_userModelFromSnapshot);
  }
}