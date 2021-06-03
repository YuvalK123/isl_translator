
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:isl_translator/services/play_video.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:isl_translator/services/show_video.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';


class RecordPage extends StatefulWidget {
  RecordPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RecordPage createState() => _RecordPage();
}

class _RecordPage extends State<RecordPage> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'לחצ/י על הכפתור על מנת לדבר';
  double _confidence = 1.0;
  int keys = 0;
  List<String> myUrls = [];
  VideoPlayerDemo _videoPlayerDemo = VideoPlayerDemo(key: Key("-1"), myUrls: [],);

  //video controller
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.network('NULL');
    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();
    // Use the controller to loop the video.
    _controller.setLooping(false);

    super.initState();
    _speech = stt.SpeechToText();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.topRight,
          child: Text('תרגום מקול לשפת הסימנים',
              textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,

          ),
        ),
        backgroundColor: Colors.cyan[800],

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme
            .of(context)
            .primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed:  !_isListening ? _listen : stop,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          backgroundColor: Colors.grey,
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Column(
            children: [
              SizedBox(height: 10.0,),
              Text(
                  _text,
                  textAlign: TextAlign.right,
              ),
              SizedBox(height: 5.0,),
              Container(
                child: AspectRatio(
                    aspectRatio: 100/100,
                    child: _videoPlayerDemo.myUrls.length < 1 ? null : _videoPlayerDemo
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // );
  }
  Future<void> stop() async {
    await _speech.stop();
    await Future.delayed(const Duration(seconds: 1));
    setState(() async{

      print("stop");
      // this.isPressed = false;
      this._isListening = false;
      var result = await meow();
    });


  }

  void _listen() async {
    // setState(() {
    //   this.isPressed = true;
    // });

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) async{
          print('onStatus: $val');
          if (val.toLowerCase().contains("not")) {
            await stop();
            return;
          }
        },
        onError: (val) => print('onError: $val'),
        debugLogging: false,
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) =>
              setState(() {
                _text = val.recognizedWords;
                print("recg is $_text");

                if (val.hasConfidenceRating && val.confidence > 0) {
                  _confidence = val.confidence;
                }
                print("confd ${val.confidence}");
              }),
        );
      }
    }

    Future<void> meoww1(String val) async{

    }

    /* Display video */
    /*String sentence = _text; // got the sentence from the user
    List<String> splitSentenceList =
    splitSentence(sentence); // split the sentence
    var url;
    List<String> letters;
    print(splitSentenceList);
    String videoName = splitSentenceList[0]; // take the first word
    StorageReference ref = FirebaseStorage.instance.ref().child("animation_openpose/" + videoName + ".mp4");
    try {
      // gets the video's url
      url = await ref.getDownloadURL();
    } catch (err) {
      // Video doesn't exist - so split the work to letters
      letters = splitToLetters(sentence);
    }

    // Display the video
    _controller = VideoPlayerController.network('$url');
    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();
    // Use the controller to loop the video.
    _controller.setLooping(false);
    setState(() {
      if (!_controller.value.isPlaying) {
        _controller.play();
      }
    });*/
  }

  Future<void> meow() async{
    String sentence = _text; // got the sentence from the user
    print("sentence is $sentence");
    List<String> splitSentenceList =
    splitSentence(sentence); // split the sentence
    String url;
    List<String> letters;
    print("split is $splitSentenceList");
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
        letters = splitToLetters(sentence);
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
    print("and this is the text: $_text from sentence $sentence");
    setState(() {
      this._videoPlayerDemo = VideoPlayerDemo(myUrls: urls, key: Key(this.keys.toString()),);
      print("video demo ind in voice translation: ${this.keys}");
      this.keys++;
    });

  }
}
