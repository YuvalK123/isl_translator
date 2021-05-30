import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
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
  // final Map<String, HighlightedWord> _highlights = {
  //   'flutter': HighlightedWord(
  //     onTap: () => print('flutter'),
  //     textStyle: const TextStyle(
  //       color: Colors.blue,
  //       fontWeight: FontWeight.bold,
  //     ),
  //   ),
  //   'voice': HighlightedWord(
  //     onTap: () => print('voice'),
  //     textStyle: const TextStyle(
  //       color: Colors.green,
  //       fontWeight: FontWeight.bold,
  //     ),
  //   ),
  //   'subscribe': HighlightedWord(
  //     onTap: () => print('subscribe'),
  //     textStyle: const TextStyle(
  //       color: Colors.red,
  //       fontWeight: FontWeight.bold,
  //     ),
  //   ),
  //   'like': HighlightedWord(
  //     onTap: () => print('like'),
  //     textStyle: const TextStyle(
  //       color: Colors.blueAccent,
  //       fontWeight: FontWeight.bold,
  //     ),
  //   ),
  //   'comment': HighlightedWord(
  //     onTap: () => print('comment'),
  //     textStyle: const TextStyle(
  //       color: Colors.green,
  //       fontWeight: FontWeight.bold,
  //     ),
  //   ),
  // };

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'לחצ/י על הכפתור על מנת לדבר';
  double _confidence = 1.0;

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
        title: Text('תרגום מקול לשפת הסימנים', textDirection: TextDirection.rtl),
        backgroundColor: Colors.deepPurple[300],

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
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          backgroundColor: Colors.indigo[400],
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(_text),
        ),
      ),
    );

    // );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
        debugLogging: false,
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val)  =>
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
    } else {
      setState(() => _isListening = false);
      _speech.stop();
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
}
