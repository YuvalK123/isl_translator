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
class _TranslatePage extends State<TranslatePage>
{
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
    StorageReference ref = FirebaseStorage.instance.ref().child("animation_openpose/אותם.mp4");
    String url = (ref.getDownloadURL().toString());
    print("url is $url");
    _controller = VideoPlayerController.network(
        'NULL'
    );
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
  void split_to_letters(String word) {
    var num = 0;
    for( var i = num ; i <= word.length; i++) {
      print(word[i]);
      // need to display each word on a video
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Sign Language'),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              TextField(
                controller: myController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your text'
                ),
              ),
              // ignore: deprecated_member_use
              FlatButton(
                onPressed: () async{
                  var url;
                  StorageReference ref  = FirebaseStorage.instance.ref().child("animation_openpose/" + myController.text + ".mp4");
                  try {
                    // gets the video's url
                    url = await ref.getDownloadURL();
                  } catch(err) {
                    // Video doesn't exist - so split the work to letters
                    split_to_letters(myController.text);
                  }

                  // Display the video
                  _controller = VideoPlayerController.network(
                    '$url'
                  );
                  // Initialize the controller and store the Future for later use.
                  _initializeVideoPlayerFuture = _controller.initialize();
                  // Use the controller to loop the video.
                  _controller.setLooping(false);
                  setState(() {
                    if (!_controller.value.isPlaying) {
                      _controller.play();
                      /*return Container(
                        child: FlickVideoPlayer(
                            flickManager: flickManager
                        ),
                      );*/
                    }
                  });
                  // start the video
                  /*setState(() {
                    // If the video is playing, pause it.
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      // If the video is paused, play it.
                      _controller.play();
                    }
                  });*/

                },
                child: Text("Translate"),
                color: Colors.black12,
              ),
              FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      // Use the VideoPlayer widget to display the video.
                      child: VideoPlayer(_controller),
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
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}