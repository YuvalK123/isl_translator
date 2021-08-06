import 'dart:io';
import 'package:dio/dio.dart';
import 'package:isl_translator/models/pair.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:isl_translator/services/video_fetcher.dart';
import 'package:path_provider/path_provider.dart';

// List<String> lettersList = ["א","ב","ג","ד","ה","ו","ז","ח","ט",
//                          "י","כ","ך","ל","מ","ם","נ","ן","ס",
//                           "ע","פ","ף","צ","ץ","ק","ר","ש","ת"];

class LruCache{
  String lettersCachePath = "";
  Map<String,String> firebaseDirNames = {"live":"live_videos/", "animation":"animation_openpose/"};
  Map<String,String> cacheFolders = {"live":"Cache/live", "animation": "Cache/animation"};
  Map<String,String> cacheLettersFolders = {"live":"Cache/live/letters", "animation":"Cache/animation/letters"};
  bool hasPermission = false;
  int animDirectorySize = 0;
  int liveDirectorySize = 0;
  Map<String, int> saved = {};
  Map<String, DateTime> animModifiedDates = {};
  Map<String, DateTime> liveModifiedDates = {};
  String cachePath = "";
  int maxSize;
  Pair<String, File> leastRecentFile;

  LruCache(int mbSize){
    this.maxSize = mbSize * 1024 * 1024; // 20M
    initAsync();
  }

