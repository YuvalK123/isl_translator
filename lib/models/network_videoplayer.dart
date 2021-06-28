import 'package:flutter/material.dart';
import 'package:isl_translator/models/video_player_widget.dart';
import 'package:video_player/video_player.dart';

class NetworkVideoPlayer extends StatefulWidget {

  final String url;

  NetworkVideoPlayer({this.url});

  @override
  _NetworkVideoPlayerState createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<NetworkVideoPlayer> {

  VideoPlayerController _controller;
  final TextEditingController textController = TextEditingController();
  List<String> _urls = [
    'https://firebasestorage.googleapis.com/v0/b/islcsproject.appspot.com/o/animation_openpose%2F%D7%90%D7%AA%D7%94.mp4?alt=media&token=40efd0bf-e7a5-4c05-b6fc-312107e6c8ab',
    'https://firebasestorage.googleapis.com/v0/b/islcsproject.appspot.com/o/animation_openpose%2F%D7%90%D7%A9.mp4?alt=media&token=ad9871c6-187a-4431-9baf-26197ec14709',
  ];

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(textController.text)
      ..addListener(() => setState(() {

      }))..setLooping(false)
    ..initialize().then((value) => _controller.play());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayerWidget(
      controller: _controller,
    );
  }
}


class VideoPlayerTrial{

  int index = 0;
  double _position = 0;
  double _buffer = 0;
  bool _lock = true;
  Map<String, VideoPlayerController> _controllers = {};
  Map<int, VoidCallback> _listeners = {};
  // Set<String> _urls;
  Set<String> _urls; // = {
  // 'https://firebasestorage.googleapis.com/v0/b/islcsproject.appspot.com/o/animation_openpose%2F%D7%90%D7%AA%D7%94.mp4?alt=media&token=40efd0bf-e7a5-4c05-b6fc-312107e6c8ab',
  // 'https://firebasestorage.googleapis.com/v0/b/islcsproject.appspot.com/o/animation_openpose%2F%D7%90%D7%A9.mp4?alt=media&token=ad9871c6-187a-4431-9baf-26197ec14709',
  // };

  @override
  void initState() {
    // super.initState();
    // _urls = widget.words;
    print("urls are at page $_urls");
    if (_urls.length > 0) {
      _initController(0).then((_) {
        _playController(0);
      });
    }

    if (_urls.length > 1) {
      _initController(1).whenComplete(() => _lock = false);
    }
  }

  VoidCallback _listenerSpawner(index) {
    return () {
      int dur = _controller(index).value.duration.inMilliseconds;
      int pos = _controller(index).value.position.inMilliseconds;
      int buf = _controller(index).value.buffered.last.end.inMilliseconds;

      // setState(() {
      if (dur <= pos) {
        _position = 0;
        return;
      }
      _position = pos / dur;
      _buffer = buf / dur;
      // });
      if (dur - pos < 1) {
        if (index < _urls.length - 1) {
          _nextVideo();
        }
      }
    };
  }

  VideoPlayerController _controller(int index) {
    return _controllers[_urls.elementAt(index)];
  }

  Future<void> _initController(int index) async {
    var controller = VideoPlayerController.network(_urls.elementAt(index));
    _controllers[_urls.elementAt(index)] = controller;
    await controller.initialize();
  }

  void _removeController(int index) {
    _controller(index).dispose();
    _controllers.remove(_urls.elementAt(index));
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
    await _controller(index).play();
    // setState(() {});
  }

  void _previousVideo() {
    if (_lock || index == 0) {
      return;
    }
    _lock = true;

    _stopController(index);

    if (index + 1 < _urls.length) {
      _removeController(index + 1);
    }

    _playController(--index);

    if (index == 0) {
      _lock = false;
    } else {
      _initController(index - 1).whenComplete(() => _lock = false);
    }
    // setState(() {
    //   print("urls, set state at page");
    //   _urls = widget.words;
    // });
  }

  void _nextVideo() async {
    if (_lock || index == _urls.length - 1) {
      return;
    }
    _lock = true;

    _stopController(index);

    if (index - 1 >= 0) {
      _removeController(index - 1);
    }

    _playController(++index);

    if (index == _urls.length - 1) {
      _lock = false;
    } else {
      _initController(index + 1).whenComplete(() => _lock = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playing ${index + 1} of ${_urls.length}"),
      ),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onLongPressStart: (_) => _controller(index).pause(),
            onLongPressEnd: (_) => _controller(index).play(),
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller(index).value.aspectRatio,
                child: Center(child: VideoPlayer(_controller(index))),
              ),
            ),
          ),
          Positioned(
            child: Container(
              height: 10,
              width: MediaQuery.of(context).size.width * _buffer,
              color: Colors.grey,
            ),
          ),
          Positioned(
            child: Container(
              height: 10,
              width: MediaQuery.of(context).size.width * _position,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(onPressed: _previousVideo, child: Icon(Icons.arrow_back)),
          SizedBox(width: 24),
          FloatingActionButton(onPressed: _nextVideo, child: Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }

}

class SeqVideoPlayer extends StatefulWidget {

  final Set<String> urls = {};

  @override
  _SeqVideoPlayerState createState() => _SeqVideoPlayerState();
}

class _SeqVideoPlayerState extends State<SeqVideoPlayer> {

  int _index = 0;
  double _position = 0;
  double _buffer = 0;
  bool _lock = true;
  VideoPlayerController currController;
  VideoPlayerController nextController;
  List<VideoPlayerController> _controllers = [];
  // Map<String, VideoPlayerController> _controllers = {};
  Map<int, VoidCallback> _listeners = {};
  Set<String> _urls = {""," "};

  @override
  void initState() {
    super.initState();
    _urls = widget.urls;
    print("urls are at page $_urls");
    // if (_urls.length > 0) {
      _initController(0).then((_) {
    //     // _playController(0);
      });
    // }
    //
    if (_urls.length > 1) {
      _initController(1).whenComplete(() => _lock = false);
    }
  }

  VideoPlayerController _controller(int index) {
    return (index % 2 == 0) ? currController : nextController ;
    // return _controllers[_urls.elementAt(index)];
  }

  Future<void> _initController(int index) async {

    var controller = VideoPlayerController.network(_urls.elementAt(index));

    // _controllers[_urls.elementAt(index)] = controller;
    await controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meow Playing ${_index + 1} of ${_urls.length}"),
      ),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onLongPressStart: (_) => _controller(_index).pause(),
            onLongPressEnd: (_) => _controller(_index).play(),
            child: Center(
              // child: AspectRatio(
              //   aspectRatio: _controller(index).value.aspectRatio,
              //   child: Center(child: VideoPlayer(_controller(index))),
              // ),
            ),
          ),
          Positioned(
            child: Container(
              height: 10,
              width: MediaQuery.of(context).size.width * _buffer,
              color: Colors.grey,
            ),
          ),
          Positioned(
            child: Container(
              height: 10,
              width: MediaQuery.of(context).size.width * _position,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(onPressed: () {}, child: Icon(Icons.arrow_back)),
          SizedBox(width: 24),
          FloatingActionButton(onPressed: () {}, child: Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }
}

