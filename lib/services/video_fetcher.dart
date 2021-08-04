import 'dart:async';
import 'dart:io' as io;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:isl_translator/services/video_cache.dart';
import 'package:isl_translator/shared/reg.dart';
import 'package:firebase_auth/firebase_auth.dart';


class VideoFetcher { // extends State<VideoFetcher> {
  bool doneLoading = false;
  List<String> urls = [];
  final String sentence;
  bool isValidSentence = false;
  static String lettersCachePath;
  static LruCache lruCache = LruCache();

  Map<int, String> indexToUrl = Map<int,String>();
  Map<String,String> wordsToUrls = {};
  Map<int,String> indexToWord = {};

  final _auth = FirebaseAuth.instance;
  static final savedLetters = <String>[];

  bool get isFirstLoaded {
    return indexToUrl.containsKey(0);
  }

  VideoFetcher({this.sentence});

  static Future<List<String>> getDowloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) {
        ref.getDownloadURL();
      }).toList());


  // List<String> specialChars = ["*","-","_","'","\"","\\","/","=","+",",",".","?","!"];

  Future<List<String>> proccessWord(String word,String dirName) async{
    String exec = dirName == "animation_openpose/" ? "mp4" : "mkv";
    List<String> urls = [];
    print("check for verb...");
    final stopWatch = Stopwatch()..start();
    var verb = await checkIfVerb(word, dirName);
    print("elapsed: ${stopWatch.elapsed} is verb??? $verb");
    if (verb != null){
      urls.add(verb);
      // return {word : verb};
      return urls;
    }
    var nonPre = await getNonPrepositional(word, dirName);
    if (nonPre != null){
      // return {word : nonPre};
      urls.add(nonPre);
      return urls;
    }
    // Video doesn't exist - so split the work to letters
    var letters = splitToLetters(word);
    for(int j=0; j < letters.length; j++){
      var letter = letters[j];
      if (!hebrewChars.containsKey(letter)){
        continue;
      }
      if (savedLetters.contains(letter)){
        urls.add("#");
        continue;
      }
      print("working on ${letters[j]}.$exec");
      Reference ref = FirebaseStorage.instance
          .ref("$dirName").child("${letters[j]}.$exec");
      var url = await ref.getDownloadURL();
      print("got url at $url for letter ${letters[j]}. adding to $urls");
      urls.add(url);
      print("letter added ==> " + letters[j]);
      // lettersUrlsMap[letter] = url;
    }
    return urls;
  }


  static Future<String> getUrl(String word, String firebaseDirName) async{
    String exec = firebaseDirName == "animation_openpose/" ? ".mp4" : ".mkv";
    print("fetching ${"$firebaseDirName" + word + "$exec"}");
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("$firebaseDirName" + word + "$exec");
    return await ref.getDownloadURL();
  }

  // static Future<String> getPersonalUrl(String word, String firebaseDirName) async{
  //   String exec = firebaseDirName == "animation_openpose/" ? ".mp4" : ".mkv";
  //   // check if video exist in personal DB
  //   Reference ref = FirebaseStorage.instance
  //       .ref()
  //       .child("$firebaseDirName" + VideoFetcher()._auth.currentUser.uid + "/"+ word + "$exec");
  //   return await ref.getDownloadURL();
  // }



  Future<void> _urlsTry(
      String word, bool isAnimation, Map<String,String> urlsWords, String dirName,
      Map<String,int> indicesMap, List<String> urls
      ) async{

    print("indices map in urlsTry for word $word: $indicesMap");
    // gets the video's url
    String url = await getUrl(word, dirName);
    bool isAnimation = dirName.toLowerCase().contains("animation");
    // lruCache.saveVideosFromUrls(isAnimation, map);
    await lruCache.saveFile(url, word, isAnimation, false, true);
    this.indexToWord[indicesMap["indexToWord"]++] = word;

    String strStart = word.length == 1 ? "#" : "&&";
    // indexToUrl[indicesMap["indexToUrl"]++] = url;
    indexToUrl[indicesMap["indexToUrl"]++] = strStart;
    urlsWords[word] = strStart;

    urls.add(url);
  }

  Future<void> _urlsCatch(
      Exception err,
      String word, bool isAnimation, Map<String,String> urlsWords, String dirName,
      Map<String,int> indicesMap, List<String> urls
      ) async{
    print("indices map in _urlsCatch for word $word: $indicesMap");
    try {
      // check if word exist in the personal videos
      String url = await getUrl(word, dirName + _auth.currentUser.uid + "/");
      // this.indexToWord[indicesMap["indexToWord"]++] = word;
      // bool isAnimation = dirName.toLowerCase().contains("animation");
      // await lruCache.saveFile(url, "$word.mp4", isAnimation, false);
      // String strStart = word.length == 1 ? "#" : "&&";
      addToMaps(word, url, indicesMap, urlsWords);
      // urlsWords[word] = strStart;
      // indexToUrl[indicesMap["indexToUrl"]++] = strStart;
      urls.add(url);
    } catch (err2) {
      var urlsList = await proccessWord(word, dirName);
      print("urls list for $word is $urlsList}");
      List<String> letters = urlsList.length == 1 ? null : splitToLetters(word);
      if (letters == null){
        print("none letters word $word");
        String url = urlsList[0];
        addToMaps(word, url, indicesMap, urlsWords);
        urls.add(url);
        return;
      }
      for (int i = 0; i < urlsList.length; i++) {
        String letter = letters[i];
        bool isSaved = savedLetters.contains(letter);
        if (!isSaved){
          isSaved = await lruCache.fetchVideoFile(letters[i], isAnimation, "#") != null;
          if (isSaved){
            lettersList.add(letter);
          }
        }

        String url = urlsList[i];
        // String url = urlsList[i];
        addToMaps(letter, url, indicesMap, urlsWords);
        urls.add(url);
      }
    }
  }

  void addToMaps(String word, String url, Map<String,int> indicesMap,
      Map<String,String> urlsWords){
    indexToUrl[indicesMap["indexToUrl"]++] = url;
    indexToWord[indicesMap["indexToWord"]++] = word;
    urlsWords[word] = url;
  }

  Future<List> getUrls(String dirName, bool toSave) async {
    List<String> splitSentenceList = splitSentence(sentence); // split the sentence
    if (splitSentenceList == null) {
      return null;
    }
    bool isAnimation = dirName == "animation_openpose/";
    this.isValidSentence = true;
    print("splitSentenceList $splitSentenceList");
    List<String> urls = [];
    int j = 0, k = 0;
    Map<String, String> urlsWords = {};
    Map<String,int> indicesMap = {"indexToUrl": j, "indexToWord": k};

    for(int i=0; i < splitSentenceList.length; i++)
    {
      // if (i > 2){
      //   this.doneLoading = true;
      // }
      // updating the indices map and current word
      String word = splitSentenceList[i];
      try {
        bool isSaved = (await lruCache.fetchVideoFile(word, isAnimation, null) != null);
        print("$word word isSaved == $isSaved");
        if (isSaved){
          print("$word word is saved!");
          String strStart = word.length == 1 ? "#" : "&&";
          addToMaps(word, strStart, indicesMap, urlsWords);
          continue;

        }
        await _urlsTry(word, isAnimation, urlsWords, dirName, indicesMap, urls);
        print("indexToWord after _urlsTry: $indexToWord\n indexToUrl after _urlsTry: $indexToUrl\n  urls after _urlsTry: $urls\n");
      } on io.SocketException catch (err) {
        print(err);
        print("no internet connection");
        // CupertinoAlertDialog(title: "No internet Connection");
      } catch (err) {
        await _urlsCatch(err, word, isAnimation, urlsWords, dirName, indicesMap,
            urls);
      }
    }
    // Future.wait(refs.map((ref) {
    //   ref.getDownloadURL();
    // }).toList());
    this.urls = urls;
    if (toSave){

    }
    print("dirname in urls is $dirName");
    this.wordsToUrls = urlsWords;
    if (toSave){
      lruCache.saveVideosFromUrls(dirName.toLowerCase().contains("animation"), urlsWords);
    }
    this.doneLoading = true;
    // print("urls are $urls");
    // print("index to word is : $indexToWord");
    print("finished getUrls.\n indexToUrl: $indexToUrl\n wordsToUrls: $wordsToUrls");
    print("indexToWord: $indexToWord");
    return urls;
  }



  Future<List> getUrls2(String dirName, bool toSave) async {
    List<String> splitSentenceList = splitSentence(sentence); // split the sentence
    if (splitSentenceList == null) {
      return null;
    }
    bool isAnimation = dirName == "animation_openpose/";
    this.isValidSentence = true;
    print("splitSentenceList $splitSentenceList");
    List<String> urls = [];
    int i = 0, j = 0, k = 0;
    Map<String, String> map = {};
    Map<String,int> indicesMap = {"i": i, "j": j, "k": k};
    for(i=0; i < splitSentenceList.length; i++)
    {
      // if (i > 2){
      //   this.doneLoading = true;
      // }
      indicesMap["i"] = i;
      print("yoyo ($i)");
      String word = splitSentenceList[i];
      try {
        // checks if file exists
        bool isExists = await lruCache.isFileExists(word, isAnimation);
        if (isExists){
          map[word] = "&&";
          indexToUrl[indicesMap["j"]++] = "&&";
          continue;
        }
        // doesnt exists - try fetching
        await _urlsTry(word, isAnimation, map, dirName, indicesMap,
            urls);
        print("indexToWord after _urlsTry: $indexToWord\n indexToUrl after _urlsTry: $indexToUrl\n  urls after _urlsTry: $urls\n");
      } on io.SocketException catch (err) {
        print(err);
        print("no internet connection");
        // CupertinoAlertDialog(title: "No internet Connection");
      } catch (err) {
        await _urlsCatch(err, word, isAnimation, map, dirName, indicesMap,
            urls);
      }
    }
    // Future.wait(refs.map((ref) {
    //   ref.getDownloadURL();
    // }).toList());
    this.urls = urls;
    print("dirname in urls is $dirName");
    this.wordsToUrls = map;
    // if (toSave) lruCache.saveVideosFromUrls(dirName.toLowerCase().contains("animation"), map);
    this.doneLoading = true;
    print("urls are $urls");
    print("index to word is : $indexToWord");
    return urls;
  }

}


