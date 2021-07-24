import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/screens/dictonary/subject.dart';
import '../../shared/main_drawer.dart';

/*
Dictionary class
Dictionary of ISL videos&animations, each word belong to a specific subject
*/
class Dictionary extends StatefulWidget {
  @override
  _DictionaryState createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  @override
  void initState() {
    super.initState();
  }
  // list of subjects
  List<Card> _buildGridCards(BuildContext context) {
    ButtonImage holidays = new ButtonImage("hanukkah.jfif","חגים ומועדים","holidays");
    ButtonImage pronoun = new ButtonImage("pointing.jfif","כינוי גוף","pronoun");
    ButtonImage animals = new ButtonImage("animals.jfif","בעלי חיים","animals");
    ButtonImage shapes = new ButtonImage("shapes.jfif", "צורות","shapes");
    ButtonImage body = new ButtonImage("body.jfif","גוף האדם","body");
    ButtonImage time = new ButtonImage("time.jfif","זמן","time");
    ButtonImage geography = new ButtonImage("geography.jfif","גאוגרפיה","geography");
    ButtonImage food = new ButtonImage("food.jfif","אוכל","food");
    List<ButtonImage> products = [holidays,pronoun,shapes,animals,body,time,geography,food];

    // if the list of subject if empty - show an empty card
    if (products == null || products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);

    // return a Card that contains the subjects we define above
    return products.map((product) {
      return Card(
        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 2),
            borderRadius: const BorderRadius.all(
                Radius.circular(8.0)
            )),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // show the image
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 18 / 12,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child:Image.asset(
                          "assets/images/" + product.name
                      ),
                    ),
                  ),
                ),
                // show the text below each image
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 35.0, 20.0,10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
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
                ),
              ],
            ),
            // define what to do when tapping the image
            Positioned(
              left: 0.0,
              top: 0.0,
              bottom: 0.0,
              right: 0.0,
              child: Material(
                type: MaterialType.transparency,
                child:InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        // show the specific subject dict
                        MaterialPageRoute(builder: (context) => Subject(product.onTap)),
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: MainDrawer(currPage: pageButton.DICT,),
      appBar: AppBar(
        title: Container(
            alignment: Alignment.centerRight,
            child: Text(
              "מילון שפת הסימנים",
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

/*
ButtonImage class
Each button image contain:
- name
- text to display below to image
- onTap variable that define which page to open when tapping
*/
class ButtonImage{
  String name;
  String text;
  String onTap;

  ButtonImage(this.name, this.text,this.onTap);
}

