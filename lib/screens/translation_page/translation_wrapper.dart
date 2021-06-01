import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:isl_translator/screens/home/home.dart';
import 'package:isl_translator/screens/home/main_drawer.dart';
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

  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
      onTap: () => print('flutter'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'voice': HighlightedWord(
      onTap: () => print('voice'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    'subscribe': HighlightedWord(
      onTap: () => print('subscribe'),
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    'like': HighlightedWord(
      onTap: () => print('like'),
      textStyle: const TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'comment': HighlightedWord(
      onTap: () => print('comment'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

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
          // actions: <Widget>[
          //   FlatButton.icon(onPressed: (){
          //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home()));
          //   },
          //       icon: Icon(Icons.home),
          //       label: Text("Home")
          //   ),
          // ],
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

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
        debugLogging: false,
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}



