
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
                    child: _videoPlayerDemo.myUrls.length < 1 ?
                    Container(width: 0.0, height: 0.0,) : _videoPlayerDemo
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
    if(mounted) {
      setState(() {
        print("stop");
        // this.isPressed = false;
        this._isListening = false;

        // _text = 'לחצ/י על הכפתור על מנת לדבר';
      });
    }
    var result = await playVideos();


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
        _text = "";
        setState(() => _isListening = true);
        var res = await _speech.listen(
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
      } else{
        await stop();
      }
    } else{
      await stop();
    }

  }

  Future<void> playVideos() async{
    print("playpl");
    List<String> urls = await _getUrls();
    print("urls list are $urls");

    setState(() {

      this._videoPlayerDemo = VideoPlayerDemo(myUrls: urls, key: UniqueKey(),);
      print("video demo ind in voice translation: ${this.keys}");
      this.keys++;
    });
  }

  Future<List<String>> _getUrls() async{
    String sentence = _text; // got the sentence from the user
    List<String> splitSentenceList = splitSentence(sentence); // split the sentence
    List<String> urls = [];
    for(int i=0; i < splitSentenceList.length; i++) {
      print("($i) split word ${splitSentenceList[i]}");
      await _getWordUrl(splitSentenceList[i], urls, i);
    }
    print("and this is the text: $_text from sentence $sentence");
    print("and urls are $urls");
    return urls;
  }

  Future<void> _getWordUrl(String word, List<String> urls, int i) async{
    String url;
    List<String> letters = [];
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("animation_openpose/" + word + ".mp4");
    try {
      // gets the video's url
      url = await ref.getDownloadURL();
      // urls[i] = url;
      urls.add(url);
    } catch (err) {
      print("err is $err");
      // Video doesn't exist - so split the work to letters
      letters = splitToLetters(word);
      for (int j = 0; j < letters.length; j++) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child("animation_openpose/" + letters[j] + ".mp4");
        url = await ref.getDownloadURL();
        print("url is $url");
        urls.add(url);
      }
    }
    print("($i) hello this is the urls ==> " + urls.toString());

  }


}
