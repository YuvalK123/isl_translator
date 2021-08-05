import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/screens/dictonary/subject.dart';
import '../../shared/main_drawer.dart';


/// Dictionary class
///
/// Dictionary of ISL videos & animations
/// Each word belong to a specific subject
class Dictionary extends StatefulWidget {
  @override
  _DictionaryState createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {

  /// Init
  @override
  void initState() {
    super.initState();
  }

  /// List of subjects
  List<Card> _buildGridCards(BuildContext context) {
    ButtonImage holidays = new ButtonImage("hanukkah.jfif","חגים ומועדים",SubjectName.HOLIDAYS);
    ButtonImage pronoun = new ButtonImage("pointing.jfif","כינוי גוף",SubjectName.PRONOUNS);
    ButtonImage animals = new ButtonImage("animals.jfif","בעלי חיים",SubjectName.ANIMALS);
    ButtonImage shapes = new ButtonImage("shapes.jfif", "צורות",SubjectName.SHAPES);
    ButtonImage body = new ButtonImage("body.jfif","גוף האדם",SubjectName.BODY);
    ButtonImage time = new ButtonImage("time.jfif","זמן",SubjectName.TIMES);
    ButtonImage geography = new ButtonImage("geography.jfif","גאוגרפיה",SubjectName.GEOG);
    ButtonImage food = new ButtonImage("food.jfif","אוכל",SubjectName.FOOD);
    List<ButtonImage> products = [holidays,pronoun,shapes,animals,body,time,geography,food];

    /// If the subject list is empty - show an empty card
    if (products == null || products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);

    /// Return a Card that contains the subjects we define above
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
                /// Show the image
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
                              style: theme.textTheme.headline6,
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
            /// Define what to do when tapping the image
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
                        /// Show the specific subject dict
                        MaterialPageRoute(builder: (context) => Subject(subjectName: product.onTap,)),
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

  /// Build the dictionary
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


/// ButtonImage class
///
/// Each button image contain: name, text to display below the image,
/// onTap variable that define which page to open when tapping
class ButtonImage{
  String name;
  String text;
  SubjectName onTap;

  ButtonImage(this.name, this.text,this.onTap);
}

