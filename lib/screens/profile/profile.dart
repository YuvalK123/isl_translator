import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:isl_translator/screens/home/main_drawer.dart';
import 'package:isl_translator/services/database.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isl_translator/models/user.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username;
  Gender gender;
  bool vidType = false;


  @override
  Widget build(BuildContext context) {
    final user = getUser(context);
    print("user: $user");
    var uid = user?.uid ?? "";
    print("uid is $uid");
    // var _userStream = DatabaseUserService(uid: uid).users ?? null;
    return user == null ? Loading() : Scaffold(
        appBar: AppBar(
          title: Container(
            alignment: Alignment.centerRight,
            child: Text(
              "פרופיל",
              textAlign: TextAlign.right,
            ),
          ),
        ),
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        endDrawer: MainDrawer(currPage: pageButton.PROFILE,),
        body: StreamBuilder(
          // catchError: (_,_) => null,
          initialData: null,

            stream: mounted ? DatabaseUserService(uid: getUser(context)?.uid ?? "").users : null,
            builder: (context, snapshot) {
              if(snapshot.hasError) {
                print("snapshot error in profile: ${snapshot.error}");
                return Container(width: 0.0,height: 0.0,);
              }
              if (!snapshot.hasData){
                print("snapshot dont has data ${snapshot.hasData}");
                return Loading();
              }
              UserModel userModel = snapshot.data;
              print("userModel is $userModel");
              return Container(
                child: ListView(
                  children: <Widget>[
                    Row(
                      children: [
                        Spacer(),
                        Text(userModel.username, textAlign: TextAlign.center,),
                        Spacer(),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            width: 100.0,
                            height: 100.0,
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                      'https://static.toiimg.com/photo/msid-67586673/67586673.jpg'),
                                  fit: BoxFit.fitHeight
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0,),
                    Center(
                      child: Row(
                        children: [

                          Expanded(
                            // width: 1.0,
                            child: ListTile(
                              title: TextField(
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "משתמש חדש",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  fillColor: Colors.grey[400],
                                  filled: true,

                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "שם משתמש",
                            style: TextStyle(
                                fontSize: 18.0
                            ),
                          ),

                        ],

                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RadioListTile(
                        title: Text('נקבה'),
                        value: Gender.FEMALE,
                        groupValue: userModel.genderModel,
                        onChanged: (newVal) {userModel.genderModel = newVal;},
                      ),
                    ),
                    RadioListTile(
                      title: Text('זכר'),
                      value: Gender.MALE,
                      groupValue: userModel.genderModel,
                      onChanged: (newVal) {userModel.genderModel = newVal;},
                    ),
                    RadioListTile(
                      title: Text('אחר'),
                      value: Gender.OTHER,
                      groupValue: userModel.genderModel,
                      onChanged: (newVal) {userModel.genderModel = newVal;},
                    ),
                    Row(
                      children: [
                        Spacer(),
                        Text("Animation"),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: FlutterSwitch(
                            activeColor: Colors.pink[200],
                              inactiveColor: Colors.pink[400],
                              value: vidType,
                              onToggle: (val) {
                                setState(() {
                                  vidType = val;
                                });

                              }
                          ),
                        ),
                        Text("Live"),
                        Spacer(),
                      ],
                    )
                  ],
                ),
              );
            },

        )
    );
  }


  UserModel getUser(BuildContext context){
    print("get user");
    try{
      return Provider.of<UserModel>(context);
    } catch (e){
      return null;
    }
    final user = Provider.of<UserModel>(context);
    print("user is $user");
    return user;
  }
}
