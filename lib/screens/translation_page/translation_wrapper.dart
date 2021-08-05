import 'package:flutter/material.dart';
import '../../shared/main_drawer.dart';
import 'voice_translation.dart';
import 'text_translation.dart';

/// Main function
///
/// Run the TranslationWrapper class (home page)
/// that allows us to move easily between
/// the Text_to_ISL page to Voice_to_ISL page
void main() {
  runApp(TranslationWrapper());
}

/// TranslationWrapper class
///
/// Allows the user to move easily between
/// the Text_to_ISL page to Voice_to_ISL page
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

  /// Init
  @override
  void initState() {
    super.initState();
  }

  /// Translation wrapper
  ///
  /// Allow the user to navigate easily between
  /// Text_to_ISL page to Voice_to_ISL page
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
            /// Bar for navigate between Text_to_ISL page to Voice_to_ISL page
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
                /// Voice to ISL
                RecordPage(),
                /// Text to ISL
                TranslatePage(),
              ]
          ),
        ),
      ),
    );
  }
}



