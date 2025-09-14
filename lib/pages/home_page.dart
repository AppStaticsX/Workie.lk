import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/models/post_model.dart';
import 'package:workie/widgets/custom_icon_button.dart';
import 'package:workie/widgets/custom_textfield.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../services/location_service.dart';
import '../services/pull_data/post_data_service.dart';
import '../widgets/circular_category_bar.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> with TickerProviderStateMixin {

  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<Map<String, dynamic>> _posts = [];
  bool _isLoadingPosts = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _postsPerPage = 10;
  bool _hasMorePosts = true;

  String _currentLoction = '';
  bool _isUpdatingLocation = false;

  bool _isCategoryBarVisible = true;
  double _lastScrollOffset = 0.0;
  final double _scrollThreshold = 10.0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start with category bar visible
    _animationController.forward();

    // Add scroll listener
    _scrollController.addListener(_onScroll);

    _getLocation();
    _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _getLocation() async {
    setState(() {
      _isUpdatingLocation = true;
    });

    String? areaName = await LocationService.getCurrentAreaName(context);

    setState(() {
      _currentLoction = areaName ?? 'Location Permission Denied.';
      _isUpdatingLocation = false;
    });
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMorePosts = true;
        _isLoadingPosts = true;
      });
    }

    try {
      final newPosts = await PostDataService.getFeedPosts(
        page: _currentPage,
        limit: _postsPerPage,
      );

      setState(() {
        if (refresh) {
          _posts = newPosts.map((post) => PostDataService.formatPostForWidget(post)).toList();
        } else {
          _posts.addAll(newPosts.map((post) => PostDataService.formatPostForWidget(post)).toList());
        }

        _hasMorePosts = newPosts.length == _postsPerPage;
        _currentPage++;
        _isLoadingPosts = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
        _isLoadingMore = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadPosts();
  }

  Future<void> _onRefresh() async {
    await _loadPosts(refresh: true);
  }

  void _handleLike(String postId) async {
    try {
      await PostDataService.toggleLike(postId: postId);
      // Optionally update local state or reload posts
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleComment(String postId) {
    // Navigate to comment screen or show comment bottom sheet
    print('Comment on post: $postId');
  }

  void _handleShare(String postId) {
    // Handle share functionality
    print('Share post: $postId');
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final difference = currentOffset - _lastScrollOffset;

    if (currentOffset >= _scrollController.position.maxScrollExtent - 500) {
      _loadMorePosts();
    }

    // Only react if scroll difference is significant enough
    if (difference.abs() > 5.0) {
      if (difference > 0 && currentOffset > _scrollThreshold) {
        // Scrolling up - hide category bar
        if (_isCategoryBarVisible) {
          setState(() {
            _isCategoryBarVisible = false;
          });
          _animationController.reverse();
        }
      } else if (difference < 0) {
        // Scrolling down - show category bar
        if (!_isCategoryBarVisible) {
          setState(() {
            _isCategoryBarVisible = true;
          });
          _animationController.forward();
        }
      }
      _lastScrollOffset = currentOffset;
    }
  }

  final List<CategoryItem> categories = [
    CategoryItem(id: '1',
        name: 'Carpenter',
        svgAsset: 'assets/icon/profession/mono/carpenter-svgrepo-com.svg'),
    CategoryItem(id: '2',
        name: 'Mason',
        svgAsset: 'assets/icon/profession/mono/mason-svgrepo-com.svg'),
    CategoryItem(id: '3',
        name: 'Painter',
        svgAsset: 'assets/icon/profession/mono/painter-svgrepo-com.svg'),
    CategoryItem(id: '4',
        name: 'Plumber',
        svgAsset: 'assets/icon/profession/mono/plumber-svgrepo-com.svg'),
    CategoryItem(id: '5',
        name: 'Welder',
        svgAsset: 'assets/icon/profession/mono/welder-svgrepo-com.svg'),
  ];

  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      appBar: AppBar(
        surfaceTintColor: const Color(0xFF4E6BF5),
        backgroundColor: const Color(0xFF4E6BF5),
        leadingWidth: double.maxFinite,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Iconsax.location, color: Color(0xFFFFD542)),
                  const SizedBox(width: 4),
                  Text(
                    _isUpdatingLocation
                        ? 'Updating...'
                        : _currentLoction,
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(width: 4),
                  _isUpdatingLocation
                      ? SizedBox(
                        width: 28,
                        height: 24,
                        child: Transform.scale(
                          scale: 0.45, // Makes it half the size
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 8,
                              color: Colors.white,
                              strokeCap: StrokeCap.square,
                            ),
                          ),
                        ),
                      )
                      : InkWell(
                    onTap: _getLocation,
                    customBorder: const CircleBorder(),
                    child: const Icon(
                      Iconsax.arrow_right_3_copy,
                      size: 18,
                      color: Color(0xFFFFD542),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InkWell(
              customBorder: const CircleBorder(),
              child: CustomIconButton(
                iconData: Iconsax.sms_notification_copy,
                color: Colors.white.withValues(alpha: 0.3),
                width: 44,
                height: 44,
                size: 24,
                iconColor: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _WidgetSearchBar(isCategoryBarVisible: _isCategoryBarVisible),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -80 * (1 - _animation.value)),
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    height: _animation.value * 95, // Adjust height as needed
                    decoration: const BoxDecoration(
                        color: Color(0xFF4E6BF5),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        )
                    ),
                    padding: const EdgeInsets.only(bottom: 4.0, top: 8),
                    child: CircularCategoryBar(
                      categories: categories,
                      selectedCategoryId: selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          selectedCategory = category.id;
                        });
                      },
                      selectedColor: const Color(0xFFFFD542),
                      unselectedColor: Colors.white.withValues(alpha: 0.7),
                      selectedTextColor: Colors.white,
                      unselectedTextColor: Colors.white.withValues(alpha: 0.8),
                      itemSize: 60,
                      spacing: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
              );
            },
          ),
          // Main content - Now scrollable with real posts
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: _isLoadingPosts
                  ? ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: 5, // Show 5 shimmer posts
                itemBuilder: (context, index) {
                  return _buildPostShimmer();
                },
              )
                  : RefreshIndicator(
                onRefresh: _onRefresh,
                child: _posts.isEmpty
                    ? const Center(
                  child: Text(
                    'No posts available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(0),
                  itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _posts.length) {
                      // Loading indicator at bottom
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final post = _posts[index];
                    return PostCardModel(
                      profileImageUrl: post['profileImageUrl'],
                      userName: post['userName'],
                      userTitle: post['userTitle'],
                      timeAgo: post['timeAgo'],
                      isVerified: post['isVerified'],
                      content: post['content'],
                      mediaUrls: post['mediaUrls'],
                      hashtags: post['hashtags'],
                      initialLikeCount: post['initialLikeCount'],
                      commentCount: post['commentCount'],
                      shareCount: post['shareCount'],
                      onLike: () => _handleLike(post['id']),
                      onComment: () => _handleComment(post['id']),
                      onShare: () => _handleShare(post['id']),
                      comments: post['comments'],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer loading widget for posts
  // Shimmer loading widget for posts
  Widget _buildPostShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                // Profile image shimmer - circular
                const SizedBox.shrink().withShimmerAi(
                  loading: true,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name shimmer
                      Text(' ').withShimmerAi(
                        loading: true,
                        width: 120,
                        height: 16,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                      ),
                      // Title shimmer
                      Text(' ').withShimmerAi(
                        loading: true,
                        width: 160,
                        height: 12,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                      ),
                      // Time shimmer
                      Text(' ').withShimmerAi(
                        loading: true,
                        width: 80,
                        height: 11,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(' ').withShimmerAi(
                  loading: true,
                  width: double.infinity,
                  height: 14,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
                Text(' ').withShimmerAi(
                  loading: true,
                  width: 280,
                  height: 14,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
                Text(' ').withShimmerAi(
                  loading: true,
                  width: 200,
                  height: 14,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          // Media shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const SizedBox.shrink().withShimmerAi(
              loading: true,
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.4),
              ),
            ),
          ),
          // Engagement stats shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(' ').withShimmerAi(
                  loading: true,
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
                Text(' ').withShimmerAi(
                  loading: true,
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          // Action buttons shimmer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) =>
                  Text(' ').withShimmerAi(
                    loading: true,
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.withValues(alpha: 0.4),
                    ),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetSearchBar extends StatelessWidget {
  final bool isCategoryBarVisible;
  const _WidgetSearchBar({required this.isCategoryBarVisible});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFF4E6BF5),
          borderRadius: isCategoryBarVisible
              ? const BorderRadius.only()
              : const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          )
      ),
      padding: isCategoryBarVisible
          ? EdgeInsets.only(top: 12.0, bottom: 16.0, left: 8.0, right: 16.0)
          : EdgeInsets.only(top: 12.0, bottom: 20.0, left: 8.0, right: 16.0),
      child: Row(
        children: [
          Expanded(
              child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CustomTextfield(
                      obscureText: false,
                      prefixIconData: const Icon(Iconsax.search_normal_copy),
                      hintText: 'Search',
                    ),
                  )
              )
          ),
          CustomIconButton(
            iconData: Iconsax.setting_4_copy,
            color: const Color(0xFFFFD542),
            width: 52,
            height: 52,
            size: 26,
            iconColor: Colors.black,
          ),
        ],
      ),
    );
  }
}