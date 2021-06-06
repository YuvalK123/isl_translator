import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/services/play_video.dart';
import 'package:isl_translator/services/show_video.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:video_player/video_player.dart';
class Animals extends StatefulWidget {
  @override
  _AnimalsState createState() => _AnimalsState();
}

class _AnimalsState extends State<Animals> {
  VideoPlayerDemo videoPlayerDemo = VideoPlayerDemo(key: Key("0"), myUrls: [],);
  List<String> myUrls;
  int ind = 1;
  @override
  void initState() {
    super.initState();
  }

  List<Card> _buildGridCards(BuildContext context) {
      ButtonImage dolphin = new ButtonImage();
      dolphin.name = "dolphin.jfif";
      dolphin.text = "דולפין";
      dolphin.onTap = "דולפין";
      dolphin.color = "green";
      List<ButtonImage> products = [
        dolphin
      ];

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
            children: <Widget>[
              Column(
                // TODO: Center items on the card (103)
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 18 / 12,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        //width: 100.0,
                        //height: 50.0,
                        //color: Colors.green[100],
                        /*child: FittedBox(
                        child: Image.asset("assets/images/" + product.name),
                        fit: BoxFit.fill,
                      )*/child:Image.asset(
                          "assets/images/" + product.name
                      ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 35.0, 20.0, 10.0),
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
                              maxLines: 1,
                            ),
                          ),
                        ],
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
                      onTap: () async {
                        String sentence = product.onTap; // got the sentence from the user
                        List<String> splitSentenceList =
                        splitSentence(sentence); // split the sentence
                        String url;
                        List<String> letters;
                        print(splitSentenceList);
                        List<String> urls = [];
                        for(int i=0; i < splitSentenceList.length; i++)
                        {
                          Reference ref = FirebaseStorage.instance
                              .ref()
                              .child("animation_openpose/" + splitSentenceList[i] + ".mp4");
                          try {
                            // gets the video's url
                            url = await ref.getDownloadURL();
                            urls.add(url);
                          } catch (err) {
                            // Video doesn't exist - so split the work to letters
                            letters = splitToLetters(splitSentenceList[i]);
                            for(int j=0; j < letters.length; j++){
                              Reference ref = FirebaseStorage.instance
                                  .ref()
                                  .child("animation_openpose/" + letters[j] + ".mp4");
                              url = await ref.getDownloadURL();
                              urls.add(url);
                            }
                          }
                        }
                        myUrls = urls;
                        print("hello this is the urls ==> " + urls.toString());
                        setState(() {
                          this.videoPlayerDemo = VideoPlayerDemo(key: Key(this.ind.toString()),myUrls: urls,);
                          this.ind++;
                        });
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => _buildPopupDialog(context),
                        );

                        /*Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VideoPlayerDemo(key: Key(this.ind.toString()),myUrls: urls,)),
                        );*/

                        /*setState(() {
                          this.videoPlayerDemo = VideoPlayerDemo(key: Key(this.ind.toString()),myUrls: urls,);
                          this.ind++;
                        });*/
                      }
                  ),
                ),
              ),
              /*Container(
                  child: AspectRatio(
                      aspectRatio: 1.0,
                      child: videoPlayerDemo.myUrls.length < 1 ? null : videoPlayerDemo
                  )
              ),*/
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
                child: videoPlayerDemo.myUrls.length < 1 ? null : videoPlayerDemo
            ),
            ),
            FlatButton(
              onPressed: () {
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
          crossAxisCount: 2,
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
  String color;
}
