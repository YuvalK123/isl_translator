import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/play_video.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:isl_translator/shared/reg.dart';
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
  VideoPlayerDemo videoPlayerDemo = VideoPlayerDemo(key: UniqueKey(), myUrls: [],);
  List<String> myUrls;
  int index = 0;
  int ind = 1;
  bool isLoading = false;
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Container(alignment: Alignment.topRight,child: Text(
            'תרגום מטקסט לשפת הסימנים',
            textDirection: TextDirection.rtl
        )
        ),
        backgroundColor: Colors.cyan[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                  onPressed: playVideos,
                  child: Text("תרגם"),
                  color: Colors.black12,
                ),
                Container(

                  child: AspectRatio(
                    aspectRatio: 1.0,
                      child: videoPlayerDemo.myUrls.length < 1 ? Container() : videoPlayerDemo
                      )
                  ),
              ]
          ),
        ),
      ),

    );
  }

  Future<List> getUrls() async {
    String sentence =
        myController.text; // got the sentence from the user
    List<String> splitSentenceList =
    splitSentence(sentence); // split the sentence
    String url;
    List<String> letters;
    print(splitSentenceList);
    List<String> urls = [];
    int i = 0, j = 0;
    for(i=0; i < splitSentenceList.length; i++)
    {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("animation_openpose/" + splitSentenceList[i] + ".mp4");
      try {
        // gets the video's url
        url = await ref.getDownloadURL();

        urls.add(url);
      } catch (err) {
        print("check for verb...");
        final stopWatch = Stopwatch()..start();
        var verb = await checkIfVerb(splitSentenceList[i]);
        print("elapsed: ${stopWatch.elapsed} is verb??? $verb");
        if (verb != null){
          urls.add(verb);
          continue;
        }
        // Video doesn't exist - so split the work to letters
        letters = splitToLetters(splitSentenceList[i]);
        List<String> lettersUrls = [];
        for(j=0; j < letters.length; j++){
          Reference ref = FirebaseStorage.instance
              .ref("animation_openpose").child("${letters[j]}.mp4");
              // .child("animation_openpose/" + letters[j] + ".mp4");
          print ("ref = $ref");
          url = await ref.getDownloadURL();
          print("got url at $url. adding to $urls");
          lettersUrls.add(url);
        }
        print("letters urls are = $lettersUrls");
        for (var l in lettersUrls){
          print("adding $l");
          urls.add(l);
        }
      }
    }
    return urls;
  }

  Future<void> playVideos() async{
    if (mounted){
      setState(() {
        this.isLoading = true;
      });
    }
    List<String> urls = await getUrls();

    // myUrls = urls;
    print("hello this is the urls ==> " + urls.toString());
    if (mounted){
      setState(() {
        this.isLoading = false;
        this.ind++;
        var videoPlayer = VideoPlayerDemo(key: UniqueKey(),myUrls: urls,);
        
        this.videoPlayerDemo = videoPlayer;

      });
    }


  }

}



