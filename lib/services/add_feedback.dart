import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/services/database_feedback.dart';
import 'package:quick_feedback/quick_feedback.dart';
import 'package:flutter/material.dart';

void showFeedback(context,inputSentence) {
  showDialog(
    context: context,
    builder: (context) {
      return QuickFeedback(
          title: '?איך היה התרגום', // Title of dialog
          showTextBox: true, // default false
          textBoxHint:
          'שתפ/י אותנו עוד', // Feedback text field hint text default: Tell us more
          submitText: 'שלח', // submit button text default: SUBMIT
          onSubmitCallback: (feedback) {
            print('$feedback');
            addFeedback(feedback['rating'],feedback['feedback'],inputSentence);
            Navigator.of(context).pop();
          },
          askLaterText: 'ביטול',
          onAskLaterCallback: () {
            print('Do something on ask later click');
            //Navigator.of(context).pop();
          }
      );
    },
  );
}

Future addFeedback(int newRating, String newText, String newSentence) async{
  FirebaseAuth auth = FirebaseAuth.instance;
  String id = auth.currentUser.uid;
  await DatabaseFeedbackService(uid: "$id$newSentence" ).updateFeedbackData(
    rating: newRating,
    text: newText,
    sentence: newSentence,
  );
}