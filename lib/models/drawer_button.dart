import 'package:flutter/material.dart';


/// class of the buttons in the main drawer
class DrawerButton extends StatelessWidget {

  final String title;
  final Function onTap;
  final Icon icon;
  final bool isCurrPage;

  /// [title] of button
  /// [onTap] what happens when clicked
  /// [icon] of button
  /// if [isCurrPage] cant press it
  DrawerButton({this.title, this.onTap, this.icon, this.isCurrPage = false});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: this.icon,
      title: Text(
        this.title,
        style: TextStyle(
          fontSize: 18,
          color: this.isCurrPage? Colors.white : Colors.black,
        ),
        textAlign: TextAlign.right,
      ),
      selectedTileColor: Colors.grey[400],
      trailing: Wrap(
        spacing: 12,
        children: <Widget>[
          this.icon,
        ],
      ),
      selected: this.isCurrPage,
      focusColor: Colors.white,
      // if not current page, you can click it
      onTap: !this.isCurrPage ? this.onTap : (){},
      hoverColor: Colors.grey[300],
    );
  }
}