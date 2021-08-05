import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:isl_translator/screens/add_video/check_animation_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:isl_translator/services/handle_sentence.dart';


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
    if(widget.expression.split(' ').length > 1){
      saveTerms.add(widget.expression);
    }

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

  /// loading the new video to firebase
  /// notify the server about the new video
  /// waiting until the server confirm that the animation is ready
  Future<void> loadToStorage() async {
    try{
      setState(() => progressInfo = 'loading video to firebase');
      await uploadVideo();
      setState(() => progressInfo = 'video uploaded. waiting for server response...');
      print('video uploaded');
      await notifyServer(uid, widget.expression);
      setState(() => progressInfo = 'new expression added. downloading animation...');
      String animationPath = await getAnimationUrl(uid, widget.expression);
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => CheckAnimation(animationPath: animationPath)
      ));
    } on TimeoutException catch(_) {
      setState(() => progressInfo = 'the connection is taking to long\ncheck your connection and try again later.');
      await Future.delayed(Duration(seconds: 3));
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => TranslationScreen()
      ));
    } catch(_) {
      setState(() => progressInfo = 'something went wrong with the server\nplease try again.');
      await Future.delayed(Duration(seconds: 3));
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => TranslationScreen()
      ));
    }
  }

  /// checking the server address
  Future<String> getServerAddr() async {
    Reference ref = FirebaseStorage.instance.ref().child('addr.txt');
    Uint8List data = await ref.getData();
    String addr = utf8.decode(data);
    String httpsAddr = addr.replaceAll('http:', 'https:');
    return httpsAddr;
  }


  /// uploading video to firebase
  Future<void> uploadVideo() async {
    Reference ref = FirebaseStorage.instance.ref();
    Reference videoRef = ref.child('live_videos').child(uid).child('${widget.expression}.mkv');
    print('uploading video');
    await videoRef.putFile(File(widget.videoFile.path));

  }

  /// sending an https post massage to the server to notify it about the new
  /// video and its name
  Future<void> notifyServer(uid ,expression) async {
    String url = await getServerAddr();
    Map<String, String> data = {
      'uid': uid,
      'expression': expression,
      'filename': '$expression.mkv'
    };

    final response = await http.post(url, body: json.encode(data)).timeout(const Duration(seconds: 120));
    print(response.body);

  }

  /// getting the animation firebase path
  Future<String> getAnimationUrl(uid, expression) async{
    String firebasePath = 'animation_openpose/$uid/$expression.mp4';
    Reference ref = FirebaseStorage.instance.ref().child(firebasePath);
    String animationPath = await ref.getDownloadURL();
    return animationPath;
  }
}