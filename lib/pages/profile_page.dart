import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workie/pages/components/cover_pic_bottomsheet.dart';
import 'package:workie/pages/components/profile_pic_bottomsheet.dart';
import 'package:workie/values/color.dart';
import '../services/pull_data/get_user_data.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

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

  @override
  void initState() {
    _loadUserRole();
    _getUserData();
    super.initState();
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

  Future<void> _refreshData() async {
    await _loadUserRole();
    await _getUserData();
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
                    // Edit button for profile picture
                    _profileImagePicker(context),
                  ],
                ),
              ),
              // Profile content section
              _profileContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Padding _profileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkGrey
              )
          ),
          const SizedBox(height: 8),
          /*Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Text(
                    '23 Works'
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 18),
                    const SizedBox(width: 4),
                    Text(
                        '4.8 (23 Reviews)'
                    ),
                  ],
                ),
              )
            ],
          )*/
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
                    if (kDebugMode) {
                      print('New image attached with scale: $scale, angle: $angle');
                    }

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

  Positioned _editProfileButton() {
    return Positioned(
      right: 16,
      top: 125, // Position to overlap background
      child: InkWell(
        child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4E6BF5),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Iconsax.user_edit_copy, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  )
                ],
              ),
            )
        ),
      ),
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