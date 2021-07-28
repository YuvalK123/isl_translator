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
    bool isExists = await lruCache.isFileExists(word, isAnimation);
    if (isExists){
      map[word] = "&&";
      indexToUrl[indicesMap["j"]++] = "&&";
      return;
      // continue;
    }
    int i = indicesMap["i"];
    // gets the video's url
    String url = await getUrl(word, dirName);
    this.indexToWord[indicesMap["k"]++] = word;
    indexToUrl[indicesMap["j"]++] = url;
    map[splitSentenceList[i]] = url;
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
      indexToUrl[indicesMap["j"]++] = url;
      // indicesMap["k"]++;
      map[splitSentenceList[i]] = url;
      urls.add(url);
    } catch (err2) {
      var urlsList = await proccessWord(splitSentenceList[i], dirName);
      print("urls list for ${splitSentenceList[i]} is $urlsList}");
      if (urlsList.length == 1 && urlsList[0].length != 1) {
        this.indexToWord[indicesMap["k"]++] = word;
        map[splitSentenceList[i]] = urlsList[0]; // if not letters. if letters/ its cached
      }
      for (var url in urlsList) {
        indexToUrl[indicesMap["j"]++] = url;
        urls.add(url);
        indexToWord[indicesMap["k"]++] = url;
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
      print("yoyo ($i)");
      String word = splitSentenceList[i];
      try {
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

  // Future<void> playVideos(String dirName) async{
  //   List<String> urls = await getUrls(dirName, true);
  //
  //   print("urls length == > " + urls.length.toString());
  //   // myUrls = urls;
  //   print("hello this is the urls ==> " + urls.toString());
  //   // if (mounted){
  //   //   setState(() {
  //   //     var videoPlayer = VideoFetcher2(key: UniqueKey(),myUrls: urls,);
  //   //     this.loading = false;
  //   //     this._videoFetcher2 = videoPlayer;
  //   //
  //   //     // this.videoPlayerDemo = videoPlayer;
  //   //
  //   //   });
  //   // }
  // }
}

class VideoPlayer2 extends StatefulWidget {

  final String sentence;

  VideoPlayer2({Key key, this.sentence}): super(key: key);

  @override
  _VideoPlayer2State createState() => _VideoPlayer2State();
}



class _VideoPlayer2State extends State<VideoPlayer2> {
  int index = 0;
  double _position = 0;
  double _buffer = 0;
  bool _lock = true;
  Map<int, bool> _locks;
  bool _isReady = false;
  Map<String, VideoPlayerController> _controllers = {};
  Map<String, bool> isInit = {};
  Map<int, VoidCallback> _listeners = {};
  Set<String> _urls;
  Color borderColor = Colors.transparent;
  Mutex _mutex = Mutex();
  double aspectRatio;
  VideoFetcher _videoFetcher;

  bool vidType = false;
  String dirName = "animation_openpose/";
  UserModel currUserModel;
  FirebaseAuth _auth = FirebaseAuth.instance;
  // var urlss;
  bool isReplay = false;
  bool isPause = false;
  bool isPlay = false;

  @override
  void initState() {
    print("init state");
    super.initState();
    this._videoFetcher = VideoFetcher(sentence: widget.sentence);
    // this._videoFetcher.getUrls();
    initAsync();
  }

  // void trymeyo() async{
  //   // io.sleep(const Duration(seconds: 2));
  //   print("meow1");
  //   if(widget.sentence == null){
  //     return;
  //   }
  //   print("meow2");
  //   while(!this._videoFetcher.doneLoading){
  //     print("waiting...");
  //     io.sleep(const Duration(seconds: 1));
  //   }
  //   print("sett!!!!!");
  //   setState(() {
  //
  //   });
  // }

  // need to move the function to another class

  Future<void> loadUser() async{
    final auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid;
    if (!auth.currentUser.isAnonymous){
      await for (var value in DatabaseUserService(uid: uid).users){
        setState(() {
          this.currUserModel = value;
          print("videp type == > " + value.videoType.toString());
          if(value.videoType == VideoType.LIVE)
          {
            vidType= true;
            this.dirName = "live_videos/";
          }
        });
        break;
      }
    }
  }

  void initAsync() async {
    await loadUser(); // load user for getting the dirName
    print("current dir name --> " + dirName);
    await this._videoFetcher.getUrls(dirName, true);
    print("indexToUrl is ${_videoFetcher.indexToUrl}");
    if (_videoFetcher.indexToUrl.isNotEmpty) {
      await _initController(0);
      if (mounted){
        setState(() {
              this.aspectRatio = _controller(0).value.aspectRatio;
              this._isReady = true;
              this.borderColor = Colors.black;
            });
      }
      _playController(0);
      // _initController(0).then((_) {
      //
      //
      //   _playController(0);
      // })..onError((error, stackTrace) {print("error on loading at 0 $error");});
      if (_videoFetcher.indexToUrl.keys.length > 1) {
        _initController(1).whenComplete(() => /*_lock = false*/flipLock(false));
      }
    }


  }


  VoidCallback _listenerSpawner() {

    return () {
      var index = this.index;
      var controller = _controller(index);
      if( controller.value.buffered.length <= 0 ) return;
      print("index is ==> " + index.toString());
      int dur = controller.value.duration.inMilliseconds;
      int pos = controller.value.position.inMilliseconds;

      int buf = controller.value.buffered[controller.value.buffered.length-1].end.inMilliseconds;
      // int buf = controller.value.buffered.last.end.inMilliseconds;

      setState(() {
        if (dur <= pos) {
          _position = 0;
          return;
        }
        _position = pos / dur;
        _buffer = buf / dur;
      });
      if (dur - pos < 1) {
        if (index < this._videoFetcher.urls.length - 1) {
          _nextVideo();
        }
      }
    };
  }

  VideoPlayerController _controller(int index) {
    // print("index == $index, ${this._videoFetcher.indexToUrl} ${this._videoFetcher.indexToUrl[index]}");
    // if (this._videoFetcher.urls.length > index){
    print("index url is $index : ${this._videoFetcher.indexToUrl[index]}");
    if(this._videoFetcher.indexToUrl.containsKey(index)){
      return _controllers[this._videoFetcher.indexToUrl[index] + index.toString()];
    }
    return null;
  }

  Future<VideoPlayerController> _getController(int index) async {
    String word = this._videoFetcher.indexToWord[index];
    String url = this._videoFetcher.wordsToUrls[word];
    if (word == null || url == null) {
      print("this._videoFetcher.indexToWord ${this._videoFetcher.indexToWord}");
      print("getcontroller is null for index $index bec of $url or $word");
      return null;
    }
    String folderName = this.dirName.contains("animation") ?
      LruCache().cacheFolders["animation"] : LruCache().cacheFolders["live"];
    // String cacheFolder = await this._videoFetcher..getCachePathByFolder(
    //     folderName);
    String cacheFolder = await VideoFetcher.lruCache.getCachePathByFolder(folderName);
    print("cacheFolder is $cacheFolder");
    io.Directory directory = io.Directory(cacheFolder);
    String localUrl = directory.path + "/$word.mp4";
    VideoPlayerController controller;
    io.File file = io.File(localUrl);
    if (await file.exists()){
      controller = VideoPlayerController.file(io.File(localUrl));
      print("return locally for $word");
      return controller;
    }
    print("failed loading from cache");
    controller = VideoPlayerController.network(url);
    print("return from firebase for $word");
    print("index url is $index : word = $word, ${this._videoFetcher.indexToUrl[index]}");
    return controller;
  }

  Future<void> _initController(int index) async {
    var myUrls = this._videoFetcher.urls;
    // urlss = this._videoFetcher.indexToUrl;
    String url = this._videoFetcher.indexToUrl[index];
    print("url for $index is $url . word is ${this._videoFetcher.indexToWord[index]}");
    VideoPlayerController controller;
    if (url.startsWith("#")){ // letter
      print("letter!");
      if(VideoFetcher.lettersCachePath == null){
        String folderName;
        if (this.dirName.contains("animation")){
          folderName = LruCache().cacheLettersFolders["animation"];
        }else{
          folderName = LruCache().cacheLettersFolders["live"];
        }
        String newPath = await VideoFetcher.lruCache.createLettersCachePath(folderName);
      }
      url = url.replaceFirst("#", VideoFetcher.lettersCachePath);
      print("loading from file $url");
      controller = VideoPlayerController.file(io.File(url));
    }
    else if (url.startsWith("&&")){
      print("saved file!");
      String folderName = this.dirName.contains("animation") ?
        LruCache().cacheFolders["animation"] :
        LruCache().cacheFolders["live"];
      url = url.replaceFirst("&&", VideoFetcher.lettersCachePath);
      print("loading from file $url");
      controller = VideoPlayerController.file(io.File(url));
    }
    else{
      print("not letter or saved file!");
      controller = await _getController(index);
    }
    if (controller == null){
      print("got null for controller!");
      controller = VideoPlayerController.network(url);
    }
    print("init controller index is $index");
    isInit[this._videoFetcher.indexToUrl[index] + index.toString()] = false;

    controller.setVolume(0.0);
    _controllers[this._videoFetcher.indexToUrl[index] + index.toString()] = controller;
    await controller.initialize();
    isInit[this._videoFetcher.indexToUrl[index] + index.toString()] = true;
    print("finished $index init");
  }

  void _removeController(int index) {
    _controller(index).dispose();
    _controllers.remove(this._videoFetcher.urls[index] + index.toString());
    _listeners.remove(index);
  }


  void _stopController(int index) {
    _controller(index).removeListener(_listeners[index]);
    _controller(index).pause();
    _controller(index).seekTo(Duration(milliseconds: 0));
  }

  void _playController(int index) async {
    if (!_listeners.keys.contains(index)) {
      _listeners[index] = _listenerSpawner();
    }
    _controller(index).addListener(_listeners[index]);
    // if(index <widget.myUrls.length)
    // {
    //   _controller(index).addListener(checkIfVideoFinished);
    //
    // }
    _controller(index).addListener(checkIfVideoFinished);
    // if(index == _urls.length-1)
    //   {
    //     _controller(index).addListener(checkIfVideoFinished);
    //   }
    if (mounted){
      setState(() {
        this._isReady = true;
      });
    }
    await _controller(index).play();
    setState(() {});
  }

  void flipLock(bool val) async{
    await _mutex.acquire();
    setState(() {
      _lock = val;
    });
    _mutex.release();
  }

  void _nextVideo() async {
    if (_lock)
    {
      print("lock1");
      _stopController(index);
      //_nextVideo();
      // await _controller(index)?.pause();
      //return;
    }
    if(index == this._videoFetcher.urls.length - 1) {
      return;
    }

    _stopController(index);

    if (index - 1 >= 0) {
      _removeController(index - 1);
    }

    //_lock = true;
    flipLock(true);
    _playController(++index);

    if (index == this._videoFetcher.urls.length - 1) {
      // _lock = false;
      flipLock(false);
    } else {
      _initController(index + 1).whenComplete(() => /*_lock = false*/flipLock(false));
      // if(index < widget.myUrls.length - 3)
      //   {
      //     _initController(index + 2).whenComplete(() => _lock = false);
      //   }
    }
  }

  void checkIfVideoFinished() {
      if (_controller(index) == null ||
          _controller(index).value == null ||
          _controller(index).value.position == null ||
          _controller(index).value.duration == null) return;
      if (_controller(index).value.position.inSeconds ==
          _controller(index).value.duration.inSeconds)
      {
        _controller(index).removeListener(() => checkIfVideoFinished());
        //_controller.dispose();
        //_controller(index) = null;
        //_nextVideo();
        print("index for finish === >> " + index.toString());
        if(index == this._videoFetcher.indexToUrl.length -1){
          //add replay button
          print("finish all videos!!!");
          return;
        }
        //playHi(sentence, index+1);
      }
    }

  @override
  void dispose(){
    _controller(index)?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("sentence2 is ${widget.sentence}");
    if (widget.sentence == null) {
      return Container();
    }

    print("isready = ${this._isReady}, loading? ${this._videoFetcher.doneLoading}");
    print("is Loaded $index?? ${this._videoFetcher.indexToUrl.containsKey(index)}");
    // if (!this._videoFetcher.indexToUrl.containsKey(index)){
    //   return Loading();
    // } else{
    //   setState(() {
    //     print("setting stateush");
    //   });
    // }
    if (this._videoFetcher.doneLoading){
      print("hazzah 123");
    }
    if (this._videoFetcher.doneLoading){
      print("done loading!!!!");
    }
    return !this._videoFetcher.doneLoading ? Loading() : Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onLongPressStart: (_) => _controller(index).pause(),
                onLongPressEnd: (_) => _controller(index).play(),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: this.aspectRatio ?? 1.0,
                    // aspectRatio: _controller(index).value.aspectRatio,
                    child: Center(child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: this.borderColor,
                              width: 4.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(7.0),
                            )
                        ),
                        child: VideoPlayer(_controller(index))),
                      // child: _videoFetcher.urls.length > 0 ? VideoPlayer(_controller(index)) : Container()),
                    ),

                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                // decoration: BoxDecoration(
                //     border: Border.all(color: Colors.black, width: 5)
                // ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2,),
                          borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Center(
                        child:
                        IconButton(
                          icon: isPause ? const Icon(Icons.play_arrow,color: Colors.green,) : const Icon(Icons.play_arrow, color: Colors.grey,),
                          onPressed: () {
                            print("play");
                            if(isPause)
                              {
                                _controller(index).play();
                                setState(() {
                                  isPause = false;
                                });
                              }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 5,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2,),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Center(
                        child:
                        IconButton(
                          icon: isPause ? const Icon(Icons.pause, color: Colors.grey,) : const Icon(Icons.pause, color: Colors.red),
                          onPressed: () {
                            print("pause");
                            if(!isPause)
                              {
                                setState(() {
                                  isPause = true;
                                });
                                _controller(index).pause();
                              }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 5,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2,),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Center(
                        child:
                        IconButton(
                          icon: const Icon(Icons.replay, color:Colors.blue),
                          onPressed: () {
                            print("replay");
                            index = 0;
                            _initController(0).then((_) {
                              setState(() {
                                isPause = false;
                                this.aspectRatio = _controller(0).value.aspectRatio;
                                this._isReady = true;
                                this.borderColor = Colors.black;
                              });

                              _playController(0);
                            })..onError((error, stackTrace) {print("error on loading at 0 $error");});
                            if (_videoFetcher.indexToUrl.keys.length > 1) {
                              _initController(1).whenComplete(() => /*_lock = false*/flipLock(false));
                            }
                            //toBeNamed();
                            //_removeController(index);
                            // _stopController(index);
                            // index = 0;
                            // _playController(index);
                            // setState(() {
                            //   index = 0;
                            //   initState();
                            // });

                            //_controller(index).play();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            SingleChildScrollView(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Center(
                  child:
                  FlatButton(onPressed: () => showFeedback(context, widget.sentence), // this will trigger the feedback modal
                    child: Text('איך היה התרגום? לחצ/י כאן להוספת משוב', textDirection: TextDirection.rtl,),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
