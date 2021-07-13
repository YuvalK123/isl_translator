import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:isl_translator/screens/home/homescreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class UploadingVideos extends StatefulWidget {
  UploadingVideos({Key key, this.videoFile, this.expression}) : super(key: key);

  final XFile videoFile;
  final String expression;

  _UploadingVideos createState() => _UploadingVideos();
}

class _UploadingVideos extends State<UploadingVideos>{
  final _auth = FirebaseAuth.instance;
  String uid;
  String progressInfo;


  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser.uid;
    loadToStorage();
    // Navigator.pop(context);
    // Navigator.push(context, MaterialPageRoute(
    //     builder: (context) => HomeScreen()
    // ));

  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitDualRing(color: Colors.cyan[800]),
            Text(progressInfo)
          ],
        ),
      ),
    );

  }

  void loadToStorage() async {
    setState(() => progressInfo = 'loading video to firebase');
    await uploadVideo();
    setState(() => progressInfo = 'video uploaded. waiting for server response...');
    print('video uploaded');
    await notifyServer(uid, widget.expression);
    setState(() => progressInfo = 'new expression added.');

  }


  Future<void> uploadVideo() async {
    Reference ref = FirebaseStorage.instance.ref();
    Reference videoRef = ref.child('live_videos').child(uid).child('${widget.expression}.mp4');
    print('uploading video');
    await videoRef.putFile(File(widget.videoFile.path));

  }

  Future<String> notifyServer(uid ,fileName) async {
    String url = 'https://8e7938336584.ngrok.io';
    Map<String, String> data = {
      'uid': uid,
      'filename': fileName,
    };

    final response = await http.post(url, body: json.encode(data));
    print(response.body);
    return response.body;

  }
}