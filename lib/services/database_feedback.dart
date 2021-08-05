import 'package:cloud_firestore/cloud_firestore.dart';

/// Database feedback class
class DatabaseFeedbackService{
  final String uid;

  DatabaseFeedbackService({ this.uid });

  /// Collection reference
  final CollectionReference feedbackCollection =
  FirebaseFirestore.instance.collection('feedback');

  /// Add the feedback to the firebase
  Future updateFeedbackData({int rating, String text, String sentence}) async {
    return await feedbackCollection.doc(uid).set({
      'rating' : rating,
      'text' : text,
      'sentence': sentence,
    });
  }
}