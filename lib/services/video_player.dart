// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:video_player/video_player.dart';
import 'package:mutex/mutex.dart';
import 'add_feedback.dart';
import 'video_fetcher.dart';
import 'package:isl_translator/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isl_translator/services/database.dart';


/// VideoPlayer class
///
/// Display the videos sequentially
/// Add replay&pause&play buttons
/// Add review to the translation
class VideoPlayer2 extends StatefulWidget {

  final String sentence;

  VideoPlayer2({Key key, this.sentence}): super(key: key);

  @override
  _VideoPlayer2State createState() => _VideoPlayer2State();
}



class _VideoPlayer2State extends State<VideoPlayer2> {
  /// Variables
  int index = 0;
  bool _lock = true;
  bool isDone = false;
  Map<String, VideoPlayerController> _controllers = {};
  Map<String, bool> isInit = {};
  Map<int, bool> isInitSuccess = {};
  Map<int, VoidCallback> _listeners = {};
  Color borderColor = Colors.transparent;
  Mutex _mutex = Mutex();
  double aspectRatio;
  VideoFetcher _videoFetcher;
  bool isAnimation = true;
  String dirName = "animation_openpose/";
  UserModel currUserModel;
  bool isPause = false;

  /// Init
  @override
  void initState() {
    super.initState();
    this._videoFetcher = VideoFetcher(sentence: widget.sentence);
    initAsync();
  }

  /// Load user from DB
  Future<void> loadUser() async{
    final auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid;
    /// If its not an anonymous user
    if (!auth.currentUser.isAnonymous){
      await for (var value in DatabaseUserService(uid: uid).users){
        this.currUserModel = value;
        /// Check if user wants to see animation or live videos
        if(value.videoType == VideoType.LIVE)
        {
          this.isAnimation = false;
          this.dirName = "live_videos/";
        }
        break;
      }
    }
  }

  /// Gets urls and Init the first controllers
  void initAsync() async {
    /// Load user for getting the dirName
    await loadUser();
    /// Get the video's urls
    await this._videoFetcher.getUrls(dirName);
    /// If there is a video to show
    if (_videoFetcher.indexToUrlNew.isNotEmpty) {
      await _initController(0);
      if (mounted){
        setState(() {
          this.aspectRatio = _controller(0) != null ? _controller(0).value.aspectRatio : 1;
          this.borderColor = Colors.black;
        });
      }
      _playController(0);
      /// If there is more than one video,
      /// init the controller of the next video
      if (_videoFetcher.indexToUrlNew.keys.length > 1) {
        _initController(1).whenComplete(() => flipLock(false));
      }
    }
  }

  /// Listener - play the next video when the previous ends
  VoidCallback _listenerSpawner() {
    return () {
      var index = this.index;
      var controller = _controller(index);
      if (controller == null || controller.value == null) return;
      if( controller.value.buffered.length <= 0 ) return;
      int dur = controller.value.duration.inMilliseconds;
      int pos = controller.value.position.inMilliseconds;
      setState(() {
        if (dur <= pos) {
          return;
        }
      });
      if (dur - pos < 1) {
        if (index < this._videoFetcher.indexToUrlNew.length - 1) {
          _nextVideo();
        }
      }
    };
  }

  /// Return the according controller
  VideoPlayerController _controller(int index) {
    if(this._videoFetcher.indexToUrlNew.containsKey(index)){
      return _controllers[this._videoFetcher.indexToUrlNew[index] + index.toString()];
    }
    return null;
  }

  /// Create video controller for each video
  Future<VideoPlayerController> _getController(int index) async {
    String word = this._videoFetcher.indexToWordNew[index];
    String url = this._videoFetcher.wordsToUrlsNew[word];
    VideoPlayerController controller;
    io.File file = await VideoFetcher.lruCache.fetchVideoFile(word, this.isAnimation, null);
    if (file != null){
      controller = VideoPlayerController.file(file);
      return controller;
    }
    if (url == "&&" || url == "#"){
      url = await this._videoFetcher.getUrl(word, dirName);
    }
    controller = VideoPlayerController.network(url);
    return controller;
  }

  /// Init controller
  Future<void> _initController(int index) async {
    if (!mounted){
      return;
    }
    /// create controller
    VideoPlayerController controller = await _getController(index);
    if (controller == null){
      String url = this._videoFetcher.indexToUrlNew[index];
      controller = VideoPlayerController.network(url);
    }
    isInit[this._videoFetcher.indexToUrlNew[index] + index.toString()] = false;
    await controller.setVolume(0.0);

    /// init controller
    try{
      await controller.initialize();
      isInitSuccess[index] = true;
    } catch (e){
      isInitSuccess[index] = false;
      return;
    }
    /// save the controller in the controllers array
    _controllers[this._videoFetcher.indexToUrlNew[index] + index.toString()] = controller;
    isInit[this._videoFetcher.indexToUrlNew[index] + index.toString()] = true;
    if (mounted){
      setState(() {
      });
    }
  }

