import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:isl_translator/screens/home/home.dart';
import 'package:isl_translator/services/video_cache.dart';
import '../../shared/main_drawer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'voice_translation.dart';
import 'text_translation.dart';

void main() {
  runApp(TranslationWrapper());
}

class TranslationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TranslationScreen(),

    );
  }
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text;
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(

        appBar: AppBar(
            title: Container(
              alignment: Alignment.centerRight,
                child: Text(
                  "תרגום שפת הסימנים",
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
            ),
            backgroundColor: Colors.cyan[900],
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'שמע',icon: Icon(Icons.speaker_phone)),
                Tab(text: 'טקסט', icon: Icon(Icons.text_fields)),
              ],
            ),
          ),
        endDrawer: MainDrawer(),
        body: SafeArea(
          bottom: false,
          child: TabBarView(
              children: [
                RecordPage(),
                TranslatePage(),
              ]
          ),
        ),
      ),
    );
  }
}



