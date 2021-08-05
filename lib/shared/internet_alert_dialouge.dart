import 'package:flutter/material.dart';

class InternetAlertDialogue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    showInternetAlert(context);
    return Container();
  }
}

void showInternetAlert(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Wifi"),
        content: Text("Wifi not detected. Please activate it."),
      )
  );
}


