import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Profile Image class
class ProfileImage{

  /// Variables
  String imageUrl;
  ImageProvider _img;
  File imageFile;
  String uid;
  Function setState;
  AssetImage _localAnonImg = AssetImage("assets/user.png");

  /// Constructor
  ProfileImage({this.uid, this.setState}){
    setImage();
  }

  /// Return the profile image when done loading
  ///
  /// Return profile image if exist, otherwise return the default image
  Future<ImageProvider> get img async{
    if (this._img == null){
      Completer completer = Completer();
      await setImage();
      completer.complete(this._img);
      return completer.future;
    }
    return this._img;
  }

  /// Gets the local default image
  AssetImage get localAnonImg{
    return _localAnonImg;
  }

  /// Update profile image
  ///
  /// If profile image exist gets the image by URL,
  /// otherwise gets the default image from assets
  Future<void> setImage() async{
    this.imageUrl = await getImageUrl();
    this._img = this.imageUrl == null ? this._localAnonImg: NetworkImage(this.imageUrl);
  }

  /// Gets the profile image url for the specific user from the firebase
  Future<String> getImageUrl() async{
    var isImageExist = true;
    String imageUrl;
    FirebaseAuth auth = FirebaseAuth.instance;
    String id = auth.currentUser.uid;
    var storageReference = FirebaseStorage.instance.ref().child('users_profile_pic/${Path.basename(id)}');
    try {
      /// Gets the video's url
      imageUrl = await storageReference.getDownloadURL();
    } catch (err) {
      isImageExist = false;
    }
    /// Check if image exist
    if(!isImageExist)
    {
      return null;
    }
    return imageUrl;
  }

  /// Choose file from gallery
  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      /// save the image locally
      imageFile = image;
      this._img = Image.file(image).image;
    });
  }

  /// Upload profile image to firebase
  Future uploadFile() async {
    var storageReference = FirebaseStorage.instance
        .ref()
        .child('users_profile_pic/${Path.basename(this.uid)}');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.whenComplete(() => (print('File Uploaded')));
    storageReference.getDownloadURL().then((fileURL) {});
  }
}