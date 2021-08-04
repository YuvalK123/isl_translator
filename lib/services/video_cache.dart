import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:disk_lru_cache/disk_lru_cache.dart';
import 'package:isl_translator/main.dart';
import 'package:isl_translator/models/pair.dart';
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
  Map<String,String> firebaseDirNames = {"live":"live_videos/", "animation":"animation_openpose/"};
  Map<String,String> cacheFolders = {"live":"Cache/live", "animation": "Cache/animation"};
  Map<String,String> cacheLettersFolders = {"live":"Cache/live/letters", "animation":"Cache/animation/letters"};
  bool hasPermission = false;
  int animDirectorySize = 0;
  int liveDirectorySize = 0;
  Map<String, int> saved = {};
  Map<String, DateTime> modifiedDates = {};
  String cachePath = "";
  int maxSize;
  Pair<String, File> leastRecentFile;

  LruCache(){
    this.maxSize = 10 * 1024 * 1024; // 10M
    // Directory cacheDirectory = Directory("${Directory.systemTemp.path}/cache");
    // print("cacheDirectory == $cacheDirectory");
    initAsync();
  }

  void initAsync() async{

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
        await VideoFetcher.lruCache.saveFile(url, letter, cacheFolder.contains("animation"), true, false);
        print("saved!!");
      } catch(e){
        print("err for letter $letter is $e");
      }

    }
    hasLettersLocal = true;
  }

  Future<void> saveVideosFromUrls(bool isAnimation, Map<String,String> urls) async{
    isAnimation = isAnimation == null ? true : isAnimation;
    // String cacheFolder = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
    // String firebaseDirName = !isAnimation ? firebaseDirNames["live"] : firebaseDirNames["animation"];
    // print("save videos. isAnimation = $isAnimation, cacheFolder = $cacheFolder, firbaseDir = $firebaseDirName");
    try{
      List<Future> futures = <Future>[];
      urls.forEach((String word, String url) async{
        if (url == "&&" || url == "#"){
          return;
        }
        // if (await isFileExist(word, isAnimation)) {
          // print("on $firebaseDirName/$word.mp4");
          // String url = await VideoFetcher.getUrl(word, firebaseDirName);
          bool isLetter = word.length == 1;
          // print("adding $word to save");
          futures.add(saveFile(url, word, isAnimation, isLetter, false));
        // }
      });
      await Future.wait(futures);
      if (toDelete(isAnimation, 0)){
        deleteLeastRecentFile(isAnimation);
      }
      print("saved words!");

    } catch(e){
      print("e for words $urls is $e");
    }
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
      // print("folder == $folder");
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
    /***
     * function finds the android path of cache, and con to it the folderName
     * only works for android
     */
    if (folderName == null || folderName == ""){
      // default cache folder.
      folderName = "/Cache";
    }else if (!folderName.startsWith("/")){
      // folder name should be of '/...' type
      folderName = "/" + folderName;
    }
    if (folderName.endsWith("/")){
      // folder should'nt end with '/'
      folderName.substring(0, folderName.length - 1);
    }
    if (this.cachePath != ""){
      return this.cachePath + folderName;
    }
    Directory directory = await getExternalStorageDirectory();
    String newPath = "";
    List<String> folders = directory.path.split("/");
    for (int i = 1; i < folders.length; i++){
      String folder = folders[i];
      // print("folder == $folder");
      // newPath += "/" + folder;
      if (folder != "android"){
        // no need to attach android to path
        newPath += "/" + folder;
      }else{
        break;
      }
    }
    this.cachePath = newPath;
    newPath = newPath + folderName;
    return newPath;
  }

  Future<bool> saveFile(
      String url, String title, bool isAnimation, bool isLetter, bool toUpdate
      ) async{
    String fileName = "$title.mp4";
    print("saving file $fileName -> $fileName\n params: "
        "isAnimation: $isAnimation, isLetter: $isLetter, url: $url");
    String cacheKey = isAnimation ? "animation" : "live";
    String folderName = isLetter ? cacheLettersFolders[cacheKey] : cacheFolders[cacheKey];
    // String folderName = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
    Directory directory;
    try {
      if (Platform.isAndroid){
        if (await _requestPermission(Permission.storage)){
          print("got permission");
          String newPath = await getCachePathByFolder(folderName);
          print("newPath is $newPath");
          directory = Directory(newPath);
        }
        else{
          // no permission for files
          return false;
        }
      } else{
        // apple
        return false;
      }
      // String newPath = await getCachePathByFolder(folderName);
      if (!(await directory.exists())){
        // if directory exists - no need to create it. o.w - create.
        await directory.create(recursive: true);
      }
      if (await directory.exists()){
        String fullName = directory.path + "/$fileName";
        print("full directory name is $fullName");
        File saveFile = File(fullName);
        if (await saveFile.exists()){
          // file exists - no need to download
          return true;
        }
        // save file
        Dio dio = Dio();
        var result = await dio.download(url, saveFile.path,
            onReceiveProgress: (int received, int total) {
          total *= 8;
          if (this.saved.containsKey(title)){
            return;
          }
          this.saved[title] = total;
          if (isAnimation){
            this.animDirectorySize += total;
          } else{
            this.liveDirectorySize += total;
          }

          print("saved $fileName! total == $total, received == $received");
        }, );// onReceiveProgress: {downloaded, totalSize});
        print("anim dir size == $animDirectorySize, live == $liveDirectorySize");
        print("$fileName downloaded!!");
        saveFile = File(fullName);
        if (saveFile != null && !modifiedDates.containsKey(title)){
          modifiedDates[title] = saveFile.statSync().modified;
        }
        if (toUpdate && toDelete(isAnimation, this.saved[title])){
          await deleteLeastRecentFile(isAnimation);
        }

        if (isLetter && !VideoFetcher.savedLetters.contains(title)){
          VideoFetcher.savedLetters.add(title);
        }
        return true;
      }
    }
    catch (e){
      print("  err is $e");
    }
    // failed to create directory
    return false;
  }



  Future<File> fetchVideoFile(String title, bool isAnimation, String replacementStr) async{
    if (title == null || title.length < 1){
      return null;
    }
    if (!(await _requestPermission(Permission.storage))){
      // doesnt have permission to get to storage
      return null;
    }
    bool isLetter = title.length == 1;
    if (replacementStr == null){
      replacementStr = isLetter ? "#" : "&&";
    }
    String cacheKey = isAnimation ? "animation" : "live";
    String dirName = isLetter ? cacheLettersFolders[cacheKey] : cacheFolders[cacheKey];
    // String url = title.replaceFirst("#", dirName);
    String cacheFolder = await getCachePathByFolder(dirName);
    String url = "$cacheFolder/$title.mp4";
    print("fetchVideoFile for title $title : loading from file $url");
    File file = File(url);
    if (await file.exists()){
      print("file $file exists! fir $title title");
      if (modifiedDates.containsKey(title)){
        modifiedDates[title] = file.statSync().modified;
      }
      return file;
    }
    return null;
  }

  Future<bool> _requestPermission(Permission permission) async{
    if (await permission.isGranted){
      this.hasPermission = true;
      return true;
    }
    var result = await permission.request();
    bool perm = PermissionStatus.granted.isGranted;
    this.hasPermission = perm;
    return perm;
  }

  Future<bool> isFileExists(String word, bool isAnimation) async{
    // String cacheFolder = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
    String cacheKey = isAnimation ? "animation" : "live";
    bool isLetter = word.length == 1;
    String dirName = isLetter ? cacheLettersFolders[cacheKey] : cacheFolders[cacheKey];
    String cacheFolder = await getCachePathByFolder(dirName);
    String url = "$cacheFolder/$word.mp4";
    // String cacheFolder;
    // if (isLetter){
    //   cacheFolder = !isAnimation ? cacheLettersFolders["live"] : cacheLettersFolders["animation"];
    // }else{
    //   cacheFolder = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
    // }
    // File file = File("$cacheFolder/$word");
    File file = File(url);
    return await file.exists();
  }

  bool toDelete(bool isAnimation, int fileSize){
    int currSize = isAnimation ? this.animDirectorySize : this.liveDirectorySize;
    if (this.maxSize >= currSize + fileSize){
      return false;
    }

    return true;
  }

  Future<void> deleteLeastRecentFile(bool isAnimation) async{
    if (this.leastRecentFile != null){
      print("deleting least recent ${this.leastRecentFile.a}");
    }
    await _deleteLeastRecent(isAnimation);
    // get leastRecentDate
    while (toDelete(isAnimation, 0)){
      await _deleteLeastRecent(isAnimation);
      
    }
    
    // await deleteFile(title, isAnimation, title.length == 1);
  }

  Future<void> _updateLeastRecentFile(bool isAnimation) async{
    Pair<String, DateTime> leastRecent;
    this.modifiedDates.forEach((String title, DateTime dateTime) {
      if (leastRecent == null){
        leastRecent = Pair(title, dateTime);
        return;
      }
      final currDate = leastRecent.b;
      if (dateTime.isBefore(currDate)){
        leastRecent = Pair(title, dateTime);
      }
    });
    File file = await fetchVideoFile(leastRecent.a, isAnimation, null);
    this.leastRecentFile = Pair<String, File>(leastRecent.a, file);
  }

  Future<void> _deleteLeastRecent(bool isAnimation) async{
    if (this.leastRecentFile == null){
      await _updateLeastRecentFile(isAnimation);
    }
    int size = await this.leastRecentFile.b.length();
    this.leastRecentFile.b.delete(recursive: true);
    if (isAnimation){
      this.animDirectorySize -= size;
    } else{
      this.liveDirectorySize -= size;
    }
    this.saved.remove(this.leastRecentFile.a);
    await _updateLeastRecentFile(isAnimation);
  }

  Future<int> sizeOfDirectory(String folderName) async{
    String cacheFolderPath = await getCachePathByFolder(folderName);
    Directory directory = Directory(cacheFolderPath);
    int size = 0;
    if (!(await directory.exists())){
      return 0;
    }
    try{
      directory.list(recursive: true).forEach((FileSystemEntity file) async{
        if (file is File){
          size += await file.length();
        }
      });
      print("size of directory is $size");
      return size;
    } catch (e){
      print("error of sizeOfDirectory $e");
    }

    return 0;
  }


}