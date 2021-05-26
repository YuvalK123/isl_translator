import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services//show_video.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
//import 'package:flick_video_player/flick_video_player.dart';

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

  /* Split the word to letters */
  List<String> split_to_letters(String word) {
    List<String> lettersList = List<String>(word.length);
    var num = 0;
    for (var i = num; i < word.length; i++) {
      print(word[i]);
      lettersList[i] = word[i];
    }
    return lettersList;
  }

  /* Search for terms in the sentence and return a list ot terms */
  List<String> search_term(String sentence, List<String> saveTerms) {
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

  /* Split the sentence to word/term and return a list of the split sentence*/
  List<String> split_sentence(String sentence) {
    var new_sentence = sentence.replaceAll(
        new RegExp(r'[\u200f]'), ""); // replace to regular space
    List sentence_list = new_sentence.split(" "); //split the sentence to words

    List<String> saveTerms = [
      'יום הזיכרון',
      'ארבעת המינים',
      'כרטיס ברכה'
    ]; // list of terms(need to create one)
    List<String> terms =
    search_term(new_sentence, saveTerms); // terms in the sentence

    //var new_terms = sentence.replaceAll(new RegExp(r'[\u200f]'), "");
    List<String> splitSentence = [];

    // save the index and the length of the terms
    List indexTerms = [];
    for (int i = 0; i < terms.length; i++) {
      indexTerms.add(Pair(new_sentence.indexOf(terms[i]), terms[i].length));
    }
    //indexTerms.sort((a, b) => getIndex(a).compareTo(getIndex(b)));
    indexTerms.sort((x,y) => x.a.compareTo(y.a));

    // split the sentence to word and terms
    int terms_count = 0;
    int sentence_list_count = 0;
    for (int i = 0; i < new_sentence.length;) {
      if (terms_count < indexTerms.length && i == indexTerms[terms_count].a) {
        splitSentence.add(new_sentence.substring(i, i + indexTerms[terms_count].b));
        List termSplit = new_sentence.substring(i, i + indexTerms[terms_count].b).split(" ");
        i += indexTerms[terms_count].b + 1;
        sentence_list_count += termSplit.length;
        terms_count++;
      } else {
        splitSentence.add(sentence_list[sentence_list_count]);
        i += sentence_list[sentence_list_count].length + 1;
        sentence_list_count += 1;
      }
    }

    return splitSentence;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('תרגום מטקסט לשפת הסימנים',textDirection: TextDirection.rtl),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              TextField(
                textDirection: TextDirection.rtl,
                controller: myController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'הכנס/י טקסט'),
              ),
              // ignore: deprecated_member_use
              FlatButton(
                onPressed: () async {
                  String sentence =
                      myController.text; // got the sentence from the user
                  List<String> splitSentence =
                  split_sentence(sentence); // split the sentence
                  var url;
                  List<String> letters;
                  print(splitSentence);
                  String videoName = splitSentence[0]; // take the first word
                  StorageReference ref = FirebaseStorage.instance
                      .ref()
                      .child("animation_openpose/" + videoName + ".mp4");
                  try {
                    // gets the video's url
                    url = await ref.getDownloadURL();
                  } catch (err) {
                    // Video doesn't exist - so split the work to letters
                    letters = split_to_letters(myController.text);
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
                  });
                },
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
                        child: VideoPlayer(_controller),
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
}

/* Create Tuple */
class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}
