
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/services/show_video.dart';


List<String> infinitivess = [
  "להדיח", "לסלק", "להדיח כלים", "להעתיק",  "לסתום", "לצבוע",
  "לפתוח דלת", "לרתוח", "לדעת", "להיכשל בבחינה", "לפתוח", "להטיל ספק",
  "לפתוח חלון", "לעקור שן", "לפרוץ בבכי", "לעקור", "לרכוב",
  "לרכוב על אופניים", "לרכוב על סוס", "לפתוח תיק", "למעוך אוכל", "למעוך",
  "לעקור צמח", "לרחוץ בעל חיים", "לרחוץ", "לנקד", "לסרב", "לצחצח נעליים",
  "לצחצח שיניים", "לנעוץ", "להבריק", "לצחצח", "לקצר", "להתרחץ", "להסתפר",
  "להתאבד", "לעלות", "לעלות במדרגות", "לקטוף פרי", "לקטוף",
  "לגדוע", "לעלות במדרגות נעות", "לכרות", "לנפח", "לקטוע", "לנפח גלגל",
  "לעלות במעלית", "לאהוב", "לאהוב משהו", "לבקר", "לימוד", "להדליק טלוויזיה",
  "להדליק מדורה", "להדליק אור", "להדליק", "להדליק גפרור", "להתחנן",
  "לתפוס בשעת מעשה", "לברור", "לישון", "לכבות מדורה", "להשתיק", "להתנחל",
  "לכבות שריפה", "להשתמש", "לכבות גפרור", "לדחות", "לכבות", "לטייל",
  "להסתובב", "לכבות את האור", "לטעון",  "לפחד",
  "למשוך", "לחסום", "לקרוא", "לרוץ", "לקום", "לנתק", "לי", "להבטיח", "לשיר",
  "לעשות", "לצחוק", "לטוס", "לקלף", "לשבוע", "להיפרד", "להיפרד לשלום",
  "לבגוד", "להחליף", "לבגוד במדינה", "לטפל", "לסדר", "לארגן", "להחליט",
  "לנום", "להיכנס", "להתחיל", "לדרוך", "להשקיט", "לרמוס", "לנוח", "להגר",
  "למיין", "לעזוב את הארץ", "לתפוס על חם", "לבזבז", "לחשוב", "לתפוס",
  "לקלוט", "לגלח", "לעטוף", "לרקוד", "לגהץ", "לטרוף", "לנבוח", "לשלם",
  "לתמוך", "להתאכזב", "לחייך", "להאמין", "להזיע", "לבכות", "ליפול", "לבוא",
  "להמציא", "להצטבר", "לפטפט", "לשדרג", "להשפיע", "להיכשל", "לעודד",
  "להכין", "להשקיף", "לראות", "לפייס", "להזמין", "להצטרף", "להרביץ",
  "לנצל", "לשמוע", "לך", "לברוא", "לסבול", "לרכז", "להצליח", "לקשט",
  "לפסול",  "לשכנע", "לשים לב", "לברך", "להתפלל",
   "להמיר",  "ללמוד",  "לשתות", "לנגוס", "ללגום",
  "למזוג",  "לאחל", "ללמד", "ללכת", "לצאת", "ללכת ברגל",
  "לתקוע בשופר", "לדבר", "לסרוג", "לצלול", "לקחת", "לשכוח", "לחתור", "לבקש", "להיזהר",
  "לשאול", "לקנות", "להילחם", "להסתכל סביב", "להתפטר", "לנאום", "לקפל", "לפטר", "לבדוק", "לשטוף", "להיכנע",
  "להמריא", "לתת", "להשתעל", "לנמנם", "לנחם", "לסמוך", "לחשוד", "לברוח", "להפריד", "לטפס",
  "להתעורר", "לרחם", "לחפש", "להפריע", "ללוות", "לצפות", "ללוש", "לבטל", "לגרש", "לדקור", "לזרוק", "להתרגש",
  "לשנוא", "להתנגד", "לטבול", "לזרוע", "לחנוק", "לרשום", "להפסיד", "להחזיר", "להטעין", "לזלזל", "למרוח",
  "לכעוס", "לאסוף", "להשתדל", "להתפלא", "להעביר", "לנגוע", "למצוא", "לערבב", "להתקרב", "להוציא", "למהר", "להפוך",
  "לעזוב", "לסגור", "לגעור", "להכניס", "להתלונן", "לשלוח", "לנדוד", "לצוות", "להתרכז", "לזעום", "להסכים", "להגיע",
  "לשבת", "ללטף", "לשכב", "להתחרט", "לחגוג", "להגיד", "לאכול", "לבלוע", "להירדם", "לדרוש", "לשאוב", "לדרוס",
  "לעבוד", "לנגב",  "להצטער", "להתקשר", "לירות", "לחתוך", "ללעוג", "לשחק", "להודיע", "להיבהל",
  "למכור", "לקבל", "ללבוש", "לצייר", "להחליק", "לצעוק", "להקים", "להתבייש", "לשמור", "להרוג", "להשתתף", "לעזור",
  "לנסות", "לחטוף", "להתחשב",
  "להיעלב", "לחלות", "לפגוש", "להריח", "לחזור", "לשים", "לבחור", "להוסיף", "לגזור", "לעמוד", "לנחות",
  "לעצור", "להקשיב", "להתחייב", "להתלבט", "לכם", "לעקוץ", "לכתוב", "לזכור", "לנסוע", "לרצות", "לא מבין",
  "לא מכיר", "להחזיק", "להכיר", "לרדוף", "לפזר", "לקפוץ", "לנחש", "להרגיש",
  "להיפגע", "לחבב", "להבין", "להביא", "לאפות", "לקבוע", "להתעמל"
];

