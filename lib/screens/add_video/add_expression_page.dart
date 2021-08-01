import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/screens/add_video/uploading_page.dart';
import 'package:video_player/video_player.dart';

class AddExpression extends StatefulWidget {
  AddExpression({Key key, this.videoFile}) : super(key: key);

  final XFile videoFile;

  @override
  _AddExpression createState() => _AddExpression();
}

class _AddExpression extends State<AddExpression> {
  final _auth = FirebaseAuth.instance;
  VideoPlayerController controller;
  String uid;
  String expression = '';

  @override
  void initState() {
    super.initState();
    this.uid = _auth.currentUser.uid;
    controller = VideoPlayerController.file(File(widget.videoFile.path))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('תצוגה מקדימה', textDirection: TextDirection.rtl),
        backgroundColor: Colors.cyan[800],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
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
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: TextFormField(
                  onFieldSubmitted: (value) async {
                    expression = value;
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => UploadingVideos(
                        videoFile: widget.videoFile,
                        expression: expression,
                      )
                    ));
                  },
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'הכנס ביטוי',
                      hintStyle: TextStyle(
                          color: Colors.white,
                      ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
