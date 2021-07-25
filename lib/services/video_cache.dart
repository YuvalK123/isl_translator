import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:disk_lru_cache/disk_lru_cache.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:isl_translator/services/video_fetcher.dart';
import 'package:path_provider/path_provider.dart';

List<String> lettersList = ["א","ב","ג","ד","ה","ו","ז","ח","ט",
                         "י","כ","ך","ל","מ","ם","נ","ן","ס",
                          "ע","פ","ף","צ","ץ","ק","ר","ש","ת"];

bool hasLettersLocal = false;


class LruCache{
  final LruMap<String,String> map = LruMap();
  String lettersCachePath = "";
  DiskLruCache _cache;
  Map<String,String> firebaseDirNames = {"live":"live_videos/", "animation":"animation_openpose/"};
  Map<String,String> cacheFolders = {"live":"Cache/live", "animation": "Cache/animation"};
  Map<String,String> cacheLettersFolders = {"live":"Cache/live/letters", "animation":"Cache/animation/letters"};


  DiskLruCache get cache {
    return _cache;
  }

  static String getPath() {
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
        await LruCache().saveFile(url, "$letter.mp4", cacheFolder);
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
          await saveFile(url, "$word.mp4", cacheFolder);
          print("saved $word!!");
        // }
      });

    } catch(e){
      print("e for words $urls is $e");
    }
  }

  // Future<bool> isFileExist(String word, bool isAnimation) async{
  //   bool isLetter = word.length == 1;
  //   String cacheFolder;
  //   if (isLetter){
  //     cacheFolder = !isAnimation ? cacheLettersFolders["live"] : cacheLettersFolders["animation"];
  //   }else{
  //     cacheFolder = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
  //   }
  // }

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


  ///
/// ordering
///

  Future<String> createLettersCachePath(String folderName) async{
    if (folderName == null || folderName == ""){
      folderName = "/Cache";
    }else if (!folderName.startsWith("/")){
      folderName = "/" + folderName;
    }
    if (folderName.endsWith("/")){
      folderName.substring(0, folderName.length - 1);
    }
    print("folderName is $folderName");
    Directory directory = await getExternalStorageDirectory();
    print("path is ${directory.path}");
    String newPath = "";
    List<String> folders = directory.path.split("/");
    for (int i = 1; i < folders.length; i++){
      String folder = folders[i];
      print("folder == $folder");
      // newPath += "/" + folder;
      if (folder != "android"){
        newPath += "/" + folder;
      }else{
        break;
      }
    }
    newPath = newPath + folderName;
    // lettersCachePath = newPath;
    return newPath;
  }

  Future<String> getCachePathByFolder(String folderName) async{
    if (folderName == null || folderName == ""){
      folderName = "/Cache";
    }else if (!folderName.startsWith("/")){
      folderName = "/" + folderName;
    }
    if (folderName.endsWith("/")){
      folderName.substring(0, folderName.length - 1);
    }
    print("folderName is $folderName");
    Directory directory = await getExternalStorageDirectory();
    print("path is ${directory.path}");
    String newPath = "";
    List<String> folders = directory.path.split("/");
    for (int i = 1; i < folders.length; i++){
      String folder = folders[i];
      print("folder == $folder");
      // newPath += "/" + folder;
      if (folder != "android"){
        newPath += "/" + folder;
      }else{
        break;
      }
    }
    newPath = newPath + folderName;
    return newPath;
  }

  Future<bool> saveFile(String url, String fileName, String folderName) async{
    Directory directory;
    Dio dio = Dio();
    print("path for letters be4 is $lettersCachePath");
    try {
      print("android");
      if (Platform.isAndroid){
        print("downloading for android");
        if (await _requestPermission(Permission.storage)){
          print("got permission");
          String newPath = await getCachePathByFolder(folderName);
          print("newPath is $newPath");
          directory = Directory(newPath);
        }
      }else{
        // apple, and not loaded
      }
      String newPath = await getCachePathByFolder(folderName);
      print("directory is $Directory");
      if (!(await directory.exists())){
        print("recursive");
        await directory.create(recursive: true);
        print("recursed");
      }
      if (await directory.exists()){
        print("exists");
        String fullName = directory.path + "/$fileName";
        print("full name is $fullName");
        File saveFile = File(fullName);
        if (await saveFile.exists()){
          return true;
        }
        print("saved! now downloading to ${saveFile.path}");
        await dio.download(url, saveFile.path);// onReceiveProgress: {downloaded, totalSize});
        print("$fileName downloaded!!");
        return true;
      }
      else{
        print("doesnt exist");
      }
    }
    catch (e){
      print("save err is $e");
    }
    return false;
  }

  Future<bool> _requestPermission(Permission permission) async{
    if (await permission.isGranted){
      return true;
    }
    var result = await permission.request();
    return PermissionStatus.granted.isGranted;
  }

  Future<bool> isFileExists(String word, bool isAnimation) async{
    // String cacheFolder = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
    bool isLetter = word.length == 1;
    String cacheFolder;
    if (isLetter){
      cacheFolder = !isAnimation ? cacheLettersFolders["live"] : cacheLettersFolders["animation"];
    }else{
      cacheFolder = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
    }
    File file = File("$cacheFolder/$word");
    return await file.exists();
    return null;
  }


}