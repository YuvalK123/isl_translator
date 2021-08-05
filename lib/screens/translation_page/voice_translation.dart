import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/video_player.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:video_player/video_player.dart';

/// Translate voice to sign language
class RecordPage extends StatefulWidget {
  RecordPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RecordPage createState() => _RecordPage();
}

class _RecordPage extends State<RecordPage> {
  /// Variables
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'לחצ/י על הכפתור על מנת לדבר';
  int keys = 0;
  List<String> myUrls = [];
  String inputSentence;
  VideoPlayer2 _videoFetcher = VideoPlayer2(key: UniqueKey(), sentence: null,);
  /// Video controller
  VideoPlayerController _controller;

  /// Init
  @override
  void initState() {
    _controller = VideoPlayerController.network('NULL');
    _controller.setLooping(false);
    super.initState();
    _speech = stt.SpeechToText();
  }

  /// Voice translation page UI
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
                    aspectRatio: 1.0,
                    child: _videoFetcher,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Stop listening
  Future<void> stop() async {
    await _speech.stop();
    if (this._text == ""){
      this._text = 'לחצ/י על הכפתור על מנת לדבר';
      return;
    }
    await Future.delayed(const Duration(seconds: 1));
    if (mounted){
      setState(() {
        this._isListening = false;
        this._videoFetcher = VideoPlayer2(key: UniqueKey(), sentence: this._text,);
      });
    }
  }

  /// Listen function
  ///
  /// Record the user for translate the words to ISL
  void _listen() async {
    this._text = "";
    /// If not listening initialize and start listening
    if (!_isListening) {
      /// Init speech
      bool available = await _speech.initialize(
        onStatus: (val) async{
          if (val.toLowerCase().contains("not")) {
            await stop();
            return;
          }
        },
        onError: (val) => print('onError: $val'),
        debugLogging: false,
      );

      /// Start listening
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) =>
              setState(() {
                /// Get text from the voice recognizer
                _text = val.recognizedWords;
              }),
        );
      }
    }
  }
}
