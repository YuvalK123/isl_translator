import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/screens/add_video/uploading_page.dart';
import 'package:isl_translator/screens/home/homescreen.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddExpression extends StatefulWidget {
  AddExpression({Key key, this.videoFile}) : super(key: key);

  // final String title;
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
                  onFieldSubmitted: (value) async {
                    expression = value;
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UploadingVideos(
                        videoFile: widget.videoFile,
                        expression: expression,
                      )
                    ));
                    // await uploadVideo(widget.videoFile);
                    // print('video uploaded');
                    // await notifyServer(uid, expression);
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (context) => HomeScreen()
                    // ));
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

  Future<void> uploadVideo(videoFile) async {
    Reference ref = FirebaseStorage.instance.ref();
    Reference videoRef = ref.child('live_videos').child(uid).child('$expression.mp4');
    print('uploading video');
    await videoRef.putFile(File(videoFile.path));

  }

  Future<void> notifyServer(uid ,fileName) async {
    String url = 'https://8e7938336584.ngrok.io';
    Map<String, String> data = {
      'uid': uid,
      'filename': fileName,
    };

    final response = await http.post(url, body: json.encode(data));
    print(response.body);

  }
}
