import 'package:flutter/material.dart';
import 'package:isl_translator/models/drawer_button.dart';
import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/add_video/add_video.dart';
import 'package:isl_translator/screens/profile/profile.dart';
import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:isl_translator/services/auth.dart';
import 'package:isl_translator/services/database.dart';
import 'package:provider/provider.dart';
import 'home.dart';

enum pageButton{
  TRANSLATION, ADDVID, PROFILE, DICT
}

class MainDrawer extends StatelessWidget {

  final pageButton currPage;
  final AuthService _auth = AuthService();

  MainDrawer({this.currPage = pageButton.TRANSLATION});

  @override
  Widget build(BuildContext context) {
    // future user image
    String imgUrl = 'https://static.toiimg.com/photo/msid-67586673/67586673.jpg';
    final user = Provider.of<UserModel>(context);
    print("user: ${user.toString()}");
    final DatabaseUserService userService = DatabaseUserService(uid: user.uid);
    print("curr page = ${this.currPage}");
    return Drawer(

      child: Column(
        children: <Widget> [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.0),
            color: Colors.cyan[900],
            child: Center(
              child:Row(

                children: [
                  Spacer(),
                  Column(
                    children: <Widget> [
                      SizedBox(height: 15.0,),
                      Text("שם משתמש",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Text('mail@gmail.com',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    width: 100.0,
                    height: 70.0,
                    margin: EdgeInsets.only(top: 30.0, bottom: 10.0, left: 0.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(imgUrl),
                          fit: BoxFit.fitHeight
                      ),
                    ),
                  ),
                ],
            ),
            ),
          ),
          DrawerButton(
            title: "תרגום",
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TranslationWrapper(),
                )
            ),
            icon: Icon(Icons.translate),
            isCurrPage: this.currPage == pageButton.TRANSLATION,
          ),
          DrawerButton(
              title: "הוסף וידיאו",
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddVideoPage(),
                  )
              ),
              icon: Icon(Icons.video_library),
            isCurrPage: this.currPage == pageButton.ADDVID,
          ),
          DrawerButton(
              title: "מילון",
              onTap: null,
              icon: Icon(Icons.book),
            isCurrPage: this.currPage == pageButton.DICT,
          ),
          DrawerButton(
              title: "איזור אישי",
              onTap:  () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Profile(),
                  )
              ),
              icon: Icon(Icons.person),
            isCurrPage: this.currPage == pageButton.PROFILE,
          ),
          DrawerButton(
              title: "התנתק/י",
              onTap: () async {
                await _auth.signOut();
              },
              icon: Icon(Icons.logout),
            isCurrPage: false,
          ),
        ],
      ),
    );
  }
}





