import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/play_video.dart';
import 'package:isl_translator/services/video_player.dart';
import 'package:flutter/services.dart' show rootBundle;
/*
Subject class
Each subject in the dict has a subject-dict of words that belong to this specific subject
*/

List<String> geography = [
  "תל אביב יפו",
  "רמת גן",
  "ירושלים",
  "אילת",
  "חיפה",
  "כפר סבא",
  "פתח תקווה",
  "ראשון לציון",
  "חדרה",
  "רעננה",
  "אשדוד",
  "גבעתיים",
  "דימונה",
  "זיכרון יעקב",
  "ראש העין",
  "מודיעין",
  "קיבוץ",
  "מושב"
];

List<String> holidays = [
  "חג",
  "מנהג",
  "ראש השנה",
  "סוכות",
  "חנוכה",
  "פורים",
  "פסח",
  "יום העצמאות",
  "לג בעומר"
];

List<String> times = [
  "דקה",
  "שנייה",
  "בוקר",
  "לפני הצהריים",
  "צהריים",
  "אחרי הצהריים",
  "ערב",
  "לילה",
  "יום",
  "אתמול",
  "שלשום",
  "היום",
  "מחר",
  "מחרתיים",
  "שבוע",
  "שבועיים",
  "חודש",
  "שנה",
  "ינואר",
  "פבואר",
  "מארס",
  "אפריל",
  "מאי",
  "יוני",
  "יולי",
  "אוגוסט",
  "ספטמבר",
  "אוקטובר",
  "נובמבר",
  "דצמבר",
  "יום ראשון",
  "יום שני",
  "יום שלישי",
  "יום רביעי",
  "יום חמישי",
  "יום שישי",
  "יום שבת",
  "מוצאי שבת",
  "עכשיו"
];

List<String> animals = [
  "דולפין",
  "נמלה",
  "קיפוד",
  "נחש",
  "צפרדע",
  "חמור",
  "סוס",
  "ארנב",
  "פרפר",
  "שפן",
  "דוב",
  "אריה",
  "נמר",
  "זאב",
  "תנין",
  "לווייתן",
  "ציפור",
  "דבורה",
  "זבוב",
  "יתוש",
  "ינשוף",
  "תוכי",
  "אייל",
  "צבי",
  "עכביש",
  "טווס",
  "פיל"
];

List<String> pronouns = [
  "אותנו",
  "היא",
  "הוא",
  "אותך",
  "אתה",
  "את",
  "אותי",
  "אני",
  "לנו",
  "הם",
  "הן",
  "שלכן",
  "שלכם",
  "שלנו",
  "בשבילה",
  "בשבילו",
  "שלה",
  "שלו",
  "בשבילך",
  "שלך",
  "בשבילי",
  "שלי",
  "אותן",
  "אותם",
  "לך",
  "לי",
  "לה",
  "לכם",
  "זה",
  "זאת",
  "אנחנו"
];

List<String> shapes = [
  "עיגול",
  "ריבוע",
  "מלבן",
  "משולש",
  "טרפז",
  "מעוין",
  "משושה",
  "מעגל",
  "צורה"
];

List<String>  body = [
  "פנים",
  "עיניים",
  "אוזניים",
  "אף",
  "יד",
  "רגל",
  "סנטר",
  "עורף",
  "מרפק",
  "מצח",
  "גרון",
  "שיניים",
  "דם",
  "כבד",
  "כליות",
  "ריאות",
  "לב",
  "עצם"
];

List<String> food = [
  "כריך",
  "קציצה",
  "בורקס",
  "עוגייה",
  "פיצה",
  "מרק",
  "אורז",
  "גלידה",
  "מלח",
  "פלפל שחור",
  "בטטה",
  "תפוח אדמה",
  "עגבנייה",
  "מלפפון",
  "בננה",
  "תפוח",
  "אגס",
  "שזיף",
  "תאנה",
  "לימון",
  "סופגנייה",
  "רימון",
  "אוזן המן",
  "מופלטה"
];

enum SubjectName{
  ANIMALS, FOOD, BODY, SHAPES, TIMES, GEOG, PRONOUNS, HOLIDAYS
}

class Subject extends StatefulWidget {
  final SubjectName subjectName;

  Subject({this.subjectName});

  @override
  _SubjectState createState() => _SubjectState();
}

class _SubjectState extends State<Subject> {
  List<String> myUrls;
  int ind = 1;
  SubjectName subjectName;
  String sentence;
  String dictAssetsPath = "assets/dictionary/";
  VideoPlayer2 _videoFetcher = VideoPlayer2(
    key: UniqueKey(),
    sentence: null,
  );

  @override
  void initState() {
    super.initState();
    subjectName = widget.subjectName;
  }

  // Play videos function
  Future<void> playVideos() async {
    //String sentence = myController.text;
    if (sentence == "") {
      sentence = null;
    }
    if (mounted) {
      setState(() {
        this._videoFetcher = VideoPlayer2(
          key: UniqueKey(),
          sentence: sentence,
        );
      });
    }
  }

