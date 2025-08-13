import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workie/pofile_setup/verification/worker/verification_start_page_worker.dart';
import 'package:workie/screens/main_screen.dart';
import 'package:workie/values/color.dart';
import '../values/dimension.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String selectedRole = 'job_seeker'; // 'job_seeker' or 'employer'
  bool _isSaving = false;

  // Navigate to Role Selection
  _navigateToHomePage() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const WorkerVerificationStartPage())
      );
    }
    setState(() {
      _isSaving = false;
    });
  }

  // Save string to SharedPreferences
  Future<void> _saveUserRole(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('USER_ROLE', value);
  }

  void _onRoleSelected(String role) {
    setState(() {
      selectedRole = (selectedRole == role ? null : role)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              ),
              child: const Text(
                'SKIP',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              const _TitleSection(),
              const SizedBox(height: 48),
              _RoleSelectionSection(
                selectedRole: selectedRole,
                onRoleSelected: _onRoleSelected,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              _ContinueButton(
                onPressed: () {
                  setState(() {
                    _isSaving = true;
                  });
                  _navigateToHomePage();
                  _saveUserRole(selectedRole);
                }, isSaving: _isSaving,
              ),
            ],
          ),
        ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What are you ',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold
              ),
            ),
            Text(
              'Looking',
              style: TextStyle(
                  fontSize: 28,
                  color: const Color(0xFF4E6BF5),
                  fontWeight: FontWeight.bold
              ),
            ),
            Text(
              ' for?',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                'assets/icon/undraw_predictive-analytics_6vi1.svg',
                width: 120,
                height: 120,
              ),
              SvgPicture.asset(
                'assets/icon/undraw_business-deal_nx2n.svg',
                width: 120,
                height: 120,
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          textAlign: TextAlign.center,
          'Are you looking for a New Job or\nlooking for New Employee?',
          style: TextStyle(
              fontSize: 18
          ),
        ),
      ],
    );
  }
}

// Role selection cards section
class _RoleSelectionSection extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleSelected;

  const _RoleSelectionSection({
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
            child: _RoleCard(
              role: 'job_seeker',
              title: 'Find Jobs',
              description: 'It\'s easy to find your jobs here with us.',
              iconAsset: Iconsax.briefcase_copy,
              iconPadding: 16.0,
              isSelected: selectedRole == 'job_seeker',
              onTap: () => onRoleSelected('job_seeker'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _RoleCard(
              role: 'employer',
              title: 'Hire Workers',
              description: 'It\'s easy to find skilled workers here with us.',
              iconAsset: Iconsax.user_copy,
              iconPadding: 18.0,
              isSelected: selectedRole == 'employer',
              onTap: () => onRoleSelected('employer'),
            ),
          ),
        ],
      ),
    );
  }
}

// Individual role card
class _RoleCard extends StatelessWidget {
  final String role;
  final String title;
  final String description;
  final IconData iconAsset;
  final double iconPadding;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.iconPadding,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4E6BF5) : const Color(0xFF4E6BF5).withValues(alpha: 0.5),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF4E6BF5).withValues(alpha: 0),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoleIcon(
                iconAsset: iconAsset,
                iconPadding: iconPadding,
                isSelected: isSelected,
              ),
              const SizedBox(height: 16),
              _RoleTitle(
                title: title,
                isSelected: isSelected,
              ),
              const SizedBox(height: 4),
              _RoleDescription(
                description: description,
                isSelected: isSelected,
              ),
              if (isSelected) ...[
                const SizedBox(height: 12),
                const _SelectionIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Role card icon
class _RoleIcon extends StatelessWidget {
  final IconData iconAsset;
  final double iconPadding;
  final bool isSelected;

  const _RoleIcon({
    required this.iconAsset,
    required this.iconPadding,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4E6BF5) : const Color(0xFF4E6BF5).withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(iconPadding),
        child: Icon(iconAsset, size: 36),
      ),
    );
  }
}

// Role card title
class _RoleTitle extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _RoleTitle({
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: TextAlign.center,
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        color: isSelected ? const Color(0xFF4E6BF5) : Theme.of(context).colorScheme.inversePrimary,
      ),
    );
  }
}

// Role card description
class _RoleDescription extends StatelessWidget {
  final String description;
  final bool isSelected;

  const _RoleDescription({
    required this.description,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 13,
        color: isSelected ? const Color(0xFF4E6BF5) : AppColors.textSilver,
      ),
    );
  }
}

// Selection indicator (checkmark)
class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Iconsax.tick_circle,
      color: Colors.green,
      size: 30,
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
      padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault * 3),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E6BF5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
                'Continue',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}