import 'dart:io';
import 'package:dio/dio.dart';
import 'package:isl_translator/models/pair.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:isl_translator/services/video_fetcher.dart';
import 'package:path_provider/path_provider.dart';

/// lru cache for videos
class LruCache{
  String lettersCachePath = "";
  Map<String,String> firebaseDirNames =
                {"live":"live_videos/", "animation":"animation_openpose/"};
  Map<String,String> cacheFolders =
                {"live":"Cache/live", "animation": "Cache/animation"};
  Map<String,String> cacheLettersFolders =
    {"live":"Cache/live/letters", "animation":"Cache/animation/letters"};
  bool hasPermission = false;
  int animDirectorySize = 0;
  int liveDirectorySize = 0;
  Map<String, int> saved = {}; // saved words in this run, and their sizes
  Map<String, DateTime> animModifiedDates = {};
  Map<String, DateTime> liveModifiedDates = {};
  String cachePath = "";
  int maxSize;
  bool hasBeenAnimation = true;
  Pair<String, File> leastRecentFile;

  /// constructor recieves maxsize in mb [mbSize]
  LruCache(int mbSize){
    this.maxSize = mbSize * 1024 * 1024; // 20M
    initAsync();
  }

  /// function to run async in constructor
  void initAsync() async{
    this.liveDirectorySize = await sizeOfDirectory(cacheFolders["live"]);
    this.animDirectorySize = await sizeOfDirectory(cacheFolders["animation"]);
  }

  /// get size of [folderName]
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
          // length is in bits. convert to bytes
          size += ((await file.length())/8).ceil();
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

  /// save videos from [urls] list in respective directory if [isAnimation]
  Future<void> saveVideosFromUrls(bool isAnimation, Map<String,String> urls) async{
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
        await deleteLeastRecentFile(isAnimation);
      }

    } catch(e){
      print("e for words $urls is $e\n failed to save from list");
    }
  }

  /// function finds the android path of cache, and con to it the [folderName]
  /// only works for android
  Future<String> getCachePathByFolder(String folderName) async{
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

  /// save [url] with the name [title] in respective folder.
  /// and [toUpdate] to delete if bigger
  Future<bool> saveFile(
      String url, String title, bool isAnimation, bool toUpdate
      ) async{
    bool isLetter = title.length == 1;
    String fileName = "$title.mp4", cacheKey = isAnimation ? "animation" : "live";
    String folderName = isLetter ? cacheLettersFolders[cacheKey] : cacheFolders[cacheKey];
    Directory directory;
    try {
      if (Platform.isAndroid){ // only on android platforms
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
            onReceiveProgress: (int received, int total) =>
                onReceiveProgress(received, total, title, isAnimation)
        );
        saveFile = File(fullName);
        final modifiedDates = isAnimation ? animModifiedDates : liveModifiedDates;
        if (saveFile != null){ // add file modifiedDate
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

  /// when saving a file, this is the function that saves the size of the file
  /// so we update it while running. size in bits is [total]
  void onReceiveProgress(int received, int total, String title, bool isAnimation){
    // no need to save current file size if already saved
    if (this.saved.containsKey(title) || title.length < 2){
      return;
    }
    this.saved[title] = total;
    if (isAnimation){
      this.animDirectorySize += total;
    } else{
      this.liveDirectorySize += total;
    }
  }


  /// fetch a video with the name [title] from the respective folder
  /// with [isAnimation]. [replacementStr] is if its a letter or not
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
    // init local variables
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

  /// request [permission] from user
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

  /// checks if needs to delete a file in folder
  bool toDelete(bool isAnimation, int fileSize){
    int currSize = isAnimation ? this.animDirectorySize : this.liveDirectorySize;
    if (this.maxSize >= currSize + fileSize){
      return false;
    }
    return true;
  }

  /// delete the least recent file from [isAnimation] directory
  Future<void> deleteLeastRecentFile(bool isAnimation) async{
    if ( this.hasBeenAnimation != isAnimation || // replaced folder
        this.leastRecentFile == null || this.leastRecentFile.b == null){
      this.hasBeenAnimation = isAnimation; // update folder
      await _updateLeastRecentFile(isAnimation);
    }
    await _deleteLeastRecent(isAnimation); // delete at least once
    while (toDelete(isAnimation, 0)){ // delete until its good
      await _deleteLeastRecent(isAnimation);
      
    }
    
  }

  /// update the least recent file from the [isAnimation] folder
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

  /// delete least recent file
  Future<void> _deleteLeastRecent(bool isAnimation) async{
    // if no least recent file
    if (this.leastRecentFile == null){
      await _updateLeastRecentFile(isAnimation);
      // no file to delete
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



}