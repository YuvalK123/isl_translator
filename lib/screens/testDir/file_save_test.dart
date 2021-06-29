import 'package:flutter/material.dart';
import 'package:isl_translator/services/video_cache.dart';
import 'package:isl_translator/shared/main_drawer.dart';

class DummyPage extends StatefulWidget {
  @override
  _DummyPageState createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  List<String> _firebaseDirNames = ["live_videos/", "animation_openpose/"];
  List<String> _cacheFolders = ["Cache/live/letters/", "Cache/animation/letters/"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tumtum"),),
      endDrawer: MainDrawer(currPage: pageButton.ADDVID,),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text("dummy page"),
              ElevatedButton(
                  onPressed: cacheLetters,
                  child: Icon(Icons.download),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cacheLetters() async {
    for (int i = 0; i < this._firebaseDirNames.length; i++) {
      String firebaseDirName = this._firebaseDirNames[i],
          cacheFolder = this._cacheFolders[i];
      print("caching letters for $firebaseDirName in $cacheFolder");
      await LruCache.saveLetters(firebaseDirName, cacheFolder);
    }
  }
}

// class ImagePickerHandler {
//   ImagePickerDialog imagePicker;
//   AnimationController _controller;
//   ImagePickerListener _listener;
//
//   ImagePickerHandler(this._listener, this._controller);
//
//   openCamera() async {
//     imagePicker.dismissDialog();
//     var image = await ImagePicker.pickImage(source: ImageSource.camera);
//     cropImage(image);
//   }
//
//   openGallery() async {
//     imagePicker.dismissDialog();
//     var image = await ImagePicker.pickImage(source: ImageSource.gallery);
//     cropImage(image);
//   }
//
//   void init() {
//     imagePicker = new ImagePickerDialog(this, _controller);
//     imagePicker.initState();
//   }
//
//   Future cropImage(File image) async {
//     File croppedFile = await ImageCropper.cropImage(
//       //   sourcePath: image.path,
//       //   //ratioX: 1.0,
//       //   //ratioY: 1.0,
//       //   maxWidth: 512,
//       //   maxHeight: 512,
//       // );
//         aspectRatioPresets: Platform.isAndroid
//             ? [
//           CropAspectRatioPreset.square,
//           CropAspectRatioPreset.ratio3x2,
//           CropAspectRatioPreset.original,
//           CropAspectRatioPreset.ratio4x3,
//           CropAspectRatioPreset.ratio16x9
//         ]
//             : [
//           CropAspectRatioPreset.original,
//           CropAspectRatioPreset.square,
//           CropAspectRatioPreset.ratio3x2,
//           CropAspectRatioPreset.ratio4x3,
//           CropAspectRatioPreset.ratio5x3,
//           CropAspectRatioPreset.ratio5x4,
//           CropAspectRatioPreset.ratio7x5,
//           CropAspectRatioPreset.ratio16x9
//         ],
//         androidUiSettings: AndroidUiSettings(
//             toolbarTitle: 'Cropper',
//             toolbarColor: Colors.deepOrange,
//             toolbarWidgetColor: Colors.white,
//             initAspectRatio: CropAspectRatioPreset.original,
//             lockAspectRatio: false),
//         iosUiSettings: IOSUiSettings(
//           title: 'Cropper',
//         ));
//
//
//     _listener.userImage(croppedFile);
//   }
//
//   showDialog(BuildContext context) {
//     imagePicker.getImage(context);
//   }
// }