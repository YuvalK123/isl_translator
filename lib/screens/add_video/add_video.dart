// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:isl_translator/screens/add_video/add_expression_page.dart';
import 'package:isl_translator/shared/main_drawer.dart';
import 'package:flutter/services.dart';

class AddVideoPage extends StatefulWidget {
  AddVideoPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AddVideoPageState createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {

  CameraController controller;
  List cameras;
  int selectedCameraIndex;
  int recordingDelay = 5;
  int recordingTime = 3;
  Timer timer;
  int counter = 0;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    Timer.run(() => instructions(context));

    // setting the screen orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
        initController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('Error :${err.code}Error message : ${err.message}');
    });

  }

  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  /// Initializing camera controller
  Future initController(CameraDescription description) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(description, ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    if (controller.value.hasError) {
      print('Camera error ${controller.value.errorDescription}');
    }

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Display camera preview
  Widget cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }
    return RotatedBox(
      quarterTurns: 2,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }

  /// Display control bar
  Widget cameraControlWidget(context) {
    return Expanded(
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
          InkWell(
            child: Icon(
              this.isRecording
                  ? Icons.radio_button_on
                  : Icons.panorama_fish_eye,
              color: this.isRecording
                  ? Colors.red
                  : Colors.white,
              size: 80,
            ),
            onTap: () {
              onCapturePressed(context);
            },
          ),
        ],
          ),
        )
    );
  }

  /// The camera picker widget
  Widget cameraToggleRowWidget(){
    if (cameras == null || cameras.isEmpty){
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: FlatButton.icon(
          onPressed: onSwitchCamera,
          icon: Icon(
            getCameraLensIcon(lensDirection),
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            '',
          ),
        ),
      ),
    );
  }

  void instructions(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('???????????? ????????????', textDirection: TextDirection.rtl),
            content: Text('???? ?????? ?????????? ?????????????? ???????????? ???????????? ?????????? ???????????? ????????????.\n?????????? ?????????? ?????????? ?????? ????????????,\n?????????? ???? ?????? ???????? ???????????? ?????????????????? ??????????', textDirection: TextDirection.rtl),
            actions: <Widget>[
              MaterialButton(
                  child: Icon(Icons.check),
                  onPressed: () => Navigator.of(context).pop()
              ),
            ],
          );
        }
    );
  }


  Widget timing(BuildContext context){
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: FlatButton.icon(
          onPressed: () {
            int delay = recordingDelay;
            int time = recordingTime;
            return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('??????????'),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('??????????'),
                        SpinBox(
                          max: 15,
                          min: 0,
                          value: recordingDelay.toDouble(),
                          onChanged: (value) => delay = value.toInt(),
                        ),
                        Text('?????? ??????????'),
                        SpinBox(
                          max: 15,
                          min: 0,
                          value: recordingTime.toDouble(),
                          onChanged: (value) => time = value.toInt(),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      MaterialButton(
                          child: Icon(Icons.check),
                          onPressed: () {
                            recordingDelay = delay;
                            print(recordingDelay);
                            recordingTime = time;
                            Navigator.of(context).pop();
                          }
                      )
                    ],
                  );
                });
          },
          icon: Icon(
            Icons.timer,
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            '',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('???????? ??????????', textDirection: TextDirection.rtl),
        backgroundColor: Colors.cyan[800],
        actions: [],
      ),
      endDrawer: MainDrawer(
        currPage: pageButton.ADDVID,
      ),
      body: Container(
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    cameraPreviewWidget(),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        (counter > 0) ? '$counter' : '',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: double.infinity,
                  width: 120,
                  padding: EdgeInsets.all(15),
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      cameraToggleRowWidget(),
                      cameraControlWidget(context),
                      SingleChildScrollView(child: timing(context)),
                      // Spacer()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  void showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError message: ${e.description}';
    print(errorText);
  }

  /// counting down for recording
  void countDown(context) {
    counter = recordingDelay + 1;

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (counter > 0) {
          counter--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  /// recording sequence
  /// starting countdown and start to record after its done.
  /// recording for a duration of time that was previously defined.
  /// navigating out of the page after thr recording is done
  void onCapturePressed(context) async {
    countDown(context);
    await Future.delayed(Duration(seconds: recordingDelay + 1));
    try {
      await controller.startVideoRecording();
      this.isRecording = true;
      await Future.delayed(Duration(seconds: recordingTime));
      XFile videoFile = await controller.stopVideoRecording();
      this.isRecording = false;

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AddExpression(videoFile: videoFile)));
    } catch (e) {
      showCameraException(e);
    }
  }

  /// camera switch
  /// pick the camera we want to use.
  void onSwitchCamera() {
    selectedCameraIndex =
    selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    initController(selectedCamera);
  }


  /// return the correct camera icon
  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

}
