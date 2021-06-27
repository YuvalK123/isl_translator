import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:path/path.dart' as Path;


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
  ProfileImage _profileImage = ProfileImage(uid: FirebaseAuth.instance.currentUser.uid);
  bool isSave = false;
  // for select pic
  File _image;
  final picker = ImagePicker();
  /// Variables
  var imageUrl;
  File imageFile;
  String _uploadedFileURL;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
    // initImgUrl();

  }

  void initImgUrl() async{
    var img = await ProfileImage.getImageUrl();
    if(mounted){
      setState(() {
        this.imageUrl =img;
      });
    }

  }

  void loadUser() async{
    final auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid;
    await for (var value in DatabaseUserService(uid: uid).users){
      setState(() {
        this.currUserModel = value;
        _character = value.genderModel;
        print(_character);
        print("videp type == > " + value.videoType.toString());
        if(value.videoType == VideoType.LIVE)
          {
            vidType= true;
          }
      });
    }
    print("done, $_character");
    print("done, $vidType");
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
                                          image: new DecorationImage(
                                              image: _profileImage.img,
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
                                              await _profileImage.chooseFile();
                                              setState(() {

                                              });
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
                                             'שם משתמש: ' + userModel.username,
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
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            _auth.currentUser.email + " :אימייל",
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
                                        activeColor: Colors.cyan[700],
                                        inactiveColor: Colors.cyan[700],
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
                                                  left: 25.0, right: 25.0, top: 80.0),
                                              child: StatefulBuilder(
                                                  builder: (context, setState){
                                              return SingleChildScrollView(
                                                child: AlertDialog(
                                                  content: Stack(
                                                    overflow: Overflow.visible,
                                                    children: <Widget>[
                                                      Form(
                                                        key: _formKey,
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: Text("סיסמה ישנה"),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: new TextField(
                                                              textDirection: TextDirection.rtl,
                                                              controller: oldPassController,
                                                              decoration: const InputDecoration(
                                                                  hintText: "הכנס/י סיסמה ישנה"),
                                                              textAlign: TextAlign.right,
                                                            ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: Text("סיסמה חדשה"),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child:  new TextField(
                                                                textDirection: TextDirection.rtl,
                                                                controller: newPassController,
                                                                decoration: const InputDecoration(
                                                                    hintText: "הכנס/י סיסמה חדשה"),
                                                                textAlign: TextAlign.right,
                                                              ),
                                                            ),
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
                                                      child: new Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.only(left: 10.0),
                                                              child: Container(
                                                                  child: new RaisedButton(
                                                                    child: Text("החלפ/י"),
                                                                    onPressed: () async{
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
                                                                    shape: new RoundedRectangleBorder(
                                                                        borderRadius: new BorderRadius.circular(20.0)),
                                                                  )),
                                                            ),
                                                            flex: 2,
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.only(right: 10.0),
                                                              child: Container(
                                                                  child: new RaisedButton(
                                                                    child: Text("ביטול"),
                                                                    onPressed: () async{
                                                                      if (_formKey.currentState.validate()) {
                                                                        _formKey.currentState.save();
                                                                      }
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                    textColor: Colors.white,
                                                                    color: Colors.red,
                                                                    shape: new RoundedRectangleBorder(
                                                                        borderRadius: new BorderRadius.circular(20.0)),
                                                                  )),
                                                            ),
                                                            flex: 2,
                                                          ),

                                                        ],
                                                      ),
                                                    ),
                                                            Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: this.passErr == "!הסיסמה הוחלפה בהצלחה" ?
                                                              Text(this.passErr,style: TextStyle(color: Colors.green),) :
                                                              Text(this.passErr,style: TextStyle(color: Colors.red),),
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
                                    });},
                                    child: Text("לחצ/י כאן להחלפת סיסמה"),
                                  ),
                                ),
                              ),
                              _getActionButtons(),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: isSave ? Text("!הנתונים נשמרו בהצלחה",style: TextStyle(color: Colors.green),) : Text("")
                                ),
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
    String id = _auth.currentUser.uid;

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

    //update data in data (name, gender) in firebase
    await DatabaseUserService(uid: id).updateUserData2(
        username: newName,
        gender: newGender,
        videoType: newVidType,
    );

    // upload profile picture to the firebase
    print("imageFile" + imageFile.toString());
    if(imageFile.toString() != "assets/user.png" && imageFile != null )
      {
        print("uploadFile");
        uploadFile();
      }

    setState(() {
      isSave = true;
    });
  }

  Future<String> changePass(String newPassword) async{
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    try{
      if(newPassword.length < 6)
      {
        return "הסיסמה צריכה להכיל לפחות 6 תויים!";
      }
      AuthCredential credential = EmailAuthProvider.credential(email: "israela.megira@gmail.com", password: oldPassController.text);
      await _auth.currentUser.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword).then((value) => null).catchError((error) => print(error));
    } on FirebaseAuthException catch(e){
      print("e is ${e.code}");
      if (e.code == "wrong-password"){
        print("pass wrong :(");
        return "סיסמה ישנה שגויה";
      }
      if (e.code == "too-many-requests"){
        return "בעיה פנימית במסד הנתונים";
      }
      setState(() {
        this.passErr = e.code;
      });
      return e.code;
    } catch (e){
      return e.toString();
    }
    return "!הסיסמה הוחלפה בהצלחה";
  }

  void changeEmail(String newEmail) async{
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    print(user.email);
    await user.updateEmail(newEmail).then((value) {
      print("changed mail... ");
      user.sendEmailVerification();
    }).catchError((error) => print(error));
  }

  /// Get from gallery
  _getFromGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    print("pickedFile.path" + pickedFile.path);
    File bla = File(pickedFile.path);
    imageFile = bla;
    setState(() {imageFile = bla;});    //_cropImage(pickedFile.path);
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        imageFile = image;
      });
    });
  }

  Future uploadFile2(File file) async {
    FirebaseStorage storage = FirebaseStorage(storageBucket: "https://console.firebase.google.com/project/islcsproject/storage/islcsproject.appspot.com/files");
    FirebaseAuth auth = FirebaseAuth.instance;
    String id = auth.currentUser.uid;
    var storageRef = storage.ref().child('users_profile_pic/$id}');
    print("file image: " + file.toString());
    UploadTask uploadTask = storageRef.putFile(file);
    await uploadTask.whenComplete(() => print('File Uploaded'));
    //var completeTask = await uploadTask.onComplete;
    storageRef.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  Future uploadFile() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String id = auth.currentUser.uid;
    var storageReference = FirebaseStorage.instance
        .ref()
        .child('users_profile_pic/${Path.basename(id)}');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.whenComplete(() => print('File Uploaded'));
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
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