List<String> prepositionalLetters = ["ב","כ","מ","ל", "ו", "ה", "ש"];
List<String> prepositionalWords = ["של"];

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

Future<String> checkForUrl(List<String> initiatives, String dirName) async{
  for (var initi in initiatives){
    var url = await getUrl(initi, dirName);
    if (url != null){
      print("found url for $initi : $url");
      return url;
    }
    print("no url for $initi");
  }
  return null;
}

Future<String> checkIfVerb(String word, String dirName) async{
  // print(" special try = ${checkSpecialVerbs(word, false).a}");
  // print(" special try 2 = ${checkSpecialVerbs2(word, false)?.a}");

  List<String> initiatives = wordToInitiatives(word, patterns, infinitives);
  print("1 inits are $initiatives");
  if (initiatives != null){
    String url = await checkForUrl(initiatives, dirName);
    if (url != null){
      return url;
    }
  }

  // search for url

  // 2 letters

  initiatives = wordToInitiatives(word, patterns2Letters, infinitives2);
  print("2 inits are $initiatives");
  if (initiatives != null){
    String url = await checkForUrl(initiatives, dirName);
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
   String url = await findUrlInList(specialCase.a, dirName);
   if (url != null){
     return url;
   }
  }
  String url = await checkGenderCase(word, dirName);
  if (url != null){
    return url;
  }

  // search for url
  // for (var initi in initiatives){
  //   var url = await getUrl(initi, dirName);
  //   if (url != null){
  //     print("found url for $initi : $url");
  //     return url;
  //   }
  //   print("no url for $initi");
  // }

  // no url for this verb
  return null;
}

String handleRootH(String root){
  if (root.endsWith("ה") || root.endsWith("י")){ // היה/
    return root.substring(0, root.length-1) + "ת";
  }
  return root;
}

