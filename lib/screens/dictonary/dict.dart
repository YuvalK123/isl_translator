import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/screens/dictonary/animals.dart';
import 'package:isl_translator/screens/home/main_drawer.dart';
import 'package:random_color/random_color.dart';

class Dictionary extends StatefulWidget {
  @override
  _DictionaryState createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  @override
  void initState() {
    super.initState();
  }

  RandomColor _randomColor = RandomColor();

  List<Card> _buildGridCards(BuildContext context) {
    ButtonImage holidays = new ButtonImage();
    holidays.name = "hanukkah.jfif";
    holidays.text = "חגים ומועדים";
    holidays.onTap = "חגים ומועדים";

    ButtonImage pronoun = new ButtonImage();
    pronoun.name = "pointing.jfif";
    pronoun.text = "כינוי גוף";
    pronoun.onTap = "כינוי גוף";

    ButtonImage animals = new ButtonImage();
    animals.name = "animals.jfif";
    animals.text = "בעלי חיים";
    animals.onTap = "בעלי חיים";

   ButtonImage shapes = new ButtonImage();
    shapes.name = "shapes.jfif";
    shapes.text = "צורות";
    shapes.onTap = "צורות";


    List<ButtonImage> products = [holidays,pronoun,shapes,animals,animals,animals,animals,animals,animals,animals,animals];

    if (products == null || products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    /*final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());*/

    return products.map((product) {
      return Card(
        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 2),
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
                      child:Image.asset(
                          "assets/images/" + product.name,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 35.0, 20.0,10.0),
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
                child:InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Animals()),
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
      endDrawer: MainDrawer(currPage: pageButton.DICT,),
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
}

