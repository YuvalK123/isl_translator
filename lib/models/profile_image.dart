
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileImage{
  String imageUrl;
  ImageProvider _img;
  // bool loaded = false;
  File imageFile;
  bool _isLocal = true;
  // NetworkImage _networkImage;
  // FileImage _fileImage;
  String _uploadedFileURL;
  String uid;
  Function setState;
  AssetImage _localAnonImg = AssetImage("assets/user.png");


//   bool get hasImg {
//     return _fileImage != null || _networkImage != null;
// }

  Future<ImageProvider> get img async{
    if (this._img == null){
      Completer completer = Completer();
      await setImage();
      completer.complete(this._img);
      return completer.future;
    }
    return this._img;
    // return this._img != null ? _img : AssetImage("assets/user.png");
  }

  AssetImage get localAnonImg{
    return _localAnonImg;
  }



  set setStatee(Function value) {
    this.setState = value;
  }

  ProfileImage({this.uid, this.setState}){
    setImage();

  }

  // void _setImageUrl() async{
  //
  //   await setImage();
  // }

  Future<void> setImage() async{
    // if (imageUrl == null){
    //   return;
    // }
    // if (this.isLocal){
    //   this._fileImage = FileImage(_imageFile);
    // }else{
    //   this.imageUrl = await getImageUrl();
    //   this._networkImage = NetworkImage(this.imageUrl);
    // }
    this.imageUrl = await getImageUrl();
    // this._img = NetworkImage(this.imageUrl);
    this._img = this._isLocal ? Image.asset(imageUrl): NetworkImage(this.imageUrl);
    // if (this.setState != null) this.setState();

  }

  Future<String> getImageUrl() async{
    var isImageExist = true;
    String imageUrl;
    FirebaseAuth auth = FirebaseAuth.instance;
    String id = auth.currentUser.uid;
    //Reference ref = FirebaseStorage.instance.ref().child('users_profile_pic/$id}');
    var storageReference = FirebaseStorage.instance.ref().child('users_profile_pic/${Path.basename(id)}');
    try {
      // gets the video's url
      imageUrl = await storageReference.getDownloadURL();
      _isLocal = false;
      print("got it!");
    } catch (err) {
      print("don't exist");
      isImageExist = false;

    }

    if(!isImageExist)
    {
      storageReference = FirebaseStorage.instance.ref("assets").child('user.png');
      try {
        // gets the video's url
        imageUrl = await storageReference.getDownloadURL();

      } catch (err) {
        print("don't exist");
      }
    }
    print("done get image");
    return imageUrl;
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
    imageFile = bla;    //_cropImage(pickedFile.path);
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      print("_imageFile _imageFile" );
      imageFile = image;
      this._img = Image.file(image).image;
    });
  }

  Future uploadFile2(File file) async {
    FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket: "https://console.firebase.google.com/project/islcsproject/storage/islcsproject.appspot.com/files"
    );
    FirebaseAuth auth = FirebaseAuth.instance;
    var storageRef = storage.ref().child('users_profile_pic/${this.uid}}');
    print("file image: " + file.toString());
    UploadTask uploadTask = storageRef.putFile(file);
    await uploadTask.whenComplete(() => print('File Uploaded'));
    //var completeTask = await uploadTask.onComplete;
    storageRef.getDownloadURL().then((fileURL) {
        _uploadedFileURL = fileURL;
    });
  }

  Future uploadFile() async {
    print("upload file!!!! ${this.imageFile}");
    FirebaseAuth auth = FirebaseAuth.instance;
    var storageReference = FirebaseStorage.instance
        .ref()
        .child('users_profile_pic/${Path.basename(this.uid)}');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.whenComplete(() => print('File Uploaded'));
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileURL = fileURL;
    });
  }

}