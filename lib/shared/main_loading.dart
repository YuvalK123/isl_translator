import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:isl_translator/services/handle_sentence.dart';
int i = 0;
bool isLoading = true;
Future<void> bla() async{
  print("be4 $i");
  i++;
  // List<String> futureTerms = await findTermsDB();
  await findTermsDB();
  isLoading = false;
  //await findTermsDB();
  print("after $i");
  i++;
  // saveTerms = futureTerms;
  print("saved $i");
  i++;
}

class MainLoading extends StatefulWidget {
  MainLoading({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainLoading createState() => _MainLoading();
}

class _MainLoading extends State<MainLoading> {
  @override
  void initState() {
    super.initState();
    bla();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.brown[100],
      child: Center(
        child: SpinKitDualRing(
          color: Colors.brown,
          size: 50.0,
        ),
      ),
    );
  }
}


// class Loading extends StatelessWidget {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.brown[100],
//       child: Center(
//         child: SpinKitDualRing(
//           color: Colors.brown,
//           size: 50.0,
//         ),
//       ),
//     );
//   }
// }