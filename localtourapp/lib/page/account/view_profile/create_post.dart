import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localtourapp/provider/place_provider.dart';
import 'package:localtourapp/provider/schedule_provider.dart';
import 'package:localtourapp/models/places/place.dart';
import 'package:localtourapp/models/posts/post.dart';
import 'package:localtourapp/models/posts/postmedia.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';
import 'package:localtourapp/page/search_page/search_page.dart';
import 'package:provider/provider.dart';

import '../../../provider/user_provider.dart';

class CreatePostOverlay extends StatefulWidget {
  final int? placeId;
  final Post? existingPost;

  const CreatePostOverlay({
    Key? key,
    this.placeId,
    this.existingPost,
  }) : super(key: key);

  @override
  _CreatePostOverlayState createState() => _CreatePostOverlayState();
}

class _CreatePostOverlayState extends State<CreatePostOverlay> {
  final ImagePicker _picker = ImagePicker();
  Place? selectedPlace;
  String? selectedSchedule;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<PostMedia> mediaList = [];
  String placeName = "Unknown Place";
  String photoDisplay = "";
  bool isUpdateMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingPost != null) {
      _initializeForUpdate(widget.existingPost!);
    }
    _fetchPlaceDetails();
  }

  void _initializeForUpdate(Post post) {
    // Set update mode and initialize fields
    isUpdateMode = true;
    titleController.text = post.title;
    contentController.text = post.content ?? '';
    final scheduleProvider =
    Provider.of<ScheduleProvider>(context, listen: false);
    selectedSchedule = scheduleProvider.getScheduleNameById(post.scheduleId!);
    mediaList = List<PostMedia>.from(
        Provider.of<PostProvider>(context, listen: false)
            .getMediaForPost(post.id));
  }

  void _fetchPlaceDetails() {
    final scheduleProvider =
    Provider.of<ScheduleProvider>(context, listen: false);
    if (widget.placeId != null) {
      placeName = scheduleProvider.getPlaceName(widget.placeId!, 'en'); // Replace 'en' with desired language code
      photoDisplay = scheduleProvider.getPhotoDisplay(widget.placeId!);
    }
  }

  void _selectPlace(Place place) {
    final scheduleProvider =
    Provider.of<ScheduleProvider>(context, listen: false);
    setState(() {
      selectedPlace = place;
      placeName = scheduleProvider.getPlaceName(place.placeId, 'en');
      photoDisplay = scheduleProvider.getPhotoDisplay(place.placeId);
    });
  }

  void _removePlace() {
    setState(() {
      selectedPlace = null;
      placeName = "Unknown Place";
      photoDisplay = "";
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
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      int totalSize = _calculateTotalMediaSize();
      List<PostMedia> newMediaList = [];

      for (XFile pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        // Check if adding this file exceeds the total limit
        if (totalSize + fileSize > 200 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Total media size exceeds 200 MB.')),
          );
          break; // Stop adding more files
        }

        newMediaList.add(PostMedia(
          id: DateTime.now().millisecondsSinceEpoch,
          url: pickedFile.path,
          type: 'photo',
          createdAt: DateTime.now(),
          postId: widget.existingPost?.id ?? 0, // Temporary, updated later
        ));
        totalSize += fileSize;
      }

      setState(() {
        mediaList.addAll(newMediaList);
      });
    }
  }


  Future<void> _pickVideo() async {
    final XFile? pickedFile =
    await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (_calculateTotalMediaSize() + fileSize > 200 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total media size exceeds 200 MB.')),
        );
        return;
      }

      setState(() {
        mediaList.add(PostMedia(
          id: DateTime.now().millisecondsSinceEpoch,
          url: pickedFile.path,
          type: 'video',
          createdAt: DateTime.now(),
          postId: widget.existingPost?.id ?? 0, // Temporary, updated later
        ));
      });
    }
  }

  int _calculateTotalMediaSize() {
    return mediaList.fold(0, (sum, media) {
      final file = File(media.url);
      return sum + (file.existsSync() ? file.lengthSync() : 0);
    });
  }

  void _createOrUpdatePost() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final scheduleId = _getSelectedScheduleId();
    final hasContent = content.isNotEmpty;
    final hasPlace = selectedPlace != null;
    final hasMedia = mediaList.isNotEmpty;
    final hasSchedule = scheduleId != null;

    // Check if at least one of the required fields is provided
    if (!hasContent && !hasPlace && !hasMedia && !hasSchedule) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least one of: Schedule, Place, Content, or Media.'),
        ),
      );
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Obtain current user from UserProvider
    final currentUserId = userProvider.currentUser!.userId;

    final newPost = Post(
      id: widget.existingPost?.id ?? DateTime.now().millisecondsSinceEpoch,
      placeId: selectedPlace?.placeId,
      title: title,
      content: content,
      createdAt: widget.existingPost?.createdAt ?? DateTime.now(),
      authorId: currentUserId,
      updatedAt: DateTime.now(),
      isPublic: true,
      scheduleId: scheduleId,
    );

    if (isUpdateMode) {
      postProvider.updatePost(newPost);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully!')),
      );
    } else {
      postProvider.addPost(newPost);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    }

    for (var media in mediaList) {
      media.postId = newPost.id;
      if (!isUpdateMode || !postProvider.isMediaAttached(media)) {
        postProvider.addMedia(media);
      }
    }

    Navigator.pop(context);
  }


  int? _getSelectedScheduleId() {
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false); // Fetch UserProvider
    final String? currentUserId = userProvider.currentUser.userId; // Get current user's ID

    if (currentUserId == null) {
      return null; // Handle cases where the user ID is not available
    }

    final schedule = scheduleProvider.schedules.firstWhereOrNull(
          (s) => s.scheduleName == selectedSchedule && s.userId == currentUserId,
    );

    return schedule?.id;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false); // Fetch UserProvider
    final String? currentUserId = userProvider.currentUser.userId; // Get current user's ID
    if (currentUserId == null) {
      return const Center(
        child: Text('Unable to fetch user information.'),
      );
    }

    final List<Schedule> userSchedules = scheduleProvider.schedules
        .where((s) => s.userId == currentUserId)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                              backgroundColor: Colors.pinkAccent,
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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedSchedule,
                    items: userSchedules
                        .map((schedule) => DropdownMenuItem(
                      value: schedule.scheduleName,
                      child: Text(schedule.scheduleName),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSchedule = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Selected place display or Add More Place/Delete Place button
                  if (selectedPlace != null) ...[
                    Row(
                      children: [
                        if (photoDisplay.isNotEmpty)
                          Image.network(
                            photoDisplay,
                            width: 50,
                            height: 50,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          placeName,
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
                      height: 100, // Adjust height for thumbnails
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
                                  child: media.type == 'photo'
                                      ? Image.file(
                                    File(media.url),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                      : Icon(Icons.videocam,
                                      size: 100,
                                      color: Colors.grey),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                        Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        mediaList.removeAt(index);
                                      });
                                    },
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
