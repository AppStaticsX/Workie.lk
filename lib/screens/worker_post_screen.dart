import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:workie/screens/googlemap_screen.dart';
import '../services/push_data/worker_post_service.dart';
import '../services/notification_service.dart';
import '../services/ai_post_generation_service.dart';
import '../widgets/add_hashtag_dialog.dart';
import '../widgets/ai_content_writer_dialog.dart';

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
  final GlobalKey<GoogleMapScreenState> _googleMapScreenKey = GlobalKey();

  final Map<String, VideoPlayerController?> _videoControllers = {};
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  List<String> selectedHashtags = [];
  bool _isPosting = false;
  String _pickedLocationAdress = '';
  static const int _uploadNotificationId = 12345; // Fixed ID for single notification

  VideoPlayerController? _getVideoController(String videoPath) {
    if (!_videoControllers.containsKey(videoPath)) {
      final controller = VideoPlayerController.file(File(videoPath));
      controller.initialize();
      _videoControllers[videoPath] = controller;
    }
    return _videoControllers[videoPath];
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService.initialize();
      await NotificationService.requestPermissions();
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
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

  Future<void> _showProgressNotification(int progress, int maxProgress, String message) async {
    // Use FlutterLocalNotificationsPlugin directly to maintain same notification ID
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'progress_channel',
      'Progress Notifications',
      channelDescription: 'Notifications showing progress',
      importance: Importance.max,
      priority: Priority.high,
      showProgress: true,
      onlyAlertOnce: true,
    );

    final AndroidNotificationDetails progressDetails = AndroidNotificationDetails(
      'progress_channel',
      'Progress Notifications',
      channelDescription: 'Notifications showing progress',
      importance: Importance.max,
      priority: Priority.high,
      showProgress: true,
      progress: progress,
      maxProgress: maxProgress,
      onlyAlertOnce: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);
    final NotificationDetails progressDetailsWrapper = NotificationDetails(android: progressDetails);

    // Import needed for direct access
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.show(
      _uploadNotificationId,
      'Uploading Media',
      message,
      progressDetailsWrapper,
      payload: 'media_upload_progress',
    );
  }

  Future<void> _handleUploadPost() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are not logged in.')),
        );
      }
      return;
    }
    try {
      final totalFiles = _selectedImages.length + _selectedVideos.length;
      final allFiles = [..._selectedImages, ..._selectedVideos];
      List<Map<String, dynamic>> uploadedMedia = [];

      if (totalFiles > 0) {
        // Calculate total size of all files
        int totalSize = 0;
        for (final file in allFiles) {
          totalSize += await file.length();
        }

        // Show initial progress notification
        await _showProgressNotification(0, 100, 'Preparing to upload $totalFiles file(s)...');

        // Upload media files with real-time progress tracking
        uploadedMedia = await WorkerPostService.uploadPostMediaWithProgress(
          files: allFiles,
          token: token,
          onProgress: (int sent, int total, double speed, String eta) async {
            if (total > 0) {
              final percentage = ((sent / total) * 70).round(); // Use 70% for upload progress
              final sizeInMB = (sent / (1024 * 1024)).toStringAsFixed(1);
              final totalSizeInMB = (total / (1024 * 1024)).toStringAsFixed(1);
              final speedMBps = (speed / (1024 * 1024)).toStringAsFixed(2);

              String progressMessage;
              if (sent == total) {
                progressMessage = 'Uploaded ${sizeInMB}MB';
              } else {
                progressMessage = 'Uploading... ${sizeInMB}MB/${totalSizeInMB}MB • $speedMBps MB/s • ETA $eta';
              }

              await _showProgressNotification(
                  percentage,
                  100,
                  progressMessage
              );
            }
          },
        );

        // Show upload completion progress
        await _showProgressNotification(75, 100, 'Media uploaded successfully, creating post...');
      } else {
        // No media files, just creating post
        await _showProgressNotification(10, 100, 'Creating post...');
      }

      // 2. Create post with content and uploaded media info
      await _showProgressNotification(90, 100, 'Finalizing post...');

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
        location: _pickedLocationAdress,
      );

      // Show final progress
      await _showProgressNotification(100, 100, 'Post created successfully!');

      // Clear the notification after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        NotificationService.cancelNotification(_uploadNotificationId);
      });

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post created successfully!')),
        );
      }
    } catch (e) {
      // Show error notification
      await NotificationService.showNotification(
        title: 'Upload Failed',
        body: 'Failed to create post: ${e.toString()}',
        payload: 'upload_error',
      );

      setState(() {
        _isPosting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
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
          size: 28,
        ),
        title: Row(
          children: [
            Row(
              children: [
                Text(
                  'New Post',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (context) => AIContentWriterDialog(
                      selectedHashtags: selectedHashtags,
                      onContentGenerated: (String content) {
                        setState(() {
                          _textController.text = content;
                        });
                      },
                    ),
                  );
                },
                icon: Icon(Iconsax.magicpen)
            ),
          ),
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
                    'Publish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  fontSize: 16,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts...',
                  hintStyle: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
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
              color: Theme.of(context).colorScheme.surface,
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
                          color: Colors.grey,
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
                          color: Colors.grey,
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
                          color: Colors.grey,
                          size: 28,
                        ),
                        onPressed: () async {
                          // Use await and handle the result properly
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GoogleMapScreen(
                                    key: _googleMapScreenKey,
                                    onPressed: () {
                                      final googleMapScreenState = _googleMapScreenKey.currentState;
                                      if (googleMapScreenState != null &&
                                          googleMapScreenState.pickedLocation.isNotEmpty) {
                                        // Use text property instead of setText method
                                        setState(() {
                                          _pickedLocationAdress = googleMapScreenState.pickedLocation;
                                        });
                                      }
                                    },
                                  )
                              )
                          );

                          // Refresh the UI after returning
                          setState(() {});
                        },
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                            fontSize: 24
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Iconsax.hashtag_copy,
                          color: Colors.grey,
                          size: 26,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'add_manual',
                            child: Row(
                              children: [
                                Icon(Iconsax.hashtag_1, size: 20),
                                SizedBox(width: 8),
                                Text('Add Hashtags'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'suggest_ai',
                            child: Row(
                              children: [
                                Icon(Iconsax.magicpen, size: 20),
                                SizedBox(width: 8),
                                Text('AI Suggestions'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (String value) async {
                          if (value == 'add_manual') {
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
                          } else if (value == 'suggest_ai') {
                            if (_textController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Write some content first to get hashtag suggestions')),
                              );
                              return;
                            }

                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 16),
                                    Text('Generating hashtag suggestions...'),
                                  ],
                                ),
                              ),
                            );

                            try {
                              final suggestions = await AIPostGenerationService.generateHashtagSuggestions(
                                content: _textController.text,
                                maxSuggestions: 10,
                              );

                              Navigator.pop(context); // Close loading dialog

                              if (suggestions.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('AI Hashtag Suggestions'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Select hashtags to add:'),
                                          SizedBox(height: 16),
                                          SizedBox(
                                            height: 200,
                                            child: ListView.builder(
                                              itemCount: suggestions.length,
                                              itemBuilder: (context, index) {
                                                final hashtag = suggestions[index];
                                                final isSelected = selectedHashtags.contains(hashtag);

                                                return CheckboxListTile(
                                                  title: Text('#$hashtag'),
                                                  value: isSelected,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true && !selectedHashtags.contains(hashtag)) {
                                                        selectedHashtags.add(hashtag);
                                                      } else if (value == false) {
                                                        selectedHashtags.remove(hashtag);
                                                      }
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Done'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not generate hashtag suggestions. Try again later.')),
                                );
                              }
                            } catch (e) {
                              Navigator.pop(context); // Close loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error generating suggestions: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () => _textController.clear(),
                      icon: Icon(Iconsax.trash_copy, size: 28, color: Colors.red,)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

