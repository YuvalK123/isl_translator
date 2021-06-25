// import 'package:avatar_glow/avatar_glow.dart';
// import 'package:flutter/material.dart';
// import 'package:highlight_text/highlight_text.dart';
// import 'package:isl_translator/services/play_video.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:isl_translator/services/show_video.dart';
// import 'package:video_player/video_player.dart';
// import 'package:firebase_storage/firebase_storage.dart';
//
//
// class RecordPage extends StatefulWidget {
//   RecordPage({Key key, this.title}) : super(key: key);
//   final String title;
//
//   @override
//   _RecordPage createState() => _RecordPage();
// }
//
// class _RecordPage extends State<RecordPage> {
//   stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _text = 'לחצ/י על הכפתור על מנת לדבר';
//   double _confidence = 1.0;
//   int keys = 0;
//   List<String> myUrls = [];
//   VideoPlayerDemo _videoPlayerDemo = VideoPlayerDemo(key: Key("-1"), myUrls: [],);
//
//   //video controller
//   VideoPlayerController _controller;
//   Future<void> _initializeVideoPlayerFuture;
//
//   @override
//   void initState() {
//     _controller = VideoPlayerController.network('NULL');
//     // Initialize the controller and store the Future for later use.
//     _initializeVideoPlayerFuture = _controller.initialize();
//     // Use the controller to loop the video.
//     _controller.setLooping(false);
//
//     super.initState();
//     _speech = stt.SpeechToText();
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Container(
//           alignment: Alignment.topRight,
//           child: Text('תרגום מקול לשפת הסימנים',
//               textDirection: TextDirection.rtl,
//             textAlign: TextAlign.right,
//
//           ),
//         ),
//         backgroundColor: Colors.cyan[800],
//
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: AvatarGlow(
//         animate: _isListening,
//         glowColor: Theme
//             .of(context)
//             .primaryColor,
//         endRadius: 75.0,
//         duration: const Duration(milliseconds: 2000),
//         repeatPauseDuration: const Duration(milliseconds: 100),
//         repeat: true,
//         child: FloatingActionButton(
//           onPressed:  !_isListening ? _listen : stop,
//           child: Icon(_isListening ? Icons.mic : Icons.mic_none),
//           backgroundColor: Colors.grey,
//         ),
//       ),
//       body: SingleChildScrollView(
//         reverse: true,
//         child: Container(
//           alignment: Alignment.topRight,
//           padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
//           child: Column(
//             children: [
//               SizedBox(height: 10.0,),
//               Text(
//                   _text,
//                   textAlign: TextAlign.right,
//               ),
//               SizedBox(height: 5.0,),
//               Container(
//                 child: AspectRatio(
//                     aspectRatio: 100/100,
//                     child: _videoPlayerDemo.myUrls.length < 1 ? null : _videoPlayerDemo
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//
//     // );
//   }
//   Future<void> stop() async {
//     setState(() {
//       this._isListening = false;
//     });
//     await _speech.stop();
//     // await Future.delayed(const Duration(seconds: 1));
//     if (mounted) {
//       var result = await meow();
//       setState(() {
//         print("stop");
//         // this.isPressed = false;
//
//       });
//
//     }
//
//
//   }
//
//   void _listen() async {
//     // setState(() {
//     //   this.isPressed = true;
//     // });
//
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (val) async{
//           print('onStatus: $val');
//           if (val.toLowerCase().contains("not")) {
//             await stop();
//             return;
//           }
//         },
//         onError: (val) async {
//           print("onerror");
//           if (val.toString().toLowerCase().contains("not")) {
//             await stop();
//             return;
//           }
//         },
//         debugLogging: false,
//       );
//
//       if (available) {
//         setState(() => _isListening = true);
//         _speech.listen(
//           onResult: (val) =>
//               setState(() {
//                 _text = val.recognizedWords;
//                 print("recg is $_text");
//
//                 if (val.hasConfidenceRating && val.confidence > 0) {
//                   _confidence = val.confidence;
//                 }
//                 print("confd ${val.confidence}");
//               }),
//         );
//       } else{
//         await stop();
//       }
//     } else {
//       await stop();
//     }
//
//
//   }
//
//   Future<void> meow() async{
//     String sentence = _text; // got the sentence from the user
//     print("sentence is $sentence");
//     List<String> splitSentenceList =
//     splitSentence(sentence); // split the sentence
//     String url;
//     List<String> letters;
//     print("split is $splitSentenceList");
//     List<String> urls = [];
//     for(int i=0; i < splitSentenceList.length; i++)
//     {
//       Reference ref = FirebaseStorage.instance
//           .ref()
//           .child("animation_openpose/" + splitSentenceList[i] + ".mp4");
//       try {
//         // gets the video's url
//         url = await ref.getDownloadURL();
//         urls.add(url);
//       } catch (err) {
//         // Video doesn't exist - so split the work to letters
//         letters = splitToLetters(sentence);
//         for(int j=0; j < letters.length; j++){
//           Reference ref = FirebaseStorage.instance
//               .ref()
//               .child("animation_openpose/" + letters[j] + ".mp4");
//           url = await ref.getDownloadURL();
//           urls.add(url);
//         }
//       }
//
//       //_initController(url).whenComplete(() => _lock = false);
//     }
//     myUrls = urls;
//     print("hello this is the urls ==> " + urls.toString());
//     print("and this is the text: $_text from sentence $sentence");
//     setState(() {
//       this._videoPlayerDemo = VideoPlayerDemo(myUrls: urls, key: Key(this.keys.toString()),);
//       print("video demo ind in voice translation: ${this.keys}");
//       this.keys++;
//     });
//
//   }
// }

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/video_fetcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:video_player/video_player.dart';



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
  // VideoPlayerDemo _videoPlayerDemo = VideoPlayerDemo(key: Key("-1"), myUrls: [],);
  String inputSentence;
  VideoPlayer2 _videoFetcher = VideoPlayer2(key: UniqueKey(), sentence: null,);

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
                    aspectRatio: 1.0,
                    child: _videoFetcher,
                    // child: _videoPlayerDemo.myUrls.length < 1 ? null : _videoPlayerDemo
                ),
              ),
              // SingleChildScrollView(
              //   child: Container(
              //     child: Center(
              //       child:
              //       _videoPlayerDemo.myUrls.length < 1 ? null : FlatButton(onPressed: () => showFeedback(context,inputSentence), // this will trigger the feedback modal
              //         child: Text('איך היה התרגום? לחצ/י כאן להוספת משוב', textDirection: TextDirection.rtl,),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );

    // );
  }
  Future<void> stop() async {
    var result = await _speech.stop();
    // print("result ${result}");
    await Future.delayed(const Duration(seconds: 1));
    if (mounted){
      setState(() {
        this._isListening = false;
        this._videoFetcher = VideoPlayer2(key: UniqueKey(), sentence: this._text,);
      });
    }

    // var result = await meow();
    // setState(() async{
    //   print("stop");
    //   // this.isPressed = false;
    //   this._isListening = false;
    //   var result = await meow();
    // });


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

  }

  // Future<void> meow() async{
  //   String sentence = _text; // got the sentence from the user
  //   inputSentence = sentence;
  //   print("sentence is $sentence");
  //   List<String> splitSentenceList =
  //   splitSentence(sentence); // split the sentence
  //   String url;
  //   List<String> letters;
  //   print("split is $splitSentenceList");
  //   List<String> urls = [];
  //   for(int i=0; i < splitSentenceList.length; i++)
  //   {
  //     Reference ref = FirebaseStorage.instance
  //         .ref()
  //         .child("animation_openpose/" + splitSentenceList[i] + ".mp4");
  //     try {
  //       // gets the video's url
  //       url = await ref.getDownloadURL();
  //       urls.add(url);
  //     } catch (err) {
  //       // Video doesn't exist - so split the work to letters
  //       letters = splitToLetters(sentence);
  //       for(int j=0; j < letters.length; j++){
  //         Reference ref = FirebaseStorage.instance
  //             .ref()
  //             .child("animation_openpose/" + letters[j] + ".mp4");
  //         url = await ref.getDownloadURL();
  //         urls.add(url);
  //       }
  //     }
  //
  //     //_initController(url).whenComplete(() => _lock = false);
  //   }
  //   myUrls = urls;
  //   print("hello this is the urls ==> " + urls.toString());
  //   print("and this is the text: $_text from sentence $sentence");
  //   setState(() {
  //     this._videoPlayerDemo = VideoPlayerDemo(myUrls: urls, key: Key(this.keys.toString()),);
  //     print("video demo ind in voice translation: ${this.keys}");
  //     this.keys++;
  //   });
  //
  // }
}
