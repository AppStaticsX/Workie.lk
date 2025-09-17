import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../services/pull_data/get_user_data.dart';
import '../services/pull_data/post_data_service.dart';

class CommentBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> initialComments;
  final String postId;
  final Function(List<Map<String, dynamic>>)? onCommentsUpdated;

  const CommentBottomSheet({
    super.key,
    required this.initialComments,
    required this.postId,
    this.onCommentsUpdated,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  String _userAvatarUrl = '';
  String _userName = '';
  bool _isLoading = false;
  bool _isSendingComment = false;

  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
    _getUserData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userPhotos = await GetUserDataService.getCurrentUserPhotos();
      if (userPhotos != null) {
        setState(() {
          _userAvatarUrl = userPhotos['profilePicture'] ?? '';
          _userName = '${userPhotos['firstName'] ?? ''} ${userPhotos['lastName'] ?? ''}'.trim();
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    setState(() {
      _isSendingComment = true;
    });

    try {
      final result = await PostDataService.addComment(
        postId: widget.postId,
        comment: commentText,
      );

      if (result['success'] == true) {
        // Create new comment object
        final newComment = {
          'commentedUserProfileImgUrl': _userAvatarUrl,
          'commentedUserName': _userName.isNotEmpty ? _userName : 'You',
          'comment': commentText,
          'ísVerified': false,
          'timestamp': 'now',
        };

        setState(() {
          _comments.insert(0, newComment); // Add to top of list
          _commentController.clear();
        });

        // Notify parent widget about updated comments
        widget.onCommentsUpdated?.call(_comments);

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Comment added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isSendingComment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments (${_comments.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Comments list
          Expanded(
            child: _comments.isEmpty
                ? Center(
              child: Text(
                'No comments yet\nBe the first to comment!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: comment['commentedUserProfileImgUrl']?.isNotEmpty == true
                            ? NetworkImage(comment['commentedUserProfileImgUrl'])
                            : null,
                        child: comment['commentedUserProfileImgUrl']?.isEmpty == true
                            ? Icon(Icons.person, color: Colors.grey[600])
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment['commentedUserName'] ?? 'Unknown User',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (comment['ísVerified'] == true)
                                  Icon(Iconsax.verify, size: 14, color: Colors.blue),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment['comment'] ?? '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.inverseSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  comment['timestamp'] ?? '2h ago',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    // Handle like comment
                                  },
                                  child: Text(
                                    'Like',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    // Handle reply
                                  },
                                  child: Text(
                                    'Reply',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[300],
                    child: _isLoading
                        ? ClipOval(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                      ).withShimmerAi(
                        loading: true,
                        baseColor: Colors.grey.withValues(alpha: 0.2),
                      ),
                    )
                        : _userAvatarUrl.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        _userAvatarUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, color: Colors.grey[600]);
                        },
                      ),
                    )
                        : Icon(Icons.person, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      enabled: !_isSendingComment,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSendingComment ? null : _sendComment,
                    icon: _isSendingComment
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    )
                        : Icon(
                      Iconsax.send_1_copy,
                      size: 28,
                      color: _commentController.text.trim().isNotEmpty
                          ? Theme.of(context).colorScheme.inverseSurface
                          : Colors.grey,
                    ),
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