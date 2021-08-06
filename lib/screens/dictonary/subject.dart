import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:isl_translator/services/video_player.dart';

/// Subjects Name
enum SubjectName{
  ANIMALS, FOOD, BODY, SHAPES, TIMES, GEOG, PRONOUNS, HOLIDAYS
}

/// Subject class
/// Each subject in the dict has a subject-dict of words that belong to this specific subject
class Subject extends StatefulWidget {
  final SubjectName subjectName;

  Subject({this.subjectName});

  @override
  _SubjectState createState() => _SubjectState();
}

class _SubjectState extends State<Subject> {
  /// Variables
  List<String> myUrls;
  int ind = 1;
  SubjectName subjectName;
  String sentence;
  String dictAssetsPath = "assets/dictionary/"; // take the subjects list from a file
  VideoPlayer2 _videoFetcher = VideoPlayer2(
    key: UniqueKey(),
    sentence: null,
  );

  /// Init
  @override
  void initState() {
    super.initState();
    subjectName = widget.subjectName;
  }

  /// Play videos function
  Future<void> playVideos() async {
    /// if there is not sentence
    if (sentence == "") {
      sentence = null;
    }
    /// call to videoFetcher for showing the video/animation
    if (mounted) {
      setState(() {
        this._videoFetcher = VideoPlayer2(
          key: UniqueKey(),
          sentence: sentence,
        );
      });
    }
  }

  /// Gets the words from the according file
  Future<List<String>> get names async{
    Function func = rootBundle.loadString;
    switch(this.subjectName){
      case SubjectName.ANIMALS:
        return (await func(this.dictAssetsPath + "animals.txt")).split(",");
        break;
      case SubjectName.FOOD:
        return (await func(this.dictAssetsPath + "food.txt")).split(",");
        break;
      case SubjectName.BODY:
        return (await func(this.dictAssetsPath + "body.txt")).split(",");
        break;
      case SubjectName.SHAPES:
        return (await func(this.dictAssetsPath + "shapes.txt")).split(",");
        break;
      case SubjectName.TIMES:
        return (await func(this.dictAssetsPath + "times.txt")).split(",");
        break;
      case SubjectName.GEOG:
        return (await func(this.dictAssetsPath + "geography.txt")).split(",");
        break;
      case SubjectName.PRONOUNS:
        return (await func(this.dictAssetsPath + "pronouns.txt")).split(",");
        break;
      case SubjectName.HOLIDAYS:
        return (await func(this.dictAssetsPath + "holidays.txt")).split(",");
        break;
    }
    return null;
  }

  /// Build the cards (the subject dictionary view)
  Future<List<Card>> _buildGridCards(BuildContext context) async{
    List<ButtonImage> products = [];
    /// Gets the words in this dictionary (for the specific subject)
    List<String> subjects;
    try{
      subjects = await names;
    } catch (e){
      subjects = [];
    }

    /// Create ButtonImage to each word
    for (int i = 0; i < subjects.length; i++) {
      products.add(new ButtonImage("", subjects[i], subjects[i]));
    }

    /// If there is not word to show, show an empty card
    if (products == null || products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);

    /// Create Card for each word (card contain image, word name, and on tap function)
    return products.map((product) {
      return Card(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.cyan[800], width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(8.0))),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              product.text,
                              style: theme.textTheme.headline6,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              bottom: 0.0,
              right: 0.0,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: () {
                  sentence = product.onTap;
                  playVideos();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Dialog to show the video
  Widget _buildPopupDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetAnimationDuration: const Duration(milliseconds: 100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        /// Use container to change width and height
        height: 400,
        width: 1000,
        child: Column(
          children: <Widget>[
            /// Contain the videoFetcher that display the video/animation
            Container(
              child: AspectRatio(aspectRatio: 1.0, child: _videoFetcher
                  ),
            ),
            // ignore: deprecated_member_use
            FlatButton(
              onPressed: () {
                if (mounted) {}
                Navigator.of(context).pop();
              },
              child: new Text("סגור"),
            ),
          ],
        ),
      ),
    );
  }

  /// Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
            alignment: Alignment.centerRight,
            child: Text(
              "תרגום שפת הסימנים",
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        backgroundColor: Colors.cyan[900],
      ),
      /// List of cards
      body: FutureBuilder<List<Card>>(
        future: _buildGridCards(context),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          List<Card> value;
          if (snapshot.hasError || !snapshot.hasData){
            value = <Card>[];
          }
          else if (snapshot.hasData){
            value = snapshot.data;
          }
          return GridView.count(
            crossAxisCount: 3,
            padding: EdgeInsets.all(16.0),
            childAspectRatio: 8.0 / 9.0,
            children: value,
          );
        },
      ),
    );
  }
}

/// ButtonImage class
///
/// Each button image contain: name, text to display below the image,
/// onTap variable that define which page to open when tapping
class ButtonImage {
  String name;
  String text;
  String onTap;

  ButtonImage(this.name, this.text, this.onTap);
}