  void initAsync() async{
    this.liveDirectorySize = await sizeOfDirectory(cacheFolders["live"]);
    this.animDirectorySize = await sizeOfDirectory(cacheFolders["animation"]);
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
          futures.add(saveFile(url, word, isAnimation, false));
      });
      await Future.wait(futures);
      if (toDelete(isAnimation, 0)){
        print("needs to delete");
        await deleteLeastRecentFile(isAnimation);
      }
      print("saved words!");

    } catch(e){
      print("e for words $urls is $e");
    }
  }


  Future<String> createLettersCachePath(String folderName) async{
    if (folderName == null || folderName == ""){
      folderName = "/Cache";
    }else if (!folderName.startsWith("/")){
      folderName = "/" + folderName;
    }
    if (folderName.endsWith("/")){
      folderName.substring(0, folderName.length - 1);
    }
    Directory directory = await getExternalStorageDirectory();
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
      String url, String title, bool isAnimation, bool toUpdate
      ) async{
    String fileName = "$title.mp4";
    String cacheKey = isAnimation ? "animation" : "live";
    bool isLetter = title.length == 1;
    String folderName = isLetter ? cacheLettersFolders[cacheKey] : cacheFolders[cacheKey];
    Directory directory;
    try {
      if (Platform.isAndroid){
        if (await _requestPermission(Permission.storage)){
          String newPath = await getCachePathByFolder(folderName);
          directory = Directory(newPath);
        }
        else{
          // no permission for files
          return false;
        }
      } else{
        // apple - not supported
        return false;
      }
      if (!(await directory.exists())){
        // if directory exists - no need to create it. o.w - create.
        await directory.create(recursive: true);
      }
      if (await directory.exists()){
        String fullName = directory.path + "/$fileName";
        File saveFile = File(fullName);
        if (await saveFile.exists()){
          // file exists - no need to download
          return true;
        }
        // save file
        Dio dio = Dio();
        await dio.download(url, saveFile.path,
        // await dio.download(url, directory.path + "/$fileName",
            onReceiveProgress: (int received, int total) {
          if (this.saved.containsKey(title) || title.length < 2){
            return;
          }
          this.saved[title] = total;
          if (isAnimation){
            this.animDirectorySize += total;
          } else{
            this.liveDirectorySize += total;
          }
        }, );// onReceiveProgress: {downloaded, totalSize});;
        saveFile = File(fullName);
        final modifiedDates = isAnimation ? animModifiedDates : liveModifiedDates;
        if (saveFile != null && !modifiedDates.containsKey(title)){
          modifiedDates[title] = (await saveFile.stat()).modified;
        }
        if (toUpdate && toDelete(isAnimation, this.saved[title])){
          await deleteLeastRecentFile(isAnimation);
        }
        List<String> savedLetters = isAnimation ?
        VideoFetcher.animSavedLetters : VideoFetcher.liveSavedLetters;
        if (isLetter && !savedLetters.contains(title)){
          savedLetters.add(title);
        }
        return true;
      }
    }
    catch (e){
      print("err is $e");
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
    final modifiedDates = isAnimation ? animModifiedDates : liveModifiedDates;
    String cacheFolder = await getCachePathByFolder(dirName);
    String url = "$cacheFolder/$title.mp4";
    File file = File(url);
    if (await file.exists()){
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
    await permission.request();
    bool perm = PermissionStatus.granted.isGranted;
    this.hasPermission = perm;
    return perm;
  }

  Future<bool> isFileExists(String word, bool isAnimation) async{
    String cacheKey = isAnimation ? "animation" : "live";
    bool isLetter = word.length == 1;
    String dirName = isLetter ? cacheLettersFolders[cacheKey] : cacheFolders[cacheKey];
    String cacheFolder = await getCachePathByFolder(dirName);
    String url = "$cacheFolder/$word.mp4";
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
    if (this.leastRecentFile == null || this.leastRecentFile.b == null){
      await _updateLeastRecentFile(isAnimation);
    }
    if (this.leastRecentFile != null){
    }
    await _deleteLeastRecent(isAnimation);
    // get leastRecentDate
    while (toDelete(isAnimation, 0)){
      await _deleteLeastRecent(isAnimation);
      
    }
    
  }

  Future<void> _updateLeastRecentFile(bool isAnimation) async{
    Pair<String, DateTime> leastRecent;
    final modifiedDates = isAnimation ? animModifiedDates : liveModifiedDates;
    modifiedDates.forEach((String title, DateTime dateTime) {
      if (leastRecent == null){
        leastRecent = Pair(title, dateTime);
      } else{
        final currDate = leastRecent.b;
        if (dateTime.isBefore(currDate)){
          leastRecent = Pair(title, dateTime);
        }
      }
    });
    File file = await fetchVideoFile(leastRecent.a, isAnimation, null);
    this.leastRecentFile = Pair<String, File>(leastRecent.a, file);
  }

  Future<void> _deleteLeastRecent(bool isAnimation) async{
    if (this.leastRecentFile == null){
      await _updateLeastRecentFile(isAnimation);
      if (this.leastRecentFile == null){
        return;
      }
    }

    int size = this.saved[this.leastRecentFile.a];
    String title = this.leastRecentFile.a;
    this.leastRecentFile.b.delete(recursive: true);
    if (isAnimation){
      this.animModifiedDates.remove(title);
      this.animDirectorySize -= size;
    } else{
      this.liveModifiedDates.remove(title);
      this.liveDirectorySize -= size;
    }
    this.saved.remove(this.leastRecentFile.a);
    await _updateLeastRecentFile(isAnimation);
  }

  Future<int> sizeOfDirectory(String folderName) async{
    String cacheFolderPath = await getCachePathByFolder(folderName);
    bool isAnimation = folderName.contains("animation");
    final modifiedDates = isAnimation ? animModifiedDates : liveModifiedDates;
    Directory directory = Directory(cacheFolderPath);
    int size = 0;
    if (!(await directory.exists())){
      return 0;
    }
    try{
      directory.list(recursive: true).forEach((FileSystemEntity file) async{
        if (file is File){
          // size += (await file.stat()).size;
          size += ((await file.length())/8).floor();
          final fileName = file.path.split('/').last;
          if (!modifiedDates.containsKey(fileName)){
            modifiedDates[fileName] = (await file.stat()).modified;
          }
        }
      });
      return size;
    } catch (e){
      print("error of sizeOfDirectory $e");
    }

    return 0;
  }
}