List<String> wordToInitiatives(String word, List<String> patterns, List<String> infinitives){
  List<String> wordInitiative = [];
  // verbs.forEach((verb) {
  //   print("now at verb $verb");
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
    var handleMatch = handleVerbMatch(wordData.b, wordData.a, word, infinitives); // is a verb
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


List<String> handleVerbMatch(int index, String pattern, String word, List<String> infinitives){
  print("search root...");
  List<String> wordInitiatives = [];
  String root = getRoot(index, pattern, word);
  print("root be4 process is $root");
  root = handleRootH(root);
  print("root after process is $root");
  if (specialRootLetters.keys.contains(root[0])){
    var verbCheck = checkSpecialVerbs(root, true);
    if (verbCheck != null){
      wordInitiatives.addAll(verbCheck.a);
      // String url = await findUrlInList(verbCheck.a, "dirName");
    }
  }else if (specialRootLettersT.contains(root[0])){
    var verbCheck = checkSpecialVerbs2(root, true);
    if (verbCheck != null){
      wordInitiatives.addAll(verbCheck.a);
      // String url = await findUrlInList(verbCheck.a, "dirName");
    }
  }

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
  print("got for $word -> $wordInitiatives");
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
  "נ...{1,2}", // נפעל
  "נ..ו.{1,2}", // נתפוס
  "י..ו.{1,2}", // יתפוס
  "א..ו.{1,2}", // אתפוס
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
  5: "לשים",
  6: "ללוש",
  7: "לבוא"

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

  "שם" : 5,
  "תשים" : 5,
  "ישים" : 5,
  "ישימו" : 5,
  "שמה" : 5,
  "שמים" : 5,
  "שמות" : 5,
  "תשימו" : 5,

  "לש" : 6,
  "תלוש" : 6,
  "ילוש" : 6,
  "ילושו" : 6,
  "לשה" : 6,
  "לשים" : 6,
  "אלוש" : 6,
  "תלושו" : 6,
};

List<String> pluralVerbs = [
  "", // נפעול
  "", // נפעול
  "", // תפעלו
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

List<String> infinitives2 = [ // שם פועל
  "ל.ו.", // לפעול
  "לה.י.", // להפעיל
  "ל..", // לחשב
];



// to be continued

// if plural male/female

// if single and if male - convert to female + plurals
// if single and if female - convert to male + plurals

Future<String> findUrlInList(List<String> list, String dirName) async{
  for (var word in list){
    var url = await getUrl(word, dirName);
    if (url != null){
      print("findUrlList found url for $word: $url");
      return url;
    }
  }
  return null;
}

Future<String> checkGenderCase(String word, String dirName) async{
  // checks if its male/female word - גרפיקאי->גרפיקאית
  List<String> singularVersions = [];
  if (word.endsWith("ים") || word.endsWith("ות")){ // גרושים/גרושות, פועלים/פועלות
    String singular = word.substring(0,word.length-2);
    singularVersions = [singular, singular + "ה", singular + "ית", singular + "ת", singular + "י"];
    print("singular (1) == $singularVersions");
  }
  else if (word.endsWith("ה") ||  word.endsWith("ת")){
    String singular = word.substring(0,word.length-1);
    singularVersions = [singular, singular + "ות", singular + "ים", singular + "ו"];
    print("singular (2) == $singularVersions");
  } else if(word.endsWith("י")){
    String singular = word;
    singularVersions = [singular + "ות", singular + "ם", singular + "ת"];
    print("singular (3) == $singularVersions");
  }else{
    String singular = word;
    singularVersions = [singular + "ות", singular + "ים", singular + "ה",
      singular + "ת", singular + "ית"];
    print("singular (4) == $singularVersions");
  }
  if (singularVersions.isNotEmpty){
    var url = findUrlInList(singularVersions, dirName);
    if (url != null){
      return url;
    }
  }
  return null;
}

Pair<List<String>,String> checkSpecialVerbs(String verb, bool isRoot){
  // הזדקן, השתמש, הסתפר
  // Map<String, String> specialLetters = {
  //   "ס": "ת",
  //   "ש" : "ת",
  //   "ז" : "ד",
  //   "צ" : "ט",
  // };
  // List<String> startingletters = ["א","י","מ","נ","ת", "ה"]; // אזדקן, תזדקן, נזדקן, יזדקן, מזדקן
  String root = verb;
  List<String> inftis = [];
  if(!isRoot){
    if (!specialRootLetters.keys.contains(verb[1]) || !startingletters.contains(verb[0])){
      return null;
    }
    // root = verb[1] + verb[3] + verb[4];
    root = verb.substring(1);
    inftis.add("ל" + root); // לספר, לצלם
    // if (verb.length > 5) {
    //   root += verb[5];
    // }
  }

  String infti = "לה" + root[0] + specialRootLetters[root[0]] + root.substring(1); //root[1] + root[2]; // להזדקן, להשתמש, להסתפר
  inftis.add(infti);
  return Pair(inftis, root);
}


Pair<List<String>,String> checkSpecialVerbs2(String verb, bool isRoot){
  // הזדקן, השתמש, הסתפר
  String root = verb;
  List<String> inftis = [];
  if (!isRoot){
    // List<String> specialLetters = ["ד","ט","ת"]; // אתמר במקום אתתמר, אטלפן, אדפק
    if (!specialRootLettersT.contains(verb[1]) || !startingletters.contains(verb[0])){
      return null;
    }

    // check so i wont use on התפעל
    root = verb.substring(1);
    inftis.add( "ל" + root.substring(0,2) + "ו" + root.substring(2));//; // לדפוק)
  }

  String infti1 = "לה" + root; // להדפק
  String infti2 = "להי" + root; // להדפק
  inftis.add(infti1);
  inftis.add(infti2);

  // if (root.length > 3){
  //   infti += root[3];
  // }
  print("yoyo1234 $inftis}");
  return Pair(inftis, root);
}

List<String> startingletters = ["א","י","מ","נ","ת", "ה"]; // אזדקן, תזדקן, נזדקן, יזדקן, מזדקן, הזדקן
List<String> specialRootLettersT = ["ד","ט","ת"];
Map<String,String> specialRootLetters = {
  "ס": "ת",
  "ש" : "ת",
  "ז" : "ד",
  "צ" : "ט",
};