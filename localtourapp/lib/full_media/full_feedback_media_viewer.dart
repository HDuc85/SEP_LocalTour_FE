import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/media_model.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class FullFeedbackMediaViewer extends StatefulWidget {
  final List<MediaModel> feedbackMediaList;
  final int initialIndex;

  const FullFeedbackMediaViewer({
    Key? key,
    required this.initialIndex,
    required this.feedbackMediaList,
  }) : super(key: key);

  @override
  _FullFeedbackMediaViewerState createState() =>
      _FullFeedbackMediaViewerState();
}

class _FullFeedbackMediaViewerState extends State<FullFeedbackMediaViewer> {
  late PageController _pageController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _initializeVideoController();
  }

  Future<File> _copyAssetToLocal(String assetPath) async {
    final directory = await getTemporaryDirectory();
    final localFile = File('${directory.path}/temp_video.mp4');

    // Copy the asset to the local file
    final byteData = await rootBundle.load(assetPath);
    await localFile.writeAsBytes(byteData.buffer.asUint8List());

    return localFile;
  }

  void _initializeVideoController() async {
    final currentMedia = widget.feedbackMediaList[_currentIndex];
    _videoController?.dispose();

    // Determine media type dynamically
    final fileExtension = currentMedia.url.split('.').last.toLowerCase();
    const videoExtensions = ['mp4', 'avi', 'mov', 'mkv'];

    if (videoExtensions.contains(fileExtension)) {
      if (currentMedia.url.startsWith('assets')) {
        final localFile = await _copyAssetToLocal(currentMedia.url);
        _videoController = VideoPlayerController.file(localFile);
      } else if (currentMedia.url.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(currentMedia.url));
      } else {
        _videoController = VideoPlayerController.file(File(currentMedia.url));
      }

      await _videoController!.initialize();
      setState(() {}); // Refresh to show the video
      _videoController!.play();
    } else {
      setState(() {
        _videoController = null; // Clear the video controller for non-videos
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.feedbackMediaList.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _initializeVideoController();
                });
              },
                itemBuilder: (context, index) {
                  final media = widget.feedbackMediaList[index];

                  // Determine media type dynamically
                  final fileExtension = media.url.split('.').last.toLowerCase();
                  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
                  const videoExtensions = ['mp4', 'avi', 'mov', 'mkv'];

                  if (imageExtensions.contains(fileExtension)) {
                    // Display image
                    return Center(
                      child: media.url.startsWith('http')
                          ? Image.network(
                        media.url,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      )
                          : Image.file(
                        File(media.url),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    );
                  } else if (videoExtensions.contains(fileExtension)) {
                    // Display video
                    return Center(
                      child: _videoController != null && _videoController!.value.isInitialized
                          ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                          : const CircularProgressIndicator(),
                    );
                  } else {
                    // Unsupported media type
                    return const Center(
                      child: Text(
                        'Unsupported media type',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                }
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.feedbackMediaList.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

