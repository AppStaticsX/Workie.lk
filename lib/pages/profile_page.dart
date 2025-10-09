import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workie/pages/components/cover_pic_bottomsheet.dart';
import 'package:workie/pages/components/education_detail_model.dart';
import 'package:workie/pages/components/profile_page_post_helper.dart';
import 'package:workie/pages/components/profile_pic_bottomsheet.dart';
import '../services/pull_data/get_user_data.dart';
import '../services/pull_data/current_user_posts.dart';
import '../models/post_model.dart';
import '../services/pull_data/post_data_service.dart';
import '../services/education_data_service.dart';
import '../models/education_model.dart';
import '../services/hive_service.dart';
import '../services/get_user_skills.dart';

class ProfileTabPage extends StatefulWidget {

  final VoidCallback? onCreatePost;

  const ProfileTabPage({
    super.key,
    this.onCreatePost
  });

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  String selectedRole = '';
  String _fullName = '';
  String _userCity = '';
  String _userProvince = '';
  String _userAvatarUrl = '';
  String _userTitle = '';
  String _userCoverImageUrl = '';

  String _selectedChipLable = 'Posts';

  // Add this variable to track selected chip
  int selectedChipIndex = 0;
  final List<String> chipLabels = ['Posts', 'Videos', 'Photos', 'Saved'];

  // Add these variables for posts
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoadingPosts = false;
  int _totalPostsCount = 0;

  // Add these variables for education
  List<EducationModel> _userEducation = [];
  Map<String, String> _schoolLogos = {};
  bool _isLoadingEducation = false;

  // Add these variables for saved posts
  List<Map<String, dynamic>> _savedPosts = [];
  bool _isLoadingSavedPosts = false;

  // Add these variables for skills
  List<Map<String, dynamic>> _userSkills = [];
  bool _isLoadingSkills = false;

  @override
  void initState() {
    _loadUserRole();
    _getUserData();
    _loadUserPosts();
    _loadEducationData();
    _loadSavedPosts();
    _loadUserSkills();
    super.initState();
  }

