import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/values/color.dart';
import 'package:workie/services/add_skills_service.dart';

class AddSkillsPage extends StatefulWidget {
  final ValueChanged<bool>? onSkillsChanged; // <-- Add this callback

  const AddSkillsPage({super.key, this.onSkillsChanged});

  @override
  State<AddSkillsPage> createState() => AddSkillsPageState();
}

class AddSkillsPageState extends State<AddSkillsPage> {
  final int maxSkills = 15;
  final TextEditingController _skillController = TextEditingController();

  List<String> selectedSkills = [];
  bool isLoading = true;
  String? errorMessage;

  List<String> suggestedSkills = [
    // Masonry & Construction Work
    'Bricklaying',
    'Concrete Work',

    // Carpentry & Wood Work
    'Furniture Making',
    'Door and Window Installation',

    // Welding & Metal Fabrication
    'Arc Welding',
    'Metal Gate Fabrication',

    // Painting & Finishing Work
    'Wall Painting',
    'Wood Polishing',

    // Tile & Flooring Work
    'Tile Laying',
    'Floor Finishing',
  ];


  void _notifyParent() {
    widget.onSkillsChanged?.call(selectedSkills.isNotEmpty);
  }

  void _addSkill(String skill) {
    if (selectedSkills.length >= maxSkills) return;
    setState(() {
      selectedSkills.add(skill);
      _removeSuggestedSkill(skill);
    });
    _skillController.clear();
    _notifyParent();
  }

  void _removeSuggestedSkill(String skill) {
    suggestedSkills.removeWhere((s) => s.toLowerCase() == skill.toLowerCase());
  }

  void _removeSkill(String skill) {
    setState(() {
      selectedSkills.remove(skill);
      _addBackToSuggested(skill);
    });
    _notifyParent();
  }

  void _addBackToSuggested(String skill) {
    // Add back to suggested if it was in the original suggested list
    final originalSuggested = [
      // Masonry & Construction Work
      'Bricklaying',
      'Concrete Work',

      // Carpentry & Wood Work
      'Furniture Making',
      'Door and Window Installation',

      // Welding & Metal Fabrication
      'Arc Welding',
      'Metal Gate Fabrication',

      // Painting & Finishing Work
      'Wall Painting',
      'Wood Polishing',

      // Tile & Flooring Work
      'Tile Laying',
      'Floor Finishing',
    ];
    
    if (originalSuggested.any((s) => s.toLowerCase() == skill.toLowerCase()) &&
        !suggestedSkills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
      suggestedSkills.add(skill);
    }
  }

  void _onSkillInput(String value) {
    if (value.trim().isEmpty) return;
    if (selectedSkills.length >= maxSkills) return;
    if (selectedSkills.contains(value.trim())) return;
    setState(() {
      selectedSkills.add(value.trim());
    });
    _skillController.clear();
    _notifyParent();
  }

  @override
  void initState() {
    super.initState();
    _loadExistingSkills();
  }

  Future<void> _loadExistingSkills() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Get current user ID
      String? userId = await AddSkillsService.getCurrentUserId();
      
      if (userId != null) {
        // Fetch existing skills from database
        List<Map<String, dynamic>>? userSkills = await AddSkillsService.getUserSkills(userId);
        
        if (userSkills != null) {
          setState(() {
            // Extract skill names from the response
            selectedSkills = userSkills
                .map((skill) => skill['name']?.toString() ?? '')
                .where((name) => name.isNotEmpty)
                .toList();
            
            // Remove existing skills from suggested skills
            for (String selectedSkill in selectedSkills) {
              _removeSuggestedSkill(selectedSkill);
            }
            
            isLoading = false;
          });
          
          // Notify parent after loading
          _notifyParent();
        } else {
          setState(() {
            isLoading = false;
          });
          _notifyParent();
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _notifyParent();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load existing skills: $e';
      });
      _notifyParent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: isLoading 
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                        IconButton(
                          onPressed: _loadExistingSkills,
                          icon: Icon(Icons.refresh, color: Colors.red, size: 20),
                          tooltip: 'Retry',
                        ),
                      ],
                    ),
                  ),
                Text(
                  'Nearly there! Add the work skills you know',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2
                  ),
                ),
            const SizedBox(height: 12),
            Text(
              'Your skills show clients what jobs you can do and help us suggest work for you. You can add, remove, or type new skills anytime.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSilver,
                height: 1.3
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your skills',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedSkills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
                        backgroundColor: Colors.transparent,
                        shape: StadiumBorder(
                          side: BorderSide(color: Theme.of(context).colorScheme.inverseSurface, width: 1.5),
                        ),
                        deleteIcon: Icon(Icons.close, color: Theme.of(context).colorScheme.inverseSurface),
                        onDeleted: () => _removeSkill(skill),
                      );
                    }).toList(),
                  ),
                  if (selectedSkills.length < maxSkills)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: _skillController,
                        style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
                        decoration: InputDecoration(
                          hintText: 'Enter skills here',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                              onPressed:() {
                                _onSkillInput(
                                    _skillController.text.trim()
                                  );
                                },
                              icon: Icon(
                                  Iconsax.save_add,
                                color: Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.4),
                              )
                          )
                        ),
                        onSubmitted: _onSkillInput,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Max $maxSkills skills',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Suggested skills',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: suggestedSkills.map((skill) {
                return GestureDetector(
                  onTap: selectedSkills.length < maxSkills
                      ? () => _addSkill(skill)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.inverseSurface, width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Theme.of(context).colorScheme.inverseSurface, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          skill,
                          style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
                const SizedBox(height: 32),
              ],
            ),
          ),
    );
  }
}