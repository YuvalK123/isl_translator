import 'package:flutter/material.dart';
import 'package:isl_translator/models/drawer_button.dart';
import 'package:isl_translator/screens/add_video/add_video.dart';
import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'home.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // future user image
    String imgUrl = 'https://static.toiimg.com/photo/msid-67586673/67586673.jpg';

    return Drawer(

      child: Column(
        children: <Widget> [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.0),
            color: Theme.of(context).primaryColor,
            child: Center(
              child:Row(
                children: [
                  Container(
                    width: 100.0,
                    height: 70.0,
                    margin: EdgeInsets.only(top: 30.0, bottom: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(imgUrl),
                          fit: BoxFit.fitHeight
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget> [
                      SizedBox(height: 15.0,),
                      Text('Username',
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
                ],
            ),
            ),
          ),
          DrawerButton(
              title: "Home",
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    // to be a new Home page
                    builder: (context) => Home(),
                  )
              ),
              icon: Icon(Icons.home)
          ),
          DrawerButton(
              title: "Add video",
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddVideoPage(),
                  )
              ),
              icon: Icon(Icons.video_library)
          ),
          DrawerButton(
              title: "Translation",
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TranslationWrapper(),
                  )
              ),
              icon: Icon(Icons.translate)
          ),
          DrawerButton(
              title: "Dictionary",
              onTap: null,
              icon: Icon(Icons.book)),
          DrawerButton(
              title: "Profile",
              onTap: null,
              icon: Icon(Icons.person)
          ),
          DrawerButton(
              title: "Log out",
              onTap: null,
              icon: Icon(Icons.logout)
          ),
        ],
      ),
    );
  }
}





