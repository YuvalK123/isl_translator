
import 'dart:ui';
import 'package:path/path.dart' as Path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileImage{
  String imageUrl;
  Image img;

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

}