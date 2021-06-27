
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileImage{
  String imageUrl;
  Image _img;
  bool isLocal = false;
  bool loaded = false;
  File _imageFile;
  NetworkImage _networkImage;
  FileImage _fileImage;
  String _uploadedFileURL;
  String uid;


  bool get hasImg {
    return _fileImage != null || _networkImage != null;
}

  ImageProvider get img{
    return this.isLocal ? _fileImage : _networkImage;
  }

  ProfileImage(bool isLocal){
    this.isLocal = isLocal;
    _setImageUrl();
  }

  void _setImageUrl() async{

    await setImage();
  }

  Future<void> setImage() async{
    // if (imageUrl == null){
    //   return;
    // }
    if (this.isLocal){
      this._fileImage = FileImage(_imageFile);
    }else{
      this.imageUrl = await getImageUrl();
      this._networkImage = NetworkImage(this.imageUrl);
    }

  }


  static Future<String> getImageUrl() async{
    var isImageExist = true;
    String imageUrl;
    FirebaseAuth auth = FirebaseAuth.instance;
    String id = auth.currentUser.uid;
    //Reference ref = FirebaseStorage.instance.ref().child('users_profile_pic/$id}');
    var storageReference = FirebaseStorage.instance.ref().child('users_profile_pic/${Path.basename(id)}');
    try {
      // gets the video's url
      imageUrl = await storageReference.getDownloadURL();
      print("got it!");
    } catch (err) {
      print("don't exist");
      isImageExist = false;

    }

    if(isImageExist == false)
    {
      storageReference = FirebaseStorage.instance.ref().child('users_profile_pic/user.png');
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
    _imageFile = bla;    //_cropImage(pickedFile.path);
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      _imageFile = image;
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
        _uploadedFileURL = fileURL;
    });
  }

  Future uploadFile() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String id = auth.currentUser.uid;
    var storageReference = FirebaseStorage.instance
        .ref()
        .child('users_profile_pic/${Path.basename(id)}');
    UploadTask uploadTask = storageReference.putFile(_imageFile);
    await uploadTask.whenComplete(() => print('File Uploaded'));
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileURL = fileURL;
    });
  }

}