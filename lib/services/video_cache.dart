import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:disk_lru_cache/disk_lru_cache.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isl_translator/services/video_fetcher.dart';

List<String> lettersList = ["א","ב","ג","ד","ה","ו","ז","ח","ט",
                         "י","כ","ך","ל","מ","ם","נ","ן","ס",
                          "ע","פ","ף","צ","ץ","ק","ר","ש","ת"];

bool hasLettersLocal = false;


class LruCache{
  final LruMap<String,String> map = LruMap();
  DiskLruCache _cache;
  Map<String,String> firebaseDirNames = {"live":"live_videos/", "animation":"animation_openpose/"};
  Map<String,String> cacheFolders = {"live":"Cache/live", "animation": "Cache/animation"};
  Map<String,String> cacheLettersFolders = {"live":"Cache/live/letters", "animation":"Cache/animation/letters"};


  DiskLruCache get cache {
    return _cache;
  }

  String getPath() {
    return Directory.current.path;
  }

  static Future<void> saveLetters(String firebaseDirName, String cacheFolder) async{
    print("saving letters in $cacheFolder");
    // return;
    for (var letter in lettersList){
      try{
        print("on $firebaseDirName/$letter.mp4");
        String url = await VideoFetcher.getUrl("$letter",firebaseDirName);
        print("downloaded letter url $url");
        await VideoFetcher().saveFile(url, "$letter.mp4", cacheFolder);
        print("saved!!");
      } catch(e){
        print("e for letter $letter is $e");
      }

    }
    hasLettersLocal = true;
  }

  Future<void> saveVideosFromUrls(bool isAnimation, Map<String,String> urls) async{
    isAnimation = isAnimation == null ? true : isAnimation;
    String cacheFolder = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
    String firebaseDirName = !isAnimation ? firebaseDirNames["live"] : firebaseDirNames["animation"];
    print("save videos. isAnimation = $isAnimation, cacheFolder = $cacheFolder, firbaseDir = $firebaseDirName");
    try{

      urls.forEach((String word, String url) async{
        // if (await isFileExist(word, isAnimation)) {
          // print("on $firebaseDirName/$word.mp4");
          // String url = await VideoFetcher.getUrl(word, firebaseDirName);
          print("downloaded letter url $url");
          await VideoFetcher().saveFile(url, "$word.mp4", cacheFolder);
          print("saved $word!!");
        // }
      });

    } catch(e){
      print("e for words $urls is $e");
    }


  }

  Future<bool> isFileExist(String word, bool isAnimation) async{
    bool isLetter = word.length == 1;
    String cacheFolder;
    if (isLetter){
      cacheFolder = !isAnimation ? cacheLettersFolders["live"] : cacheLettersFolders["animation"];
    }else{
      cacheFolder = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
    }
  }

  LruCache(){
    int maxSize = 10 * 1024 * 1024; // 10M
    Directory cacheDirectory = Directory("${Directory.systemTemp.path}/cache");
    this._cache = DiskLruCache(
        maxSize: maxSize,
        directory: cacheDirectory,
        filesCount: 1
    );
  }

  Future<void> writeCache(String key, String value) async{
    CacheEditor editor = await this.cache.edit(key);
    if (editor == null){
      return null;
    }
    IOSink sink = await editor.newSink(0);
    sink.write(value);
    var result = await sink.close();
    return await editor.commit();
  }

  Future<String> readCache(String key) async{
    CacheSnapshot snapshot = await cache.get(key);
    return await snapshot.getString(0);
  }

  // Future<void> writeCacheBytes(String key, String value) async {
  //   CacheEditor editor = await cache.edit(key);
  //   if (editor == null) {
  //     return null;
  //   }
  //   HttpClient client = new HttpClient();
  //   HttpClientRequest request = await client.openUrl("GET", Uri.parse(
  //       "https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1534075481&di=1a90bd266d62bc5edfe1ce84ac38330e&src=http://photocdn.sohu.com/20130517/Img376200804.jpg"));
  //   HttpClientResponse response = await request.close();
  //   Stream<List<int>> stream = await editor.copyStream(0, response);
  //   // The bytes has been written to disk at this point.
  //
  //   await StreamBuilder(builder: stream).
  //   // await new ByteStream(stream).toBytes();
  //   await editor.commit();
  // }

  Future<Uint8List> readBytes() async{
    CacheSnapshot snapshot =  await cache.get('imagekey');
    return await snapshot.getBytes(0);
  }

  Future<void> clean() async {
    return await this.cache.clean();
  }

}