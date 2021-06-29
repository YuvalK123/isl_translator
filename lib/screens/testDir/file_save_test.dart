import 'package:flutter/material.dart';
import 'package:isl_translator/services/video_cache.dart';
import 'package:isl_translator/shared/main_drawer.dart';

class DummyPage extends StatefulWidget {
  @override
  _DummyPageState createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  List<String> _firebaseDirNames = ["live_videos/", "animation_openpose/"];
  List<String> _cacheFolders = ["Cache/live/letters/", "Cache/animation/letters/"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tumtum"),),
      endDrawer: MainDrawer(currPage: pageButton.ADDVID,),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text("dummy page"),
              ElevatedButton(
                  onPressed: cacheLetters,
                  child: Icon(Icons.download),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cacheLetters() async {
    for (int i = 0; i < this._firebaseDirNames.length; i++) {
      String firebaseDirName = this._firebaseDirNames[i],
          cacheFolder = this._cacheFolders[i];
      print("caching letters for $firebaseDirName in $cacheFolder");
      await LruCache.saveLetters(firebaseDirName, cacheFolder);
    }
  }
}
