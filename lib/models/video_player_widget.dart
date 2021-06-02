import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatelessWidget {

  final VideoPlayerController controller;

  VideoPlayerWidget({@required this.controller});

  @override
  Widget build(BuildContext context) {
    if(controller != null && controller.value.initialized){
      return Container(
        alignment: Alignment.center,
        child: buildVideo(),
      );
    }
    return Container();

  }


  Widget buildVideo() => buildVideoPlayer();

  Widget buildVideoPlayer() => VideoPlayer( controller);
}
