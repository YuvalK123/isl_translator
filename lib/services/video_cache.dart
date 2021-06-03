import 'dart:io';
import 'package:disk_lru_cache/disk_lru_cache.dart';

class LruCache{
  final LruMap<String,String> map = LruMap();
  DiskLruCache _cache;

  DiskLruCache get cache {
    return _cache;
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

}