// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:isl_translator/models/pair.dart';
import 'package:isl_translator/shared/reg.dart';
import 'package:firebase_storage/firebase_storage.dart';

List<String> saveTerms = [];

/// Split [word] to letters
List<String> splitToLetters(String word) {
  List<String> lettersList = List<String>(word.length);
  var num = 0;
  for (var i = num; i < word.length; i++) {
    print(word[i]);
    lettersList[i] = word[i];
  }
  return lettersList;
}

/// Search for terms in the [sentence] and return
/// [saveTerms] a list ot terms
List<String> searchTerm(String sentence, List<String> saveTerms) {
  List<String> terms = [];
  for (var i = 0; i < saveTerms.length; i++) {
    var searchName = saveTerms[i].replaceAll(new RegExp(r'[\u200f]'), "");
    if (sentence.contains(new RegExp(searchName, caseSensitive: false))) {
      terms.add(saveTerms[i]);
    }
  }
  return terms;
}

/// Find all the terms in DB
/// terms are phrases of 2+ words
Future<void> findTermsDB() async{
  saveTerms.clear();
  var futures = <Future>[];
  await FirebaseStorage.instance.ref().child("animation_openpose/").listAll().then((result) {
    var items = result.items;
    for (int i=0; i< items.length; i++){
      futures.add(addSavedExp(items[i]));
    }
  });
  return await Future.wait(futures);
}

/// save expression of [item] reference
Future<void> addSavedExp(Reference item) async{
  String videoName = item.toString().substring(55,item.toString().length -5);
  if(videoName.split(" ").length > 1){
    saveTerms.add(videoName);
  }
}

/// Split the [sentence] to word/term and return a list of the split sentence
List<String> splitSentence(String sentence) {
  if (sentence == null){
    return null;
  }
  List<String> hebrewLetters = hebrewChars.keys.toList();
  var newSentence = sentence.replaceAll(
      new RegExp(r'[\u200f]'), ""); // replace to regular space
  var vals = hebrewLetters.toString().substring(1,hebrewLetters.toString().length - 1).replaceAll(",", "");
  newSentence = newSentence.replaceAll(RegExp('[^$vals]'), "");
  if (newSentence.isEmpty){
    return null;
  }
  List<String> sentenceList = newSentence.split(" "); //split the sentence to words
  List<String> terms = searchTerm(newSentence, saveTerms); // terms in the sentence
  List<String> splitSentence = [];

  // save the index and the length of the terms
  List indexTerms = [];
  for (int i = 0; i < terms.length; i++) {
    indexTerms.add(Pair(newSentence.indexOf(terms[i]), terms[i].length));
  }
  indexTerms.sort((x,y) => x.a.compareTo(y.a));

  // split the sentence to word and terms
  int termsCount = 0;
  int sentenceListCount = 0;
  for (int i = 0; i < newSentence.length;) {
    if (termsCount < indexTerms.length && i == indexTerms[termsCount].a) {
      splitSentence.add(newSentence.substring(i, i + indexTerms[termsCount].b));
      List termSplit = newSentence.substring(i, i + indexTerms[termsCount].b).split(" ");
      i += indexTerms[termsCount].b + 1;
      sentenceListCount += termSplit.length;
      termsCount++;
    } else {
      splitSentence.add(sentenceList[sentenceListCount]);
      i += sentenceList[sentenceListCount].length + 1;
      sentenceListCount += 1;
    }
  }

  return splitSentence;
}