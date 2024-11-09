import 'package:flutter/material.dart';
import 'video_player_screen.dart';

class VideoThumbnail extends StatelessWidget {
  final String videoPath;

  const VideoThumbnail({Key? key, required this.videoPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoPath: videoPath),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/video_placeholder.png', // Placeholder image
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          const Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }
}
