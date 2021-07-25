// import 'dart:io' as io;
// import 'package:permission_handler/permission_handler.dart';
//
// import 'package:flutter/material.dart';
// import 'package:isl_translator/services/video_fetcher.dart';
// import 'package:isl_translator/shared/reg.dart';
// import 'package:path_provider/path_provider.dart';
//
// class TmpDeleteMe extends StatefulWidget {
//   @override
//   _TmpDeleteMeState createState() => _TmpDeleteMeState();
// }
//
// class _TmpDeleteMeState extends State<TmpDeleteMe> {
//
//   List<String> lettersList = ["א","ב","ג","ד","ה","ו","ז","ח","ט",
//     "י","כ","ך","ל","מ","ם","נ","ן","ס",
//     "ע","פ","ף","צ","ץ","ק","ר","ש","ת"];
//   bool hasLettersLocal = false;
//
//   Map<String,String> firebaseDirNames = {"live":"live_videos/", "animation":"animation_openpose/"};
//   Map<String,String> cacheFolders = {"live":"Cache/live", "animation": "Cache/animation"};
//   Map<String,String> cacheLettersFolders = {"live":"Cache/live/letters", "animation":"Cache/animation/letters"};
//
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
//
//   ///
//   /// Video cache
//   ///
//
//   static String getPath() {
//     return io.Directory.current.path;
//   }
//
//   Future<void> saveVideosFromUrls(bool isAnimation, Map<String,String> urls) async{
//     isAnimation = isAnimation == null ? true : isAnimation;
//     String cacheFolder = !isAnimation ? cacheFolders["live"] : cacheFolders["animation"];
//     String firebaseDirName = !isAnimation ? firebaseDirNames["live"] : firebaseDirNames["animation"];
//     print("save videos. isAnimation = $isAnimation, cacheFolder = $cacheFolder, firbaseDir = $firebaseDirName");
//     try{
//
//       urls.forEach((String word, String url) async{
//         // if (await isFileExist(word, isAnimation)) {
//         // print("on $firebaseDirName/$word.mp4");
//         // String url = await VideoFetcher.getUrl(word, firebaseDirName);
//         print("downloaded letter url $url");
//         await VideoFetcher().saveFile(url, "$word.mp4", cacheFolder);
//         print("saved $word!!");
//         // }
//       });
//
//     } catch(e){
//       print("e for words $urls is $e");
//     }
//   }
//
//   Future<void> saveLetters(String firebaseDirName, String cacheFolder) async{
//     print("saving letters in $cacheFolder");
//     // return;
//     for (var letter in lettersList){
//       try{
//         print("on $firebaseDirName/$letter.mp4");
//         String url = await VideoFetcher.getUrl("$letter",firebaseDirName);
//         print("downloaded letter url $url");
//         await VideoFetcher().saveFile(url, "$letter.mp4", cacheFolder);
//         print("saved!!");
//       } catch(e){
//         print("e for letter $letter is $e");
//       }
//
//     }
//     hasLettersLocal = true;
//   }
//
//
//   ///
//   /// Video fetcher
//   ///
//
//   Future<String> createLettersCachePath(String folderName) async{
//     if (folderName == null || folderName == ""){
//       folderName = "/Cache";
//     }else if (!folderName.startsWith("/")){
//       folderName = "/" + folderName;
//     }
//     if (folderName.endsWith("/")){
//       folderName.substring(0, folderName.length - 1);
//     }
//     print("folderName is $folderName");
//     io.Directory directory = await getExternalStorageDirectory();
//     print("path is ${directory.path}");
//     String newPath = "";
//     List<String> folders = directory.path.split("/");
//     for (int i = 1; i < folders.length; i++){
//       String folder = folders[i];
//       print("folder == $folder");
//       // newPath += "/" + folder;
//       if (folder != "android"){
//         newPath += "/" + folder;
//       }else{
//         break;
//       }
//     }
//     newPath = newPath + folderName;
//     var lettersCachePath = newPath;
//     return newPath;
//   }
//
//   Future<String> getCachePathByFolder(String folderName) async{
//     if (folderName == null || folderName == ""){
//       folderName = "/Cache";
//     }else if (!folderName.startsWith("/")){
//       folderName = "/" + folderName;
//     }
//     if (folderName.endsWith("/")){
//       folderName.substring(0, folderName.length - 1);
//     }
//     print("folderName is $folderName");
//     io.Directory directory = await getExternalStorageDirectory();
//     print("path is ${directory.path}");
//     String newPath = "";
//     List<String> folders = directory.path.split("/");
//     for (int i = 1; i < folders.length; i++){
//       String folder = folders[i];
//       print("folder == $folder");
//       // newPath += "/" + folder;
//       if (folder != "android"){
//         newPath += "/" + folder;
//       }else{
//         break;
//       }
//     }
//     newPath = newPath + folderName;
//     return newPath;
//   }
//
//
//   // Future<void> _initController(int index) async {
//   //   var myUrls = this._videoFetcher.urls;
//   //   urlss = this._videoFetcher.indexToUrl;
//   //   String url = urlss[index];
//   //   print("url for $index is $url");
//   //   VideoPlayerController controller;
//   //   if (url.startsWith("#")){ // letter
//   //     print("letter!");
//   //     if(VideoFetcher.lettersCachePath == null){
//   //       String folderName;
//   //       if (this.dirName.contains("animation")){
//   //         folderName = LruCache().cacheLettersFolders["animation"];
//   //       }else{
//   //         folderName = LruCache().cacheLettersFolders["live"];
//   //       }
//   //       String newPath = await this._videoFetcher.createLettersCachePath(folderName);
//   //     }
//   //     url = url.replaceFirst("#", VideoFetcher.lettersCachePath);
//   //     print("loading from file $url");
//   //     controller = VideoPlayerController.file(io.File(url));
//   //   }
//   //   else{
//   //     print("not letter!");
//   //     controller = await _getController(index);
//   //   }
//   //   if (controller == null){
//   //     print("got null for controller!");
//   //     controller = VideoPlayerController.network(url);
//   //   }
//   //   print("init controller index is $index");
//   //   isInit[urlss[index] + index.toString()] = false;
//   //
//   //   controller.setVolume(0.0);
//   //   _controllers[urlss[index] + index.toString()] = controller;
//   //   await controller.initialize();
//   //   isInit[urlss[index] + index.toString()] = true;
//   //   print("finished $index init");
//   // }
//
//   // need to move the function to another class
//
//   Future<String> loadUser() async{
//     return null;
//     // final auth = FirebaseAuth.instance;
//     // String uid = auth.currentUser.uid;
//     // if (!auth.currentUser.isAnonymous){
//       // await for (var value in DatabaseUserService(uid: uid).users){
//       //   setState(() {
//           // this.currUserModel = value;
//           // print("videp type == > " + value.videoType.toString());
//           // if(value.videoType == VideoType.LIVE)
//           // {
//             // vidType= true;
//             // this.dirName = "live_videos/";
//           // }
//         // });
//         // break;
//       // }
//     // }
//   }
//
//   Future<void> saveFile(){
//
//   }
//
//   Future<void> saveVids(){
//     saveFile();
//   }
//
//   Future<String> setUrls(){
//     getUrl(word, dirName);
//     getPersonalUrl();
//     saveVids();
//
//     return null;
//   }
//
//   Future<bool> _requestPermission(Permission permission) async{
//     if (await permission.isGranted){
//       return true;
//     }
//     var result = await permission.request();
//     return PermissionStatus.granted.isGranted;
//   }
//
//   Future<void> toBeNamed() async{
//     String userDir = await loadUser(); // video fetcher
//     var urls = await setUrls();
//     /* VP2:
//     loadUser()
//     this.setUrls()
//     * setUrls:
//     geturl
//     getpersUrl
//     saveVids
//     * saveVids:
//     saveFile
//
//      */
//   }
//
// }