  /// Remove controller
  Future<void> _removeController(int index) async {
    await _controller(index).dispose();
    _controllers.remove(this._videoFetcher.indexToUrlNew[index] + index.toString());
    _listeners.remove(index);
  }

  /// Stop controller
  Future<void> _stopController(int index) async{
    _controller(index).removeListener(_listeners[index]);
    await _controller(index).pause();
    await _controller(index).seekTo(Duration(milliseconds: 0));
  }

  /// Play controller
  Future<void> _playController(int index) async {
    /// Add listener for all videos
    if (!_listeners.keys.contains(index)) {
      _listeners[index] = _listenerSpawner();
    }
    if (_listeners[index] == null) {
      _listeners[index] = _listenerSpawner();
    }
    if (_controller(index) != null) {
      _controller(index).addListener(_listeners[index]);
      _controller(index).addListener(() => finishVideo(index));
      if (mounted) {
        setState(() {
        });
      }
      /// Play the current video
      await _controller(index).play();
      if(index == this._videoFetcher.indexToUrlNew.length -1){
      }
    }
    setState(() {
    });
  }

  /// Change lock to be lock/unlock
  void flipLock(bool val) async{
    if (mounted){
      await _mutex.acquire();
      setState(() {
        _lock = val;
      });
      _mutex.release();
    }
  }

  /// Play next video
  void _nextVideo() async {
    /// Lock
    if (_lock)
    {
      _stopController(index);
    }
    /// Last video
    if(index == this._videoFetcher.indexToUrlNew.length - 1) {
      return;
    }

    /// Stop current video
    int currIndex = index;
    await _stopController(index);

    /// Remove lase controller
    if (index - 1 >= 0) {
      await _removeController(index - 1);
    }
    if (mounted){
      setState(() {
      });
    }

    /// Play next video
    flipLock(true);
    await _playController(++index);

    /// Handle locks
    if (index == this._videoFetcher.indexToUrlNew.length - 1) {
      flipLock(false);
    } else {
      await _initController(index + 1);
      flipLock(false);
      while(!isVideoFinished(currIndex)){
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
  }

  /// If video finished - update the variables and remove removeListener
  void finishVideo(int index) {
    if (isVideoFinished(index))
    {
      /// Remove listener
      _controller(index).removeListener(() => finishVideo(index));
      if(index == this._videoFetcher.indexToUrlNew.length -1){
        /// Update the boolean
        if (mounted) {
          setState(() {
            isDone = true;
          });
        }
        return;
      }
    }
  }

  /// Check if video is finished
  bool isVideoFinished(int index) {
    final controller = _controller(index);
    if (controller == null || controller.value == null ||
        controller.value.position == null || controller.value.duration == null) {
      return false;
    }
    if (controller.value.position.inSeconds >= controller.value.duration.inSeconds)
    {
      return true;
    }
    return false;
  }


  /// Dispose
  @override
  void dispose(){
    _controller(index)?.dispose();
    super.dispose();
  }


  /// Build
  @override
  Widget build(BuildContext context) {
    if (widget.sentence == null) {
      return Container();
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            /// Display video
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onLongPressStart: (_) => _controller(index).pause(),
                onLongPressEnd: (_) => _controller(index).play(),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: this.aspectRatio ?? 1.0,
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
                            String key = this._videoFetcher.indexToUrlNew[index] + index.toString();
                            if (!isInit.containsKey(key) || !isInit[key]){
                              return Loading();
                            }
                            return VideoPlayer(controller);
                          }
                      ),
                    ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Play button
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
                    /// Pause button
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
                    /// Replay button
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
            /// Review
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

  /// Pause the video
  void pause(){
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

  /// Contain the videoPlayer
  Future<VideoPlayerController> videoPlayerContainer(int index) async {
    Completer<VideoPlayerController> completer = Completer();
    if ((isInitSuccess.containsKey(index) && !isInitSuccess[index])){
      setState(() {
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

  /// Replay
  ///
  /// Start play all the sequence of videos from the beginning
  void replay(){
    index = 0;
    _initController(0).then((_) {
      setState(() {
        isPause = false;
        this.isDone = false;
        this.aspectRatio = _controller(0).value.aspectRatio;
        this.borderColor = Colors.black;
      });

      _playController(0);
    })..onError((error, stackTrace) {print("error on loading at 0 $error");});
    if (_videoFetcher.indexToUrlNew.keys.length > 1) {
      _initController(1).whenComplete(() => flipLock(false));
    }
  }

  /// Play the video
  void play(){
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