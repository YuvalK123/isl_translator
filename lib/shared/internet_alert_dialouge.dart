import 'package:flutter/material.dart';

class InternetAlertDialogue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    showAlert(context);
    return Container();
  }
}

void showAlert(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Wifi"),
        content: Text("Wifi not detected. Please activate it."),
      )
  );
}

Future<void> _showMyDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('AlertDialog Title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
