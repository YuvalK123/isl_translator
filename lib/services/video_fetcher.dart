import 'dart:io' as io;

import 'package:cached_video_player/cached_video_player.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/play_video.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:isl_translator/shared/reg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:mutex/mutex.dart';

import 'add_feedback.dart';

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

  VideoFetcher({this.sentence});
  // VideoPlayerDemo _videoPlayerDemo = VideoPlayerDemo(key: Key("0"), myUrls: [],);


  static Future<List<String>> getDowloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  Future<bool> _requestPermission(Permission permission) async{
    if (await permission.isGranted){
      return true;
    }
    var result = await permission.request();
    return PermissionStatus.granted.isGranted;
  }

  Future<bool> saveFile(String url, String fileName) async{
    io.Directory directory;
    Dio dio = Dio();
    try {
      if (io.Platform.isAndroid){
        if (await _requestPermission(Permission.storage)){
          directory = await getExternalStorageDirectory();
          print(directory.path);
          String newPath = "";
          List<String> folders = directory.path.split("/");
          for (int i = 1; i < folders.length; i++){
            String folder = folders[i];
            if (folder != "android"){
              newPath += "/"+folder;
            }else{
              break;
            }
          }
          newPath = newPath + "/Cache";
          directory = io.Directory(newPath);
        }
      }else{
        // apple

      }
      if (await directory.exists()){
        String fullName = directory.path + "/$fileName";
        io.File saveFile = io.File(fullName);
        await dio.download(url, saveFile.path);// onReceiveProgress: {downloaded, totalSize});
      }
    }
    catch (e){

    }
    return false;
  }


  Future<List<String>> proccessWord(String word) async{
    var nonPre = await getNonPrepositional(word);
    List<String> urls = [];
    if (nonPre != null){
      urls.add(nonPre);
      return urls;
    }
    print("check for verb...");
    final stopWatch = Stopwatch()..start();
    var verb = await checkIfVerb(word);
    print("elapsed: ${stopWatch.elapsed} is verb??? $verb");
    if (verb != null){
      urls.add(verb);
      return urls;
    }
    // Video doesn't exist - so split the work to letters
    var letters = splitToLetters(word);
    List<String> lettersUrls = [];
    for(int j=0; j < letters.length; j++){
      Reference ref = FirebaseStorage.instance
          .ref("animation_openpose").child("${letters[j]}.mp4");
      // .child("animation_openpose/" + letters[j] + ".mp4");
      print ("ref = $ref");
      var url = await ref.getDownloadURL();
      print("got url at $url. adding to $urls");
      urls.add(url);
      print("letter added ==> " + letters[j]);
    }
    return urls;
    // print("letters urls are = $lettersUrls");
    // for(int l=0; l < lettersUrls.length; l++){
    //   print("adding" + lettersUrls[l]);
    //   urls.add(lettersUrls[l]);
    //   print("Hiiii adding to $urls");
    // }
    // print("got url at $url. adding to $urls");
  }


  Future<List> getUrls() async {
    List<String> splitSentenceList = splitSentence(sentence); // split the sentence
    print("splitSentenceList $splitSentenceList");
    List<String> urls = [];
    int i = 0, j = 0;
    for(i=0; i < splitSentenceList.length; i++)
    {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("animation_openpose/" + splitSentenceList[i] + ".mp4");
      try {
        // gets the video's url
        String url = await ref.getDownloadURL();
        urls.add(url);
      } catch (err) {
        var urlsList = await proccessWord(splitSentenceList[i]);
        print("urls list for ${splitSentenceList[i]} is $urlsList}");
        for (var url in urlsList){
          urls.add(url);
        }
      }
    }
    this.urls = urls;
    this.doneLoading = true;
    return urls;
  }

  Future<void> playVideos() async{
    List<String> urls = await getUrls();

    print("urls length == > " + urls.length.toString());
    // myUrls = urls;
    print("hello this is the urls ==> " + urls.toString());
    // if (mounted){
    //   setState(() {
    //     var videoPlayer = VideoFetcher2(key: UniqueKey(),myUrls: urls,);
    //     this.loading = false;
    //     this._videoFetcher2 = videoPlayer;
    //
    //     // this.videoPlayerDemo = videoPlayer;
    //
    //   });
    // }
  }
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
  bool state;
  Color borderColor = Colors.transparent;
  Mutex _mutex = Mutex();
  double aspectRatio;
  VideoFetcher _videoFetcher;


  @override
  void initState() {
    this._videoFetcher = VideoFetcher(sentence: widget.sentence);
    super.initState();
    toBeNamed();
  }

  void toBeNamed() async {
    await this._videoFetcher.getUrls();
    this.state = true;
    print(_videoFetcher.urls);
    if (_videoFetcher.urls.length > 0) {
      _initController(0).then((_) {
        setState(() {
          this.aspectRatio = _controller(0).value.aspectRatio;
          this._isReady = true;
          this.borderColor = Colors.black;
        });

        _playController(0);
      });
    }

    if (_videoFetcher.urls.length > 1) {
      _initController(1).whenComplete(() => /*_lock = false*/flipLock(false));
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
    print("index == $index");
    return _controllers[this._videoFetcher.urls[index] + index.toString()];
  }

  Future<void> _initController(int index) async {
    var myUrls = this._videoFetcher.urls;
    print("init $index");
    isInit[myUrls[index] + index.toString()] = false;
    VideoPlayerOptions options = VideoPlayerOptions(mixWithOthers: true);
    var controller = VideoPlayerController.network(myUrls[index]);
    _controllers[myUrls[index] + index.toString()] = controller;
    await controller.initialize();
    isInit[myUrls[index] + index.toString()] = true;
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
    //_controller(index).addListener(checkIfVideoFinished);
    if (mounted){
      setState(() {
        this._isReady = true;
      });
    }
    await _controller(index).play();
    setState(() {});
  }



  void _previousVideo() {
    if (_lock || index == 0) {
      return;
    }
    _lock = true;

    _stopController(index);

    if (index + 1 < this._videoFetcher.urls.length) {
      _removeController(index + 1);
    }

    _playController(--index);

    if (index == 0) {
      _lock = false;

    } else {
      _initController(index - 1).whenComplete(() => _lock = false);
    }
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
      return;
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
    return !this._isReady && !this._videoFetcher.doneLoading ? Loading() : Scaffold(
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
                        child: _videoFetcher.urls.length > 0 ? VideoPlayer(_controller(index)) : Container()),
                    ),

                  ),
                ),
              ),
            ),
            SingleChildScrollView(
                child: Container(
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

