import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import '../../models/places/placefeeedbackmedia.dart'; // For formatting the date

class FullFeedbackMediaViewer extends StatefulWidget {
  final List<PlaceFeedbackMedia> feedbackMediaList;
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

    // Check if the video is from assets or local/network storage
    if (currentMedia.type.toLowerCase() == 'video') {
      if (currentMedia.url.startsWith('assets')) {
        // Copy asset to a temporary location and use that path
        final localFile = await _copyAssetToLocal(currentMedia.url);
        _videoController = VideoPlayerController.file(localFile);
      } else if (currentMedia.url.startsWith('http')) {
        _videoController = VideoPlayerController.network(currentMedia.url);
      } else {
        _videoController = VideoPlayerController.file(File(currentMedia.url));
      }

      await _videoController!.initialize();
      setState(() {}); // Refresh to show the video
      _videoController!.play();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Function to format DateTime
  String _formatDate(DateTime date) {
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Clean background
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.feedbackMediaList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _initializeVideoController(); // Reinitialize video for the new page
              });
            },
            itemBuilder: (context, index) {
              final media = widget.feedbackMediaList[index];
              if (media.type.toLowerCase() == 'photo') {
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
              } else if (media.type.toLowerCase() == 'video') {
                return Center(
                  child: _videoController != null &&
                      _videoController!.value.isInitialized
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
                return const Center(
                  child: Text(
                    'Unsupported media type',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Adjust for status bar
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // Current index indicator
          Positioned(
            bottom: 40,
            right: 20,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          // Display createDate at bottom-left corner
          Positioned(
            bottom: 40, // Adjust as needed
            left: 20,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _formatDate(widget.feedbackMediaList[_currentIndex].createDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
