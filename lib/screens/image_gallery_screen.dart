import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/dot_indicator.dart';

class ImageGalleryScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String profileImageUrl;
  final String userName;
  final bool isVerified;
  final String connectionStatus;
  final String userTitle;
  final String timeAgo;
  final String? fullContent;
  final String shortContent;

  const ImageGalleryScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    required this.profileImageUrl,
    required this.userName,
    required this.isVerified,
    required this.connectionStatus,
    required this.userTitle,
    required this.timeAgo,
    required this.fullContent,
    required this.shortContent,
  });

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
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
          // Image viewer
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      child: Center(
                        child: Image.network(
                          widget.imageUrls[index],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.error, color: Colors.white, size: 50),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                if (widget.imageUrls.length > 1)
                  Positioned(
                    bottom: 210,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: DotIndicator(
                        itemCount: widget.imageUrls.length,
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
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15), topRight: Radius.circular(15), topLeft: Radius.circular(15))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${_currentIndex + 1} of ${widget.imageUrls.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: _buildBottomDetails()
                ),

                Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: _buildContent()
                ),

                Positioned(
                    bottom: 20,
                    left: MediaQuery.of(context).size.width -60,
                    right: 0,
                    child: _buildActionButtons()
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDetails() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 70, bottom: 8),
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.only(bottomLeft: Radius.zero, bottomRight: Radius.zero, topRight: Radius.circular(15), topLeft: Radius.circular(15))
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
            customBorder: CircleBorder(),
            onTap: (){},
            child: Icon(
              Iconsax.like_1_copy,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            customBorder: CircleBorder(),
            onTap: (){},
            child: Icon(
              Iconsax.message_2_copy,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            customBorder: CircleBorder(),
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
            child: Icon(
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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 70),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15), topRight: Radius.zero, topLeft: Radius.zero)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                  onTap: (){
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        builder: (context) => _expandedContent()
                    );
                  },
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expandedContent() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16, bottom: 48, top: 16),
      child: Text(
          widget.fullContent ?? ''
      ),
    );
  }
}