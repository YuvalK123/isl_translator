import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:isl_translator/models/profile_image.dart';
import '../../shared/main_drawer.dart';
import 'package:isl_translator/services/database.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isl_translator/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:isl_translator/services/profilePic/home_screen.dart';
import 'package:isl_translator/services/profilePic/try.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as Path;

// enum SingingCharacter { female, male, other }

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

  Gender _character = Gender.FEMALE;
  UserModel currUserModel;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();


  // for select pic
  File _image;
  final picker = ImagePicker();


  /// Variables
  // var imageUrl;
  File imageFile;
  ProfileImage _profileImage = ProfileImage(false);
  String _uploadedFileURL;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
    // imageUrl = ProfileImage.getImageUrl();
  }

  void loadUser() async{
    final auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid;
    await for (var value in DatabaseUserService(uid: uid).users){
      setState(() {
        this.currUserModel = value;
        _character = value.genderModel;
      });
    }
    print("done, $_character");
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
            //this._character = userModel.genderModel;
            // currUserModel = userModel;
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
                        height: 160.0,
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
                                          image: !this._profileImage.hasImg ? null : new DecorationImage(
                                              image: this._profileImage.img,
                                              // image: imageFile != null ? FileImage(imageFile) : NetworkImage(imageUrl),
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
                                          child: new IconButton(
                                            icon: new Icon(Icons.camera_alt,),
                                            onPressed: () async{
                                              print("pressed icon");
                                              var profileImg = ProfileImage(true);
                                              await profileImg.chooseFile();
                                              setState(() {
                                                this._profileImage = profileImg;
                                              });
                                              // imagePicker.showDialog(context),
                                              // child: new Center(
                                              // child: _image == null
                                              // ? new Stack(
                                              // children: <Widget>[
                                              //
                                              // new Center(
                                              // child: new CircleAvatar(
                                              // radius: 80.0,
                                              // backgroundColor: const Color(0xFF778899),
                                              // ),
                                              // ),
                                              // new Center(
                                              // child: new Image.asset("assets/photo_camera.png"),
                                              // ),
                                              //
                                              // ],
                                              // )
                                              //     : new Container(
                                              // height: 160.0,
                                              // width: 160.0,
                                              // decoration: new BoxDecoration(
                                              // color: const Color(0xff7c94b6),
                                              // image: new DecorationImage(
                                              // image: new ExactAssetImage(_image.path),
                                              // fit: BoxFit.cover,
                                              // ),
                                              // border:
                                              // Border.all(color: Colors.red, width: 5.0),
                                              // borderRadius:
                                              // new BorderRadius.all(const Radius.circular(80.0)),
                                              // ),
                                              // ),
                                              // ),

                                            },
                                          )
                                          // child: new Icon(
                                          //   Icons.camera_alt,
                                          //   color: Colors.white,
                                          // ),
                                        ),
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
                              // Container(
                              //   alignment: Alignment.topRight,
                              //   child: new Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     mainAxisSize: MainAxisSize.max,
                              //     children: <Widget>[
                              //       Spacer(),
                              //       new Column(
                              //         mainAxisAlignment: MainAxisAlignment.start,
                              //         mainAxisSize: MainAxisSize.min,
                              //         children: <Widget>[
                              //           Container(
                              //             alignment: Alignment.topRight,
                              //             child: new Text(
                              //               'פרטים אישיים',
                              //               textDirection: TextDirection.rtl,
                              //               textAlign: TextAlign.right,
                              //               style: TextStyle(
                              //                   fontSize: 18.0,
                              //                   fontWeight: FontWeight.bold),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
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
                                          controller: nameController,
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
                                          textDirection: TextDirection.rtl,
                                          controller: emailController,
                                          decoration: const InputDecoration(
                                              hintText: "הכנס/י מייל"),
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
                                            'מגדר',
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
                                    left: 0, right: 0, top: 4.0),
                                child: Center(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child:Align(
                                            alignment: Alignment.centerRight,
                                            child: RadioListTile(
                                              title: Text('נקבה',textDirection: TextDirection.rtl,),
                                              value: Gender.FEMALE,
                                              groupValue: _character,
                                              onChanged: (Gender value) {
                                                setState(() {
                                                  _character = value;
                                                });
                                              },
                                              //onChanged: (newVal) {userModel.genderModel = newVal;},
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
                                              groupValue: _character,
                                              onChanged: (Gender value) {
                                                setState(() {
                                                  userModel.genderModel = value;
                                                  _character = value;
                                                });
                                              },
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
                                              groupValue: _character,
                                              onChanged: (Gender value) {
                                                setState(() {
                                                  _character = value;
                                                });
                                              },
                                              controlAffinity: ListTileControlAffinity.trailing,
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
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
                                            'סוג תרגום',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
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
                      print("pressed");
                      saveData();
                      print("After");
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
          // Expanded(
          //   child: Padding(
          //     padding: EdgeInsets.only(left: 10.0),
          //     child: Container(
          //         child: new RaisedButton(
          //           child: new Text("ביטול"),
          //           textColor: Colors.white,
          //           color: Colors.red,
          //           onPressed: () {
          //             setState(() {
          //               _status = true;
          //               FocusScope.of(context).requestFocus(new FocusNode());
          //             });
          //           },
          //           shape: new RoundedRectangleBorder(
          //               borderRadius: new BorderRadius.circular(20.0)),
          //         )),
          //   ),
          //   flex: 2,
          // ),
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

  void saveData() async{
    // get the user id
    FirebaseAuth auth = FirebaseAuth.instance;
    String id = auth.currentUser.uid;

    // get the new data from the text field
    String newName = nameController.text;
    if (newName == "")
      {
        newName = currUserModel.username; // name does not change
      }

    String newMail = emailController.text;
    if (newMail != "")
    {
      changeEmail(newMail); // change mail
    }

    String newGender = _character.toString();
    if(_character == Gender.MALE)
      {
        newGender = "m";
      }
    else if(_character == Gender.FEMALE)
    {
      newGender = "f";
    }
    else
      {
        newGender = "o";
      }

    print("new gender == > " + newGender);

    final newVidType = vidType == false ? VideoType.ANIMATION : VideoType.LIVE;
    // if(vidType == false)
    //   {
    //     newVidType = "animation";
    //   }
    // else
    //   {
    //     newVidType = "video";
    //   }

    //update data in data (name, gender) in firebase
    await DatabaseUserService(uid: id).updateUserData2(
        username: newName,
        gender: newGender,
        videoType: newVidType,
    );

    // upload profile picture to the firebase
    // uploadFile();
  }

  void changePass(String newPassword) async{
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    await user.updatePassword(newPassword).then((value) => null).catchError((error) => print(error));
  }

  void changeEmail(String newEmail) async{
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    await user.updateEmail(newEmail).then((value) => null).catchError((error) => print(error));
  }




// FirebaseStorage storage = FirebaseStorage(storageBucket: "https://console.firebase.google.com/project/islcsproject/storage/islcsproject.appspot.com/files");
  // uploadFile(File file) async{
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   String id = auth.currentUser.uid;
  //
  //   var storageRef = storage.ref().child("user/profile/${id}");
  //   var uploadTask = storageRef.putFile(file);
  //   var completeTask = await uploadTask.onComplete;
  //
  // }

}