  Future<void> _loadUserPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final posts = await CurrentUserPostsService.getCurrentUserPostsFormatted(
        page: 1,
        limit: 1, // Only load the latest post
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

  Future<void> _getUserData() async {
    final userData = await GetUserDataService.getCurrentUserData();
    if (userData != null) {
      setState(() {
        _fullName = userData.fullName;
        _userCity = userData.address!.city!;
        _userProvince = userData.address!.state!;
        _userTitle = userData.profile!.title!;
      });
    }

    final userPhotos = await GetUserDataService.getCurrentUserPhotos();
    if (userPhotos != null) {
      setState(() {
        _userAvatarUrl = userPhotos['profilePicture']!;
        _userCoverImageUrl = userPhotos['coverPhoto']!;
      });
    }
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('USER_ROLE') ?? 'No data saved';
    });
  }

  Future<void> _loadEducationData() async {
    setState(() {
      _isLoadingEducation = true;
    });

    try {
      final result = await EducationDataService.getUserEducationDataWithLogos();
      final educationData = result['education'] as List<EducationModel>;
      final logos = result['logos'] as Map<String, String>;

      setState(() {
        _userEducation = educationData;
        _schoolLogos = logos;
        _isLoadingEducation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEducation = false;
        _userEducation = [];
        _schoolLogos = {};
      });
    }
  }

  Future<void> _loadUserSkills() async {
    setState(() {
      _isLoadingSkills = true;
    });

    try {
      final result = await GetUserSkillsService.getCurrentUserSkills();
      if (result['success'] == true && result['skills'] != null) {
        setState(() {
          _userSkills = List<Map<String, dynamic>>.from(result['skills']);
          _isLoadingSkills = false;
        });
      } else {
        setState(() {
          _userSkills = [];
          _isLoadingSkills = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error loading user skills: $e');
      setState(() {
        _isLoadingSkills = false;
        _userSkills = [];
      });
    }
  }

  Future<void> _loadSavedPosts() async {
    setState(() {
      _isLoadingSavedPosts = true;
    });

    try {
      // Get saved post IDs from Hive
      final savedPostIds = await HiveService.getSavedPostIds();

      if (savedPostIds.isEmpty) {
        setState(() {
          _savedPosts = [];
          _isLoadingSavedPosts = false;
        });
        return;
      }

      List<Map<String, dynamic>> formattedSavedPosts = [];

      try {
        // Try to fetch posts using batch method first
        final savedPostsFromBackend = await PostDataService.getPostsByIds(savedPostIds);

        // Format posts for UI
        for (var post in savedPostsFromBackend) {
          try {
            if (post.isNotEmpty) {
              final formattedPost = await PostDataService.formatSavedPostForWidget(post);
              formattedSavedPosts.add(formattedPost);
            }
          } catch (e) {
            // Skip this post instead of adding an error template
          }
        }
      } catch (e) {
        // Fallback: Try to fetch posts individually
        for (String savedId in savedPostIds) {
          try {
            final post = await PostDataService.getPostById(savedId);
            if (post != null) {
              try {
                final formattedPost = await PostDataService.formatSavedPostForWidget(post);
                formattedSavedPosts.add(formattedPost);
              } catch (formatError) {
                // Skip malformed posts instead of adding error template
              }
            } else {
              // Remove non-existent post from saved posts
              await HiveService.removePostId(savedId);
            }
          } catch (postError) {
            //
          }
        }

        // If individual fetch also fails, try searching through feed posts
        if (formattedSavedPosts.isEmpty) {
          try {
            final feedPosts = await PostDataService.getFeedPosts(page: 1, limit: 50);

            for (String savedId in savedPostIds) {
              try {
                final foundPost = feedPosts.firstWhere(
                      (post) => post['_id'] == savedId,
                  orElse: () => {},
                );

                if (foundPost.isNotEmpty) {
                  try {
                    final formattedPost = await PostDataService.formatSavedPostForWidget(foundPost);
                    formattedSavedPosts.add(formattedPost);
                  } catch (formatError) {
                    // Skip malformed posts instead of adding error template
                  }
                }
              } catch (searchError) {
                //
              }
            }
          } catch (feedError) {
            //
          }
        }
      }

      setState(() {
        _savedPosts = formattedSavedPosts;
        _isLoadingSavedPosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSavedPosts = false;
        _savedPosts = [];
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserRole();
    await _getUserData();
    await _loadUserPosts();
    await _loadEducationData();
    await _loadSavedPosts();
    await _loadUserSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: const Color(0xFF4E6BF5),
        elevation: 0,
        leading: Icon(Iconsax.user_copy, size: 26, color: Colors.white,),
        title: Text(
          'My Profile',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to settings
            },
            icon: const Icon(Iconsax.setting, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background image container
                    _coverImage(),
                    // Edit button for background
                    _coverImageEditButton(),
                    // Profile picture
                    _profileImage(context),

                    _editProfileButton(),
                    _profileCompletion(),
                    // Edit button for profile picture
                    _profileImagePicker(context),
                  ],
                ),
              ),
              // Profile content section
              _profileContent(context),
              _statsContent(),
              const SizedBox(height: 12),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.secondary,
                height: 12,
              ),
              _myMediaContents(context),
              const SizedBox(height: 12),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.secondary,
                height: 12,
              ),
              _educationSection(context),
              const SizedBox(height: 12),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.secondary,
                height: 12,
              ),
              _skillsSection(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _skillsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                  'Top Skills',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IconButton(
                  onPressed: (){
                    _loadUserSkills();
                  },
                  icon: Icon(CupertinoIcons.add)
              ),
            )
          ],
        ),
        // Education content
        _buildSkillsContent(),
      ],
    );
  }

  Widget _educationSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                  'Education',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IconButton(
                  onPressed: _navigateToEducationEdit,
                  icon: Icon(CupertinoIcons.add)
              ),
            )
          ],
        ),
        // Education content
        _buildEducationContent(),
      ],
    );
  }

  Widget _buildEducationContent() {
    if (_isLoadingEducation) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userEducation.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                CupertinoIcons.book,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No Education Added',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your education to showcase your qualifications',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _userEducation.map((education) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 8),
          child: EducationDetailModel(
            school: education.school,
            degree: education.course,
            field: education.fieldOfStudy,
            startDate: education.startYear,
            endDate: education.endYear ?? 'Present',
            schoolUrl: _schoolLogos[education.school] ?? 'https://logo.clearbit.com/edu',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillsContent() {
    if (_isLoadingSkills) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userSkills.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                CupertinoIcons.settings,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No Skills Added',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your skills to showcase your talents',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 12.0,
            runSpacing: 12.0,
            children: _userSkills.map((skill) => _buildSkillChip(skill)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(Map<String, dynamic> skill) {
    final skillName = skill['name']?.toString() ?? '';
    final _ = skill['level']?.toString() ?? 'beginner';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.diamonds, size: 18, color: const Color(0xFF36C897)),
          const SizedBox(width: 12),
          Text(
            skillName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }




  Widget _myMediaContents(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'My Posts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5
                      )
                  ),
                  Text(
                    '$_totalPostsCount posts found. 🎉',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        height: 1
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton(
                  onPressed: widget.onCreatePost,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      width: 2,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                  child: Text(
                    'Create-Post',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5
                    ),
                  )
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      _selectedChipLable = chipLabels[i];
                    });

                    // Load saved posts when "Saved" chip is selected
                    if (chipLabels[i] == 'Saved') {
                      _loadSavedPosts();
                    }
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
        const SizedBox(height: 16),
        // Posts content based on selected chip
        _buildPostsContent(),

        // Option 1: Using conditional rendering with if statement
        if (!_isLoadingPosts && _filterPostsByChip().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12)
                  )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => ProfilePagePostHelper(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                      child: Row(
                        children: [
                          Text(
                              'Show All $_selectedChipLable', // Using null-aware operator with fallback
                              style: Theme.of(context).textTheme.titleSmall
                          ),
                          const SizedBox(width: 8),
                          const Icon(CupertinoIcons.arrow_right)
                        ],
                      )
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostsContent() {

    // Show loading indicator for the selected chip
    bool isLoading = selectedChipIndex == 3 ? _isLoadingSavedPosts : _isLoadingPosts;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check if the relevant data source is empty
    bool isEmpty = selectedChipIndex == 3 ? _savedPosts.isEmpty : _userPosts.isEmpty;

    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                selectedChipIndex == 0
                    ? Iconsax.document_text_copy
                    : selectedChipIndex == 1
                    ? Iconsax.video_play_copy
                    : selectedChipIndex == 2
                    ? Iconsax.gallery_copy
                    : Iconsax.bookmark_copy, // For saved posts
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                selectedChipIndex == 0
                    ? 'No posts yet'
                    : selectedChipIndex == 1
                    ? 'No videos yet'
                    : selectedChipIndex == 2
                    ? 'No photos yet'
                    : 'No saved posts yet', // For saved posts
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selectedChipIndex == 3
                    ? 'Save posts to view them here!'
                    : 'Share your first ${chipLabels[selectedChipIndex].toLowerCase()} to get started!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    List<Map<String, dynamic>> filteredPosts = _filterPostsByChip();

    if (filteredPosts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                selectedChipIndex == 1 ? Iconsax.video_play_copy : Iconsax.gallery_copy,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No ${chipLabels[selectedChipIndex].toLowerCase()} yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Show only the first (latest) post from filtered posts
          if (filteredPosts.isNotEmpty) ...[
            if (kDebugMode)
              Text('DEBUG: Rendering PostCardModel for post ID: ${filteredPosts[0]['id']}'),
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: PostCardModel(
                postId: filteredPosts[0]['id'] ?? '',
                profileImageUrl: filteredPosts[0]['profileImageUrl'] ?? '',
                userName: filteredPosts[0]['userName'] ?? '',
                userTitle: filteredPosts[0]['userTitle'] ?? '',
                timeAgo: filteredPosts[0]['timeAgo'] ?? '',
                content: filteredPosts[0]['content'] ?? '',
                mediaUrls: List.from(filteredPosts[0]['mediaUrls'] ?? []),
                hashtags: List<String>.from(filteredPosts[0]['hashtags'] ?? []),
                initialLikeCount: filteredPosts[0]['initialLikeCount'] ?? 0,
                commentCount: filteredPosts[0]['commentCount'] ?? 0,
                shareCount: filteredPosts[0]['shareCount'] ?? 0,
                isVerified: filteredPosts[0]['isVerified'] ?? false,
                comments: List<Map<String, dynamic>>.from(filteredPosts[0]['comments'] ?? []),
                isLikedByCurrentUser: filteredPosts[0]['isLikedByCurrentUser'] ?? false,
                likes: List<Map<String, dynamic>>.from(filteredPosts[0]['likes'] ?? []),
                onLike: () => _handlePostLike(filteredPosts[0]['id']),
                onComment: () => _handlePostComment(filteredPosts[0]['id']),
                onShare: () => _handlePostShare(filteredPosts[0]['id']),
                bRadius: 0,
                popupMenuItemIcon: Iconsax.trash_copy,
                popupMenuItemIconColor: Colors.red,
                options: [
                  PopupMenuOption(
                      title: 'Save',
                      icon: Iconsax.save_add_copy,
                      onTap: () => HiveService.savePostId(filteredPosts[0]['id']),
                      textColor: Theme.of(context).colorScheme.inverseSurface
                  ),
                  PopupMenuOption(
                      title: 'Share',
                      icon: Iconsax.share_copy,
                      onTap: () => _handlePostShare(filteredPosts[0]['id']),
                      textColor: Theme.of(context).colorScheme.inverseSurface
                  ),
                ],
                iconSize: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterPostsByChip() {

    List<Map<String, dynamic>> result;
    switch (selectedChipIndex) {
      case 0: // Posts - show all posts
        result = _userPosts;
        break;
      case 1: // Videos - show only posts with videos
        result = _userPosts.where((post) {
          final mediaUrls = post['mediaUrls'] as List?;
          return mediaUrls?.any((media) => media.type?.toString() == 'MediaType.video') ?? false;
        }).toList();
        break;
      case 2: // Photos - show only posts with images
        result = _userPosts.where((post) {
          final mediaUrls = post['mediaUrls'] as List?;
          return mediaUrls?.any((media) => media.type?.toString() == 'MediaType.image') ?? false;
        }).toList();
        break;
      case 3: // Saved - show saved posts
        result = _savedPosts;
        break;
      default:
        result = _userPosts;
        break;
    }

    return result;
  }

  void _handlePostLike(String postId) async {
    try {
      await PostDataService.toggleLike(postId: postId);
      // Refresh posts to update like status
      await _loadUserPosts();
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

  void _navigateToEducationEdit() {
    // Navigate to education management page or show bottom sheet
    // For now, just refresh the education data
    // You can navigate to the AddEducationPage here
    // Navigator.push(context, MaterialPageRoute(builder: (context) => AddEducationPage()));

    // For now, just refresh education data
    _loadEducationData();
  }

  // Method to refresh saved posts when called from other parts of the app
  void refreshSavedPosts() {
    if (selectedChipIndex == 3) { // Only refresh if currently viewing saved posts
      _loadSavedPosts();
    }
  }

  // Method to force refresh saved posts regardless of current tab
  void forceRefreshSavedPosts() {
    _loadSavedPosts();
  }

  // Method to handle post save/unsave actions from other widgets
  Future<void> handlePostSaveToggle(String postId, bool isSaved) async {
    try {
      if (isSaved) {
        await HiveService.savePostId(postId);
      } else {
        await HiveService.removePostId(postId);
      }

      // Refresh saved posts if currently viewing them
      refreshSavedPosts();
    } catch (e) {
      //
    }
  }

  Widget _statsContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Iconsax.star),
                Text('4.9', style: TextStyle(fontSize: 18),),
                Text('(23 Reviews)', style: TextStyle(fontSize: 14),)
              ],
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.grey.shade300,
            margin: EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Iconsax.briefcase),
                Text('23', style: TextStyle(fontSize: 18),),
                Text('Total Works', style: TextStyle(fontSize: 14),)
              ],
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.grey.shade300,
            margin: EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Iconsax.money),
                Text('50.5K', style: TextStyle(fontSize: 18),),
                Text('Total Earning', style: TextStyle(fontSize: 14),)
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding _profileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and title section
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _fullName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Iconsax.verify)
            ],
          ),
          if (selectedRole == 'job_seeker')
            Text(
                _userTitle,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontSize: 15,
                    height: 1.3
                )
            ),
          const SizedBox(height: 2),
          Text(
              '$_userCity, $_userProvince Province',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              )
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Positioned _profileImagePicker(BuildContext context) {
    return Positioned(
      left: 110, // Position relative to profile picture
      top: 140,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF4E6BF5),
          shape: BoxShape.circle,
          border: Border.all(
            width: 3,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ProfilePicBottomsheet(
                  currentImageUrl: _userAvatarUrl, // Pass current profile image URL
                  closeBottomSheet: () {
                    Navigator.pop(context);
                  },
                  onImageAttached: (file, webBytes, scale, angle) {
                    // Handle the image attachment logic here
                    // You can upload the new image and update the UI
                    // Example: You might want to refresh user data after upload
                    // _getUserData();
                  },
                ),
              ),
            );
          },
          icon: const Icon(
            Iconsax.camera,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Positioned _profileCompletion() {
    return Positioned(
      right: 112,
        top: 116,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Completion'
            ),
            Text(
              '42%',
              style: TextStyle(
                fontSize: 24,
                color: const Color(0xFF36C897),
                fontWeight: FontWeight.bold
              ),
            )
          ],
        )
    );
  }

  Positioned _editProfileButton() {
    return Positioned(
        right: 16,
        top: 125, // Position to overlap background
        child: IconButton(
            onPressed: (){},
            icon: Icon(CupertinoIcons.pencil_outline, size: 32)
        )
    );
  }

  Positioned _profileImage(BuildContext context) {
    return Positioned(
      left: 16,
      top: 54, // Position to overlap background
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 4,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            _userAvatarUrl,
            width: 120, // diameter = 2 * radius
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }


  Positioned _coverImageEditButton() {
    return Positioned(
      top: 8,
      right: 16,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.55, // 50% of screen height
                child: CoverPicBottomsheet(
                  currentImageUrl: _userCoverImageUrl, // Pass current cover image URL
                  closeBottomSheet: () {
                    Navigator.pop(context);
                  },
                  onImageAttached: (file, webBytes) {
                    // Handle the cover image attachment logic here
                    // Example: You might want to refresh user data after upload
                    // _getUserData();
                  },
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.edit,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Container _coverImage() {
    return Container(
      height: 105,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15)),
        image: DecorationImage(
          image: NetworkImage(
              _userCoverImageUrl
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}