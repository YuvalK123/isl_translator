import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


class AddExpression extends StatefulWidget {
  AddExpression({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AddExpression createState() => _AddExpression();
}

class _AddExpression extends State<AddExpression> {
  CameraController controller;
  List cameras;
  int selectedCameraIndex;
  String imgPath;

  @override
  void initState() {
    super.initState();
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

  // Display camera preview
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

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  // Display control bar
  Widget cameraControlWidget(context) {
    return Expanded(
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FloatingActionButton(
                child: Icon(
                  Icons.camera,
                ),
                onPressed: () {
                  onCapturePressed(context);
                },
              )
            ],
          ),
        )
    );
  }

  Widget cameraToggleRowWidget(){
    if (cameras == null || cameras.isEmpty){
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: FlatButton.icon(
              onPressed: onSwitchCamera,
              icon: Icon(
                getCameraLensIcon(lensDirection)
              ),
              label: Text(
                '${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1).toUpperCase()}',
              )
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: cameraPreviewWidget(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      cameraToggleRowWidget(),
                      cameraControlWidget(context),
                      Spacer()
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

  void onCapturePressed(context) async {
    try {
      final path = join((await getTemporaryDirectory()).path,
      '${DateTime.now()}.png');

      await controller.takePicture();
    } catch (e) {
      showCameraException(e);
    }
  }

  void onSwitchCamera() {
    selectedCameraIndex =
    selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    initController(selectedCamera);
  }


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
