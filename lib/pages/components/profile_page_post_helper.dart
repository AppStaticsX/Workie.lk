import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/pages/components/edit_post_screen.dart';
import 'package:workie/screens/worker_post_screen.dart';
import '../../services/pull_data/current_user_posts.dart';
import '../../models/post_model.dart';
import '../../models/media_item_model.dart';
import '../../services/pull_data/post_data_service.dart';

class ProfilePagePostHelper extends StatefulWidget {
  const ProfilePagePostHelper({super.key});

  @override
  State<ProfilePagePostHelper> createState() => _ProfilePagePostHelperState();
}

class _ProfilePagePostHelperState extends State<ProfilePagePostHelper> {
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoadingPosts = false;
  int _totalPostsCount = 0;
  int selectedChipIndex = 0;
  final List<String> chipLabels = ['Posts', 'Videos', 'Photos'];

  @override
  void initState() {
    super.initState();
    _loadAllUserPosts();
  }

  Future<void> _loadAllUserPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final posts = await CurrentUserPostsService.getCurrentUserPostsFormatted(
        page: 1,
        limit: 10, // Load all posts (adjust limit as needed)
      );
      final postsCount = await CurrentUserPostsService.getCurrentUserPostsCount();

      setState(() {
        _userPosts = posts;
        _totalPostsCount = postsCount;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  List<Map<String, dynamic>> _filterPostsByChip() {
    switch (selectedChipIndex) {
      case 0: // Posts - show all posts
        return _userPosts;
      case 1: // Videos - show only posts with videos
        return _userPosts.where((post) {
          final mediaUrls = post['mediaUrls'] as List?;
          return mediaUrls?.any((media) => media.type == MediaType.video) ?? false;
        }).toList();
      case 2: // Photos - show only posts with images
        return _userPosts.where((post) {
          final mediaUrls = post['mediaUrls'] as List?;
          return mediaUrls?.any((media) => media.type == MediaType.image) ?? false;
        }).toList();
      default:
        return _userPosts;
    }
  }

  void _handlePostLike(String postId) async {
    try {
      await PostDataService.toggleLike(postId: postId);
      // Refresh posts to update like status
      await _loadAllUserPosts();
    } catch (e) {
      //
    }
  }

  void _handlePostComment(String postId) {
    // Comment handling is managed by the PostCardModel itself
  }

  void _handlePostShare(String postId) {
    // Handle post sharing
  }

  void _handlePostDelete(String postId) async {
    try {
      // Show confirmation dialog
      final confirmed = await _showDeleteConfirmationDialog();
      if (!confirmed) return;

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleting post...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Delete the post
      await PostDataService.deletePost(postId: postId);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Refresh the posts list
      await _loadAllUserPosts();

    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting post: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handlePostEdit(Map<String, dynamic> postData) {
    showModalBottomSheet(
        context: context,
        builder: (context)=> EditPostScreen(
          postToEdit: postData,
          onPostSuccess: () {
            // Refresh posts after successful edit
            _loadAllUserPosts();
          },
        ),
      scrollControlDisabledMaxHeightRatio: 1,
      showDragHandle: true
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Post', style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Lato', color: Theme.of(context).colorScheme.primary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: const Color(0xFF4E6BF5),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'All Posts ($_totalPostsCount)',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                for (int i = 0; i < chipLabels.length; i++) ...[
                  ChoiceChip(
                    label: Text(
                      chipLabels[i],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: selectedChipIndex == i ? Colors.black : null,
                      ),
                    ),
                    selected: selectedChipIndex == i,
                    onSelected: (selected) {
                      setState(() {
                        selectedChipIndex = i;
                      });
                    },
                    selectedColor: const Color(0xFF36C897),
                    showCheckmark: false,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  if (i < chipLabels.length - 1) const SizedBox(width: 12),
                ],
              ],
            ),
          ),
          // Posts content
          Expanded(
            child: _buildPostsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsContent() {
    if (_isLoadingPosts) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_text_copy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your first post to get started!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    List<Map<String, dynamic>> filteredPosts = _filterPostsByChip();

    if (filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selectedChipIndex == 1 ? Iconsax.video_play_copy : Iconsax.gallery_copy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${chipLabels[selectedChipIndex].toLowerCase()} yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllUserPosts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        itemCount: filteredPosts.length,
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: PostCardModel(
              key: ValueKey('profile_post_${post['id']}'), // Add unique key to prevent widget recycling
              postId: post['id'] ?? '',
              profileImageUrl: post['profileImageUrl'] ?? '',
              userName: post['userName'] ?? '',
              userTitle: post['userTitle'] ?? '',
              timeAgo: post['timeAgo'] ?? '',
              content: post['content'] ?? '',
              mediaUrls: List.from(post['mediaUrls'] ?? []),
              hashtags: List<String>.from(post['hashtags'] ?? []),
              initialLikeCount: post['initialLikeCount'] ?? 0,
              commentCount: post['commentCount'] ?? 0,
              shareCount: post['shareCount'] ?? 0,
              isVerified: post['isVerified'] ?? false,
              comments: List<Map<String, dynamic>>.from(post['comments'] ?? []),
              isLikedByCurrentUser: post['isLikedByCurrentUser'] ?? false,
              likes: List<Map<String, dynamic>>.from(post['likes'] ?? []),
              onLike: () => _handlePostLike(post['id']),
              onComment: () => _handlePostComment(post['id']),
              onShare: () => _handlePostShare(post['id']),
              bRadius: 12,
              popupMenuItemIcon: Iconsax.trash_copy,
              popupMenuItemIconColor: Colors.red,
              options: [
                PopupMenuOption(
                    title: 'Save',
                    icon: Iconsax.save_add_copy,
                    onTap: (){},
                    textColor: Theme.of(context).colorScheme.inverseSurface
                ),
                PopupMenuOption(
                    title: 'Share',
                    icon: Iconsax.share_copy,
                    onTap: (){},
                    textColor: Theme.of(context).colorScheme.inverseSurface
                ),
                PopupMenuOption(
                    title: 'Edit',
                    icon: Iconsax.edit_2_copy,
                    onTap: () => _handlePostEdit(post),
                    textColor: Theme.of(context).colorScheme.inverseSurface
                ),
                PopupMenuOption(
                    title: 'Delete',
                    icon: Iconsax.trash_copy,
                    onTap: () => _handlePostDelete(post['id']),
                    textColor: Theme.of(context).colorScheme.inverseSurface,
                    iconColor: Colors.red
                ),
              ],
              iconSize: 24,
            ),
          );
        },
      ),
    );
  }
}
