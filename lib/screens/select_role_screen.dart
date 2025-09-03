import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:workie/pofile_setup/collect_info/client/add_personal_details_page.dart';
import 'package:workie/pofile_setup/collect_info/worker/init_page.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String selectedRole = 'job_seeker'; // 'job_seeker' or 'employer'
  bool _isSaving = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  // Initialize video player
  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/video/background.mp4');
      await _videoController!.initialize();

      // Set video to loop and play
      _videoController!.setLooping(true);
      _videoController!.play();

      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing video: $e');
      }
      // Video failed to load, you can show a fallback image here
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_videoController != null && _isVideoInitialized) {
      _videoController!.play();
    }
  }

  _navigateToHomePage() async {

    await Future.delayed(const Duration(seconds: 3));
    if (mounted && selectedRole == 'job_seeker') {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const InitPage())
      );
    } else if (mounted && selectedRole == 'employer') {
      // Navigate to employer page
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddPersonalDetailsPage())
      );
    }
    setState(() {
      _isSaving = false;
    });
    _videoController?.pause();
  }

  // Save string to SharedPreferences
  Future<void> _saveUserRole(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('USER_ROLE', value);
  }

  Future<void> _retrieveUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('USER_ROLE') ?? 'job_seeker';
    setState(() {
      selectedRole = role;
    });
  }

  void _onRoleSelected(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video background
          _VideoBackground(
            controller: _videoController,
            isInitialized: _isVideoInitialized,
          ),
          // Content overlay
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Title section - now closer to bottom
                Container(
                  padding: EdgeInsets.only(top: 36),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 25,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const _TitleSection(),
                      const SizedBox(height: 24),
                      // Bottom buttons section
                      _BottomButtonsSection(
                        selectedRole: selectedRole,
                        onRoleSelected: _onRoleSelected,
                      ),
                      const SizedBox(height: 30),
                      // Continue button
                      _ContinueButton(
                        onPressed: () {
                          setState(() {
                            _isSaving = true;
                          });
                          _navigateToHomePage();
                          _saveUserRole(selectedRole);
                          _retrieveUserRole();
                        },
                        isSaving: _isSaving,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Video background widget
class _VideoBackground extends StatelessWidget {
  final VideoPlayerController? controller;
  final bool isInitialized;

  const _VideoBackground({
    required this.controller,
    required this.isInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Fallback background color while video loads
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
          // Video player
          if (isInitialized && controller != null)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller!.value.size.width,
                  height: controller!.value.size.height,
                  child: VideoPlayer(controller!),
                ),
              ),
            ),
          // Dark overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Title and subtitle section
class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'What describes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2
          ),
        ),
        Text(
          'you best?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Pick an option to continue. You can always switch or add another later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// Bottom buttons section
class _BottomButtonsSection extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleSelected;

  const _BottomButtonsSection({
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        children: [
          Expanded(
            child: _RoleButton(
              tlRadius: 36,
              blRadius: 36,
              trRadius: 0,
              brRadius: 0,
              role: 'employer',
              title: 'I\'m a Client',
              isSelected: selectedRole == 'employer',
              onTap: () => onRoleSelected('employer'),
            ),
          ),
          //const SizedBox(width: 16),
          Expanded(
            child: _RoleButton(
              tlRadius: 0,
              blRadius: 0,
              trRadius: 36,
              brRadius: 36,
              role: 'job_seeker',
              title: 'I\'m a Worker',
              isSelected: selectedRole == 'job_seeker',
              onTap: () => onRoleSelected('job_seeker'),
            ),
          ),
        ],
      ),
    );
  }
}

// Individual role button
class _RoleButton extends StatelessWidget {
  final String role;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final double tlRadius;
  final double trRadius;
  final double blRadius;
  final double brRadius;

  const _RoleButton({
    required this.role,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.tlRadius,
    required this.trRadius,
    required this.blRadius,
    required this.brRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(tlRadius),
            topRight: Radius.circular(trRadius),
            bottomLeft: Radius.circular(blRadius),
            bottomRight: Radius.circular(brRadius)
          ),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Continue button
class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSaving;

  const _ContinueButton({
    required this.onPressed,
    required this.isSaving
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E6BF5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSaving)
                Transform.scale(
                  scale: 0.45, // Makes it half the size
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 9,
                      color: Colors.white,
                      strokeCap: StrokeCap.square,
                    ),
                  ),
                ),
              Text(
                'Let\'s Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}