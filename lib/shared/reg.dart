
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/services/show_video.dart';

List<String> verbs = [
  "אהב" , "בגד" , "בדק" , "בא", "בלע", "ברח", "ברר",
  "אסף", "בקר", "אכל", "גהץ", "אחל", "אפה",
  "בטל", "בקש", "ארגן", "", "", "",
];

String nonAsciiChar = "[^\x00-\x7F]";
// String reg = "הת$nonAsciiChar$nonAsciiChar$nonAsciiChar";

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

Future<String> getUrl(String word) async{
  Reference ref = FirebaseStorage.instance
      .ref()
      .child("animation_openpose/" + word + ".mp4");
  try {
    // gets the video's url
    var url = await ref.getDownloadURL();
    return url;
  } catch (err) { // no url
    // print(err);
    return null;
  }
}

Future<String> checkIfVerb(String word) async{
  List<String> initiatives = wordToInitiatives(word);
  print("inits are $initiatives");
  if (initiatives == null){
    return null;
  }
  // search for url
  for (var initi in initiatives){
    var url = await getUrl(initi);
    if (url != null){
      print("found url for $initi : $url");
      return url;
    }
    print("no url for $initi");
  }
  // no url for this verb
  return null;
}

List<String> wordToInitiatives(String word){
  List<String> wordInitiative = [];
  // verbs.forEach((verb) {
  //   print("now at verb $verb");
  //   if (verb[verb.length - 1] == "ה"){
  //     // TODO: from h to y
  //     // רצה -> רציתי
  //   }
  //   if (verb[0] == "א"){
  //     // TODO: remove a if past tense
  //   }
  //   var wordData = getVerbPattern(word); // here we check if in verb pattern
  //   if (wordData != null){
  //     return handleVerbMatch(wordData.b, wordData.a, word); // is a verb
  //   }
  // });
  var wordData = getVerbPattern(word); // here we check if in verb pattern
  print("word data = $wordData");
  if (wordData != null){
    print("wordData not null!!");
    var handleMatch = handleVerbMatch(wordData.b, wordData.a, word); // is a verb
    return handleMatch;
    }
  return null;
}

Pair<String, int> getVerbPattern(String word){
  // return pair of pattern/ pattern index
  // print("patterns length is ${patterns.length}");
  // print("patterns = $patterns");
  for (int index = 0; index < patterns.length; index++){
    var pattern = patterns[index];
    print("($index) at pattern ${pattern}");
    RegExp regExp = RegExp(pattern);

    // Iterable<RegExpMatch> matches = regExp.allMatches(word);
    bool hasMatch = regExp.hasMatch(word);
    print("has match? $hasMatch");
    if (hasMatch){

      return Pair(pattern, index);
    }
  }
  print("___");
  // patterns.asMap().forEach((index, pattern) {
  //   print("($index) at pattern $pattern");
  //   RegExp regExp = RegExp(pattern);
  //
  //   // Iterable<RegExpMatch> matches = regExp.allMatches(word);
  //   bool hasMatch = regExp.hasMatch(word);
  //   print("has match? $hasMatch");
  //   if (hasMatch){
  //     return Pair(pattern, index);
  //   }
  // });
  return null;
}

List<String> handleVerbMatch(int index, String pattern, String word){
  print("search root...");
  String root = getRoot(index, pattern, word);
  print("root is $root");
  List<String> wordInitiatives = [];
  for (var infinitive in infinitives){ // get list of infinitives
    print("in for infinitive");
    int rootIndex = 0;
    print("infinitive is $infinitive, root is $root");
    String infin = "";
    for (int i = 0; i <infinitive.length; i++){
      print("($i) infin letter = ${infinitive[i]}");
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
      // } else if (letter == "{" && rootIndex < root.length){
      //   for (int j = rootIndex; j < root.length; j++){
      //     infin += root[j];
      //   }
      // } else if (letter != "{" || letter != "1" || letter != "2" ||
      //     letter != "," || letter != "}"){ // is not a verb letter
      //   infin += letter;
      // }
    }
    infin = handleFinalLetter(infin);
    wordInitiatives.add(infin);
    // להתפעל

    // לפעול
    // לפעל
    // לחשוב
    // לחשב
    // להפעיל
  }

  // handle final letters
  return wordInitiatives;
}

