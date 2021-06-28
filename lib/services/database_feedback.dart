import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/models/video.dart';

class DatabaseFeedbackService{
  final String uid;

  DatabaseFeedbackService({ this.uid });

  // collection reference
  final CollectionReference feedbackCollection =
  FirebaseFirestore.instance.collection('feedback');

  Future updateFeedbackData({int rating, String text, String sentence}) async {
    return await feedbackCollection.doc(uid).set({
      'rating' : rating,
      'text' : text,
      'sentence': sentence,
    });
  }

  Future getFeedbackData() async{
    if (this.uid == null){
      return null;
    }
    return await feedbackCollection.doc(this.uid).get();
  }

  // List<UserModel> _userListFromSnapshot(QuerySnapshot snapshot){
  //   return snapshot.docs.map((doc) =>
  //       UserModel(username: doc.data()['username'] ?? 'Anon user',
  //           age: doc.data()['age'] ?? 0,
  //           gender: doc.data()['gender'] ?? "")
  //   ).toList();
  // }

  // UserModel _userModelFromSnapshot(DocumentSnapshot documentSnapshot){
  //   return UserModel(
  //     uid: this.uid,
  //     username: documentSnapshot.data()["username"] ?? "anon user",
  //     gender: documentSnapshot.data()["gender"],
  //     age: documentSnapshot.data()["age"],
  //   );
  //}

  // get brews stream
  // Stream<UserModel> get users {
  //   print("uid is $uid");
  //   return usersCollection.doc(this.uid).snapshots()
  //       .map(_userModelFromSnapshot);
  // }
}