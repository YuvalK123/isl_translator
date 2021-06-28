import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AddExpression extends StatefulWidget {
  AddExpression({Key key, this.videoPath}) : super(key: key);

  // final String title;
  final String videoPath;

  @override
  _AddExpression createState() => _AddExpression();
}

class _AddExpression extends State<AddExpression> {
  VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('תצוגה מקדימה', textDirection: TextDirection.rtl),
        backgroundColor: Colors.deepPurple[300],
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
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'הכנס ביטוי',
                      suffixIcon: CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.black12,

                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
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
