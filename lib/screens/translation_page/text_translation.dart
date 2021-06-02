import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/play_video.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/play_video.dart';

class TranslatePage extends StatefulWidget {
  TranslatePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TranslatePage createState() => _TranslatePage();
}

class _TranslatePage extends State<TranslatePage> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();
  VideoPlayerDemo videoPlayerDemo = VideoPlayerDemo(myUrls: [],);
  List<String> myUrls;
  int index = 0;
  double _position = 0;
  double _buffer = 0;
  bool _lock = true;
  Map<String, VideoPlayerController> _controllers = {};
  Map<int, VoidCallback> _listeners = {};
  Set<String> _urls;
  var _showContainer;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    //_controller = VideoPlayerController.network('NULL');
    //_next_controller = VideoPlayerController.network('NULL');

    // Initialize the controller and store the Future for later use.
    /*_initializeVideoPlayerFuture = _controller.initialize();
    _next_initializeVideoPlayerFuture = _next_controller.initialize();
    // Use the controller to loop the video.
    _controller.setLooping(false);
    _next_controller.setLooping(false);
    super.initState();*/

    _showContainer=false;
    super.initState();

  }
  void show() {
    setState(() {
      _showContainer = !_showContainer;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    //_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(alignment: Alignment.topRight,child: Text('תרגום מטקסט לשפת הסימנים',textDirection: TextDirection.rtl)),
        backgroundColor: Colors.cyan[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: <Widget>[
              TextField(
                textDirection: TextDirection.rtl,
                controller: myController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'הכנס/י טקסט'),
                    textAlign: TextAlign.right,
              ),

              // ignore: deprecated_member_use
              FlatButton(
                onPressed: () async {
                  String sentence =
                  myController.text; // got the sentence from the user
                  List<String> splitSentenceList =
                  splitSentence(sentence); // split the sentence
                  String url;
                  List<String> letters;
                  print(splitSentenceList);
                  List<String> urls = [];
                  for(int i=0; i < splitSentenceList.length; i++)
                  {
                      Reference ref = FirebaseStorage.instance
                          .ref()
                          .child("animation_openpose/" + splitSentenceList[i] + ".mp4");
                      try {
                        // gets the video's url
                        url = await ref.getDownloadURL();
                        urls.add(url);
                      } catch (err) {
                        // Video doesn't exist - so split the work to letters
                        letters = splitToLetters(myController.text);
                        for(int j=0; j < letters.length; j++){
                          Reference ref = FirebaseStorage.instance
                              .ref()
                              .child("animation_openpose/" + letters[j] + ".mp4");
                          url = await ref.getDownloadURL();
                          urls.add(url);
                        }
                      }

                  //_initController(url).whenComplete(() => _lock = false);
                  }
                  myUrls = urls;
                  print("hello this is the urls ==> " + urls.toString());
                  /*show();
                  if (myUrls.length > 0) {
                    _initController(0).then((_) {
                      _playController(0);
                    });
                  }

                  if (myUrls.length > 1) {
                    _initController(1).whenComplete(() => _lock = false);
                  }*/
                  /*var playerDemo = VideoPlayerDemo(myUrls);
                  setState(() {
                    _videoPlayerDemo = playerDemo;

                  });*/

                  /* new Column(
                      children: <Widget>[VideoPlayerDemo(urls)]);*/

                   // Navigator.push(
                   //   context,
                   //   MaterialPageRoute(builder: (context) => VideoPlayerDemo(myUrls: myUrls,)),
                   // );
                  // this.videoPlayerDemo.myUrls.clear();
                  setState(() {
                    this.videoPlayerDemo = VideoPlayerDemo(myUrls: urls,);
                  });


                  /*Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerDemo(urls),
                    ));*/
                },
                child: Text("תרגם"),
                color: Colors.black12,
              ),
              Container(
                child: AspectRatio(
                  aspectRatio: 100/100,
                    child: videoPlayerDemo.myUrls.length < 1 ? null : videoPlayerDemo
                ),
              ),
              /*Visibility(
                child: GestureDetector(
                onLongPressStart: (_) => _controller(index).pause(),
                onLongPressEnd: (_) => _controller(index).play(),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller(index).value.aspectRatio,
                    child: Center(child: VideoPlayer(_controller(index))),
                  ),
                ),
              ),
                visible: _showContainer,
              ),*/
            ]
        ),
      ),

    );
  }

  // from play_video class
  VoidCallback _listenerSpawner(index) {
    return () {
      print("index is ==> " + index);
      int dur = _controller(index).value.duration.inMilliseconds;
      int pos = _controller(index).value.position.inMilliseconds;
      int buf = _controller(index).value.buffered.last.end.inMilliseconds;

      setState(() {
        if (dur <= pos) {
          _position = 0;
          return;
        }
        _position = pos / dur;
        _buffer = buf / dur;
      });
      if (dur - pos < 1) {
        if (index < myUrls.length - 1) {
          _nextVideo();
        }
      }
    };
  }

  VideoPlayerController _controller(int index) {
    return _controllers[myUrls[index]];
  }

  Future<void> _initController(int index) async {
    var controller = VideoPlayerController.network(myUrls[index]);
    _controllers[myUrls[index]] = controller;
    await controller.initialize();
  }

  void _removeController(int index) {
    _controller(index).dispose();
    _controllers.remove(myUrls[index]);
    _listeners.remove(index);
  }

  void _stopController(int index) {
    _controller(index).removeListener(_listeners[index]);
    _controller(index).pause();
    _controller(index).seekTo(Duration(milliseconds: 0));
  }

  void _playController(int index) async {
    if (!_listeners.keys.contains(index)) {
      _listeners[index] = _listenerSpawner(index);
    }
    _controller(index).addListener(_listeners[index]);
    if(index <myUrls.length)
    {
      _controller(index).addListener(checkIfVideoFinished);

    }
    //_controller(index).addListener(checkIfVideoFinished);
    await _controller(index).play();
    setState(() {});
  }

  void checkIfVideoFinished() {
    if (_controller == null ||
        _controller(index).value == null ||
        _controller(index).value.position == null) return;
    if (_controller(index).value.position.inSeconds ==
        _controller(index).value.duration.inSeconds)
    {
      _controller(index).removeListener(() => checkIfVideoFinished());
      //_controller.dispose();
      //_controller(index) = null;
      _nextVideo();
      //playHi(sentence, index+1);
    }
  }

  void _nextVideo() async {
    if (_lock || index == myUrls.length - 1) {
      return;
    }
    _lock = true;

    _stopController(index);

    if (index - 1 >= 0) {
      _removeController(index - 1);
    }

    _playController(++index);

    if (index == myUrls.length - 1) {
      _lock = false;
    } else {
      _initController(index + 1).whenComplete(() => _lock = false);
    }
  }
}



