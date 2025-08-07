import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/models/post_model.dart';
import 'package:workie/widgets/custom_icon_button.dart';
import 'package:workie/widgets/custom_textfield.dart';
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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final difference = currentOffset - _lastScrollOffset;

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
                  const Text(
                    'New York, USA',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    customBorder: const CircleBorder(),
                    child: const Icon(
                      Iconsax.arrow_down_1_copy,
                      size: 20,
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

          // Main content - Now scrollable
          Expanded(
            child: Container(
              color: Theme
                  .of(context)
                  .colorScheme
                  .surface,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    PostCardModel(
                      profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
                      userName: 'Alex Johnson',
                      userTitle: 'Senior Software Engineer at TechCorp',
                      timeAgo: '2h',
                      isVerified: true,
                      shortContent: 'Excited to share that our team just launched a new feature that reduces load times by 40%! 🚀',
                      fullContent: '\n\nBuilding scalable solutions requires patience, collaboration, and continuous learning. Here are 3 key lessons from this project:\n\n1️⃣ Performance optimization starts with understanding your users\n2️⃣ Small improvements compound into significant results\n3️⃣ Team collaboration beats individual brilliance every time\n\nWhat\'s your biggest learning from recent projects? Share in the comments! 👇',
                      postImageUrls: ['https://images.pexels.com/photos/11427444/pexels-photo-11427444.jpeg',
                        'https://images.pexels.com/photos/1249611/pexels-photo-1249611.jpeg',
                        'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=600&h=300&fit=crop',
                        'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=600&h=300&fit=crop',
                        'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=600&h=300&fit=crop',
                        'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=600&h=300&fit=crop',

                      ],
                      hashtags: const [
                        'WebDevelopment',
                        'Performance',
                        'TeamWork',
                        'TechInnovation'
                      ],
                      initialLikeCount: 127,
                      commentCount: 23,
                      shareCount: 8,
                      onLike: () {},
                      onComment: () {},
                      onShare: () {},
                      comments: [
                        {
                          'commentedUserProfileImgUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Mrbeast_in_2025_1.png/500px-Mrbeast_in_2025_1.png',
                          'commentedUserName': 'John Doe',
                          'comment': 'This is a great post!',
                          'ísVerified': false,
                          'timestamp': '2h ago',
                        },
                        {
                          'commentedUserProfileImgUrl': 'https://i.pinimg.com/474x/0c/f1/2d/0cf12d2c4ac1fc6a27e51e9b3c5e2db0.jpg',
                          'commentedUserName': 'Sarah Wilson',
                          'comment': 'I completely agree with this.',
                          'ísVerified': true,
                          'timestamp': '1h ago',
                        },
                        {
                          'commentedUserProfileImgUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/The_rock_read_one_%28cropped%29.jpg/500px-The_rock_read_one_%28cropped%29.jpg',
                          'commentedUserName': 'Mike Johnson',
                          'comment': 'Thanks for sharing this information.',
                          'ísVerified': false,
                          'timestamp': '30m ago',
                        },
                      ],
                    ),

                    PostCardModel(
                      profileImageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
                      userName: 'Mike Chen',
                      userTitle: 'Data Scientist at Analytics Pro',
                      timeAgo: '6h',
                      isVerified: true,
                      shortContent: 'Excited to share insights from our latest machine learning model! 🤖📊',
                      fullContent: '\n\nData science is not just about algorithms - it\'s about solving real problems.\n\nOur new model achieved:\n\n📈 95% accuracy improvement\n⚡ 60% faster processing\n💰 30% cost reduction\n🎯 Better user predictions\n\nThe key was understanding the business context, not just the technical metrics.',
                      postImageUrls: ['https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=600&h=300&fit=crop'],
                      hashtags: const ['DataScience', 'MachineLearning', 'AI', 'Analytics'],
                      initialLikeCount: 156,
                      commentCount: 31,
                      shareCount: 12,
                      onLike: () {},
                      onComment: () {},
                      onShare: () {}, comments: [],
                    ),

                    PostCardModel(
                      profileImageUrl: 'https://i.pinimg.com/474x/0c/f1/2d/0cf12d2c4ac1fc6a27e51e9b3c5e2db0.jpg',
                      userName: 'Sarah Wilson',
                      userTitle: 'UX Designer at DesignCorp',
                      timeAgo: '4h',
                      isVerified: true,
                      shortContent: 'Just finished designing a new mobile app interface! Clean, minimal, and user-friendly. 📱✨',
                      fullContent: '\n\nDesign is not just what it looks like and feels like. Design is how it works.\n\nKey principles I followed:\n\n🎯 User-centered design\n🎨 Consistent visual hierarchy\n⚡ Optimized for performance\n🔍 Accessibility first\n\nWhat design trends are you excited about in 2025?',
                      postImageUrls: ['https://images.unsplash.com/photo-1561070791-2526d30994b5?w=600&h=300&fit=crop'],
                      hashtags: const ['UXDesign', 'MobileApp', 'UI', 'DesignTrends'],
                      initialLikeCount: 89,
                      commentCount: 15,
                      shareCount: 5,
                      onLike: () {},
                      onComment: () {},
                      onShare: () {}, comments: [],
                    ),
                    // Add more PostCardModel widgets here if needed
                    // They will all be scrollable within this area
                  ],
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