  List<String> get names{
    switch(this.subjectName){
      case SubjectName.ANIMALS:
        return animals;
        break;
      case SubjectName.FOOD:
        return food;
        break;
      case SubjectName.BODY:
        return body;
        break;
      case SubjectName.SHAPES:
        return shapes;
        break;
      case SubjectName.TIMES:
        return times;
        break;
      case SubjectName.GEOG:
        return geography;
        break;
      case SubjectName.PRONOUNS:
        return pronouns;
        break;
      case SubjectName.HOLIDAYS:
        return holidays;
        break;
    }
    return null;
  }

  Future<List<String>> get namess async{
    Function func = rootBundle.loadString;
    // rootBundle.loadString('assets/dictionary/animals.txt')).split(",")
    switch(this.subjectName){
      case SubjectName.ANIMALS:
        return (await func(this.dictAssetsPath + "animals.txt")).split(",");
        break;
      case SubjectName.FOOD:
        return (await func(this.dictAssetsPath + "food.txt")).split(",");
        // return food;
        break;
      case SubjectName.BODY:
        return (await func(this.dictAssetsPath + "body.txt")).split(",");
        // return body;
        break;
      case SubjectName.SHAPES:
        return (await func(this.dictAssetsPath + "shapes.txt")).split(",");
        // return shapes;
        break;
      case SubjectName.TIMES:
        return (await func(this.dictAssetsPath + "times.txt")).split(",");
        // return times;
        break;
      case SubjectName.GEOG:
        return (await func(this.dictAssetsPath + "geography.txt")).split(",");
        // return geography;
        break;
      case SubjectName.PRONOUNS:
        return (await func(this.dictAssetsPath + "pronouns.txt")).split(",");
        // return pronouns;
        break;
      case SubjectName.HOLIDAYS:
        return (await func(this.dictAssetsPath + "holidays.txt")).split(",");
        break;
    }
    return null;
  }

  void printBundle() async{
    print("yoyo\n ${(await rootBundle.loadString('assets/dictionary/animals.txt')).split(",")}");
  }

  Future<List<Card>> _buildGridCards(BuildContext context) async{
    List<ButtonImage> products = [];
    List<String> subjects;
    try{
      subjects = await namess;
    } catch (e){
      print("err in dict is $e");
      subjects = names;
    }
    // print(subjects.join(","));
    // printBundle();
    for (int i = 0; i < subjects.length; i++) {
      products.add(new ButtonImage("", subjects[i], subjects[i]));
    }
    // if (subjectName == "holidays") {
    //
    //
    // } else if (subjectName == "pronoun") {
    //
    //
    //   for (int i = 0; i < names.length; i++) {
    //     products.add(new ButtonImage("", names[i], names[i]));
    //   }
    // } else if (subjectName == "animals") {
    //
    //   for (int i = 0; i < names.length; i++) {
    //     products.add(new ButtonImage("", names[i], names[i]));
    //   }
    // } else if (subjectName == "shapes") {
    //
    //   for (int i = 0; i < names.length; i++) {
    //     products.add(new ButtonImage("", names[i], names[i]));
    //   }
    // } else if (subjectName == "body") {
    //
    //   for (int i = 0; i < names.length; i++) {
    //     products.add(new ButtonImage("", names[i], names[i]));
    //   }
    // } else if (subjectName == "time") {
    //
    //   for (int i = 0; i < names.length; i++) {
    //     products.add(new ButtonImage("", names[i], names[i]));
    //   }
    // } else if (subjectName == "geography") {
    //
    //   for (int i = 0; i < names.length; i++) {
    //     products.add(new ButtonImage("", names[i], names[i]));
    //   }
    // } else if (subjectName == "food") {
    //
    //   for (int i = 0; i < names.length; i++) {
    //     products.add(new ButtonImage("", names[i], names[i]));
    //   }
    // }

    if (products == null || products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    /*final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());*/

    return products.map((product) {
      return Card(
        //color: Colors.cyan[800],
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
                              style: theme.textTheme.title,
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

  Widget _buildPopupDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetAnimationDuration: const Duration(milliseconds: 100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        // use container to change width and height
        height: 400,
        width: 1000,
        child: Column(
          children: <Widget>[
            Container(
              child: AspectRatio(aspectRatio: 1.0, child: _videoFetcher
                  // child: videoPlayerDemo.myUrls.length < 1 ? null : videoPlayerDemo
                  ),
            ),
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

            // children: _buildGridCards(context) // Changed code
          );
        },
      ),
    );
  }
}

/*
ButtonImage class
Each button image contain:
- name
- text to display below to image
- onTap variable that define which page to open when tapping
*/
class ButtonImage {
  String name;
  String text;
  String onTap;

  ButtonImage(this.name, this.text, this.onTap);
}