String handleFinalLetter(String infin){
  // if last letter is a final letter small letter, handle it
  String lastLetter = infin[infin.length - 1], newInfin = "";
  if (lastLetter == "כ"){
    // newInfin = infin[-1];
    // infin[infin.length - 1] = "ך";
  } else if (lastLetter == "מ"){

  } else if (lastLetter == "נ"){

  } else if (lastLetter == "צ"){

  }else if (lastLetter == "פ"){

  } else{
    return infin;
  }
  return infin;
}

String getVerb(String root){
  return null;
}

String getRoot(int index, String pattern, String word){
  String root = "";
  int i = 0;
  print("start root loop");
  for (i =0; i < pattern.length; i++){
    var letter = pattern[i];
    print("($i) $letter");
    if (letter == "."){
      root += word[i];
    }else if(letter == "{" || letter == "1" || letter == "2" ||
        letter == "," || letter == "}"){
      print("break");
      break;
    }
  }
  for (int j = i; j < word.length; j++){
    print("at j loop");
    root += word[j];
  }
  return root;
  switch (index){
    case 0: // אהבתי
      break;
    case 1: // אוהב
      break;
    case 2: // מאוהב
      break;
    case 3: // מאוהבת
      break;
    case 4: // אתאהב
      break;
    case 5: // יתאהב
      break;
    case 6: // תתאהב
      break;
    case 7: // יאהב
      break;
    case 8: // תאהב
      break;
    case 9: // אהב
      break;
    case 10: //אהוב
      break;
    case 11: // אהבנו
      break;
    case 12: // אהבת
      break;
    case 13: // אהבו
      break;
    case 14: // אהבתן
      break;
    default: // אהבתם
      break;
  }
   return null;
  if (pattern == patterns[0]){ // אהבתי

  }
  if (pattern == patterns[1]){

  }
  if (pattern == patterns[2]){

  }
  if (pattern == patterns[3]){

  }
  if (pattern == patterns[4]){

  }
  if (pattern == patterns[5]){

  }
  if (pattern == patterns[6]){

  }
  if (pattern == patterns[7]){

  }
  if (pattern == patterns[8]){

  }
  if (pattern == patterns[9]){

  }
  if (pattern == patterns[10]){

  }
  if (pattern == patterns[11]){

  }
  if (pattern == patterns[12]){

  }
  if (pattern == patterns[13]){

  }
}

List<String> patterns = [
  "...{1,2}תי", // אהבתי
  ".ו..{1,2}", // אוהב
  "מ.ו..{1,2}", // מאוהב
  "מ.ו..{1,2}ת", // מאוהבת
  "את...{1,2}", // אתאהב
  "ית...{1,2}", //יתאהב
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
  "...{1,2}", // אהב
];

// List<String> patterns = [
//   "...+${hebrewChars["ת"]}${hebrewChars["י"]}", // אהבתי
//   ".${hebrewChars["ו"]}..+", // אוהב
//   "${hebrewChars["מ"]}.${hebrewChars["ו"]}..+", // מאוהב
//   "${hebrewChars["מ"]}.${hebrewChars["ו"]}.$nonAsciiChar+${hebrewChars["ת"]}", // מאוהבת
//   "${hebrewChars["א"]}${hebrewChars["ת"]}..$nonAsciiChar+", // אתאהב
//   "${hebrewChars["י"]}${hebrewChars["ת"]}..$nonAsciiChar+", //יתאהב
//   "${hebrewChars["ת"]}${hebrewChars["ת"]}..$nonAsciiChar+", //תתאהב
//   "${hebrewChars["י"]}..$nonAsciiChar+", //יאהב
//   "${hebrewChars["ת"]}..$nonAsciiChar+", //תאהב
//   "..$nonAsciiChar+", // אהב
//   "..${hebrewChars["ו"]}$nonAsciiChar+", //אהוב
//   "..$nonAsciiChar+${hebrewChars["נ"]}${hebrewChars["ו"]}", //פעלנו
//   "..$nonAsciiChar+${hebrewChars["ת"]}", // אהבת
//   "..$nonAsciiChar+${hebrewChars["ו"]}", // אהבו
//   "..$nonAsciiChar+${hebrewChars["ת"]}${hebrewChars["ן"]}", // אהבתן
//   "..$nonAsciiChar+${hebrewChars["ת"]}${hebrewChars["ם"]}", // אהבתם
// ];

