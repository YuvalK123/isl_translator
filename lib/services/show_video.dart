import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isl_translator/shared/reg.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

List<String> saveTerms = [];

/* Split the word to letters */
List<String> splitToLetters(String word) {
  List<String> lettersList = List<String>(word.length);
  var num = 0;
  for (var i = num; i < word.length; i++) {
    print(word[i]);
    lettersList[i] = word[i];
  }
  return lettersList;
}

/* Search for terms in the sentence and return a list ot terms */
List<String> searchTerm(String sentence, List<String> saveTerms) {
  List<String> terms = [];
  for (var i = 0; i < saveTerms.length; i++) {
    var searchName = saveTerms[i].replaceAll(new RegExp(r'[\u200f]'), "");
    if (sentence.contains(new RegExp(searchName, caseSensitive: false))) {
      terms.add(saveTerms[i]);
    }
  }
  print(terms);
  return terms;
}

/* Find all the terms in DB - maybe to do it only once and save it? */
// Future<List<String>> findTermsDB() async {
Future<void> findTermsDB() async{
  List<String> terms = [];
  // if (FirebaseStorage.instance.app.)
  var futures = <Future>[];
  await FirebaseStorage.instance.ref().child("animation_openpose/").listAll().then((result) {
    var items = result.items;
    for (int i=0; i< items.length; i++){
      futures.add(addSavedExp(items[i]));
    }
  });
  return await Future.wait(futures);
  // return;
}

Future<void> addSavedExp(Reference item) async{
  String videoName = item.toString().substring(55,item.toString().length -5);
  if(videoName.split(" ").length > 1){
    print("adding $videoName");
    saveTerms.add(videoName);
  }
}

/* Split the sentence to word/term and return a list of the split sentence*/
List<String> splitSentence(String sentence) {
  if (sentence == null){
    return null;
  }
  List<String> hebrewLetters = hebrewChars.keys.toList();
  var newSentence = sentence.replaceAll(
      new RegExp(r'[\u200f]'), ""); // replace to regular space
  print("^[${hebrewLetters.toString()}]'");
  var vals = hebrewLetters.toString().substring(1,hebrewLetters.toString().length - 1).replaceAll(",", "");
  newSentence = newSentence.replaceAll(RegExp('[^$vals]'), "");
  print("fixed sentence is $newSentence");
  if (newSentence.isEmpty){
    return null;
  }
  List<String> sentenceList = newSentence.split(" "); //split the sentence to words

  // // get all terms
  // Future<List<String>> futureTerms = findTermsDB();
  // print('futureTerms');
  // futureTerms.then((result) => saveTerms=  result)
  //     .catchError((e) => print('error'));
  print("hello save terms ==> " + saveTerms.toString());
  List<String> terms = searchTerm(newSentence, saveTerms); // terms in the sentence
  //List<String> terms = [];
  //var new_terms = sentence.replaceAll(new RegExp(r'[\u200f]'), "");
  List<String> splitSentence = [];

  // save the index and the length of the terms
  List indexTerms = [];
  for (int i = 0; i < terms.length; i++) {
    indexTerms.add(Pair(newSentence.indexOf(terms[i]), terms[i].length));
  }
  //indexTerms.sort((a, b) => getIndex(a).compareTo(getIndex(b)));
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

/* Create Tuple */
class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}