import 'dart:io';
import 'dart:typed_data';
import 'package:disk_lru_cache/disk_lru_cache.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isl_translator/services/video_fetcher.dart';

List<String> lettersList = ["א","ב","ג","ד","ה","ו","ז","ח","ט",
                         "י","כ","ך","ל","מ","ם","נ","ן","ס",
                          "ע","פ","ף","צ","ץ","ק","ר","ש","ת"];

class LruCache{
  final LruMap<String,String> map = LruMap();
  DiskLruCache _cache;

  DiskLruCache get cache {
    return _cache;
  }

  String getPath() {
    return Directory.current.path;
  }

  static Future<void> saveLetters(String dirName) async{
    print("save letters");
    for (var letter in lettersList){
      print("on $letter.mp4");
      String url = await VideoFetcher.getUrl("$letter",dirName);
      print("downloaded letter url $url");
      VideoFetcher().saveFile(url, "$letter.mp4");
      print("saved!!");
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