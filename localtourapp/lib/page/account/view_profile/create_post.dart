import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localtourapp/models/HomePage/placeCard.dart';
import 'package:localtourapp/models/posts/post_model.dart';
import 'package:localtourapp/models/schedule/schedule_model.dart';
import 'package:localtourapp/models/posts/postmedia.dart';
import 'package:localtourapp/page/search_page/search_page.dart';
import 'package:localtourapp/services/media_service.dart';
import 'package:localtourapp/services/place_service.dart';
import 'package:localtourapp/services/post_service.dart';
import 'package:localtourapp/services/schedule_service.dart';

class CreatePostOverlay extends StatefulWidget {
  final int? placeId;
  final PostModel? existingPost;
  final VoidCallback? callback;

  const CreatePostOverlay({
    Key? key,
    this.placeId,
    this.existingPost,
    this.callback,
  }) : super(key: key);

  @override
  _CreatePostOverlayState createState() => _CreatePostOverlayState();
}

class _CreatePostOverlayState extends State<CreatePostOverlay> {
  final ScheduleService _scheduleService = ScheduleService();
  final PostService _postService = PostService();
  final PlaceService _placeService = PlaceService();
  final MediaService _mediaService = MediaService();
  final ImagePicker _picker = ImagePicker();
  PlaceCardModel? selectedPlace;
  int? selectedScheduleId;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<PostMedia> mediaList = [];
  bool isUpdateMode = false;
  late List<ScheduleModel> myListSchedule;
  List<File> listFilePick = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingPost != null) {
      _initializeForUpdate(widget.existingPost!);
    }
    _fetchPlaceDetails();
  }

  void _initializeForUpdate(PostModel post) {
    isUpdateMode = true;
    titleController.text = post.title;
    contentController.text = post.content;
    // Initialize other fields as necessary
  }

  Future<void> _fetchPlaceDetails() async {
    try {
      var result = await _scheduleService.GetScheduleCurrentUser();

      if (isUpdateMode) {
        PostModel postmodel = widget.existingPost!;

        if (postmodel.placeId != null) {
          var p = await _placeService.GetPlaceDetail(postmodel.placeId!);

          selectedPlace = PlaceCardModel(
            placeId: p.id,
            wardName: '',
            photoDisplayUrl: p.photoDisplay,
            latitude: 0,
            longitude: 0,
            placeName: p.name,
            rateStar: p.rating,
            countFeedback: 0,
            distance: 0,
            address: '',
          );
        }

        if (postmodel.scheduleId != null) {
          selectedScheduleId = postmodel.scheduleId;
        }

        for (var item in postmodel.media) {
          var result =
          await _mediaService.downloadAndConvertToXFile(item.url);
          if (result != null) {
            mediaList.add(PostMedia(
              createdAt: DateTime.now(),
              id: DateTime.now().millisecondsSinceEpoch,
              type: item.type.toLowerCase(), // Ensure type consistency
              url: result.path,
            ));
          }
        }
            }

      setState(() {
        myListSchedule = result;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching schedule: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _selectPlace(PlaceCardModel place) {
    setState(() {
      selectedPlace = place;
    });
  }

  void _removePlace() {
    setState(() {
      selectedPlace = null;
    });
  }

  void addMedia(PostMedia media) {
    if (mediaList.length < 10) {
      setState(() {
        mediaList.add(media);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 10 media items allowed.')),
      );
    }
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      List<PostMedia> newMediaList = [];
      bool sizeExceeded = false;
      bool itemLimitExceeded = false;

      for (XFile pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        // Check file size
        if ((fileSize / (1024 * 1024)) > 15) {
          sizeExceeded = true;
          continue; // Skip this file
        }

        // Check item limit
        if (mediaList.length + newMediaList.length >= 10) {
          itemLimitExceeded = true;
          break;
        }

        newMediaList.add(PostMedia(
          id: DateTime.now().millisecondsSinceEpoch,
          url: pickedFile.path,
          type: 'image',
          createdAt: DateTime.now(),
          postId: widget.existingPost?.id ?? 0,
        ));
      }

      setState(() {
        mediaList.addAll(newMediaList);
      });

      if (sizeExceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Each image must be less than 15 MB.')),
        );
      }

      if (itemLimitExceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot add more than 10 media items.')),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      // Check file size
      if ((fileSize / (1024 * 1024)) > 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Each video must be less than 50 MB.')),
        );
        return;
      }

      // Check item limit
      if (mediaList.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot add more than 10 media items.')),
        );
        return;
      }

      setState(() {
        mediaList.add(PostMedia(
          id: DateTime.now().millisecondsSinceEpoch,
          url: pickedFile.path,
          type: 'video',
          createdAt: DateTime.now(),
          postId: widget.existingPost?.id ?? 0,
        ));
      });
    }
  }

  Future<void> _createOrUpdatePost() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final hasContent = title.isNotEmpty || content.isNotEmpty;
    final hasMedia = mediaList.isNotEmpty;

    if (!hasContent && !hasMedia) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least a title, content, or media.'),
        ),
      );
      return;
    }

    if (hasMedia) {
      listFilePick.clear();
      for (var item in mediaList) {
        listFilePick.add(File(item.url));
      }
    }

    int? scheduleId = selectedScheduleId;

    String resultMessage;

    if (isUpdateMode) {
      var result = await _postService.UpdatePost(
        widget.existingPost!.id,
        title,
        content,
        selectedPlace?.placeId,
        scheduleId,
        listFilePick,
      );

      resultMessage = result;
    } else {
      var result = await _postService.CreatePost(
        title,
        content,
        selectedPlace?.placeId,
        scheduleId,
        listFilePick,
      );

      resultMessage = result;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultMessage)),
    );

    if (widget.callback != null) {
      widget.callback!();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : DraggableScrollableSheet(
      initialChildSize: 0.87,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 236, 179, 1),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
              border:Border.all(width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and Create/Update button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isUpdateMode
                            ? 'UPDATE POST'
                            : 'CREATE NEW POST',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          ElevatedButton(
                            onPressed: _createOrUpdatePost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              isUpdateMode ? 'Update' : 'Create',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Schedule dropdown
                  const Text('Choose Schedule:'),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedScheduleId,
                    items: myListSchedule
                        .map((schedule) => DropdownMenuItem<int>(
                      value: schedule.id, // Use unique schedule ID
                      child: Text(schedule.scheduleName),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedScheduleId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Selected place display or Add More Place/Delete Place button
                  if (selectedPlace != null) ...[
                    Row(
                      children: [
                        if (selectedPlace!.photoDisplayUrl.isNotEmpty)
                          Image.network(
                            selectedPlace!.photoDisplayUrl,
                            width: 50,
                            height: 50,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          selectedPlace!.placeName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: _removePlace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Delete This Place',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ] else ...[
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(
                                onPlaceSelected: _selectPlace,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Add More Place',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Title input
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content input
                  TextField(
                    controller: contentController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Media section with Add buttons and Media List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMediaButton(
                        icon: Icons.photo_camera,
                        label: 'Add Photo',
                        onPressed: _pickImages,
                      ),
                      _buildMediaButton(
                        icon: Icons.videocam,
                        label: 'Add Video',
                        onPressed: _pickVideo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Display selected media list
                  if (mediaList.isNotEmpty)
                    SizedBox(
                      height: 120, // Adjust height for thumbnails
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: mediaList.length,
                        itemBuilder: (context, index) {
                          final media = mediaList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  child: media.type == 'image'
                                      ? Image.file(
                                    File(media.url),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                      : Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.black12,
                                        child: Icon(
                                          Icons.videocam,
                                          size: 50,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white70,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        mediaList.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
