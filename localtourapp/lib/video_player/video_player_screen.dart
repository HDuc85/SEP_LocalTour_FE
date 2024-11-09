import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({Key? key, required this.videoPath})
      : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadAndPlayVideo();
  }

  Future<void> _loadAndPlayVideo() async {
    // Check if the path is an asset or a local file
    if (widget.videoPath.startsWith('assets')) {
      // Copy asset video to a local file
      final file = await _copyVideoToLocal(widget.videoPath);
      _controller = VideoPlayerController.file(file);
    } else {
      // If it's a file path, use it directly
      _controller = VideoPlayerController.file(File(widget.videoPath));
    }
    await _controller?.initialize();
    setState(() {
      _isInitialized = true; // Mark as initialized once done
    });
    _controller?.play();
  }

  Future<File> _copyVideoToLocal(String assetPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final localFile = File('${directory.path}/video.mp4');
    final videoData = await rootBundle.load(assetPath);
    await localFile.writeAsBytes(videoData.buffer.asUint8List());
    return localFile;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: _isInitialized && _controller != null
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
