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
  List<String> myUrls;

  //video controller
  //VideoPlayerController _controller;
  VideoPlayerDemo _videoPlayerDemo;
  VideoPlayerController _next_controller;

  Future<void> _initializeVideoPlayerFuture;
  Future<void> _next_initializeVideoPlayerFuture;


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

                  /*var playerDemo = VideoPlayerDemo(myUrls);
                  setState(() {
                    _videoPlayerDemo = playerDemo;

                  });*/

                  /* new Column(
                      children: <Widget>[VideoPlayerDemo(urls)]);*/

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VideoPlayerDemo(urls)),
                  );

                  /*Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerDemo(urls),
                    ));*/
                },
                child: Text("תרגם"),
                color: Colors.black12,
              ),

              /*FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return AspectRatio( // replay (need to add a replay button/ maybe change this code)
                      aspectRatio: _controller.value.aspectRatio,
                      child: GestureDetector(
                        onTap: () {
                          if (!_controller.value.isPlaying) {
                            setState(() {});
                            _controller.initialize();
                            _controller.play();
                          }
                        },
                        //child: VideoPlayer(_controller),
                        child: _videoPlayerDemo,
                      ),
                    );
                  } else {
                    // If the VideoPlayerController is still initializing, show a
                    // loading spinner.
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),*/
            ]
        ),
      ),

    );
  }
}



