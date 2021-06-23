import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../shared/main_drawer.dart';
import 'package:isl_translator/services/database.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isl_translator/models/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  String username;
  Gender gender;
  bool vidType = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
          backgroundColor: Colors.cyan[800],
        ),
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
              alignment: Alignment.topRight,
              color: Colors.white,
              child: new ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      new Container(
                        alignment: Alignment.topRight,
                        height: 200.0,
                        color: Colors.white,
                        child: new Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: new Stack(fit: StackFit.loose, children: <Widget>[
                                new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Container(
                                        alignment: Alignment.topRight,
                                        width: 140.0,
                                        height: 140.0,
                                        decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                              image: NetworkImage(
                                                  'https://static.toiimg.com/photo/msid-67586673/67586673.jpg'),
                                              fit: BoxFit.fitHeight
                                            //fit: BoxFit.cover,
                                          ),
                                        )),
                                  ],
                                ),
                                Padding(
                                    padding: EdgeInsets.only(top: 90.0, right: 100.0),
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        new CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 25.0,
                                          child: new Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    )),
                              ]),
                            )
                          ],
                        ),
                      ),
                      new Container(
                        alignment: Alignment.topRight,
                        color: Color(0xffFFFFFF),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 25.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topRight,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Spacer(),
                                    new Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.topRight,
                                          child: new Text(
                                            'פרטים אישיים',
                                            textDirection: TextDirection.rtl,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Spacer(),
                                      new Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'שם משתמש',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextField(
                                          textDirection: TextDirection.rtl,
                                          decoration: InputDecoration(
                                            hintText: "הכנס/י שם משתמש",
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Spacer(),
                                      new Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'מייל',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextField(
                                          decoration: const InputDecoration(
                                              hintText: "הכנס/י מייל"),
                                          enabled: !_status,
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Spacer(),
                                      new Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'פלאפון',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextField(
                                          decoration: const InputDecoration(
                                              hintText: "הכנס/י מספר פלאפון"),
                                          enabled: !_status,
                                        ),
                                      ),
                                    ],
                                  )),
                              Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child:Align(
                                        alignment: Alignment.centerRight,
                                        child: RadioListTile(
                                          title: Text('נקבה',textDirection: TextDirection.rtl,),
                                          value: Gender.FEMALE,
                                          groupValue: userModel.genderModel,
                                          onChanged: (newVal) {userModel.genderModel = newVal;},
                                          controlAffinity: ListTileControlAffinity.trailing,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child:Align(
                                        alignment: Alignment.centerLeft,
                                        child:RadioListTile(
                                          title: Text('זכר',textDirection: TextDirection.rtl,),
                                          value: Gender.MALE,
                                          groupValue: userModel.genderModel,
                                          onChanged: (newVal) {userModel.genderModel = newVal;},
                                          controlAffinity: ListTileControlAffinity.trailing,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child:Align(
                                        alignment: Alignment.center,
                                        child:RadioListTile(
                                          title: Text('אחר',textDirection: TextDirection.rtl,),
                                          value: Gender.OTHER,
                                          groupValue: userModel.genderModel,
                                          onChanged: (newVal) {userModel.genderModel = newVal;},
                                          controlAffinity: ListTileControlAffinity.trailing,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "מגדר",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        //backgroundColor: Colors.cyan[50]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Spacer(),
                                  Text("אנימציה"),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: FlutterSwitch(
                                        activeColor: Colors.grey[300],
                                        inactiveColor: Colors.grey[300],
                                        value: vidType,
                                        onToggle: (val) {
                                          setState(() {
                                            vidType = val;
                                          });

                                        }
                                    ),
                                  ),
                                  Text("סרטון"),
                                  Spacer(),
                                  Text(
                                    "סוג תרגום",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      //backgroundColor: Colors.cyan[50]
                                    ),
                                  ),
                                ],
                              ),
                              _getActionButtons(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        )
    );

  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                    child: new Text("שמור"),
                    textColor: Colors.white,
                    color: Colors.green,
                    onPressed: () {
                      setState(() {
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                    child: new Text("ביטול"),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
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