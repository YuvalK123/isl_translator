import 'package:flutter/material.dart';
import 'package:isl_translator/services/video_cache.dart';

class DummyPage extends StatefulWidget {
  @override
  _DummyPageState createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            Text("dummy page"),
            ElevatedButton(
                onPressed: () => LruCache.saveLetters("live_videos/"),
                child: Icon(Icons.download),
            )
          ],
        ),
      ),
    );
  }
}
