import 'package:flutter/cupertino.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:quick_feedback/quick_feedback.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/main.dart';
import 'package:flutter/material.dart';

class VideoPlayerDemo extends StatefulWidget {
  final List<String> myUrls;


  VideoPlayerDemo({Key key, this.myUrls}): super(key: key);


  // VideoPlayerDemo({this.words});

  @override
  _VideoPlayerDemoState createState() => _VideoPlayerDemoState();

}

class _VideoPlayerDemoState extends State<VideoPlayerDemo>{
  int index = 0;
  double _position = 0;
  double _buffer = 0;
  bool _lock = true;
  bool _isReady = false;
  Map<String, VideoPlayerController> _controllers = {};
  Map<int, VoidCallback> _listeners = {};
  Set<String> _urls;
  bool state;
  Color borderColor = Colors.transparent;

  @override
  void initState() {

    print("new page");
    super.initState();
    this.state = true;
    print("my urls!!");
    print(widget.myUrls);
    print("urls are at page $_urls");
    if (widget.myUrls.length > 0) {
      _initController(0).then((_) {
        setState(() {
          this._isReady = true;
          this.borderColor = Colors.black;
          // this.borderColor = Theme.of(context)
        });

        _playController(0);
      });
    }

    if (widget.myUrls.length > 1) {
      _initController(1).whenComplete(() => _lock = false);
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
        if (index < widget.myUrls.length - 1) {
          _nextVideo();
        }
      }
    };
  }

  VideoPlayerController _controller(int index) {
    return _controllers[widget.myUrls[index] + index.toString()];
  }

  Future<void> _initController(int index) async {
    var controller = VideoPlayerController.network(widget.myUrls[index]);
    _controllers[widget.myUrls[index] + index.toString()] = controller;
    await controller.initialize();
  }

  void _removeController(int index) {
    _controller(index).dispose();
    _controllers.remove(widget.myUrls[index] + index.toString());
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
    if(index <widget.myUrls.length)
    {
      _controller(index).addListener(checkIfVideoFinished);

    }
    //_controller(index).addListener(checkIfVideoFinished);
    await _controller(index).play();
    setState(() {});
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
      _nextVideo();
      if(index ==widget.myUrls.length -1){
        //add replay button
      }
      //playHi(sentence, index+1);
    }
  }

  void _previousVideo() {
    if (_lock || index == 0) {
      return;
    }
    _lock = true;

    _stopController(index);

    if (index + 1 < widget.myUrls.length) {
      _removeController(index + 1);
    }

    _playController(--index);

    if (index == 0) {
      _lock = false;

    } else {
      _initController(index - 1).whenComplete(() => _lock = false);
    }
  }

  void _nextVideo() async {
    if (_lock && index == widget.myUrls.length - 1) {
      print("lock1");
      _stopController(index);
    }
    if (_lock || index == widget.myUrls.length - 1) {
      print("lock2");
      setState(() {
        this.state = false;
        // this.index = 0;
        // this._urls = widget.myUrls;
      });
      return;
    }
    _lock = true;

    _stopController(index);

    if (index - 1 >= 0) {
      _removeController(index - 1);
    }

    _playController(++index);

    if (index == widget.myUrls.length - 1) {
      _lock = false;
    } else {
      _initController(index + 1).whenComplete(() => _lock = false);
    }
  }

  @override
  void dispose(){
    _controller(index)?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !this._isReady ? Loading() : Scaffold(
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onLongPressStart: (_) => _controller(index).pause(),
            onLongPressEnd: (_) => _controller(index).play(),
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller(index).value.aspectRatio,
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
                    child: VideoPlayer(_controller(index))),),

              ),
            ),
          ),
        ],
      ),
    );
  }
}