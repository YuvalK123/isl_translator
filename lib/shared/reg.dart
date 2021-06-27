
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/services/show_video.dart';




List<String> prepositionalLetters = ["ב","כ","מ","ל", "ו", "ה"];

List<String> endingRelative = ["","","","","",""];

Map<String, String> endings = {
  "ת": "ה",
};



Future<String> getNonPrepositional(String word, String dirName) async{
  if (!prepositionalLetters.contains(word[0])){
    return null;
  }
  return await getUrl(word.substring(1), dirName);
}


String nonAsciiChar = "[^\x00-\x7F]";

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

Future<String> getUrl(String word,String dirName) async{
  String exec = dirName == "animation_openpose/" ? ".mp4" : ".mkv";
  Reference ref = FirebaseStorage.instance
      .ref()
      .child("$dirName" + word + "$exec");
  try {
    // gets the video's url
    var url = await ref.getDownloadURL();
    return url;
  } catch (err) { // no url
    // print(err);
    return null;
  }
}

Future<String> checkIfVerb(String word, String dirName) async{
  List<String> initiatives = wordToInitiatives(word, patterns);
  print("inits are $initiatives");
  if (initiatives == null){
    return null;
  }
  // search for url
  for (var initi in initiatives){
    var url = await getUrl(initi, dirName);
    if (url != null){
      print("found url for $initi : $url");
      return url;
    }
    print("no url for $initi");
  }
  // 2 letters

  initiatives = wordToInitiatives(word,patterns2Letters);
  print("inits are $initiatives");
  if (initiatives == null){
    return null;
  }
  // search for url
  for (var initi in initiatives){
    var url = await getUrl(initi, dirName);
    if (url != null){
      print("found url for $initi : $url");
      return url;
    }
    print("no url for $initi");
  }

  // no url for this verb
  return null;
}

String handleRootH(String root){
  if (root.endsWith("ה") || root.endsWith("י")){
    return root.substring(0, root.length-2) + "ת";
  }
  return root;
}

List<String> wordToInitiatives(String word, List<String> patterns){
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
  var wordData = getVerbPattern(word, patterns); // here we check if in verb pattern
  print("word data = $wordData");
  if (wordData != null){
    print("wordData not null!!");
    var handleMatch = handleVerbMatch(wordData.b, wordData.a, word); // is a verb
    return handleMatch;
    }
  return null;
}



Pair<String, int> getVerbPattern(String word, List<String> patterns){
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
  print("root be4 process is $root");
  root = handleRootH(root);
  print("root after process is $root");
  List<String> wordInitiatives = [];
  for (var infinitive in infinitives){ // get list of infinitives
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
  int i = 0, ii = 0;
  print("start root loop");
  for (i =0; i < pattern.length; i++){
    var letter = pattern[i];
    print("($i) $letter");
    if (letter == "."){
      root += word[i];
    }else if(letter == "{"){
      print("break");
      ii = i + 5;
      break;
    }
  }
  // print("pattern at ii = ${pattern[ii]}");
  for (int j = i; j < word.length; j++){
    print("at j loop");
    if (pattern.length > ii && pattern[ii] != "."){
      print("ii nono $ii ${pattern[ii]}");
      ii++;
      continue;
    }
    print("yay $i");
    root += word[j];
  }
  return root;
}

// רציתי -> רציתי, רצו, רציתן/ם

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
  "...{1,2}", // אהב
];

// רץ
// קם

List<String> patterns2Letters = [
  "..תי", // רצתי
  "נ.ו.", //נרוץ
  "י.ו.", //ירוץ
  "ת.ו.", //תרוץ
  // "..ו.{1,2}", //אהוב
  "..נו", //רצנו
  "..ת", // רצת
  "..ו", // רצו
  "..תן", // רצתן
  "..תם", // רצתם
  // "מ...{1,2}", // מפעל
  "..", // רץ
];

Map<int, String> indexToInfti = {
  1 : "ללכת",
  2: "לרוץ",
  3 : "לקום",
  4: "לתת",

};

Map<String, int> shortRootsVerbs = {
  "הלך" : 1,
  "הלכה" : 1,
  "ילך" : 1,
  "תלך" : 1,
  "הלכו" : 1,
  "ילכו" : 1,
  "הולכים" : 1,
  "נלכנה" : 1,
  "הלכתי" : 1,
  "הלכנו" : 1,
  "הלכתם" : 1,
  "הלכתן" : 1,
  "אתהלך" : 1,
  "הולך" : 1,
  "הולכת" : 1,

  "רץ" : 2,
  "רצה" : 2,
  "ירוץ" : 2,
  "תרוץ" : 2,
  "רצו" : 2,
  "ירוצו" : 2,
  "רצים" : 2,
  "נרוץ" : 2,
  "רצתי" : 2,
  "רצנו" : 2,
  "רצתם" : 2,
  "רצתן" : 2,
  "ארוץ" : 2,

  "קם" : 3,
  "קמה" : 3,
  "יקום" : 3,
  "קמו" : 3,
  "קמות" : 3,
  "קמים" : 3,
  "יקומו" : 3,
  "תקומו" : 3,

  "נתן" : 4,
  "יתן" : 4,
  "תתן" : 4,
  "נתנו" : 4,
  "יתנו" : 4,
  "נותנים" : 4,
  "נותנות" : 4,
  "תתנו" : 4,
};

List<String> pluralVerbs = [
  "", // נפעול
  "", // נפעול
  "", // תפעלו
];

// to be continued

void checkGenderCase(String word){
  // checks if its male/female word - גרפיקאי->גרפיקאית

}

void checkPluralCase(String word){
  // checks if plural/singular case - גרוש->גרושים
}


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