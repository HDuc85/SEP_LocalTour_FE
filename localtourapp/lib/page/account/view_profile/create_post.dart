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
    this.callback
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
  String? selectedSchedule;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<PostMedia> mediaList = [];
  String placeName = "Unknown Place";
  String photoDisplay = "";
  bool isUpdateMode = false;
  late List<ScheduleModel> myListSchedule;
  List<File> listFilePick =[];
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
    // Set update mode and initialize fields
    isUpdateMode = true;

  }

  Future<void> _fetchPlaceDetails() async {
      try{
        var result = await _scheduleService.GetScheduleCurrentUser();

        if(isUpdateMode){
          PostModel postmodel = widget.existingPost!;

          if(postmodel.placeId != null){

            var p = await _placeService.GetPlaceDetail(widget.existingPost!.placeId!);

            selectedPlace = new PlaceCardModel(placeId: p.id,
                wardName: '',
                photoDisplayUrl: p.photoDisplay,
                latitude: 0,
                longitude: 0,
                placeName: p.name,
                rateStar: p.rating,
                countFeedback: 0,
                distance: 0,
                address: '');

          }
          if(widget.existingPost!.scheduleId != null){
            selectedSchedule = result.firstWhere((element) => element.id == postmodel.scheduleId!,).scheduleName;
          }
          titleController.text = widget.existingPost!.title;
          contentController.text = widget.existingPost!.content;
          if(postmodel.media != null){
            for(var item in postmodel.media){
               var result = await _mediaService.downloadAndConvertToXFile(item.url);
               if(result != null){
                 mediaList.add(new PostMedia(
                   createdAt: DateTime.now(),
                   id: DateTime.now().millisecondsSinceEpoch,
                   type: '${item.type}',
                   url: result.path,)
                 );
               }
            }
          }

        }

        setState(() {
          myListSchedule = result;
          isLoading = false;
        });
      }catch (e){

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

  Future<void> _createOrUpdatePost() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    //final scheduleId = _getSelectedScheduleId();
    final hasContent = content.isNotEmpty;
    //final hasPlace = selectedPlace != null;
    final hasMedia = mediaList.isNotEmpty;
    //final hasSchedule = scheduleId != null;
    if (!hasContent && !hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least one of: Title, Content.'),
        ),
      );
      return;
    }

    if(hasMedia){
      listFilePick.clear();
      for(var item in mediaList){
        listFilePick.add(new File(item.url));
      }
    }
    int scheduleId = myListSchedule.firstWhere((element) => element.scheduleName == selectedSchedule!,).id;


    if (isUpdateMode) {
      var result = await _postService.UpdatePost(widget.existingPost!.id, title, content, selectedPlace !=null ? selectedPlace!.placeId : null, scheduleId, listFilePick);

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(result)),
      );
    } else {

      var result = await _postService.CreatePost(title, content, selectedPlace !=null ? selectedPlace!.placeId : null, scheduleId, listFilePick);

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('$result')),
      );
    }


    widget.callback;
    Navigator.pop(context);
  }




  @override
  Widget build(BuildContext context) {


    return
      isLoading ? const Center(child: CircularProgressIndicator()) :
      DraggableScrollableSheet(
      initialChildSize: 0.87,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 236, 179, 1),
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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedSchedule,
                    items: myListSchedule
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
                                  child: media.type == 'Image'
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
