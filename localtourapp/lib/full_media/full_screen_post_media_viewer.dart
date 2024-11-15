
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

import '../models/posts/postmedia.dart';


class FullScreenPostMediaViewer extends StatefulWidget {
  final List<PostMedia> postMediaList;
  final int initialIndex;

  const FullScreenPostMediaViewer({
    super.key,
    required this.postMediaList,
    required this.initialIndex,
  });

  @override
  _FullScreenPostMediaViewerState createState() => _FullScreenPostMediaViewerState();
}

class _FullScreenPostMediaViewerState extends State<FullScreenPostMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.postMediaList.isEmpty) {
      // Handle empty media list
      _currentIndex = -1;
    } else {
      _currentIndex = widget.initialIndex;
    }
    _pageController = PageController(initialPage: _currentIndex >= 0 ? _currentIndex : 0);
    _initializeVideoController();
  }

  // Initialize the video controller if the current media is a video
  void _initializeVideoController() async {
    if (_currentIndex < 0 || widget.postMediaList.isEmpty) return; // Prevent accessing empty list

    final currentMedia = widget.postMediaList[_currentIndex];
    await _videoController?.dispose();

    if (currentMedia.type.toLowerCase() == 'video') {
      if (currentMedia.url.startsWith('http')) {
        // Network video
        print('Initializing network video: ${currentMedia.url}');
        _videoController = VideoPlayerController.networkUrl(Uri.parse(currentMedia.url));
      } else {
        // Asset video
        print('Initializing asset video: ${currentMedia.url}');
        _videoController = VideoPlayerController.asset(currentMedia.url);
      }
      try {
        await _videoController!.initialize();
        setState(() {});
        _videoController!.play();
      } catch (e) {
        // Handle video initialization error
        print('Error initializing video: $e');
        _videoController = null;
        // Optionally, show a user-friendly message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load video.')),
        );
      }
    } else {
      _videoController = null;
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
    if (widget.postMediaList.isEmpty || _currentIndex < 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Media Viewer')),
        body: const Center(
          child: Text(
            "No media available for this post.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // Clean background
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.postMediaList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _initializeVideoController();
              });
            },
            itemBuilder: (context, index) {
              final media = widget.postMediaList[index];
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
                return const Center(
                  child: Text(
                    "Unsupported media type",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),
          // Back Button
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
          // Current Index Indicator
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
                '${_currentIndex + 1}/${widget.postMediaList.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // Display createDate at bottom-left corner
          Positioned(
            bottom: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _formatDate(widget.postMediaList[_currentIndex].createdAt),
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
