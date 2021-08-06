import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/models/pair.dart';
import 'package:isl_translator/services/video_fetcher.dart';

List<String> prepositionalLetters = ["כש","ב","כ","מה","מ","ל", "וה","ו", "ה", "ש"];
List<String> prepositional2Letters = ["כש""מה","וה"];
List<String> prepositionalWords = ["של", "את"];


Map<String, String> hebrewChars = {
  "א" : "U+05D0",
  "ב" : "U+05D1",
  "ג" : "U+05D2",
  "ד" : "U+05D3",
  "ה" : "U+05D4",
  "ו" : "U+05D5",
  "ז" : "U+05D6",
  "ח" : "U+05D7",
  "ט" : "U+05D8",
  "י" : "U+05D9",
  "כ" : "U+05DB",
  "ך" : "U+05DA",
  "ל" : "U+05DC",
  "מ" : "U+05DE",
  "ם" : "U+05DD",
  "נ" : "U+05E0",
  "ן" : "U+05DF",
  "ס" : "U+05E1",
  "ע" : "U+05E2",
  "פ" : "U+05E4",
  "ף" : "U+05E3",
  "צ" : "U+05E6",
  "ץ" : "U+05E5",
  "ק" : "U+05E7",
  "ר" : "U+05E8",
  "ש" : "U+05E9",
  "ת" : "U+05EA",
};


/// check if [word] has a starting letter/s in [dirname]
Future<String> getNonPrepositional(String word, String dirName) async{
  String subStr = word.substring(1);
  if (!prepositionalLetters.contains(word[0]) || subStr.length < 2){
    return null;
  }
  print("substr1 == $subStr");
  String url = await getUrl(subStr, dirName);
  if (url == null){
    url = await checkIfProcessedWord(subStr, dirName);
    if (url != null){
      return url;
    }
  }

  String firstTwo = word.substring(0,2);
  bool containsFirstTwo = !prepositional2Letters.contains(firstTwo);
  if (containsFirstTwo || firstTwo.length < 2){
    return null;
  }
  // return await VideoFetcher.getUrl(word.substring(1), dirName);
  subStr = word.substring(2);
  print("substr2 == $subStr");
  url = await getUrl(subStr, dirName);
  if (url == null){
    url = await checkIfProcessedWord(subStr, dirName);
    if (url != null){
      return url;
    }
  }
  return null;
}



/// to delete
Future<String> getUrl(String word,String dirName) async{
  bool isAnimation = dirName.contains("animation");
  String exec = isAnimation ? ".mp4" : ".mkv";
  Reference ref = FirebaseStorage.instance
      .ref()
      .child("$dirName" + word + "$exec");
  try {
    File file = await VideoFetcher.lruCache.fetchVideoFile(word, isAnimation, null);
    if (file != null){
      return "&&";
    }
    // gets the video's url
    var url = await ref.getDownloadURL();
    return url;
  } catch (err) { // no url
    // check if exist in personal videos
    var _auth = FirebaseAuth.instance;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("$dirName" + _auth.currentUser.uid + "/" + word + "$exec");
    try {
      // gets the video's url
      var url = await ref.getDownloadURL();
      return url;
    } catch (err2) {
      return null;
    }
  }
}

/// check for list of [initiatives] parallel if in [dirname]
/// and if it is, return the url
Future<String> parallelCheckForUrl(List<String> initiatives, String dirName) async{
  List<Future<String>> futures = <Future<String>>[];
  for (var initi in initiatives){
    futures.add(getUrl(initi, dirName));
  }
  List<String> results = await Future.wait(futures);
  for (String url in results){
    if (url != null){
      return url;
    }
  }
  return null;
}


/// checks if [word] is a verb by checking in [dirname] in firebase
Future<String> checkIfVerb(String word, String dirName) async{
  // lalechet is a special verb with common use
  if (lalechet.containsKey(word)){
    return await getUrl(lalechet[word], dirName);
  }
  List<String> initiatives = await wordToInitiatives(word, patterns, infinitives);
  if (initiatives != null){
    String url = await parallelCheckForUrl(initiatives, dirName);
    if (url != null){
      return url;
    }
  }
  // 2 letters
  initiatives = await wordToInitiatives(word, patterns2Letters, infinitives2);
  if (initiatives != null){
    String url = await parallelCheckForUrl(initiatives, dirName);
    if (url != null){
      return url;
    }
  }
  // check special cases:
  var specialCase = checkSpecialVerbs(word, false);
  if (specialCase == null){
    specialCase = checkSpecialVerbs2(word, false);
  }
  if (specialCase != null){
   String url = await parallelFindUrlInList(specialCase.a, dirName);
   if (url != null){
     return url;
   }
  }
  // no url for this verb, or is not a verb
  return null;
}


