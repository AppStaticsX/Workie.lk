import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workie/widgets/add_hashtag_dialog.dart';

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
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  List<String> selectedHashtags = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handlePost() {
    _textController.clear();
    setState(() {
      _selectedImages.clear(); // Add this line
    });

    if (widget.onPostSuccess != null) {
      widget.onPostSuccess!();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => _textController.clear()
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[700],
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                const Text(
                  'MyName',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 0, bottom: 8),
            child: ElevatedButton(
              onPressed: () {
                _handlePost();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E6BF5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: const Text(
                'Post',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
          // Add this after the TextField in the body Column
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
                  IconButton(
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