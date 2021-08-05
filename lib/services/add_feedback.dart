import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/services/database_feedback.dart';
import 'package:quick_feedback/quick_feedback.dart';
import 'package:flutter/material.dart';

/// Feedback UI gets [context] and [inputSentence] and shows feedback
void showFeedback(BuildContext context, String inputSentence) {
  showDialog(
    context: context,
    builder: (context) {
      return QuickFeedback(
          title: '?איך היה התרגום', // Title of dialog
          showTextBox: true,
          textBoxHint:
          'שתפ/י אותנו עוד', // Feedback text field hint text default
          submitText: 'שלח', // Submit button
          onSubmitCallback: (feedback) {
            addFeedback(feedback['rating'],feedback['feedback'],inputSentence);
            Navigator.of(context).pop();
          },
          askLaterText: 'ביטול',
          onAskLaterCallback: () {
          }
      );
    },
  );
}

/// Gets [newSentence], [newRating] and free text [newText]
/// and Add the feedback to the firebase
Future addFeedback(int newRating, String newText, String newSentence) async{
  FirebaseAuth auth = FirebaseAuth.instance;
  String id = auth.currentUser.uid;
  await DatabaseFeedbackService(uid: "$id$newSentence" ).updateFeedbackData(
    rating: newRating,
    text: newText,
    sentence: newSentence,
  );
}