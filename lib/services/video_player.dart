import 'dart:async';
import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/video_cache.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:video_player/video_player.dart';
import 'package:mutex/mutex.dart';

import 'add_feedback.dart';
import 'video_fetcher.dart';
import 'package:isl_translator/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/services/database.dart';

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
  bool isDone = false;
  Map<String, VideoPlayerController> _controllers = {};
  Map<String, bool> isInit = {};
  Map<int, bool> isInitSuccess = {};
  Map<int, VoidCallback> _listeners = {};
  Set<String> _urls;
  Color borderColor = Colors.transparent;
  Mutex _mutex = Mutex();
  double aspectRatio;
  VideoFetcher _videoFetcher;

  bool isAnimation = true;
  String dirName = "animation_openpose/";
  UserModel currUserModel;
  FirebaseAuth _auth = FirebaseAuth.instance;
  // bool isReplay = false;
  bool isPause = false;
  // bool isPlay = false;

  String getKey(Map map, dynamic key){
    return map[index] + index.toString();
  }

  @override
  void initState() {
    print("init state");
    super.initState();
    this._videoFetcher = VideoFetcher(sentence: widget.sentence);
    // this._videoFetcher.getUrls();
    initAsync();
  }

  // need to move the function to another class

  Future<void> loadUser() async{
    final auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid;
    if (!auth.currentUser.isAnonymous){
      await for (var value in DatabaseUserService(uid: uid).users){
        // setState(() {
        this.currUserModel = value;
        print("video type == > " + value.videoType.toString());
        if(value.videoType == VideoType.LIVE)
        {
          this.isAnimation = false;
          this.dirName = "live_videos/";
        }
        // });
        break;
      }
    }
  }

  void initAsync() async {
    await loadUser(); // load user for getting the dirName
    print("current dir name --> " + dirName);
    await this._videoFetcher.getUrls(dirName, true);
    //await Future.delayed(Duration(seconds: 1));
    print("indexToUrl is ${_videoFetcher.indexToUrlNew}");
    if (_videoFetcher.indexToUrlNew.isNotEmpty) {
      await _initController(0);
      if (mounted){
        setState(() {
          this.aspectRatio = _controller(0) != null ? _controller(0).value.aspectRatio : 1;
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
      if (_videoFetcher.indexToUrlNew.keys.length > 1) {
        _initController(1).whenComplete(() => /*_lock = false*/flipLock(false));
      }
    }


  }


  VoidCallback _listenerSpawner() {

    return () {
      var index = this.index;
      var controller = _controller(index);
      if (controller == null || controller.value == null) return;
      if( controller.value.buffered.length <= 0 ) return;
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
        if (index < this._videoFetcher.indexToUrlNew.length - 1) {
          _nextVideo();
        }
      }
    };
  }

  VideoPlayerController _controller(int index) {
    // print("index == $index, ${this._videoFetcher.indexToUrl} ${this._videoFetcher.indexToUrl[index]}");
    // if (this._videoFetcher.urls.length > index){
    // print("index url is $index : ${this._videoFetcher.indexToUrl[index]}");
    if(this._videoFetcher.indexToUrlNew.containsKey(index)){
      return _controllers[this._videoFetcher.indexToUrlNew[index] + index.toString()];
    }
    return null;
  }

  Future<VideoPlayerController> _getController(int index) async {
    String word = this._videoFetcher.indexToWordNew[index];
    //String url = this._videoFetcher.wordsToUrls[word];
    print("from _getController = word $word");

    String url = this._videoFetcher.wordsToUrlsNew[word];
    print("from _getController = url $url");
    VideoPlayerController controller;
    // if (url == "&&" || url == "#"){
    io.File file = await VideoFetcher.lruCache.fetchVideoFile(word, this.isAnimation, null);
    if (file != null){
      controller = VideoPlayerController.file(file);
      print("return locally for $word, $controller");
      return controller;
    }
    if (url == "&&" || url == "#"){
      url = await VideoFetcher.getUrl(word, dirName);
    }
    print("failed loading from cache");
    controller = VideoPlayerController.network(url);
    print("return from firebase for $word");
    print("index url is $index : word = $word, ${this._videoFetcher.indexToUrlNew[index]}");
    return controller;
  }


  Future<void> _initController2(int index) async {
    String title = this._videoFetcher.indexToWordNew[index];

    var myUrls = this._videoFetcher.urls;
    // urlss = this._videoFetcher.indexToUrl;
    String url = this._videoFetcher.indexToUrlNew[index];
    print("url for $index is $url . word is ${this._videoFetcher.indexToWordNew[index]}");
    VideoPlayerController controller;
    if (url.startsWith("#")){ // letter
      var file = await VideoFetcher.lruCache.fetchVideoFile(title, this.dirName.contains("animation"), "#");
      print("file from fetching for # is $file");
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
      var file = await VideoFetcher.lruCache.fetchVideoFile(title, this.dirName.contains("animation"), "&&");
      controller = VideoPlayerController.file(file);
      // print("file from fetching for && is $file");
      // print("saved file!");
      // String folderName = this.dirName.contains("animation") ?
      //   LruCache().cacheFolders["animation"] :
      //   LruCache().cacheFolders["live"];
      // url = url.replaceFirst("&&", VideoFetcher.lettersCachePath);
      // print("loading from file $url");
      // controller = VideoPlayerController.file(io.File(url));
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
    isInit[this._videoFetcher.indexToUrlNew[index] + index.toString()] = false;

    controller.setVolume(0.0);
    _controllers[this._videoFetcher.indexToUrlNew[index] + index.toString()] = controller;

    await controller.initialize();
    isInit[this._videoFetcher.indexToUrlNew[index] + index.toString()] = true;
    print("finished $index init");
  }

  Future<void> _initController(int index) async {
    if (!mounted){
      return;
    }
    VideoPlayerController controller = await _getController(index);
    if (controller == null){
      print("got null for controller at index $index!");
      String url = this._videoFetcher.indexToUrlNew[index];
      controller = VideoPlayerController.network(url);
    }
    print("init controller index is $index");
    isInit[this._videoFetcher.indexToUrlNew[index] + index.toString()] = false;

    await controller.setVolume(0.0);
    String word = this._videoFetcher.indexToWordNew[index];

    print("init for $index $word");
    try{
      await controller.initialize();
      isInitSuccess[index] = true;
    } catch (e){
      print("$word init error is $e");
      isInitSuccess[index] = false;
      return;
      // await controller.dispose();
      // if (index > 0){
      //   int i = index - 1;
      //   try{
      //     print("wait to dispose last");
      //     // final prev = this._controllers[this._videoFetcher.indexToUrl[i] + i.toString()];
      //     while (!isVideoFinished(i)){
      //       await Future.delayed(Duration(milliseconds: 500));
      //     }
      //     print("prev finished ($i)");
      //     // _initController(index);
      //     return;
      //     // await _removeController(i);
      //     // await _initController(i);
      //     // print("disposed");
      //   }
      //   catch (ee){
      //     print("failed to dispose $ee");
      //   }
    }
    _controllers[this._videoFetcher.indexToUrlNew[index] + index.toString()] = controller;

    // controller = await _getController(index);
    // _controllers[this._videoFetcher.indexToUrl[index] + index.toString()] = controller;
    // controller.initialize();
    // }
    // await controller.initialize();
    print("after init for $index $word");
    isInit[this._videoFetcher.indexToUrlNew[index] + index.toString()] = true;
    if (mounted){
      setState(() {
        print("set state after init");
      });
    }

    print("finished $index init for $word, $controller");
  }

  Future<void> _removeController(int index) async {
    // await Future.delayed(const Duration(milliseconds: 1500), _controller(index).dispose);
    await _controller(index).dispose();
    _controllers.remove(this._videoFetcher.indexToUrlNew[index] + index.toString());
    _listeners.remove(index);
  }


  Future<void> _stopController(int index) async{
    _controller(index).removeListener(_listeners[index]);
    await _controller(index).pause();
    await _controller(index).seekTo(Duration(milliseconds: 0));
  }

  Future<void> _playController(int index) async {
    if (!_listeners.keys.contains(index)) {
      _listeners[index] = _listenerSpawner();
    }
    if (_listeners[index] == null) {
      _listeners[index] = _listenerSpawner();
    }
    if (_controller(index) != null) {
      // await _initController(index);
      // _playController(index);
      // return;
      // setState(() {
      //   this.index++;
      // });
      // return;
      //

      _controller(index).addListener(_listeners[index]);
      // if(index <widget.myUrls.length)
      // {
      //   _controller(index).addListener(checkIfVideoFinished);
      //
      // }
      _controller(index).addListener(() => finishVideo(index));
      // if(index == _urls.length-1)
      //   {
      //     _controller(index).addListener(checkIfVideoFinished);
      //   }
      if (mounted) {
        setState(() {
          this._isReady = true;
        });
      }
      // Future<void> future =  _controller(index).play();
      await _controller(index).play();
      if(index == this._videoFetcher.indexToUrlNew.length -1){
        // setState(() {
        //   this.isDone = true;
        // });
      }
    }
    setState(() {
      // print("future $future");
    });
    // await future;
  }

  void flipLock(bool val) async{

    if (mounted){
      await _mutex.acquire();
      setState(() {
        _lock = val;
      });
      _mutex.release();
    }


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
    if(index == this._videoFetcher.indexToUrlNew.length - 1) {
      print("ended urls");
      return;
    }
    int currIndex = index;
    await _stopController(index);

    if (index - 1 >= 0) {
      await _removeController(index - 1);
    }
    if (mounted){
      setState(() {

      });
    }

    //_lock = true;
    flipLock(true);
    await _playController(++index);
    // _playController(++index);

    if (index == this._videoFetcher.indexToUrlNew.length - 1) {
      // _lock = false;
      flipLock(false);
    } else {
      await _initController(index + 1);
      flipLock(false);

      while(!isVideoFinished(currIndex)){
        await Future.delayed(Duration(milliseconds: 500));
      }
      // _initController(index + 1).whenComplete(() => /*_lock = false*/flipLock(false));
      // if(index < widget.myUrls.length - 3)
      //   {
      //     _initController(index + 2).whenComplete(() => _lock = false);
      //   }
    }
    // flipLock(true);
    // await _playController(++index);
  }

  void finishVideo(int index) {
    if (isVideoFinished(index))
    {
      _controller(index).removeListener(() => finishVideo(index));
      //_controller.dispose();
      //_controller(index) = null;
      //_nextVideo();
      print("index for finish === >> " + index.toString());
      if(index == this._videoFetcher.indexToUrlNew.length -1){
        if (mounted) {
          print("finish all videos111111!!!");
          setState(() {
            isDone = true;
          });
        }
        print("finish all videos!!!");
        return;
      }
      //playHi(sentence, index+1);
    }
  }

  bool isVideoFinished(int index) {
    final controller = _controller(index);
    if (controller == null || controller.value == null ||
        controller.value.position == null || controller.value.duration == null) {
      return false;
    }
    if (controller.value.position.inSeconds >= controller.value.duration.inSeconds)
    {
      return true;
      //playHi(sentence, index+1);
    }
    return false;
  }

  @override
  void dispose(){
    _controller(index)?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("sentence2 is ${widget.sentence}");
    if (widget.sentence == null) {
      return Container();
    }

    // print("isready = ${this._isReady}, loading? ${this._videoFetcher.doneLoading}");
    // print("is Loaded $index?? ${this._videoFetcher.indexToUrl.containsKey(index)}");
    // if (!this._videoFetcher.indexToUrl.containsKey(index)){
    //   return Loading();
    // } else{
    //   setState(() {
    //     print("setting stateush");
    //   });
    // }
    // if (this._videoFetcher.doneLoading){
    //   print("hazzah 123");
    // }
    // if (this._videoFetcher.doneLoading){
    //   print("done loading!!!!");
    // }
    // return !this._videoFetcher.doneLoading ? Loading() : Scaffold(
    return Scaffold(
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
                      // child: (_controller(index) != null) ? // && _controller(index).value.isInitialized) ?
                      // VideoPlayer(_controller(index)) : Loading(),
                      child: FutureBuilder<VideoPlayerController>(
                          initialData: null,
                          future: videoPlayerContainer(index),
                          builder: (context, snapshot) {
                            VideoPlayerController controller;
                            if (snapshot.hasError || !snapshot.hasData){
                              return Loading();
                            } else{
                              controller = snapshot.data;
                            }
                            // if (!controller.value.isInitialized){
                            if (!isInit[this._videoFetcher.indexToUrlNew[index] + index.toString()]){
                              return Loading();
                            }
                            return VideoPlayer(controller);
                            // return VideoPlayer(_controller(index));
                          }
                      ),
                    ),
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
                          onPressed: play,
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
                          icon: (isPause || isDone) ?
                          const Icon(Icons.pause, color: Colors.grey,) :
                          const Icon(Icons.pause, color: Colors.red),
                          onPressed: pause,
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
                          onPressed: replay,
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


  void pause(){
    print("pause");
    if(!isPause && !isDone)
    {
      if (mounted){
        setState(() {
          isPause = true;
        });
      }
      _controller(index).pause();
    }
  }
  Future<VideoPlayerController> videoPlayerContainer(int index) async {
    Completer<VideoPlayerController> completer = Completer();
    if ((isInitSuccess.containsKey(index) && !isInitSuccess[index])){
      setState(() {
        // this.index++;
      });
      return null;
    }
    if (!isInit[this._videoFetcher.indexToUrlNew[index] + index.toString()]){
      await Future.delayed(Duration(milliseconds: 500));
      return videoPlayerContainer(index);
    }
    completer.complete(_controller(index));
    return completer.future;
  }
  void replay(){
    print("replay");
    index = 0;
    _initController(0).then((_) {
      setState(() {
        isPause = false;
        this.isDone = false;
        this.aspectRatio = _controller(0).value.aspectRatio;
        this._isReady = true;
        this.borderColor = Colors.black;
      });

      _playController(0);
    })..onError((error, stackTrace) {print("error on loading at 0 $error");});
    if (_videoFetcher.indexToUrlNew.keys.length > 1) {
      _initController(1).whenComplete(() => /*_lock = false*/flipLock(false));
    }
  }

  void play(){
    print("play");
    if(isPause)
    {
      _controller(index).play();

      if (mounted){
        setState(() {
          isPause = false;
        });
      }
    }
  }
}