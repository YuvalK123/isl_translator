import 'package:flutter/cupertino.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:quick_feedback/quick_feedback.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/main.dart';
import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

class PlayVideoService{

  final TextEditingController myController;
  Function play;
  VideoPlayerController videoPlayerController;
  Future<void> initializeVideoPlayerFuture;

  List<String> savedTerms = [
    'יום הזיכרון',
    'ארבעת המינים',
    'כרטיס ברכה'
  ]; // list of terms(need to create one)


  PlayVideoService({this.myController, this.videoPlayerController,
    this.initializeVideoPlayerFuture, this.play});


  Future<void> translate() async{
    return await playVideos();
  }

  Future<void> playSingleVideo() async{
    String sentence =
        myController.text; // got the sentence from the user
    List<String> splitSentenceList =
    splitSentence(sentence); // split the sentence
    var url;
    List<String> letters;
    print(splitSentenceList);
    String videoName = splitSentenceList[0]; // take the first word
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("animation_openpose/" + videoName + ".mp4");
    try {
      // gets the video's url
      url = await ref.getDownloadURL();
    } catch (err) {
      // Video doesn't exist - so split the work to letters
      letters = splitToLetters(myController.text);
    }

    // Display the video
    videoPlayerController = VideoPlayerController.network('$url');
    // Initialize the controller and store the Future for later use.
    initializeVideoPlayerFuture = videoPlayerController.initialize();
    // Use the controller to loop the video.
    videoPlayerController.setLooping(false);
    print("play !");
    play();
  }

  Future<void> playVideos() async{
    return await playSingleVideo();
  }

  void getVideoFromDB(){

  }

  List<String> getSplitSentence(String sentence){
    var newSentence = sentence.replaceAll(
        new RegExp(r'[\u200f]'), ""); // replace to regular space
    List sentenceList = newSentence.split(" "); //split the sentence to words

    List<String> terms = searchTerm(newSentence, savedTerms), splitSentence = []; // terms in the sentence

    // save the index and the length of the terms
    List indexTerms = [];
    for (int i = 0; i < terms.length; i++) {
      indexTerms.add(Pair(newSentence.indexOf(terms[i]), terms[i].length));
    }
    //indexTerms.sort((a, b) => getIndex(a).compareTo(getIndex(b)));
    indexTerms.sort((x,y) => x.a.compareTo(y.a));

    // split the sentence to word and terms
    int termsCount = 0, sentenceListCount = 0, i = 0;
    while (i < newSentence.length) {
      // split into functions
      if (termsCount < indexTerms.length && i == indexTerms[termsCount].a) {
        splitSentence.add(newSentence.substring(i, i + indexTerms[termsCount].b));
        List termSplit = newSentence.substring(i, i + indexTerms[termsCount].b).split(" ");
        i += indexTerms[termsCount].b + 1;
        sentenceListCount += termSplit.length;
        termsCount++;
      } else {
        splitSentence.add(sentenceList[sentenceListCount]);
        i += sentenceList[sentenceListCount].length + 1;
        sentenceListCount += 1;
      }
    }

    return splitSentence;
  }

/* Split the word to letters */
  List<String> wordToLetters(String word){
    List<String> lettersList = [];
    for (var i = 0; i < word.length; i++) {
      print("word to letters, $i, ${word[i]}");
      lettersList[i] = word[i];
    }
    return lettersList;
  }

/* Search for terms in the sentence and return a list ot terms */
  List<String> searchTerm(String sentence, List<String> saveTerms) {
    List<String> terms = [];
    for (var i = 0; i < saveTerms.length; i++) {
      var searchName = saveTerms[i].replaceAll(new RegExp(r'[\u200f]'), "");
      if (sentence.contains(new RegExp(searchName, caseSensitive: false))) {
        terms.add(saveTerms[i]);
      }
    }
    print(terms);
    return terms;
  }

/* Find all the terms in DB - maybe to do it only once and save it? */
  Future<List<String>> findTermsDB() async {
    List<String> terms = [];
    final result = await FirebaseStorage.instance.ref()
        .child("animation_openpose/").listAll().then((result) {
      for (int i=0; i< result.items.length; i++){
        // ??
        String videoName = (result.items)[i].toString()
            .substring(55,(result.items)[i].toString().length -5);
        if(videoName.split(" ").length > 1){
          terms.add(videoName);
        }
      }
    });
    print("$result, $terms");
    return terms;
  }
}


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
    return _controllers[widget.myUrls[index]];
  }

  Future<void> _initController(int index) async {
    var controller = VideoPlayerController.network(widget.myUrls[index]);
    _controllers[widget.myUrls[index]] = controller;
    await controller.initialize();
  }

  void _removeController(int index) {
    _controller(index).dispose();
    _controllers.remove(widget.myUrls[index]);
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
    if (_lock || index == widget.myUrls.length - 1) {
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