Map <String, String> verbsToRoots = {
  "אהבתי": "",
  "אוהב": "",
  "מאוהב": "",
  "מאוהבת": "",
  "אתאהב": "",
  "יאהב": "",
  "תאהב": "",
  "אהב": "",
  "יתאהב": "",
  "תתאהב": "",
  "אהוב": "",
  "אהבנו": "",
  "אהבת": "",
  "אהבו": "",
  "אהבתן": "",
  "אהבתם": "",
};

Map<String, int> verbsRootsIndex = {
  "אהב" : 0 ,
  "בגד" : 1,
  "בדק" : 2,
  "בא" : 3,
  "בלע" : 4,
  "ברח" : 5,
  "ברר" : 6,
  "אסף" : 7,
  "בקר" : 8,
  "אכל" : 9,
  "גהץ" : 10,
  "אחל" : 11,
  "אפה" : 12,
  "בטל" : 13,
  "בקש" : 14,
  "ארגן" : 15,
};

List<String> verbsRoots = [
  "פעל",
  "נפעל",
  "הפעיל",
  "הפעל",
  "פיעל",
  "פועל",
  "התפעל"
];

List<String> infinitives = [ // שם פועל
  "ל..ו.+", // לפעול
  "לה...+", // להעלם
  "ל...+", // לחשוב/לחשב
  "ל..ו.+", // לחשוב/לחשב
  "לה..י.+", // להפעיל
  "להת...+", // להתפעל
];

// List<String> infinitives = [ // שם פועל
//   "${hebrewChars["ל"]}..${hebrewChars["ו"]}.+", // לפעול
//   "${hebrewChars["ל"]}${hebrewChars["ה"]}...+", // להעלם
//   "${hebrewChars["ל"]}...+", // לחשוב/לחשב
//   "${hebrewChars["ל"]}..${hebrewChars["ו"]}.+", // לחשוב/לחשב
//   "${hebrewChars["ל"]}${hebrewChars["ה"]}..${hebrewChars["י"]}.+", // להפעיל
//   "${hebrewChars["ל"]}${hebrewChars["ה"]}${hebrewChars["ת"]}...+}", // להתפעל
// ];

Map<String, int> verbs1 = {
  "ברר": 6,
  "אהב": 0,
  "בגד": 0 ,
  "בדק": 0 ,
  "בא": 0,
  // "בלע": ,
  // "ברח": [],
  // "אסף": [],
  // "בקר": [],
  // "אכל": [],
  // "גהץ": [],
  // "אחל": [],
  // "אפה": [],
  // "בטל": [],
  // "בקש": [],
  // "ארגן": [],
  // "זרק": ["לזרוק"],
  // "שכנע": ["לשכנע"],
  // "שמע": ["לשמוע"],



};

Map<String, List<String>> verbs2 = {
  "ברר": ["לברור"],
  "אהב":[] ,
  "בגד": [] ,
  "בדק": [] ,
  "בא": [],
  "בלע": [],
  "ברח": [],
  "אסף": [],
  "בקר": [],
  "אכל": [],
  "גהץ": [],
  "אחל": [],
  "אפה": [],
  "בטל": [],
  "בקש": [],
  "ארגן": [],
  "זרק": ["לזרוק"],
  "שכנע": ["לשכנע"],
  "שמע": ["לשמוע"],



};



RegExp regExp = RegExp("source");