import 'dart:convert';
import 'dart:math' as math;
import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:workie/screens/media_gallery_screen.dart';
import 'package:workie/widgets/comment_bottom_sheet.dart';

import 'media_item_model.dart';

class PostCardModel extends StatefulWidget {
  final String postId;
  final Function(List<Map<String, dynamic>>)? onCommentsUpdated;
  final String profileImageUrl;
  final List<Map<String, dynamic>> comments;
  final String userName;
  final String userTitle;
  final String timeAgo;
  final String connectionStatus;
  final String content; // Changed from shortContent and fullContent
  final bool isVerified;
  final List<MediaItem> mediaUrls; // Changed from postImageUrls
  final List<String> hashtags;
  final int initialLikeCount;
  final int commentCount;
  final int shareCount;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool isLikedByCurrentUser; // Add this parameter
  final List<Map<String, dynamic>> likes;
  final double bRadius;
  final IconData popupMenuItemIcon;
  final Color? popupMenuItemIconColor;
  final List<PopupMenuOption> options;
  final Widget? customIcon;
  final Color? iconColor;
  final double iconSize;


  const PostCardModel({
    super.key,
    required this.profileImageUrl,
    required this.userName,
    required this.userTitle,
    required this.timeAgo,
    this.connectionStatus = '2ND',
    required this.content, // Updated parameter
    this.mediaUrls = const [], // Updated parameter
    this.hashtags = const [],
    this.initialLikeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.onLike,
    this.onComment,
    this.onShare,
    required this.isVerified,
    required this.comments,
    required this.postId,
    this.onCommentsUpdated,
    this.isLikedByCurrentUser = false, // Add this
    this.likes = const [],
    required this.bRadius,
    required this.popupMenuItemIcon,
    this.popupMenuItemIconColor,
    this.customIcon,
    required this.options,
    this.iconColor,
    required this.iconSize,
  });

  @override
  State<PostCardModel> createState() => _PostCardModelState();
}

