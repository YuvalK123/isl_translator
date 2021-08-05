import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../models/profile_image.dart';
import '../../shared/main_drawer.dart';
import 'package:isl_translator/services/database.dart';
import 'package:isl_translator/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:isl_translator/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

/// Profile Class
class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  /// Variables
  final FocusNode myFocusNode = FocusNode();
  String username;
  Gender gender;
  bool vidType = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool wrongOldPass = false;
  Gender _character = Gender.FEMALE;
  UserModel currUserModel;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String passErr = "";
  ProfileImage _profileImage =
      ProfileImage(uid: FirebaseAuth.instance.currentUser.uid);
  bool isSave = false;
  final picker = ImagePicker();
  var imageUrl;
  String _uploadedFileURL;

  /// Init state and load user
  @override
  void initState() {
    super.initState();
    this._profileImage.setState = setState;
    loadUser();
  }

  /// If the user has profile image load it from firebase,
  /// otherwise load default profile image
  void initImgUrl() async {
    var img = await this._profileImage.getImageUrl();
    if (mounted) {
      setState(() {
        this.imageUrl = img;
      });
    }
  }

  /// Load user data from firebase
  void loadUser() async {
    /// Get user id
    final auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid;
    await for (var value in DatabaseUserService(uid: uid).users) {
      setState(() {
        this.currUserModel = value;

        /// Get user's gender
        _character = value.genderModel;

        /// Get user's preferences of video type (animation/live)
        if (value.videoType == VideoType.LIVE) {
          vidType = true;
        }
      });
    }
  }

  /// Profile page UI
  @override
  Widget build(BuildContext context) {
    final user = getUser(context);
    return user == null
        ? Loading()
        : Scaffold(
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
            endDrawer: MainDrawer(
              currPage: pageButton.PROFILE,
            ),
            body: StreamBuilder(
              initialData: null,
              stream: mounted
                  ? DatabaseUserService(uid: getUser(context)?.uid ?? "").users
                  : null,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    width: 0.0,
                    height: 0.0,
                  );
                }
                if (!snapshot.hasData) {
                  return Loading();
                }
                UserModel userModel = snapshot.data;
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
                                  child:
                                      new Stack(fit: StackFit.loose, children: <
                                          Widget>[
                                    new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        FutureBuilder<ImageProvider>(
                                            future: this._profileImage.img,
                                            builder: (context, snapshot) {
                                              ImageProvider img;
                                              if (snapshot.hasError ||
                                                  !snapshot.hasData) {
                                                img = this
                                                    ._profileImage
                                                    .localAnonImg;
                                              } else {
                                                img = snapshot.data;
                                              }
                                              return new Container(
                                                  alignment: Alignment.topRight,
                                                  width: 140.0,
                                                  height: 140.0,
                                                  decoration: new BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: new DecorationImage(
                                                        image: img,
                                                        fit: BoxFit.fitHeight
                                                        ),
                                                  ));
                                            }),
                                      ],
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 90.0, right: 100.0),
                                        child: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new CircleAvatar(
                                                backgroundColor: Colors.red,
                                                radius: 25.0,
                                                child: new IconButton(
                                                  icon: new Icon(
                                                    Icons.camera_alt,
                                                  ),
                                                  onPressed: () async {
                                                    await _profileImage
                                                        .chooseFile();
                                                    setState(() {});
                                                  },
                                                )),
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
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 25.0),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Spacer(),
                                          new Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Text(
                                                'שם משתמש: ' +
                                                    userModel.username,
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                hintText: "החלפ/י שם משתמש",
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Text(
                                                _auth.currentUser.email +
                                                    " :אימייל",
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                  hintText: "החלפ/י מייל"),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Text(
                                                'מגדר',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: RadioListTile(
                                                dense: true,
                                                title: Text(
                                                  'נקבה',
                                                  textDirection:
                                                      TextDirection.rtl,
                                                ),
                                                value: Gender.FEMALE,
                                                groupValue: _character,
                                                onChanged: (Gender value) {
                                                  setState(() {
                                                    _character = value;
                                                  });
                                                },
                                                //onChanged: (newVal) {userModel.genderModel = newVal;},
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: RadioListTile(
                                                title: Text(
                                                  'זכר',
                                                  textDirection:
                                                      TextDirection.rtl,
                                                ),
                                                dense: true,
                                                value: Gender.MALE,
                                                groupValue: _character,
                                                onChanged: (Gender value) {
                                                  setState(() {
                                                    userModel.genderModel =
                                                        value;
                                                    _character = value;
                                                  });
                                                },
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: RadioListTile(
                                                title: Text(
                                                  'אחר',
                                                  textDirection:
                                                      TextDirection.rtl,
                                                ),
                                                value: Gender.OTHER,
                                                dense: true,
                                                groupValue: _character,
                                                onChanged: (Gender value) {
                                                  setState(() {
                                                    _character = value;
                                                  });
                                                },
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Text(
                                                'סוג תרגום',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: FlutterSwitch(
                                            activeColor: Colors.cyan[700],
                                            inactiveColor: Colors.cyan[700],
                                            value: vidType,
                                            onToggle: (val) {
                                              setState(() {
                                                vidType = val;
                                              });
                                            }),
                                      ),
                                      Text("סרטון"),
                                      Spacer(),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: RaisedButton(
                                        onPressed: () {
                                          showDialog(
                                              //useRootNavigator: true,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 25.0,
                                                      right: 25.0,
                                                      top: 80.0),
                                                  child: StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return SingleChildScrollView(
                                                      child: AlertDialog(
                                                        content: Stack(
                                                          overflow:
                                                              Overflow.visible,
                                                          children: <Widget>[
                                                            Form(
                                                              key: _formKey,
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                        "סיסמה ישנה"),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        new TextField(
                                                                      textDirection:
                                                                          TextDirection
                                                                              .rtl,
                                                                      controller:
                                                                          oldPassController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              hintText: "הכנס/י סיסמה ישנה"),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                        "סיסמה חדשה"),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        new TextField(
                                                                      textDirection:
                                                                          TextDirection
                                                                              .rtl,
                                                                      controller:
                                                                          newPassController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              hintText: "הכנס/י סיסמה חדשה"),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left:
                                                                            25.0,
                                                                        right:
                                                                            25.0,
                                                                        top:
                                                                            45.0),
                                                                    child:
                                                                        new Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 10.0),
                                                                            child: Container(
                                                                                child: new RaisedButton(
                                                                              child: Text("החלפ/י"),
                                                                              onPressed: () async {
                                                                                if (_formKey.currentState.validate()) {
                                                                                  _formKey.currentState.save();
                                                                                }
                                                                                String code = await changePass(newPassController.text);
                                                                                setState(() {
                                                                                  this.passErr = code;
                                                                                });
                                                                              },
                                                                              textColor: Colors.white,
                                                                              color: Colors.green,
                                                                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                                            )),
                                                                          ),
                                                                          flex:
                                                                              2,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.only(right: 10.0),
                                                                            child: Container(
                                                                                child: new RaisedButton(
                                                                              child: Text("ביטול"),
                                                                              onPressed: () async {
                                                                                if (_formKey.currentState.validate()) {
                                                                                  _formKey.currentState.save();
                                                                                }
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              textColor: Colors.white,
                                                                              color: Colors.red,
                                                                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                                            )),
                                                                          ),
                                                                          flex:
                                                                              2,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: this.passErr ==
                                                                            "!הסיסמה הוחלפה בהצלחה"
                                                                        ? Text(
                                                                            this.passErr,
                                                                            style:
                                                                                TextStyle(color: Colors.green),
                                                                          )
                                                                        : Text(
                                                                            this.passErr,
                                                                            style:
                                                                                TextStyle(color: Colors.red),
                                                                          ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                );
                                              });
                                        },
                                        child: Text("לחצ/י כאן להחלפת סיסמה"),
                                      ),
                                    ),
                                  ),
                                  _getActionButtons(),
                                  Center(
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: isSave
                                            ? Text(
                                                "!הנתונים נשמרו בהצלחה",
                                                style: TextStyle(
                                                    color: Colors.green),
                                              )
                                            : Text("")),
                                  ),
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
            ));
  }

  /// Dispose
  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  /// Save button UI
  /// When pressed the button calls to save data function
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
                  try{
                    saveData();
                  } on io.SocketException catch (err){
                    print("not internet");
                  }
                  catch(e){
                    print("err $e");
                  }

                  setState(() {
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

  /// Gets user
  UserModel getUser(BuildContext context) {
    try {
      return Provider.of<UserModel>(context);
    } catch (e) {
      return null;
    }
  }

  /// Save all the changes
  void saveData() async {
    /// Get the user id
    String id = _auth.currentUser.uid;

    /// Get the new data from the text field
    String newName = nameController.text;
    if (newName == "") {
      /// name does not change
      newName = currUserModel.username;
    }

    /// Get the new email from the text field
    String newMail = emailController.text;
    if (newMail != "") {
      /// Change email
      changeEmail(newMail);
    }

    /// Get the new gender
    String newGender = _character.toString();
    if (_character == Gender.MALE) {
      newGender = "m";
    } else if (_character == Gender.FEMALE) {
      newGender = "f";
    } else {
      newGender = "o";
    }

    /// Get the new video type
    final newVidType = vidType == false ? VideoType.ANIMATION : VideoType.LIVE;

    /// Update data (name, gender and videoType) in firebase
    await DatabaseUserService(uid: id).updateUserData2(
      username: newName,
      gender: newGender,
      videoType: newVidType,
    );

    /// Upload profile image to the firebase
    final imageFile = this._profileImage.imageFile;
    if (imageFile.toString() != "assets/user.png" && imageFile != null) {
      await this._profileImage.uploadFile();
    }

    /// Save is done
    setState(() {
      isSave = true;
    });
  }

  /// Change password function
  Future<String> changePass(String newPassword) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    try {
      /// Check if the new password is less the 6 chars
      if (newPassword.length < 6) {
        return "הסיסמה צריכה להכיל לפחות 6 תויים!";
      }
      /// Change password
      AuthCredential credential = EmailAuthProvider.credential(
          email: auth.currentUser.email, password: oldPassController.text);
      await _auth.currentUser.reauthenticateWithCredential(credential);
      await user
          .updatePassword(newPassword)
          .then((value) => null)
          .catchError((error) => print(error));
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        return "סיסמה ישנה שגויה";
      }
      if (e.code == "too-many-requests") {
        return "בעיה פנימית במסד הנתונים";
      }
      setState(() {
        this.passErr = e.code;
      });
      return e.code;
    } catch (e) {
      return e.toString();
    }
    return "!הסיסמה הוחלפה בהצלחה";
  }

  /// Change email function
  void changeEmail(String newEmail) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    await user.updateEmail(newEmail).then((value) {
      user.sendEmailVerification();
    }).catchError((error) => print(error));
  }
}
