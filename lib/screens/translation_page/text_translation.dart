import 'package:flutter/material.dart';
import 'package:isl_translator/services/video_player.dart';

/// Translate text to sign language
class TranslatePage extends StatefulWidget {
  TranslatePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TranslatePage createState() => _TranslatePage();
}

class _TranslatePage extends State<TranslatePage> {
  /// Create a text controller and use it to retrieve the current value
  /// of the TextField.
  final myController = TextEditingController();
  List<String> myUrls;
  int index = 0;
  int ind = 1;
  bool isLoading = false;
  VideoPlayer2 _videoFetcher = VideoPlayer2(
    key: UniqueKey(),
    sentence: null,
  );
  var _showContainer;

  /// Init
  @override
  void initState() {
    _showContainer = false;
    super.initState();
  }

  /// Change the bool variable _showContainer,
  /// that determine if to show the videoPlayer container or not
  void show() {
    setState(() {
      _showContainer = !_showContainer;
    });
  }

  /// Dispose
  @override
  void dispose() {
    /// Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  /// Text translation page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Container(
            alignment: Alignment.topRight,
            child: Text('תרגום מטקסט לשפת הסימנים',
                textDirection: TextDirection.rtl)),
        backgroundColor: Colors.cyan[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            TextField(
              textDirection: TextDirection.rtl,
              controller: myController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: 'הכנס/י טקסט'),
              textAlign: TextAlign.right,
            ),
            FlatButton(
              onPressed: playVideos,
              child: Text("תרגם"),
              color: Colors.black12,
            ),
            Container(
                child: AspectRatio(
              aspectRatio: 1.0,
              child: _videoFetcher,
              // child: videoPlayerDemo.myUrls.length < 1 ? Container() : videoPlayerDemo
            )),
          ]),
        ),
      ),
    );
  }

  /// Play videos function
  ///
  /// Check if the sentence is not null and call to videoFetcher
  /// for showing the videos
  Future<void> playVideos() async {
    String sentence = myController.text;
    if (sentence == "") {
      sentence = null;
    }
    if (mounted) {
      setState(() {
        this._videoFetcher = VideoPlayer2(
          key: UniqueKey(),
          sentence: sentence,
        );
      });
    }
  }
}