class _PostCardModelState extends State<PostCardModel> {
  bool _isLiked = false;
  late int _likeCount;
  bool _isExpanded = false;
  Map<String, VideoPlayerController> _videoControllers = {};
  late int _commentCount;
  String? _currentUserId;
  bool _hasUserCommented = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikeCount;
    _commentCount = widget.commentCount;
    _isLiked = widget.isLikedByCurrentUser; // Set initial like status
    _initializeVideoControllers();
    _getCurrentUserId();
  }

  void _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        // Decode JWT to get user ID
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
          );
          _currentUserId = payload['id'];

          // Check if current user has liked this post
          _checkIfUserLikedPost();
          // Check if current user has commented on this post
          _checkIfUserCommentedPost();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user ID: $e');
      }
    }
  }

  void _checkIfUserLikedPost() {
    if (_currentUserId != null && widget.likes.isNotEmpty) {
      final userLiked = widget.likes.any((like) =>
      like['userId'].toString() == _currentUserId.toString()
      );

      if (mounted) {
        setState(() {
          _isLiked = userLiked;
        });
      }
    }
  }

  void _checkIfUserCommentedPost() {
    if (_currentUserId != null && widget.comments.isNotEmpty) {
      final userCommented = widget.comments.any((comment) {
        // Check both userId and userInfo for user identification
        if (comment['userId'] != null) {
          return comment['userId'].toString() == _currentUserId.toString();
        }
        // If userId is not available, check userInfo
        if (comment['userInfo'] != null) {
          final userInfo = comment['userInfo'];
          if (userInfo['userId'] != null) {
            return userInfo['userId'].toString() == _currentUserId.toString();
          }
        }
        return false;
      });

      if (mounted) {
        setState(() {
          _hasUserCommented = userCommented;
        });
      }
    }
  }

  void _handleCommentStateChanged(List<Map<String, dynamic>> updatedComments) {
    if (mounted) {
      setState(() {
        _commentCount = updatedComments.length;
        // Check if user has commented in the updated list
        if (_currentUserId != null) {
          _hasUserCommented = updatedComments.any((comment) {
            if (comment['userId'] != null) {
              return comment['userId'].toString() == _currentUserId.toString();
            }
            if (comment['userInfo'] != null) {
              final userInfo = comment['userInfo'];
              if (userInfo['userId'] != null) {
                return userInfo['userId'].toString() == _currentUserId.toString();
              }
            }
            return false;
          });
        }
      });
    }
  }

  void _initializeVideoControllers() {
    for (int i = 0; i < widget.mediaUrls.length; i++) {
      if (widget.mediaUrls[i].type == MediaType.video) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.mediaUrls[i].url),
        );
        _videoControllers[widget.mediaUrls[i].url] = controller;
        controller.initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  void _handleLikeStateChanged(bool isLiked, int likeCount) {
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
        _likeCount = likeCount;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });
    widget.onLike?.call();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  // Helper method to get truncated content
  String get _truncatedContent {
    if (widget.content.length <= 95) {
      return widget.content;
    }
    return '${widget.content.substring(0, 95)}...';
  }

  // Helper method to check if content needs truncation
  bool get _needsTruncation {
    return widget.content.length > 95;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12), bottomLeft: Radius.circular(widget.bRadius), bottomRight: Radius.circular(widget.bRadius) ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(),
          if (widget.mediaUrls.isNotEmpty) _buildPostMedia(),
          _buildEngagementStats(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(widget.profileImageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (widget.isVerified)
                      Icon(
                          Iconsax.verify,
                          size: 18
                      ),
                    const SizedBox(width: 4),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.connectionStatus,
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.0, 0.7, 1.0],
                      colors: [
                        Colors.black,
                        Colors.black,
                        Colors.transparent,
                      ],
                    ).createShader(Rect.fromLTWH(0, bounds.height * 0.5, bounds.width, bounds.height * 0.5));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Text(
                    widget.userTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, // Shows ... when text overflows
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      widget.timeAgo == 'Just Now'?
                      '${widget.timeAgo} • ' : '${widget.timeAgo} Ago • ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                    Icon(
                      Iconsax.global_edit,
                      size: 12,
                      color: Theme.of(context).colorScheme.inverseSurface
                    )
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            icon: widget.customIcon ??
                Transform.rotate(
                  angle: math.pi/2,
                  child: Icon(
                    Iconsax.radar_1_copy,
                    color: widget.iconColor ?? Colors.grey.shade400,
                    size: widget.iconSize,
                  ),
                ),
            onSelected: (int index) {
              if (index >= 0 && index < widget.options.length) {
                widget.options[index].onTap();
              }
            },
            itemBuilder: (BuildContext context) => List.generate(
              widget.options.length,
                  (index) {
                final option = widget.options[index];
                return PopupMenuItem<int>(
                  value: index,
                  child: ListTile(
                    leading: Icon(
                      option.icon,
                      color: option.isDanger
                          ? Colors.red
                          : option.iconColor ?? Colors.grey.shade600,
                    ),
                    title: Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 16,
                        color: option.isDanger
                            ? Colors.red
                            : option.textColor ?? Colors.black87,
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            ////overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 15,
                //height: 1.4,
              ),
              children: [
                TextSpan(
                  text: _isExpanded ? widget.content : _truncatedContent,
                ),
              ],
            ),
          ),
          if (_needsTruncation)
            GestureDetector(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  _isExpanded ? '' : '...Expand Content',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (widget.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                children: widget.hashtags.map((hashtag) {
                  return GestureDetector(
                    onTap: () {
                      if (kDebugMode) {
                        print(hashtag);
                      }
                    },
                    child: Text(
                      hashtag.startsWith('#') ? hashtag : '#$hashtag',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPostMedia() {
    if (widget.mediaUrls.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        // Extract image URLs for gallery
        List<String> imageUrls = widget.mediaUrls
            .where((media) => media.type == MediaType.image)
            .map((media) => media.url)
            .toList();

        if (imageUrls.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaGalleryScreen(
                initialIndex: 0,
                profileImageUrl: widget.profileImageUrl,
                userName: widget.userName,
                isVerified: widget.isVerified,
                connectionStatus: widget.connectionStatus,
                userTitle: widget.userTitle,
                timeAgo: widget.timeAgo,
                content: widget.content,
                mediaItems: widget.mediaUrls,
                isLikedByCurrentUser: _isLiked, // Use current state instead of widget property
                initialLikeCount: _likeCount,
                hasUserCommented: _hasUserCommented,
                onLikeStateChanged: _handleLikeStateChanged,
                onLike: () {
                  _toggleLike();
                },
                onComment: () {
                  // Handle comment action
                },
                commentCount: _commentCount,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: _buildMediaLayout(),
        ),
      ),
    );
  }

  Widget _buildMediaLayout() {
    final mediaCount = widget.mediaUrls.length;

    if (mediaCount == 1) {
      return _buildSingleMedia(widget.mediaUrls[0]);
    } else if (mediaCount == 2) {
      return _buildTwoMediaLayout();
    } else if (mediaCount == 3) {
      return _buildThreeMediaLayout();
    } else {
      // For 4 or more media items, show first 3 and remaining count
      return _buildFourOrMoreMediaLayout();
    }
  }

  Widget _buildSingleMedia(MediaItem media) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildMediaWidget(media),
      ),
    );
  }

  Widget _buildTwoMediaLayout() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(right: 1),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              child: _buildMediaWidget(widget.mediaUrls[0]),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(left: 1),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              child: _buildMediaWidget(widget.mediaUrls[1]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThreeMediaLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(right: 1),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              child: _buildMediaWidget(widget.mediaUrls[0]),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 99,
                margin: const EdgeInsets.only(left: 1, bottom: 1),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                  child: _buildMediaWidget(widget.mediaUrls[1]),
                ),
              ),
              Container(
                height: 99,
                margin: const EdgeInsets.only(left: 1, top: 1),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                  child: _buildMediaWidget(widget.mediaUrls[2]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourOrMoreMediaLayout() {
    final remainingCount = widget.mediaUrls.length - 3;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(right: 1),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              child: _buildMediaWidget(widget.mediaUrls[0]),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 99,
                margin: const EdgeInsets.only(left: 1, bottom: 1),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                  child: _buildMediaWidget(widget.mediaUrls[1]),
                ),
              ),
              Stack(
                children: [
                  Container(
                    height: 99,
                    margin: const EdgeInsets.only(left: 1, top: 1),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                      child: _buildMediaWidget(widget.mediaUrls[2]),
                    ),
                  ),
                  Container(
                    height: 99,
                    margin: const EdgeInsets.only(left: 1, top: 1),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                    child: Center(
                      child: Text(
                        '+$remainingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaWidget(MediaItem media) {
    if (media.type == MediaType.image) {
      return Image.network(
        media.url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (media.type == MediaType.video) {
      final controller = _videoControllers[media.url];
      if (controller != null && controller.value.isInitialized) {
        return Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(controller),
            Positioned(
              right: 0,
              bottom: 0,
              child: IconButton(
                  onPressed: () {
                    // Find the index of the current video in mediaUrls
                    int videoIndex = widget.mediaUrls.indexWhere((item) => item.url == media.url);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediaGalleryScreen(
                          initialIndex: videoIndex,
                          profileImageUrl: widget.profileImageUrl,
                          userName: widget.userName,
                          isVerified: widget.isVerified,
                          connectionStatus: widget.connectionStatus,
                          userTitle: widget.userTitle,
                          timeAgo: widget.timeAgo,
                          content: widget.content,
                          mediaItems: widget.mediaUrls,
                          isLikedByCurrentUser: _isLiked, // Use current state
                          initialLikeCount: _likeCount, // Use current state
                          onLikeStateChanged: _handleLikeStateChanged, // Add this callback
                          hasUserCommented: _hasUserCommented,
                          commentCount: _commentCount,
                        ),
                      ),
                    );
                  },
                  icon: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(Iconsax.maximize_2_copy, color: Colors.white, size: 24,),
                      ))
              ),
            ),
            Center(
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, VideoPlayerValue value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      },
                      icon: Icon(
                        value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      } else {
        return Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Center(
            child: Lottie.asset(
                'assets/animation/tiktok_loading.json',
              width: 60,
            ),
          ),
        );
      }
    }
    return const SizedBox();
  }

  Widget _buildEngagementStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Iconsax.heart,
                    size: 16,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                _isLiked
                    ? (_likeCount == 1
                    ? 'You liked this'
                    : 'You & ${_likeCount - 1} ${_likeCount - 1 == 1 ? 'Other' : 'Others'}')
                    : (_likeCount == 0
                    ? 'No reactions yet'
                    : '$_likeCount ${_likeCount == 1 ? 'Reaction' : 'Reactions'}'),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                // Update comment text based on user comment status
                /*_hasUserCommented
                    ? (_commentCount > 1
                    ? 'You & ${_commentCount - 1} Others Commented'
                    : 'You Commented')*/
                    '$_commentCount Comments',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${widget.shareCount} Reposts',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: _isLiked ? Iconsax.heart : Iconsax.heart_copy,
            label: 'Like',
            color: _isLiked ? Colors.red : Colors.grey,
            onTap: _toggleLike,
          ),
          _buildActionButton(
            icon: _hasUserCommented? Iconsax.message_2 : Iconsax.message_2_copy,
            label: 'Comment',
            color: _hasUserCommented? Theme.of(context).colorScheme.inverseSurface : Colors.grey,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) => CommentBottomSheet(
                  initialComments: widget.comments, // FIXED: Use initialComments
                  postId: widget.postId, // FIXED: Pass postId
                  onCommentsUpdated: (updatedComments) {
                    // Update both local state and parent callback
                    _handleCommentStateChanged(updatedComments);
                    widget.onCommentsUpdated?.call(updatedComments);
                  },
                ),
              );
            },
          ),
          _buildActionButton(
            icon: Iconsax.repeat_copy,
            label: 'Repost',
            color: Colors.grey,
            onTap: widget.onShare,
          ),
          _buildActionButton(
            icon: Iconsax.send_2_copy,
            label: 'Send',
            color: Colors.grey,
            onTap: () async {
              try {
                await SharePlus.instance.share(ShareParams(
                    text: '${widget.userName}\n${widget.userTitle}'
                ));
              } catch (e) {
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PopupMenuOption {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;
  final bool isDanger;

  PopupMenuOption({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.isDanger = false,
  });
}