/// checks if [word] is a verb by checking in [dirname] in firebase
/// if it is, returns a url, o.w null
Future<String> checkIfProcessedWord(String word, String dirName) async{
  String url = await checkIfVerb(word, dirName);
  if (url != null){
    return url;
  }
  url = await checkGenderCase(word, dirName);
  if (url != null){
    return url;
  }
  // not a special word
  return null;
}

/// if [root] is with h, fix it
String handleRootH(String root){
  if (root.endsWith("ה") || root.endsWith("י")){ // היה/
    return root.substring(0, root.length-1) + "ת";
  }
  return root;
}


/// convert [word] to [infinitives] by checking regex with [patterns]
/// and return all infinitives if found
Future<List<String>> wordToInitiatives(
    String word, List<String> patterns, List<String> infinitives
    ) async{
  var wordData = await getVerbPatterns(word, patterns); // here we check if in verb pattern
  if (wordData != null){
    var handleMatch = handleVerbMatch(wordData.a, word, infinitives); // is a verb
    return handleMatch;
    }
  return null;
}


/// find first pattern in [patterns] that [word] is by it
/// return pair of pattern/ pattern index
Future<Pair<String, int>> getVerbPatterns(String word, List<String> patterns) async{
  final futures = <Future<Pair<String, int>>>[];
  for (int index = 0; index < patterns.length; index++){
    futures.add(getVerbPattern(word, patterns, index));
  }
  var results = await Future.wait(futures);
  Pair<String, int> res;
  for (var result in results){
    if (result != null){
      res = result;
      if (result.b != patterns.length - 1){
        break;
      }
    }
  }
  return res;
}

/// return pair of [patterns] and pattern [index]
Future<Pair<String, int>> getVerbPattern(String word, List<String> patterns, int index) async{
  var pattern = patterns[index];
  RegExp regExp = RegExp(pattern);
  bool hasMatch = regExp.hasMatch(word);
  if (hasMatch) {
    return Pair(pattern, index);
  }
  return null;
}

// /// if last letter of [infin] is a final letter small letter, handle it

/// if found match of [word] in pattern, convert to all [infinitives]
List<String> handleVerbMatch(String pattern, String word, List<String> infinitives){
  List<String> wordInitiatives = [];
  String root = getRoot(pattern, word);
  root = handleRootH(root);
  if (specialRootLetters.keys.contains(root[0])){
    var verbCheck = checkSpecialVerbs(root, true);
    if (verbCheck != null){
      wordInitiatives.addAll(verbCheck.a);
    }
  }else if (specialRootLettersT.contains(root[0])){
    var verbCheck = checkSpecialVerbs2(root, true);
    if (verbCheck != null){
      wordInitiatives.addAll(verbCheck.a);
    }
  }

  for (var infinitive in infinitives){ // get list of infinitives
    int rootIndex = 0;
    String infin = "";
    for (int i = 0; i <infinitive.length; i++){
      String letter = infinitive[i];
      if (letter == ".") {
        infin += root[rootIndex++];
      } else if (letter == "+" && rootIndex < root.length){
          for (int j = rootIndex; j < root.length; j++){
            infin += root[j];
          }
      } else if (letter != "+"){ // is not a verb letter
          infin += letter;
      }
    }
    // infin = handleFinalLetter(infin);
    wordInitiatives.add(infin);
  }
  // handle final letters
  return wordInitiatives;
}


/// get root of [word] from [pattern]
String getRoot(String pattern, String word){
  String root = "";
  int i = 0, ii = 0;
  for (i =0; i < pattern.length; i++){
    var letter = pattern[i];
    if (letter == "."){
      root += word[i];
    }else if(letter == "{"){ // if done
      ii = i + 5;
      break;
    }
  }
  // check if has finale after {}
  for (int j = i; j < word.length; j++){
    if (pattern.length > ii && pattern[ii] != "."){
      ii++;
      continue;
    }
    root += word[j];
  }
  return root;
}

List<String> patterns = [
  "...{1,2}תי", // אהבתי
  ".ו..{1,2}ת", // אוהבת
  ".ו..{1,2}", // אוהב
  "מ.ו..{1,2}", // מאוהב
  "מ.ו..{1,2}ת", // מאוהבת
  "את...{1,2}", // אתאהב
  "ית...{1,2}", //יתאהב
  "נת...{1,2}", //נתאהב
  "תת...{1,2}", //תתאהב
  "י...{1,2}", //יאהב
  "ת...{1,2}", //תאהב
  "..ו.{1,2}", //אהוב
  "...{1,2}נו", //פעלנו
  "...{1,2}ת", // אהבת
  "...{1,2}ו", // אהבו
  "...{1,2}תן", // אהבתן
  "...{1,2}תם", // אהבתם
  "מ...{1,2}", // מפעל
  "נ...{1,2}", // נפעל
  "נ..ו.{1,2}", // נתפוס
  "י..ו.{1,2}", // יתפוס
  "א..ו.{1,2}", // אתפוס
  "...{1,2}", // אהב
];

