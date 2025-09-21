import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiktok_double_tap_like/double_tap_like_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:workie/values/color.dart';
import '../models/media_item_model.dart';
import '../widgets/dot_indicator.dart';

class MediaGalleryScreen extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final String profileImageUrl;
  final String userName;
  final bool isVerified;
  final String connectionStatus;
  final String userTitle;
  final String timeAgo;
  final String content; // Changed from fullContent and shortContent
  final bool isLikedByCurrentUser;
  final int initialLikeCount;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final Function(bool isLiked, int likeCount)? onLikeStateChanged;
  final bool hasUserCommented;
  final int commentCount;

  const MediaGalleryScreen({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    required this.profileImageUrl,
    required this.userName,
    required this.isVerified,
    required this.connectionStatus,
    required this.userTitle,
    required this.timeAgo,
    required this.content, // Updated parameter
    this.isLikedByCurrentUser = false,
    this.initialLikeCount = 0,
    this.onLike,
    this.onComment,
    this.onLikeStateChanged,
    this.hasUserCommented = false,
    this.commentCount = 0,
  });

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final bool _isExpanded = false;
  Map<String, VideoPlayerController> _videoControllers = {};

  late bool _isLiked;
  late int _likeCount;
  late bool _hasUserCommented;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeVideoControllers();
    _isLiked = widget.isLikedByCurrentUser;
    _likeCount = widget.initialLikeCount;
    _hasUserCommented = widget.hasUserCommented;
  }

  void _initializeVideoControllers() {
    for (int i = 0; i < widget.mediaItems.length; i++) {
      if (widget.mediaItems[i].type == MediaType.video) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.mediaItems[i].url),
        );
        _videoControllers[widget.mediaItems[i].url] = controller;
        controller.initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });

    // Call the callback if provided
    widget.onLike?.call();

    // Update parent state
    widget.onLikeStateChanged?.call(_isLiked, _likeCount);
  }

  @override
  void dispose() {
    widget.onLikeStateChanged?.call(_isLiked, _likeCount);
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Media viewer
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    // Pause all videos when page changes
                    for (var controller in _videoControllers.values) {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      }
                    }
                  },
                  itemCount: widget.mediaItems.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      child: Center(
                        child: _buildMediaWidget(widget.mediaItems[index]),
                      ),
                    );
                  },
                ),
                if (widget.mediaItems.length > 1)
                  Positioned(
                    bottom: 210,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: DotIndicator(
                        itemCount: widget.mediaItems.length,
                        currentIndex: _currentIndex,
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.2),
                        onDotTapped: _goToPage,
                      ),
                    ),
                  ),
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.05,
                  top: MediaQuery.of(context).size.height * 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.mediaItems[_currentIndex].type == MediaType.video
                                ? Icons.videocam
                                : Icons.image,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_currentIndex + 1} of ${widget.mediaItems.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: SizedBox(
                      height: 190,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBottomDetails(),
                          _buildContent(),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                    bottom: 20,
                    left: MediaQuery.of(context).size.width -60,
                    right: 0,
                    child: SafeArea(child: _buildActionButtons())
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaWidget(MediaItem media) {
    if (media.type == MediaType.image) {
      return DoubleTapLikeWidget(
        onLike: (int value) {_isLiked? null : _toggleLike();},
        likeWidget: Icon(Iconsax.heart, color: Colors.red, size: 150),
        child: Image.network(
          media.url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: Lottie.asset(
                  'assets/animation/tiktok_loading.json',
                  width: 60
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error, color: Colors.white, size: 50),
            );
          },
        ),
      );
    } else if (media.type == MediaType.video) {
      final controller = _videoControllers[media.url];
      if (controller != null && controller.value.isInitialized) {
        return DoubleTapLikeWidget(
          onLike: (int value) {_isLiked? null : _toggleLike();},
          likeWidget: Icon(Iconsax.heart, color: Colors.red, size: 150),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              // Play/Pause button
              ValueListenableBuilder(
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
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              // Video progress indicator
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    bufferedColor: Colors.grey.withValues(alpha: 0.5),
                  ),
                ),
              ),
              // Video duration
              Positioned(
                bottom: 30,
                right: 25,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(controller.value.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          color: Colors.grey.shade900,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                    'assets/animation/tiktok_loading.json',
                    width: 60
                ),
                SizedBox(height: 16),
                Text(
                  'Loading video...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    }
    return const SizedBox();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  Widget _buildBottomDetails() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 70, bottom: 0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
                topRight: Radius.circular(15),
                topLeft: Radius.circular(15)
            )
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (widget.isVerified)
                          const Icon(
                              Iconsax.verify,
                              size: 18
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
                    Text(
                      widget.userTitle,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          height: 1.2
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          widget.timeAgo,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Iconsax.global, size: 12,)
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              _toggleLike();
            },
            child: Icon(
              _isLiked ? Iconsax.heart : Iconsax.heart_copy,
              size: 32,
              color: _isLiked ? Colors.red : Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: (){},
            child: Icon(
              _hasUserCommented ? Iconsax.message_2 : Iconsax.message_2_copy,
              size: 32,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              try {
                await SharePlus.instance.share(ShareParams(
                    text: '${widget.userName}\n${widget.userTitle}'
                ));
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Icon(
              Iconsax.send_2_copy,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Check if content exceeds 95 characters
    final bool shouldShowMore = widget.content.length > 95;
    final String displayContent = shouldShowMore
        ? widget.content.substring(0, 95)
        : widget.content;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 70),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
                topRight: Radius.zero,
                topLeft: Radius.zero
            )
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (shouldShowMore) {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        builder: (context) => _expandedContent()
                    );
                  }
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 14,
                      //height: 1.4,
                    ),
                    children: [
                      TextSpan(text: displayContent),
                      if (shouldShowMore)
                        TextSpan(text: '...more',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expandedContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16, bottom: 48, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.textDarkGrey,
                      borderRadius: BorderRadius.circular(3)
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Text(
                widget.content
            ),
          ],
        ),
      ),
    );
  }
}