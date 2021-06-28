import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/play_video.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isl_translator/services/video_cache.dart';
import 'package:isl_translator/services/video_fetcher.dart';

import 'package:video_player/video_player.dart';
class Subject extends StatefulWidget {
  final String name;
  Subject(this.name);

  @override
  _SubjectState createState() => _SubjectState();
}

class _SubjectState extends State<Subject> {
  VideoPlayerDemo videoPlayerDemo = VideoPlayerDemo(key: Key("0"), myUrls: [],);
  List<String> myUrls;
  int ind = 1;
  String subjectName;
  String sentence;
  VideoPlayer2 _videoFetcher = VideoPlayer2(key: UniqueKey(), sentence: null,);

  @override
  void initState() {
    super.initState();
    subjectName = widget.name;
  }

  Future<void> playVideos() async {
    //String sentence = myController.text;
    if (sentence == "") {
      sentence = null;
    }
    print("sentence is == $sentence");
    if (mounted) {
      setState(() {
        this._videoFetcher = VideoPlayer2(key: UniqueKey(), sentence: sentence,);
      });
    }
  }

  List<Card> _buildGridCards(BuildContext context) {
    List<ButtonImage> products = [];
      if(subjectName == "holidays")
        {
          ButtonImage holiday = new ButtonImage("","חג","חג");
          ButtonImage custom = new ButtonImage("","מנהג","מנהג");
          ButtonImage newYear = new ButtonImage("","ראש השנה","ראש השנה");
          products.addAll([holiday,custom,newYear]);
        }
      else if(subjectName == "pronoun")
        {
          ButtonImage she = new ButtonImage("","היא","היא");
          products.addAll([she]);
        }
      else if(subjectName == "animals")
      {
        // words
        ButtonImage dolphin = new ButtonImage("dolphin.jfif","דולפין","דולפין");
        ButtonImage ant = new ButtonImage("","נמלה","נמלה");
        ButtonImage hedgehog = new ButtonImage("","קיפוד","קיפוד");
        ButtonImage snake = new ButtonImage("","נחש","נחש");
        ButtonImage frog = new ButtonImage("","צפרדע","צפרדע");
        ButtonImage donkey = new ButtonImage("","חמור","חמור");
        ButtonImage horse = new ButtonImage("","סוס","סוס");
        // add words to list
        products.addAll([dolphin,ant,hedgehog,snake,frog,donkey,horse]);
      }
      else if(subjectName == "shapes")
      {
        // words
        ButtonImage circle = new ButtonImage("","עיגול","עיגול");
        // add words to list
        products.addAll([circle]);
      }
      else if(subjectName == "body")
      {
        // words
        ButtonImage braids = new ButtonImage("","צמות","צמות");
        // add words to list
        products.addAll([braids]);
      }
      else if(subjectName == "time")
      {
        // words
        ButtonImage minute = new ButtonImage("","דקה","דקה");
        // add words to list
        products.addAll([minute]);
      }
      else if(subjectName == "geography")
      {
        ButtonImage eilat = new ButtonImage("","אילת","אילת");
        ButtonImage ashdod = new ButtonImage("","אשדוד","אשדוד");
        ButtonImage givatayim = new ButtonImage("","גבעתיים","גבעתיים");
        ButtonImage kibbutz = new ButtonImage("","קיבוץ","קיבוץ");
        products.addAll([eilat,ashdod,givatayim,kibbutz]);
      }
      else if(subjectName == "food")
      {
        ButtonImage pomegranate = new ButtonImage("","רימון","רימון");
        products.addAll([pomegranate]);
      }

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
              borderRadius: const BorderRadius.all(
                  Radius.circular(8.0)
              )),
          // TODO: Adjust card heights (103)
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Column(
                // TODO: Center items on the card (103)
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    // child: AspectRatio(
                    //   aspectRatio: 18 / 12,
                    //   child: Container(
                    //     alignment: Alignment.bottomCenter,
                    //     //width: 100.0,
                    //     //height: 50.0,
                    //     //color: Colors.green[100],
                    //     /*child: FittedBox(
                    //     child: Image.asset("assets/images/" + product.name),
                    //     fit: BoxFit.fill,
                    //   )*/child:Image.asset(
                    //       "assets/images/" + product.name
                    //   ),
                    //   ),
                    // ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: SingleChildScrollView(
                        child: Column(
                          // TODO: Align labels to the bottom and center (103)
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // TODO: Change innermost Column (103)
                          children: <Widget>[
                            // TODO: Handle overflowing labels (103)
                            Container(alignment: Alignment.center,
                              child: Text(
                                product.text,
                                style: theme.textTheme.title,
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
                  child: InkWell(
                      onTap: (){
                        sentence = product.onTap;
                        playVideos();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => _buildPopupDialog(context),
                        );
                      }// got the sentence from the user
                        // List<String> splitSentenceList =
                        // splitSentence(sentence); // split the sentence
                        // String url;
                        // List<String> letters;
                        // print(splitSentenceList);
                        // List<String> urls = [];
                        // for(int i=0; i < splitSentenceList.length; i++)
                        // {
                        //   Reference ref = FirebaseStorage.instance
                        //       .ref()
                        //       .child("animation_openpose/" + splitSentenceList[i] + ".mp4");
                        //   try {
                        //     // gets the video's url
                        //     url = await ref.getDownloadURL();
                        //     urls.add(url);
                        //   } catch (err) {
                        //     // Video doesn't exist - so split the work to letters
                        //     letters = splitToLetters(splitSentenceList[i]);
                        //     for(int j=0; j < letters.length; j++){
                        //       Reference ref = FirebaseStorage.instance
                        //           .ref()
                        //           .child("animation_openpose/" + letters[j] + ".mp4");
                        //       url = await ref.getDownloadURL();
                        //       urls.add(url);
                        //     }
                        //   }
                        // }
                        // myUrls = urls;
                        // print("hello this is the urls ==> " + urls.toString());
                        // setState(() {
                        //   this.videoPlayerDemo = VideoPlayerDemo(key: Key(this.ind.toString()),myUrls: urls,);
                        //   this.ind++;
                        // });
                        // showDialog(
                        //   context: context,
                        //   builder: (BuildContext context) => _buildPopupDialog(context),
                        // );
                      //}
                  ),
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
      insetAnimationDuration:
      const Duration(milliseconds: 100),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)),
      child: Container(       // use container to change width and height
        height: 400,
        width: 1000,
        child: Column(
          children: <Widget>[
            Container(
            child: AspectRatio(
                aspectRatio: 1.0,
                child: _videoFetcher
               // child: videoPlayerDemo.myUrls.length < 1 ? null : videoPlayerDemo
            ),
            ),
            FlatButton(
              onPressed: () {
                if (mounted){

                }
                Navigator.of(context).pop();
              },
              child: new Text("סגור"),
            ),
          ],
        ),
      ),
    );
    /*return new AlertDialog(
      title: const Text('דולפין', textAlign: TextAlign.right,),
      //insetPadding: EdgeInsets.symmetric(vertical: 240),
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50.0))
      ),
      //contentPadding: EdgeInsets.all(0.0),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
        Container(
          child: AspectRatio(
              aspectRatio: 1.0,
              child: videoPlayerDemo.myUrls.length < 1 ? null : videoPlayerDemo
      ),
          ),

        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('סגור'),
        ),
      ],
    );*/
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
      body: GridView.count(
          crossAxisCount: 3,
          padding: EdgeInsets.all(16.0),
          childAspectRatio: 8.0 / 9.0,
          children: _buildGridCards(context) // Changed code
      ),
    );
  }
}

class ButtonImage{
  String name;
  String text;
  String onTap;

  ButtonImage(this.name, this.text,this.onTap);
}