List<String> patterns2Letters = [
  "..תי", // רצתי
  "נ.ו.", //נרוץ
  "י.ו.", //ירוץ
  "ת.ו.", //תרוץ
  "..נו", //רצנו
  "..ת", // רצת
  "..ו", // רצו
  "..תן", // רצתן
  "..תם", // רצתם
  "..", // רץ
  "ה..", // רץ
];



List<String> infinitives = [ // שם פועל
  "ל..ו.+", // לפעול
  "לה...+", // להעלם
  "ל...+", // לחשוב/לחשב
  "ל..ו.+", // לחשוב/לחשב
  "לה..י.+", // להפעיל
  "להת...+", // להתפעל
];

List<String> infinitives2 = [ // שם פועל
  "ל.ו.", // לפעול
  "לה.י.", // להפעיל
  "ל..", // לחשב
];

/// find urls in [words] , and if find valid url returns it
Future<String> parallelFindUrlInList(List<String> words, String dirName) async{
  List<Future<String>> futures = <Future<String>>[];
  for (var word in words){
    // futures.add(VideoFetcher.getUrl(word, dirName));
    futures.add(getUrl(word, dirName));
  }
  List<String> results = await Future.wait(futures);
  for (var url in results){
    if (url != null){
      return url;
    }
  }
  return null;
}

///  checks if its male/female [word], and sends versions of it with
///  the [dirname] to see if works
Future<String> checkGenderCase(String word, String dirName) async{
  // גרפיקאי->גרפיקאית
  List<String> singularVersions = [];
  String singular;
  if (word.endsWith("ים") || word.endsWith("ות")){ // גרושים/גרושות, פועלים/פועלות
    singular = word.substring(0,word.length-2);
    singularVersions = [singular + "ה", singular + "ית", singular + "ת", singular + "י"];
  }
  else if (word.endsWith("ה") ||  word.endsWith("ת")){
    singular = word.substring(0,word.length-1);
    singularVersions = [singular + "ות", singular + "ים", singular + "ו"];
  } else if(word.endsWith("י")){
    singular = word;
    singularVersions = [singular + "ות", singular + "ם", singular + "ת"];
  }else{ // check versions
    singular = word;
    singularVersions = [singular + "ות", singular + "ים", singular + "ה",
      singular + "ת", singular + "ית"];
  }
  if (singularVersions.isNotEmpty){
    if (singular.length > 1){
      singularVersions.add(singular);
    }
    var url = await parallelFindUrlInList(singularVersions, dirName);
    if (url != null){
      return url;
    }
  }
  return null;
}

/// check if [verb] special verb with z,s
Pair<List<String>,String> checkSpecialVerbs(String verb, bool isRoot){
  // הזדקן, השתמש, הסתפר
  String root = verb;
  List<String> inftis = [];
  if (verb.length < 2){
    return null;
  }
  if(!isRoot){
    if (!specialRootLetters.keys.contains(verb[1]) || !startingletters.contains(verb[0])){
      return null;
    }
    root = verb.substring(1);
    inftis.add("ל" + root); // לספר, לצלם
  }

  String infti = "לה" + root[0] + specialRootLetters[root[0]] + root.substring(1);
  inftis.add(infti);
  return Pair(inftis, root);
}



/// check if [verb] is special verb with short
Pair<List<String>,String> checkSpecialVerbs2(String verb, bool isRoot){
  // אתמר במקום אתתמר, אטלפן, אדפק
  String root = verb;
  List<String> inftis = [];
  if (!isRoot){
    if (!specialRootLettersT.contains(verb[1]) || !startingletters.contains(verb[0])){
      return null;
    }

    // check so i wont use on התפעל
    root = verb.substring(1);
    inftis.add( "ל" + root.substring(0,2) + "ו" + root.substring(2));//; // לדפוק)
  }
  String infti1 = "לה" + root; // להדפק
  String infti2 = "להי" + root; // להידפק
  inftis.add(infti1);
  inftis.add(infti2);
  return Pair(inftis, root);
}

Map<String, String> lalechet = {
  "הלך": "ללכת",
  "הלכה": "ללכת",
  "הלכתי": "ללכת",
  "ילך": "ללכת",
  "תלך": "ללכת",
  "הולך": "ללכת",
  "הולכת": "ללכת",

};

List<String> startingletters = ["א","י","מ","נ","ת", "ה"]; // אזדקן, תזדקן, נזדקן, יזדקן, מזדקן, הזדקן
List<String> specialRootLettersT = ["ד","ט","ת"];
Map<String,String> specialRootLetters = {
  "ס": "ת",
  "ש" : "ת",
  "ז" : "ד",
  "צ" : "ט",
};