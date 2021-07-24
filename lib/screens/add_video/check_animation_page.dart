import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:isl_translator/shared/main_drawer.dart';
import 'package:video_player/video_player.dart';


class CheckAnimation extends StatefulWidget {
  CheckAnimation({Key key, this.animationPath}) : super(key: key);

  final String animationPath;

  _CheckAnimation createState() => _CheckAnimation();
}

class _CheckAnimation extends State<CheckAnimation>{
  final _auth = FirebaseAuth.instance;
  String uid;
  VideoPlayerController controller;


  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser.uid;
    controller = VideoPlayerController.network(widget.animationPath)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('תצוגה מקדימה', textDirection: TextDirection.rtl),
        backgroundColor: Colors.cyan[800],
        actions: [],
      ),
      endDrawer: MainDrawer(
        currPage: pageButton.ADDVID,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
                  : Container(),
            ),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  setState(() {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  });
                },
                child: CircleAvatar(
                  radius: 33,
                  backgroundColor: Colors.black38,
                  child: Icon(
                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
        backgroundColor: Colors.cyan[800],
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TranslationScreen())
        ),
      ),
    );
  }
}