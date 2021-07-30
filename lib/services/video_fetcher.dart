import 'dart:async';
import 'dart:io' as io;

import 'package:cached_video_player/cached_video_player.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/play_video.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:isl_translator/services/video_cache.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:isl_translator/shared/reg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:mutex/mutex.dart';

import 'add_feedback.dart';

import 'package:isl_translator/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/services/database.dart';

// class VideoFetcher extends StatefulWidget {
//   @override
//   _VideoFetcherState createState() => _VideoFetcherState();
//   final String sentence;
//   VideoFetcher({Key key, this.sentence}): super(key: key);
// }

class VideoFetcher { // extends State<VideoFetcher> {
  bool doneLoading = false;
  List<String> urls = [];
  final String sentence;
  bool isValidSentence = false;
  Map<int, String> indexToUrl = Map<int,String>();
  static String lettersCachePath;
  static LruCache lruCache = LruCache();
  Map<String,String> wordsToUrls = {};
  Map<int,String> indexToWord = {};
  final _auth = FirebaseAuth.instance;

  bool get isFirstLoaded {
    return indexToUrl.containsKey(0);
  }

  VideoFetcher({this.sentence});
  // VideoPlayerDemo _videoPlayerDemo = VideoPlayerDemo(key: Key("0"), myUrls: [],);

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
      return urls;
    }
    var nonPre = await getNonPrepositional(word, dirName);
    if (nonPre != null){
      urls.add(nonPre);
      return urls;
    }
    // Video doesn't exist - so split the work to letters
    var letters = splitToLetters(word);
    List<String> lettersUrls = [], cachedUrls = [];
    // if (lettersCachePath == null || lettersCachePath == ""){
    //   await createLettersCachePath(null);
    // }
    for(int j=0; j < letters.length; j++){
      var letter = letters[j];
      if (!hebrewChars.containsKey(letter)){
        continue;
      }
      String cacheDirName = exec.contains("mp4") ? lruCache.cacheLettersFolders["animation"]
          : lruCache.cacheLettersFolders["live"];
      String lettersCachePath = await lruCache.getCachePathByFolder(cacheDirName);
      print("cache is $lettersCachePath");
      // if (lettersCachePath != null && lettersCachePath != ""){
      io.File saveFile = io.File("$lettersCachePath/$letter.mp4");
      if (await saveFile.exists()) {
        cachedUrls.add("#/$letter.mp4");
        print("cachedUrl for $letter");
        continue;
      }
      // }
      print("working on ${letters[j]}.$exec");
      Reference ref = FirebaseStorage.instance
          .ref("$dirName").child("${letters[j]}.$exec");
      // .child("animation_openpose/" + letters[j] + ".mp4");
      print ("ref = $ref");
      var url = await ref.getDownloadURL();
      print("got url at $url for letter ${letters[j]}. adding to $urls");
      urls.add(url);
      print("letter added ==> " + letters[j]);
    }

    return cachedUrls.isEmpty ? urls : cachedUrls;
    // print("letters urls are = $lettersUrls");
    // for(int l=0; l < lettersUrls.length; l++){
    //   print("adding" + lettersUrls[l]);
    //   urls.add(lettersUrls[l]);
    //   print("Hiiii adding to $urls");
    // }
    // print("got url at $url. adding to $urls");
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
      String word, bool isAnimation, Map<String,String> map, String dirName,
      Map<String,int> indicesMap, List<String> splitSentenceList, List<String> urls
      ) async{

    print("indices map in urlsTry for word $word: $indicesMap");

    int i = indicesMap["i"];
    // gets the video's url
    String url = await getUrl(word, dirName);
    bool isAnimation = dirName.toLowerCase().contains("animation");
    // lruCache.saveVideosFromUrls(isAnimation, map);
    await lruCache.saveFile(url, "$word.mp4", isAnimation, false);
    this.indexToWord[indicesMap["k"]++] = word;

    String strStart = word.length == 1 ? "#" : "&&";
    // indexToUrl[indicesMap["j"]++] = url;
    indexToUrl[indicesMap["j"]++] = strStart;
    map[splitSentenceList[i]] = strStart;

    urls.add(url);
  }

  Future<void> _urlsCatch(
      Exception err,
      String word, bool isAnimation, Map<String,String> map, String dirName,
      Map<String,int> indicesMap, List<String> splitSentenceList, List<String> urls
      ) async{
    int i = indicesMap["i"], j = indicesMap["j"], k = indicesMap["k"];
    print("indices map in _urlsCatch for word $word: $indicesMap");
    try {
      // check if word exist in the personal videos
      String url = await getUrl(word, dirName + _auth.currentUser.uid + "/");
      this.indexToWord[indicesMap["k"]++] = word;
      // this.indexToWord[i] = word;
      // indexToUrl[indicesMap["j"]++] = url;

      // indicesMap["k"]++;
      bool isAnimation = dirName.toLowerCase().contains("animation");
      // lruCache.saveVideosFromUrls(isAnimation, map);
      await lruCache.saveFile(url, "$word.mp4", isAnimation, false);
      String strStart = word.length == 1 ? "#" : "&&";
      map[splitSentenceList[i]] = strStart;
      indexToUrl[indicesMap["j"]++] = strStart;
      // map[splitSentenceList[i]] = url;
      urls.add(url);
    } catch (err2) {
      var urlsList = await proccessWord(splitSentenceList[i], dirName);
      print("urls list for ${splitSentenceList[i]} is $urlsList}");
      List<String> letters = urlsList.length > 1 ? null : splitToLetters(splitSentenceList[i]);
      if (letters == null){
        String url = urlsList[0];
        indexToUrl[indicesMap["j"]++] = url;
        urls.add(url);
        indexToWord[indicesMap["k"]++] = url;
        return;
      }
      // if (urlsList.length == 1 && urlsList[0].length != 1) {
      //   this.indexToWord[indicesMap["k"]++] = word;
      //   map[splitSentenceList[i]] = urlsList[0]; // if not letters. if letters/ its cached
      //   return;
      // }
      for (int i = 0; i < urlsList.length; i++) {
        String url = urlsList[i];
        indexToUrl[indicesMap["j"]++] = url;
        urls.add(url);
        indexToWord[indicesMap["k"]++] = url;
        wordsToUrls[letters[i]] = url;

        // indicesMap["k"]++;
      }
    }
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
    int i = 0, j = 0, k = 0;
    Map<String, String> map = {};
    Map<String,int> indicesMap = {"i": i, "j": j, "k": k};

    for(i=0; i < splitSentenceList.length; i++)
    {
      if (i > 2){
        this.doneLoading = true;
      }
      indicesMap["i"] = i;
      String word = splitSentenceList[i];
      try {
        bool isSaved = await lruCache.isFileExists(word, isAnimation);
        if (isSaved){
          String strStart = word.length == 1 ? "#" : "&&";
          map[word] = strStart;
          indexToUrl[indicesMap["j"]++] = strStart;
        }
        await _urlsTry(word, isAnimation, map, dirName, indicesMap,
            splitSentenceList, urls);
        print("indexToWord after _urlsTry: $indexToWord\n indexToUrl after _urlsTry: $indexToUrl\n  urls after _urlsTry: $urls\n");
      } on io.SocketException catch (err) {
        print(err);
        print("no internet connection");
        // CupertinoAlertDialog(title: "No internet Connection");
      } catch (err) {
        await _urlsCatch(err, word, isAnimation, map, dirName, indicesMap,
            splitSentenceList, urls);
      }
    }
    // Future.wait(refs.map((ref) {
    //   ref.getDownloadURL();
    // }).toList());
    this.urls = urls;
    if (toSave){

    }
    print("dirname in urls is $dirName");
    this.wordsToUrls = map;
    if (toSave) lruCache.saveVideosFromUrls(dirName.toLowerCase().contains("animation"), map);
    this.doneLoading = true;
    print("urls are $urls");
    print("index to word is : $indexToWord");
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
      if (i > 2){
        this.doneLoading = true;
      }
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
            splitSentenceList, urls);
        print("indexToWord after _urlsTry: $indexToWord\n indexToUrl after _urlsTry: $indexToUrl\n  urls after _urlsTry: $urls\n");
      } on io.SocketException catch (err) {
        print(err);
        print("no internet connection");
        // CupertinoAlertDialog(title: "No internet Connection");
      } catch (err) {
        await _urlsCatch(err, word, isAnimation, map, dirName, indicesMap,
            splitSentenceList, urls);
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


