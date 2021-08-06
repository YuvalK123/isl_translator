import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isl_translator/models/drawer_button.dart';
import '../models/profile_image.dart';
import 'package:isl_translator/models/user.dart';
import 'package:isl_translator/screens/add_video/add_video.dart';
import 'package:isl_translator/screens/dictonary/dict.dart';
import 'package:isl_translator/screens/profile/profile.dart';
import 'package:isl_translator/screens/translation_page/translation_wrapper.dart';
import 'package:isl_translator/services/auth.dart';
import 'package:isl_translator/services/database.dart';

/// page button enum to show current page
enum pageButton{
  TRANSLATION, ADDVID, PROFILE, DICT
}

/// main drawer of application
class MainDrawer extends StatelessWidget {

  final pageButton currPage;
  final AuthService auth = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileImage _profileImage = ProfileImage(uid: FirebaseAuth.instance.currentUser.uid);
  final userService = DatabaseUserService(uid: FirebaseAuth.instance.currentUser.uid);
  final String email = FirebaseAuth.instance.currentUser.email ?? "";
  MainDrawer({this.currPage = pageButton.TRANSLATION});


  @override
  Widget build(BuildContext context) {
    // future user image
    this._profileImage.setState = (context as Element).markNeedsBuild;
    this._profileImage.setImage();
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
            children: <Widget> [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.0),
                color: Colors.cyan[900],
                child: Center(
                  child:StreamBuilder<UserModel>(
                    stream: userService?.users,
                    initialData: null,
                    builder: (context, snapshot) {
                      String username = "";
                      print("snapshot is ${snapshot.data}");
                      if (snapshot == null || snapshot.hasError ||
                          !snapshot.hasData || this._auth.currentUser.isAnonymous){
                        print("err/no data");
                        username = "Anon user";
                      } else{
                        UserModel userModel = snapshot.data;
                        print("mainDrawer userModel == $userModel");
                        username = userModel.username;
                      }
                      return Row(

                        children: [
                          Spacer(),
                          Column(
                            children: <Widget> [
                              SizedBox(height: 15.0,),
                              Text(username,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              Text(this.email,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          FutureBuilder<ImageProvider>(
                            future: this._profileImage.img,
                            builder: (context, snapshot) {
                              ImageProvider img;
                              if (snapshot.hasError || !snapshot.hasData){
                                img = this._profileImage.localAnonImg;
                              } else{
                                img = snapshot.data;
                              }
                              return Container(
                                width: 100.0,
                                height: 70.0,
                                margin: EdgeInsets.only(
                                    top: 30.0,
                                    bottom: 10.0,
                                    left: 0.0
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: img,
                                      fit: BoxFit.fitHeight
                                  ),
                                ),
                              );
                            }
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ),
              DrawerButton(
                title: "תרגום",
                onTap: () => pushPage(context, TranslationWrapper()),
                icon: Icon(Icons.translate),
                isCurrPage: this.currPage == pageButton.TRANSLATION,
              ),
              FirebaseAuth.instance.currentUser.isAnonymous ?
              Container() : DrawerButton(
                  title: "הוסף וידיאו",
                  onTap: () => pushPage(context, AddVideoPage()),
                  icon: Icon(Icons.video_library),
                isCurrPage: this.currPage == pageButton.ADDVID,
              ),
            DrawerButton(
              title: "מילון",
              onTap: () => pushPage(context, Dictionary()),
              icon: Icon(Icons.book),
              isCurrPage: this.currPage == pageButton.DICT,
            ),
              FirebaseAuth.instance.currentUser.isAnonymous ? Container() :
              DrawerButton(
                    title: "איזור אישי",
                    onTap:  () => pushPage(context, ProfilePage()),
                    icon: Icon(Icons.person),
                    isCurrPage: this.currPage == pageButton.PROFILE,
                  ),
              DrawerButton(
                  title: "התנתק/י",
                  onTap: () async {
                    // Navigator.of(context).pop();
                    await auth.signOut(context);
                  },
                  icon: Icon(Icons.logout),
                isCurrPage: false,
              ),
            ],
          ),
      ),
    );
  }

  /// by getting [context] and [page] widget,
  /// we replace this page with an other.
  void pushPage(BuildContext context, Widget page){
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => page,
        )
    );
  }
}





