import 'package:flutter/material.dart';

class TranslatePage extends StatefulWidget {
  TranslatePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TranslatePage createState() => _TranslatePage();
}
class _TranslatePage extends State<TranslatePage>
{
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Sign Language'),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              children: [
                TextField(
                  controller: myController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your text'
                  ),
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () {
                    print(myController.text);
                    //VideoDemo();
                  },
                  child: Text("Translate"),
                  color: Colors.black12,
                ),
              ]
          )
      ),
    );
  }
}