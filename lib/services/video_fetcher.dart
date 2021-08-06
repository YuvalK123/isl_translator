import 'dart:async';
import 'dart:io' as io;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/services/handle_sentence.dart';
import 'package:isl_translator/services/video_cache.dart';
import 'package:isl_translator/shared/reg.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// VideoFetcher class fetch videos from either cache or firebase
class VideoFetcher {
  final String sentence;
  static String lettersCachePath;
  static LruCache lruCache = LruCache(20); // init cache to 20 mb

  Map<int,String> _indexToWord = {};
  Map<int,bool> _isLettersMap = {};
  Map<int, List<String>> _indexToUrlList = Map<int,List<String>>();
  Map<String, String> wordsToUrlsNew = {};
  Map<int,String> indexToWordNew = {};
  Map<int, String> indexToUrlNew = Map<int,String>();

  VideoFetcher({this.sentence});

  /// if complicated word, process it to see if valid
  Future<List<String>> processWord(String word,String dirName) async {
    bool isAnimation = dirName.contains("animation");
    String exec = isAnimation ? "mp4" : "mkv";
    List<String> urls = [];
    List<String> savedLetters = isAnimation
        ? LruCache.animSavedLetters
        : LruCache.liveSavedLetters;
    var processed = await checkIfProcessedWord(word, dirName);
    if (processed != null) {
      urls.add(processed);
      return urls;
    }
    var nonPre = await getNonPrepositional(word, dirName);
    if (nonPre != null) {
      urls.add(nonPre);
      return urls;
    }

    // Video doesn't exist - so split the work to letters
    var letters = splitToLetters(word);
    for (int j = 0; j < letters.length; j++) {
      var letter = letters[j];
      if (!hebrewChars.containsKey(letter)) {
        // if invalid hebrew char
        continue;
      }
      if (savedLetters.contains(letter)) {
        // if saved letter
        urls.add("#");
        continue;
      }
      try{
        Reference ref = FirebaseStorage.instance
            .ref("$dirName").child("${letters[j]}.$exec");
        var url = await ref.getDownloadURL();
        urls.add(url);
      } catch(e){
        print("error in fetching letter file\n $e");
      }

    }
    return urls;
  }

  /// get a single url from [firebaseDirName] of [word]
  Future<String> getUrl(String word, String firebaseDirName) async{
    String exec = firebaseDirName.contains("animation") ? ".mp4" : ".mkv";
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("$firebaseDirName" + word + "$exec");
    return await ref.getDownloadURL();
  }

  /// try to fetch [word] video. if succeed, add to it maps
  /// for the use of getUrls
  Future<void> _urlsTry(
      String word, bool isAnimation, Map<String,List<String>> urlsWords,
      String dirName, int index
      ) async{
    try{ // check in personal folder
      final _auth = FirebaseAuth.instance;
      String url = await getUrl(word, dirName + _auth.currentUser.uid + "/");
      addToMapsIndex(word, [url], urlsWords, index);
    } catch(e){
      // gets the video's url
      String url = await getUrl(word, dirName);
      await lruCache.saveFile(url, word, isAnimation, false);
      addToMapsIndex(word, [url], urlsWords, index);
    }
  }

  /// if failed to fetch in try, handle it
  /// for the use of getUrls
  Future<void> _urlsCatch(
      Exception err,
      String word, bool isAnimation, Map<String,List<String>> urlsWords,
      String dirName, int index
      ) async {
    List<String> savedLetters = isAnimation
        ? LruCache.animSavedLetters
        : LruCache.liveSavedLetters;
    var urlsList = await processWord(word, dirName);
    List<String> letters = urlsList.length == 1 ? null : splitToLetters(word);
    if (letters == null) {
      addToMapsIndex(word, urlsList, urlsWords, index);
      return;
    }
    for (int i = 0; i < urlsList.length; i++) {
      // add the letters to the saved list
      String letter = letters[i];
      bool isSaved = savedLetters.contains(letter);
      if (!isSaved) {
        isSaved =
            await lruCache.fetchVideoFile(letters[i], isAnimation, "#") != null;
        if (isSaved) {
          savedLetters.add(letter);
        }
      }
    }
    addToMapsIndex(word, urlsList, urlsWords, index);
  }

  /// add to fields map the [index], [word] and [urls]
  void addToMapsIndex(String word, List<String> urls,
      Map<String,List<String>> urlsWords, int index){
    _indexToUrlList[index] = urls; // add index to
    bool isLetters = urls.length != 1;
    _isLettersMap[index] = isLetters;
    _indexToWord[index] = word;
    urlsWords[word] = urls;
  }

  /// get urls from either cache or
  Future getUrls(String dirName) async {
    List<String> splitSentenceList = splitSentence(
        sentence); // split the sentence
    // if not a valid sentence
    if (splitSentenceList == null) {
      return null;
    }
    bool isAnimation = dirName.contains("animation");
    Map<String, List<String>> urlsWordsList = {};
    List<Future<void>> futures = <Future>[];
    for (int i = 0; i < splitSentenceList.length; i++) {
      // split sentence
      String word = splitSentenceList[i];
      // load urls in parallel
      futures.add(_parallelGetUrls(
          word, dirName, isAnimation, urlsWordsList, i));
    }

    // wait for loading all urls
    await Future.wait(futures);
    handleMapsAfterGet(urlsWordsList);
    // save videos to cache
    await lruCache.saveVideosFromUrls(isAnimation, wordsToUrlsNew);
  }

  /// after getUrls, update the maps on the outside
  void handleMapsAfterGet(Map<String, List<String>> urlsWordsList){
    // add letters index to indexToUrl Map
    int newIndex = 0;
    for(int i=0; i< _indexToUrlList.keys.length; i++)
    {
      for (int j = 0; j < _indexToUrlList[i].length; j++) {
        indexToUrlNew[i + newIndex] = _indexToUrlList[i][j];
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
    final keysIndexToWord = _indexToWord.keys;
    int newIndexToWord = 0;
    for(int i=0; i < keysIndexToWord.length; i++)
    {
      if (_isLettersMap[i]) {
        var letters = splitToLetters(_indexToWord[i]);
        for (int j = 0; j < letters.length; j++) {
          indexToWordNew[i + newIndexToWord] = letters[j];
          newIndexToWord++;
        }
        newIndexToWord--;
      }
      else {
        indexToWordNew[i + newIndexToWord] = _indexToWord[i];
      }
    }
  }

  /* parallelGetUrls function */
  /// get urls in parallel for futures in getUrls
  /// private method for the getUrls API
  Future<void> _parallelGetUrls(String word, String dirName, bool isAnimation,
      Map<String,List<String>> urlsWords, int index) async{
    try {
      bool isSaved = (await lruCache.fetchVideoFile(word, isAnimation, null) != null);
      if (isSaved){
        String strStart = word.length == 1 ? "#" : "&&";
        List<String> listurls = [strStart];
        addToMapsIndex(word, listurls, urlsWords, index); // add index
        return;
      }
      await _urlsTry(word, isAnimation, urlsWords, dirName, index);
    } on io.SocketException catch (err) {
      print(err);
      print("no internet connection");
    } catch (err) {
      await _urlsCatch(err, word, isAnimation, urlsWords, dirName,
          index);
    }
  }
}
