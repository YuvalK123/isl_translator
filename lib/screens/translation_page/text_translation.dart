import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/models/network_videoplayer.dart';
import 'package:isl_translator/services/play_video.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

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
  VideoPlayerDemo _videoPlayerDemo = VideoPlayerDemo();
  SeqVideoPlayer _seqVideoPlayer = SeqVideoPlayer();

  //video controller
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network('NULL');
    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();
    // Use the controller to loop the video.
    _controller.setLooping(false);

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'תרגום מטקסט לשפת הסימנים',
            textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              TextField(
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                controller: myController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'הכנס/י טקסט'),
              ),
              // ignore: deprecated_member_use
              FlatButton(
                onPressed: () async { await playVideos();},
                child: Text("תרגם"),
                color: Colors.black12,
              ),
              FutureBuilder(
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
                        child: _seqVideoPlayer,
                        // child: _videoPlayerDemo,
                        // child: VideoPlayer(_controller),
                      ),
                    );
                  } else {
                    // If the VideoPlayerController is still initializing, show a
                    // loading spinner.
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ]
        ),
      ),
    );
  }

  Future<void> playVideo(String videoName) async{
    var url;
    List<String> letters;
    // String videoName = splitSentenceList[0]; // take the first word
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
    print("url is $url");

    // Display the video
    _controller = VideoPlayerController.network('$url');
    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();
    // Use the controller to loop the video.
    _controller.setLooping(false);

    // await play();

    // setState( () {
    //   if (!_controller.value.isPlaying) {
    //     _controller.play();
    //   }
    // });
  }

  Future<void> play(){
    var yoyo = false;
    setState(() async{
      if (!_controller.value.isPlaying) {
        await _controller.play();
        print("now!");
        yoyo = true;
      }
    });
    while(!yoyo);
  }

  Future<void> playVideos() async{
    String sentence =
        myController.text; // got the sentence from the user
    List<String> splitSentenceList =
    splitSentence(sentence); // split the sentence
    print(splitSentenceList);
    var playerDemo = VideoPlayerDemo();
    // var playerDemo = _videoPlayerDemo;
    playerDemo.words.clear();
    print("were at ${playerDemo.words}");
    for(int i = 0; i < splitSentenceList.length; i++){
      String word = splitSentenceList[i];
      print("now at $word");
      word = await getUrlFromWord(word);
      playerDemo.words.add(word);
      // var result = await playVideo(word);
    }
    print("urls are ${playerDemo.words}");
    setState(() {
      _videoPlayerDemo = playerDemo;

    });
    // splitSentenceList.forEach((word) async {
    //   print(word);
    //   var result = await playVideo(word);
    // });
    // playVideo(splitSentenceList[0]);
  }

  Future<String> getUrlFromWord(String videoName) async{
    var url;
    List<String> letters;
    // String videoName = splitSentenceList[0]; // take the first word
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
    return url;
  }


  void checkIfVideoFinished() async {
    if (_controller == null ||
        _controller.value == null ||
        _controller.value.position == null) return;
    if (_controller.value.position.inSeconds >=
        _controller.value.duration.inSeconds) {
      _controller.removeListener(checkIfVideoFinished);
      _controller.dispose();
      var nextVideoUrl = 'https://firebasestorage.googleapis.com/v0/b/islcsproject.appspot.com/o/animation_openpose%2F%D7%90%D7%AA%D7%94.mp4?alt=media&token=40efd0bf-e7a5-4c05-b6fc-312107e6c8ab';
      //play(nextVideoUrl);
      print("end!!");
      _controller = VideoPlayerController.network('$nextVideoUrl');
      // Initialize the controller and store the Future for later use.
      _initializeVideoPlayerFuture = _controller.initialize();
      // Use the controller to loop the video.
      _controller.setLooping(false);
      _controller.addListener(checkIfVideoFinished);
      setState(() {
        if (!_controller.value.isPlaying) {
          _controller.play();
        }
      });
    }
  }


}