import 'package:flutter/material.dart';
import 'package:isl_translator/services//show_video.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

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
                onPressed: () {
                  //show the video in other page
                  //child: Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlayerScreen()));

                  //show the video in the same page
                  _controller = VideoPlayerController.network(
                    'https://drive.google.com/uc?export=download&id=18tX2pBLGIGCIhbhKBfV1Tvu-KsbWWLmT',
                  );
                  // Initialize the controller and store the Future for later use.
                  _initializeVideoPlayerFuture = _controller.initialize();
                  // Use the controller to loop the video.
                  _controller.setLooping(false);

                  // start the video
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
      floatingActionButton: FloatingActionButton(
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
        /*child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),*/
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}