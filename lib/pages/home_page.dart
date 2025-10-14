import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/models/post_model.dart';
import 'package:workie/screens/messages_screen.dart';
import 'package:workie/widgets/custom_icon_button.dart';
import 'package:workie/widgets/custom_textfield.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../services/hive_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/pull_data/post_data_service.dart';
import '../services/socket_service.dart';
import '../widgets/circular_category_bar.dart';
import '../widgets/comment_bottom_sheet.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> with TickerProviderStateMixin {

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<Map<String, dynamic>> _posts = [];
  bool _isLoadingPosts = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _postsPerPage = 10;
  bool _hasMorePosts = true;

  int unreadMessageCount = 12;
  bool hasUnreadMessages = true;

  String _currentLoction = '';
  bool _isUpdatingLocation = false;

  bool _isCategoryBarVisible = true;
  double _lastScrollOffset = 0.0;
  final double _scrollThreshold = 10.0;

  bool _isSearching = false;
  List<Map<String, dynamic>> _originalPosts = [];

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

    _listenToNotifications();
    _initializeSocketService();
  }

  Future<void> _initializeSocketService() async {
    try {
      final socketService = SocketService.instance;
      await socketService.initialize();
      
      // Setup listeners for live updates
      _setupSocketListeners();
    } catch (e) {
      //
    }
  }

  void _setupSocketListeners() {
    final socketService = SocketService.instance;
    
    // Listen for live post updates that affect the feed
    socketService.addEventListener('post_like_updated', _onPostLiveUpdate);
    socketService.addEventListener('post_comment_added', _onPostLiveUpdate);
    
    // Listen for new posts being created
    socketService.addEventListener('new_post_created', _onNewPostCreated);
    
    // Listen for post updates/edits
    socketService.addEventListener('post_updated', _onPostUpdated);
    
    // Listen for post deletions
    socketService.addEventListener('post_deleted', _onPostDeleted);
  }

  void _onPostLiveUpdate(dynamic data) {
    try {
      if (mounted) {
        final postId = data['postId'];
        if (postId != null) {
          // Find the post in current posts list and update it
          final postIndex = _posts.indexWhere((post) => post['id'] == postId);
          if (postIndex != -1) {
            setState(() {
              // Update like count if available
              if (data['likesCount'] != null) {
                _posts[postIndex]['initialLikeCount'] = data['likesCount'];
              }
              
              // Update comment count if available
              if (data['totalComments'] != null) {
                _posts[postIndex]['commentCount'] = data['totalComments'];
              }
              
              // Update likes array if available
              if (data['likes'] != null) {
                _posts[postIndex]['likes'] = List<Map<String, dynamic>>.from(data['likes']);
              }
            });

          }
        }
      }
    } catch (e) {
      //
    }
  }

  void _onNewPostCreated(dynamic data) {
    try {
      if (mounted && !_isSearching) {
        final newPostData = data['post'];
        if (newPostData != null) {
          // Format the new post for display
          _formatAndAddNewPost(newPostData);
        }
      }
    } catch (e) {
      //
    }
  }

  void _onPostUpdated(dynamic data) {
    try {
      if (mounted) {
        final postId = data['postId'];
        final updatedPost = data['updatedPost'];
        
        if (postId != null && updatedPost != null) {
          final postIndex = _posts.indexWhere((post) => post['id'] == postId);
          if (postIndex != -1) {
            // Re-format the updated post and replace it in the list
            _formatAndUpdatePost(postIndex, updatedPost);
          }
        }
      }
    } catch (e) {
      //
    }
  }

  void _onPostDeleted(dynamic data) {
    try {
      if (mounted) {
        final postId = data['postId']?.toString();
        if (postId != null && postId.isNotEmpty) {
          final initialLength = _posts.length;
          
          setState(() {
            // Remove the deleted post and ensure no duplicates remain
            _posts.removeWhere((post) => post['id']?.toString() == postId);
          });
          
          final finalLength = _posts.length;
          final removedCount = initialLength - finalLength;


        } else {

        }
      }
    } catch (e) {
      //
    }
  }

  // Helper method to format and add new post to the beginning of feed
  Future<void> _formatAndAddNewPost(Map<String, dynamic> backendPost) async {
    try {
      final formattedPost = await PostDataService.formatPostForWidget(backendPost);
      
      setState(() {
        // Add to the beginning of the list (newest first)
        _posts.insert(0, formattedPost);
        
        // Optionally limit the number of posts to prevent memory issues
        if (_posts.length > 100) {
          _posts.removeLast();
        }
      });
      
      // Show a subtle notification that a new post was added
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New post added to feed'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );
      }
    } catch (e) {
      //
    }
  }

  // Helper method to format and update existing post
  Future<void> _formatAndUpdatePost(int postIndex, Map<String, dynamic> updatedBackendPost) async {
    try {
      final formattedPost = await PostDataService.formatPostForWidget(updatedBackendPost);
      
      setState(() {
        _posts[postIndex] = formattedPost;
      });
    } catch (e) {
      //
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    
    // Clean up socket listeners
    final socketService = SocketService.instance;
    socketService.removeEventListener('post_like_updated', _onPostLiveUpdate);
    socketService.removeEventListener('post_comment_added', _onPostLiveUpdate);
    socketService.removeEventListener('new_post_created', _onNewPostCreated);
    socketService.removeEventListener('post_updated', _onPostUpdated);
    socketService.removeEventListener('post_deleted', _onPostDeleted);
    
    super.dispose();
  }

  void _listenToNotifications() {
    NotificationService.onNotificationTap.listen((response) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification tapped: ${response.payload}')),
        );
      }
    });
  }

  Future<void> _searchPosts() async {
    final query = _searchController.text.trim();

    // If search is empty, restore original posts
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoadingPosts = true;
    });

    try {
      // Store original posts if not already stored
      if (_originalPosts.isEmpty && _posts.isNotEmpty) {
        _originalPosts = List.from(_posts);
      }

      final searchResults = await PostDataService.searchPostsByContent(query);

      if (searchResults.isNotEmpty) {
        // Format all matching posts
        final formattedPosts = await Future.wait(
          searchResults.map((post) => PostDataService.formatPostForWidget(post)),
        );

        setState(() {
          _posts = formattedPosts;
          _isLoadingPosts = false;
        });
      } else {
        setState(() {
          _posts = [];
          _isLoadingPosts = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No posts found matching your search'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      if (_originalPosts.isNotEmpty) {
        _posts = List.from(_originalPosts);
        _originalPosts.clear();
      }
    });
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

      // Format all posts asynchronously
      final formattedPosts = await Future.wait(
          newPosts.map((post) => PostDataService.formatPostForWidget(post))
      );

      setState(() {
        if (refresh) {
          _posts = formattedPosts;
        } else {
          _posts.addAll(formattedPosts);
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
    // Find the post in the list
    final postIndex = _posts.indexWhere((post) => post['id'] == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(
        initialComments: post['comments'] ?? [],
        postId: postId,
        onCommentsUpdated: (updatedComments) {
          // Update the post's comments in the local state
          setState(() {
            _posts[postIndex]['comments'] = updatedComments;
            _posts[postIndex]['commentCount'] = updatedComments.length;
            
            // Update hasUserCommented flag if current user is in comments
            final currentUserId = SocketService.instance.currentUserId;
            if (currentUserId != null) {
              _posts[postIndex]['hasUserCommented'] = updatedComments.any(
                (comment) => comment['userId']?.toString() == currentUserId.toString()
              );
            }
          });
        },
      ),
    );
  }

  void _handleShare(String postId) {
    // Handle share functionality
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
              onTap: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          MessagesScreen(),
                      transitionsBuilder: (context, animation,
                          secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0); // Start from right
                        const end = Offset.zero; // End at current position
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve),
                        );

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    )
                );
              },
              customBorder: const CircleBorder(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomIconButton(
                    iconData: Iconsax.sms_notification_copy,
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 44,
                    height: 44,
                    size: 24,
                    iconColor: Colors.white,
                  ),
                  // Message indicator badge
                  if (hasUnreadMessages) // Replace with your condition
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadMessageCount > 9 ? '9+' : unreadMessageCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]
      ),
      body: Column(
        children: [
          _WidgetSearchBar(
            isCategoryBarVisible: _isCategoryBarVisible,
            searchController: _searchController,
            onSearch: _searchPosts,
            onClear: _clearSearch,
          ),
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
                      key: ValueKey('post_${post['id']}'), // Add unique key to prevent widget recycling
                      postId: post['id'],
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
                      isLikedByCurrentUser: post['isLikedByCurrentUser'] ?? false,
                      likes: post['likes'] ?? [],
                      onCommentsUpdated: (updatedComments) {
                        // Find the correct post by ID instead of using index
                        final postIndex = _posts.indexWhere((p) => p['id'] == post['id']);
                        if (postIndex != -1) {
                          setState(() {
                            _posts[postIndex]['comments'] = updatedComments;
                            _posts[postIndex]['commentCount'] = updatedComments.length;
                          });
                        }
                      }, bRadius: 12,
                      popupMenuItemIcon: Iconsax.save_add_copy,
                      options: [
                        PopupMenuOption(
                            title: 'Save',
                            icon: Iconsax.save_add_copy,
                            onTap: () => HiveService.savePostId(post['id']),
                            textColor: Theme.of(context).colorScheme.inverseSurface
                        ),
                        PopupMenuOption(
                            title: 'Share',
                            icon: Iconsax.share_copy,
                            onTap: (){},
                            textColor: Theme.of(context).colorScheme.inverseSurface
                        ),
                        PopupMenuOption(
                            title: 'Translate',
                            icon: Iconsax.translate_copy,
                            onTap: (){},
                            textColor: Theme.of(context).colorScheme.inverseSurface
                        ),
                      ],
                      iconSize: 24,
                      //popupMenuItemIconColor: Theme.of(context).colorScheme.inverseSurface,
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
  final TextEditingController searchController;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;

  const _WidgetSearchBar({
    required this.isCategoryBarVisible,
    required this.searchController,
    this.onSearch,
    this.onClear,
  });

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
                      controller: searchController,
                      obscureText: false,
                      prefixIconData: const Icon(Iconsax.search_status_1_copy),
                      hintText: 'Search posts...',
                      onSubmitted: (_) => onSearch?.call(),
                      suffixIconData: searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: onClear,
                      )
                          : null,
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