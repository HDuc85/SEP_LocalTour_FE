import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/appConfig.dart';
import '../../../../config/secure_storage_helper.dart';
import '../../../../models/media_model.dart';
import '../../../../services/media_service.dart';

class ReviewDialog extends StatefulWidget {
  final Function(
      int rating, String content, List<File> images, List<File> videos)
  onSubmit;
  final int initialRating;
  final String initialContent;
  final List<MediaModel>? initialMedia;
  const ReviewDialog({
    Key? key,
    required this.onSubmit,
    this.initialRating = 0,
    this.initialContent = '',
    this.initialMedia,
  }) : super(key: key);

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  MediaService _mediaService = MediaService();

  int selectedRating = 0;
  final TextEditingController contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<XFile> _selectedVideos = [];
  int _totalSize = 0; // Track total size in MB
  int initSize = 0;
  final int maxItems = 10;
  final int maxTotalSize = 200; // 200MB limit
  String _languageCode = '';

  @override
  void initState() {
    super.initState();
    selectedRating = widget.initialRating;
    contentController.text = widget.initialContent;
    _convertListMedia();

    _totalSize = _calculateTotalSize([..._selectedImages, ..._selectedVideos]);
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> _convertListMedia() async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    if(widget.initialMedia != null){
      for(var item in widget.initialMedia!){
        if(item.type == 'Video'){
          XFile? xFile = await _mediaService.downloadAndConvertToXFile(item.url);
          if (xFile != null) {
            _selectedVideos.add(xFile);
          }
        }
        if(item.type == 'Image'){
          XFile? xFile = await _mediaService.downloadAndConvertToXFile(item.url);
          if (xFile != null) {
            _selectedImages.add(xFile);
          }
        }
      }
    }
    setState(() {
      initSize = _calculateTotalSize([..._selectedImages, ..._selectedVideos]);
      _languageCode = languageCode!;
    });
  }
  
  
  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    int newSize = _calculateTotalSize([..._selectedImages, ...images, ..._selectedVideos]);
    if (_selectedImages.length + images.length <= maxItems &&
        newSize <= maxTotalSize) {
      setState(() {
        _selectedImages.addAll(images);
        _totalSize = newSize;
      });
    } else {
      _showLimitExceededMessage();
    }
  }

  Future<void> _pickVideos() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      int videoSize = await _getFileSize(video);
      int newSize = _totalSize + videoSize;
      if (_selectedVideos.length + _selectedImages.length < maxItems &&
          newSize <= maxTotalSize) {
        setState(() {
          _selectedVideos.add(video);
          _totalSize = newSize;
        });
      } else {
        _showLimitExceededMessage();
      }
    }
  }

  Future<int> _getFileSize(XFile file) async {
    int bytes = await file.length();
    return (bytes / (1024 * 1024)).ceil(); // Convert to MB
  }

  int _calculateTotalSize(List<XFile> files) {
    return files.fold<int>(
        0,
            (total, file) =>
        total + (File(file.path).lengthSync() / (1024 * 1024)).ceil());
  }

  void _showLimitExceededMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Limit exceeded: Max 10 items and 200MB total.')),
    );
  }

  bool _hasChanges() {
    bool contentChanged = widget.initialContent != contentController.text;
    bool ratingChanged = widget.initialRating != selectedRating;
    bool mediaChanged = initSize != _calculateTotalSize([..._selectedImages, ..._selectedVideos]);

    return contentChanged || ratingChanged  || mediaChanged;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color:
                        index < selectedRating ? Colors.orange : Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
              ),
              TextField(
                controller: contentController,
                maxLength: 200,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: _languageCode == 'vi' ? 'Viết đánh giá của bạn':'Write your review...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey),
                    onPressed: _pickImages,
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam, color: Colors.grey),
                    onPressed: _pickVideos,
                  ),
                ],
              ),
              // Media display with delete option
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Images with delete option
                    ..._selectedImages.map((image) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          Image.file(
                            File(image.path),
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.remove(image);
                                  _totalSize = _calculateTotalSize([..._selectedImages, ..._selectedVideos]);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    // Videos with delete option
                    ..._selectedVideos.map((video) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.videocam,
                              size: 40,
                              color: Colors.black54,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedVideos.remove(video);
                                  _totalSize = _calculateTotalSize([..._selectedImages, ..._selectedVideos]);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (selectedRating > 0) {
                    if (contentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_languageCode == 'vi' ? 'Hãy nhập nội dung':'Please enter review content.')),
                      );
                      return;
                    }
                    if (_hasChanges()) {
                      widget.onSubmit(
                        selectedRating,
                        contentController.text,
                        _selectedImages.map((e) => File(e.path)).toList(),
                        _selectedVideos.map((e) => File(e.path)).toList(),
                      );
                      Navigator.of(context).pop(); // Close the dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_languageCode == 'vi' ? 'Bạn không thay đổi điều gì':'You have not changed anything')),
                      );
                      Navigator.of(context).pop(); // Close the dialog if desired
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_languageCode == 'vi' ? 'Vui lòng chọn xếp hạng.':'Please select a rating.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDCA1A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  elevation: 2,
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
                child: Text(_languageCode == 'vi' ? 'Gửi Đánh giá': 'Submit Review',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}