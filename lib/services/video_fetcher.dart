import 'dart:async';
import 'dart:io' as io;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/services/handle_sentence.dart';
import 'package:isl_translator/services/video_cache.dart';
import 'package:isl_translator/shared/reg.dart';
import 'package:firebase_auth/firebase_auth.dart';


class VideoFetcher {
  bool doneLoading = false;
  List<String> urls = [];
  final String sentence;
  bool isValidSentence = false;
  static String lettersCachePath;
  static LruCache lruCache = LruCache(20);
  final _auth = FirebaseAuth.instance;
  static final animSavedLetters = <String>[];
  static final liveSavedLetters = <String>[];
  Map<String, List<String>> wordsToUrls = {};
  Map<String, String> wordsToUrlsNew = {};
  Map<int,String> indexToWord = {};
  Map<int,String> indexToWordNew = {};
  Map<int,bool> isLettersMap = {};
  Map<int, List<String>> indexToUrlList = Map<int,List<String>>();
  Map<int, String> indexToUrlNew = Map<int,String>();

  VideoFetcher({this.sentence});

  static Future<List<String>> getDowloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) {
        ref.getDownloadURL();
      }).toList());


  Future<List<String>> processWord(String word,String dirName) async{
    bool isAnimation = dirName.contains("animation");
    String exec = isAnimation ? "mp4" : "mkv";
    List<String> urls = [];
    List<String> savedLetters = isAnimation ? animSavedLetters : liveSavedLetters;
    print("check for verb...");
    final stopWatch = Stopwatch()..start();
    var verb = await checkIfVerb(word, dirName);
    print("elapsed: ${stopWatch.elapsed} is verb??? $verb");
    if (verb != null){
      urls.add(verb);
      return urls;
    }
    var nonPre = await getNonPrepositional(word, dirName);
    if (nonPre != null){
      urls.add(nonPre);
      return urls;
    }
    // Video doesn't exist - so split the work to letters
    var letters = splitToLetters(word);
    for(int j=0; j < letters.length; j++){
      var letter = letters[j];
      if (!hebrewChars.containsKey(letter)){
        // if invalid hebrew char
        continue;
      }
      if (savedLetters.contains(letter)){
        // if saved letter
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
    }
    return urls;
  }

  static Future<String> getUrl(String word, String firebaseDirName) async{
    String exec = firebaseDirName.contains("animation") ? ".mp4" : ".mkv";
    print("fetching ${"$firebaseDirName" + word + "$exec"}");
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("$firebaseDirName" + word + "$exec");
    return await ref.getDownloadURL();
  }

  Future<void> _urlsTry(
      String word, bool isAnimation, Map<String,List<String>> urlsWords, String dirName,
      Map<String,int> indicesMap, List<String> urls, int index
      ) async{

    print("indices map in urlsTry for word $word: $indicesMap");
    // gets the video's url
    String url = await getUrl(word, dirName);
    bool isAnimation = dirName.toLowerCase().contains("animation");
    await lruCache.saveFile(url, word, isAnimation, false, false);
    this.indexToWord[index] = word;
    addToMapsIndex(word, [url],indicesMap, urlsWords, index);
    urls.add(url);
  }

  Future<void> _urlsCatch(
      Exception err,
      String word, bool isAnimation, Map<String,List<String>> urlsWords, String dirName,
      Map<String,int> indicesMap, List<String> urls, int index
      ) async{
    print("indices map in _urlsCatch for word $word: $indicesMap");
    List<String> savedLetters = isAnimation ? animSavedLetters : liveSavedLetters;
    try {
      // check if word exist in the personal videos
      String url = await getUrl(word, dirName + _auth.currentUser.uid + "/");
      addToMapsIndex(word, [url], indicesMap, urlsWords, index);
      urls.add(url);
    } catch (err2) {
      var urlsList = await processWord(word, dirName);
      print("urls list for $word is $urlsList}");
      List<String> letters = urlsList.length == 1 ? null : splitToLetters(word);
      if (letters == null){
        print("none letters word $word");
        String url = urlsList[0];
        addToMapsIndex(word, [url], indicesMap, urlsWords, index);
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
        addToMapsIndex(word, urlsList, indicesMap, urlsWords, index);
        urls.add(url);
      }
    }
  }

  void addToMapsIndex(String word, List<String> urls, Map<String,int> indicesMap,
      Map<String,List<String>> urlsWords, int index){
    indexToUrlList[index] = urls; // add index to
    bool isLetters = urls.length != 1;
    isLettersMap[index] = isLetters;
    indexToWord[index] = word;
    urlsWords[word] = urls;
  }

  Future<List> getUrls(String dirName, bool toSave) async {
    List<String> splitSentenceList = splitSentence(
        sentence); // split the sentence
    if (splitSentenceList == null) {
      return null;
    }
    bool isAnimation = dirName == "animation_openpose/";
    this.isValidSentence = true;
    print("splitSentenceList $splitSentenceList");
    List<String> urls = [];
    int j = 0,
        k = 0;
    Map<String, List<String>> urlsWordsList = {};

    Map<String, int> indicesMap = {"indexToUrl": j, "indexToWord": k};
    List<Future<void>> futures = <Future>[];
    for (int i = 0; i < splitSentenceList.length; i++) {
      // split sentence
      String word = splitSentenceList[i];
      // load urls in parallel
      futures.add(parallelGetUrls(
          word, dirName, isAnimation, indicesMap, urlsWordsList, i));
    }

    // wait for loading all urls
    await Future.wait(futures);

    // add letters index to indexToUrl Map
    int newIndex = 0;
    for(int i=0; i< indexToUrlList.keys.length; i++)
    {
      for (int j = 0; j < indexToUrlList[i].length; j++) {
        indexToUrlNew[i + newIndex] = indexToUrlList[i][j];
        newIndex++;
      }
      newIndex--;
    }

    // add letters index to wordsToUrls Map
    final keysWords = urlsWordsList.keys;
    for (var w in keysWords) {
      if (urlsWordsList[w].length == 1) {
        wordsToUrlsNew[w] = urlsWordsList[w][0];
      }
      else {
        for (int i = 0; i < urlsWordsList[w].length; i ++) {
          wordsToUrlsNew[w[i]] = urlsWordsList[w][i];
        }
      }
    }

    // add letters index to indexToWord Map
    final keysIndexToWord = indexToWord.keys;
    int newIndexToWord = 0;
    for(int i=0; i < keysIndexToWord.length; i++)
    {
      if (isLettersMap[i]) {
        var letters = splitToLetters(indexToWord[i]);
        for (int j = 0; j < letters.length; j++) {
          indexToWordNew[i + newIndexToWord] = letters[j];
          newIndexToWord++;
        }
        newIndexToWord--;
      }
      else {
        indexToWordNew[i + newIndexToWord] = indexToWord[i];
      }
    }

    this.urls = urls;
    if (toSave) {

    }
    this.wordsToUrls = urlsWordsList;
    // save video to cache
    if (toSave) {
      await lruCache.saveVideosFromUrls(dirName.toLowerCase().contains("animation"), wordsToUrlsNew);
    }
    this.doneLoading = true;
    return urls;
  }

  /* parallelGetUrls function */
  Future<void> parallelGetUrls(String word, String dirName, bool isAnimation,
      Map<String,int> indicesMap, Map<String,List<String>> urlsWords, int index) async{
    try {
      bool isSaved = (await lruCache.fetchVideoFile(word, isAnimation, null) != null);
      if (isSaved){
        String strStart = word.length == 1 ? "#" : "&&";
        List<String> listurls = [strStart];
        addToMapsIndex(word, listurls, indicesMap, urlsWords, index); // add index
        return;
      }
      await _urlsTry(word, isAnimation, urlsWords, dirName, indicesMap, urls, index);
    } on io.SocketException catch (err) {
      print(err);
      print("no internet connection");
    } catch (err) {
      await _urlsCatch(err, word, isAnimation, urlsWords, dirName, indicesMap,
          urls, index);
    }
  }
}
