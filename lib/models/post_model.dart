import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:workie/widgets/comment_bottom_sheet.dart';

import '../screens/image_gallery_screen.dart';

class PostCardModel extends StatefulWidget {
  final String profileImageUrl;
  final List<Map<String, dynamic>> comments;
  final String userName;
  final String userTitle;
  final String timeAgo;
  final String connectionStatus;
  final String shortContent;
  final String? fullContent;
  final bool isVerified;
  final List<String> postImageUrls; // Changed from single image to list
  final List<String> hashtags;
  final int initialLikeCount;
  final int commentCount;
  final int shareCount;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCardModel({
    super.key,
    required this.profileImageUrl,
    required this.userName,
    required this.userTitle,
    required this.timeAgo,
    this.connectionStatus = '2nd',
    required this.shortContent,
    this.fullContent,
    this.postImageUrls = const [], // Changed default value
    this.hashtags = const [],
    this.initialLikeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.onLike,
    this.onComment,
    this.onShare,
    required this.isVerified,
    required this.comments,
  });

  @override
  State<PostCardModel> createState() => _PostCardModelState();
}

class _PostCardModelState extends State<PostCardModel> {
  bool _isLiked = false;
  late int _likeCount;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikeCount;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
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
          if (widget.postImageUrls.isNotEmpty) _buildPostImages(), // Updated method name
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
                        fontSize: 15,
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.userTitle,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${widget.timeAgo} • 🌍',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.grey.shade400),
            onPressed: () {},
          ),
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
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 14,
                height: 1.4,
              ),
              children: [
                TextSpan(text: widget.shortContent),
                if (widget.fullContent != null && _isExpanded)
                  TextSpan(text: widget.fullContent),
              ],
            ),
          ),
          if (widget.fullContent != null && widget.fullContent!.isNotEmpty)
            GestureDetector(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  _isExpanded ? '...less' : '...more',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
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

  Widget _buildPostImages() {
    if (widget.postImageUrls.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageGalleryScreen(
              imageUrls: widget.postImageUrls,
              initialIndex: 0,
              profileImageUrl: widget.profileImageUrl,
              userName: widget.userName,
              isVerified: widget.isVerified,
              connectionStatus: widget.connectionStatus,
              userTitle: widget.userTitle,
              timeAgo: widget.timeAgo,
              fullContent: widget.fullContent,
              shortContent: widget.shortContent,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: _buildImageLayout(),
        ),
      ),
    );
  }

  Widget _buildImageLayout() {
    final imageCount = widget.postImageUrls.length;

    if (imageCount == 1) {
      return _buildSingleImage(widget.postImageUrls[0]);
    } else if (imageCount == 2) {
      return _buildTwoImagesLayout();
    } else if (imageCount == 3) {
      return _buildThreeImagesLayout();
    } else {
      // For 4 or more images, show first 3 and remaining count
      return _buildFourOrMoreImagesLayout();
    }
  }

  Widget _buildSingleImage(String imageUrl) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTwoImagesLayout() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(right: 1),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              image: DecorationImage(
                image: NetworkImage(widget.postImageUrls[0]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(left: 1),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              image: DecorationImage(
                image: NetworkImage(widget.postImageUrls[1]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThreeImagesLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(right: 1),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              image: DecorationImage(
                image: NetworkImage(widget.postImageUrls[0]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 99,
                margin: const EdgeInsets.only(left: 1, bottom: 1),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                  image: DecorationImage(
                    image: NetworkImage(widget.postImageUrls[1]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 99,
                margin: const EdgeInsets.only(left: 1, top: 1),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                  image: DecorationImage(
                    image: NetworkImage(widget.postImageUrls[2]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourOrMoreImagesLayout() {
    final remainingCount = widget.postImageUrls.length - 3;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(right: 1),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              image: DecorationImage(
                image: NetworkImage(widget.postImageUrls[0]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 99,
                margin: const EdgeInsets.only(left: 1, bottom: 1),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                  image: DecorationImage(
                    image: NetworkImage(widget.postImageUrls[1]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Stack(
                children: [
                  Container(
                    height: 99,
                    margin: const EdgeInsets.only(left: 1, top: 1),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                      image: DecorationImage(
                        image: NetworkImage(widget.postImageUrls[2]),
                        fit: BoxFit.cover,
                      ),
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
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.thumb_up,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '👏',
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                '$_likeCount reactions',
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
                '${widget.commentCount} comments',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${widget.shareCount} reposts',
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
            icon: _isLiked ? Iconsax.like_1 : Iconsax.like_1_copy,
            label: 'Like',
            color: _isLiked ? Colors.red : Colors.grey,
            onTap: _toggleLike,
          ),
          _buildActionButton(
            icon: Iconsax.message_2_copy,
            label: 'Comment',
            color: Colors.grey,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) =>
                    CommentBottomSheet(
                      comments: widget.comments,
                    )
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