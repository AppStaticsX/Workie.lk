import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:workie/screens/googlemap_screen.dart';
import 'package:workie/widgets/add_hashtag_dialog.dart';

import '../services/push_data/worker_post_service.dart';

class WorkerPostScreen extends StatefulWidget {
  final VoidCallback? onPostSuccess;

  const WorkerPostScreen({
    super.key,
    this.onPostSuccess
  });

  @override
  State<WorkerPostScreen> createState() => _WorkerPostScreenState();
}

class _WorkerPostScreenState extends State<WorkerPostScreen> {
  Map<String, VideoPlayerController?> _videoControllers = {};
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  List<String> selectedHashtags = [];
  bool _isPosting = false;

  VideoPlayerController? _getVideoController(String videoPath) {
    if (!_videoControllers.containsKey(videoPath)) {
      final controller = VideoPlayerController.file(File(videoPath));
      controller.initialize();
      _videoControllers[videoPath] = controller;
    }
    return _videoControllers[videoPath];
  }

  @override
  void dispose() {
    _textController.dispose();
    for (var controller in _videoControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  /*Future<void> _handlePost() async {
    await Future.delayed(Duration(seconds: 3));
    _textController.clear();
    setState(() {
      _selectedImages.clear();
      _selectedVideos.clear();
      // Clear video controllers
      for (var controller in _videoControllers.values) {
        controller?.dispose();
      }
      _videoControllers.clear();
      _isPosting = false;
    });

    if (widget.onPostSuccess != null) {
      widget.onPostSuccess!();
    }
  }*/

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiVideo(
        limit: 3,
        maxDuration: const Duration(minutes: 10), // Optional: limit video duration
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          // Add all selected videos to the list
          _selectedVideos.addAll(
            pickedFiles.map((file) => File(file.path)).toList(),
          );

          // Or if you want to replace the existing videos:
          // _selectedVideos = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick videos: $e')),
        );
      }
    }
  }

  Future<void> _handleUploadPost() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are not logged in.')),
      );
      return;
    }
    try {
      // 1. Upload media files
      final uploadedMedia = await WorkerPostService.uploadPostMedia(
        files: [..._selectedImages, ..._selectedVideos], // <-- FIXED
        token: token,
      );

      // 2. Create post with content and uploaded media info
      final post = await WorkerPostService.createPost(
        token: token,
        content: _textController.text,
        media: uploadedMedia.map((m) => {
          'url': m['url'],
          'publicId': m['publicId'],
          'fileType': m['fileType'] ?? (m['mimetype']?.startsWith('video') == true ? 'video' : 'image'),
          'fileName': m['fileName'] ?? m['originalName'] ?? '',
          'folder': m['folder'] ?? 'posts',
          'size': m['size'] ?? 0,
          'mimetype': m['mimetype'] ?? '',
          'uploadedAt': m['uploadedAt'] ?? DateTime.now().toIso8601String(),
        }).toList(),
        hashtags: selectedHashtags,
        privacy: 'public',
        location: 'Colombo',
      );

      // Optionally clear UI and show success
      _textController.clear();
      setState(() {
        _selectedImages.clear();
        _selectedVideos.clear();
        for (var controller in _videoControllers.values) {
          controller?.dispose();
        }
        _videoControllers.clear();
        _isPosting = false;
      });
      if (widget.onPostSuccess != null) widget.onPostSuccess!();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      setState(() {
        _isPosting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(
          Iconsax.card_edit_copy,
          color: Colors.white,
          size: 28,
        ),
        title: Row(
          children: [
            Row(
              children: [
                const Text(
                  'New Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 0, bottom: 0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isPosting = true;
                });
                _handleUploadPost();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E6BF5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPosting)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: Colors.white,
                          strokeCap: StrokeCap.square,
                        ),
                      ),
                    ),
                  const Text(
                    'Post',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 0, left: 16, right: 16),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts...',
                  hintStyle: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
          if (selectedHashtags.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              height: 64, // Increased to accommodate padding + chip height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedHashtags.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${selectedHashtags[index]}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inverseSurface,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedHashtags.removeAt(index);
                              });
                            },
                            customBorder: const CircleBorder(),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
          // Display selected images
          if (_selectedImages.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[600]!),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
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
          // Display selected videos
          if (_selectedVideos.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedVideos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[600]!),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Builder(
                            builder: (context) {
                              final controller = _getVideoController(_selectedVideos[index].path);

                              return Stack(
                                children: [
                                  if (controller != null && controller.value.isInitialized)
                                    AspectRatio(
                                      aspectRatio: 1.0, // Changed from controller.value.aspectRatio to 1.0 for square
                                      child: VideoPlayer(controller),
                                    )
                                  else
                                    Container(
                                      color: Colors.grey[800],
                                      child: Center(
                                        child: Transform.scale(
                                          scale: 1,
                                          child: const Padding(
                                            padding: EdgeInsets.only(right: 4.0),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 5,
                                              color: Colors.white,
                                              strokeCap: StrokeCap.square,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const Center(
                                    child: Icon(
                                      Iconsax.video_play_copy,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedVideos.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              border: Border(
                top: BorderSide(
                  color: Colors.grey[800]!,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Iconsax.gallery_add_copy,
                          color: Colors.grey[400],
                          size: 28,
                        ),
                        onPressed: () {
                          _pickImageFromGallery();
                        },
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                            fontSize: 24
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Iconsax.video_vertical_copy,
                          color: Colors.grey[400],
                          size: 28,
                        ),
                        onPressed: () {
                          _pickVideoFromGallery();
                        },
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                            fontSize: 24
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Iconsax.location_copy,
                          color: Colors.grey[400],
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => GoogleMapScreen())
                          );
                        },
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () => _textController.clear(),
                      icon: Icon(Iconsax.trash_copy, size: 28, color: Colors.red,)
                  )
                  /*IconButton(
                    icon: Icon(
                      Iconsax.hashtag_copy,
                      color: Colors.grey[400],
                      size: 26,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddHashtagsDialog(
                          selectedHashtags: selectedHashtags,
                          onHashtagsChanged: (hashtags) {
                            setState(() {
                              selectedHashtags = hashtags;
                            });
                          },
                        ),
                      );
                    },
                  ),*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}