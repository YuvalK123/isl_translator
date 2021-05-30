import 'package:flutter/material.dart';

class DrawerButton extends StatelessWidget {
  final String title;
  final Function onTap;
  final Icon icon;

  DrawerButton({this.title, this.onTap, this.icon});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: this.icon,
      title: Text(
        this.title,
        style: TextStyle(
          fontSize: 18,
        ),
        textAlign: TextAlign.right,
      ),
      trailing: Wrap(
        spacing: 12,
        children: <Widget>[
          this.icon,
        ],
      ),
      onTap: this.onTap,
      hoverColor: Colors.grey[300],
    );
  }
}