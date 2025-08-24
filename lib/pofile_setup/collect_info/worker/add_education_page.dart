import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/pofile_setup/collect_info/worker/components/education_bottomsheet.dart';
import '../../../models/education_model.dart';

class AddEducationPage extends StatefulWidget {
  final Function(bool)? onEducationChanged;

  const AddEducationPage({super.key, this.onEducationChanged});

  @override
  State<AddEducationPage> createState() => _AddEducationPageState();
}

class _AddEducationPageState extends State<AddEducationPage> {
  List<EducationModel> workExperiences = [];

  void _addWorkExperience(EducationModel experience) {
    setState(() {
      workExperiences.add(experience);
    });
    // Notify parent about the change
    if (widget.onEducationChanged != null) {
      widget.onEducationChanged!(workExperiences.isNotEmpty);
    }
  }

  void _editWorkExperience(int index, EducationModel updatedExperience) {
    setState(() {
      workExperiences[index] = updatedExperience;
    });
    // Notify parent about the change
    if (widget.onEducationChanged != null) {
      widget.onEducationChanged!(workExperiences.isNotEmpty);
    }
  }

  void _deleteWorkExperience(int index) {
    setState(() {
      workExperiences.removeAt(index);
    });
    // Notify parent about the change
    if (widget.onEducationChanged != null) {
      widget.onEducationChanged!(workExperiences.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Text(
              'Clients like to know what you know - add your education here.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface
              ),
            ),
            const SizedBox(height: 32),

            // Display work experiences
            if (workExperiences.isNotEmpty) ...[
              ...workExperiences.asMap().entries.map((entry) {
                int index = entry.key;
                EducationModel experience = entry.value;
                return _buildExperienceCard(experience, index);
              }),
              const SizedBox(height: 16),
            ],

            OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: false,
                    context: context,
                    builder: (context) => EducationBottomsheet(
                      closeBottomSheet: () {
                        Navigator.pop(context);
                      },
                      onSave: _addWorkExperience,
                    )
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFF4E6BF5),
                  width: 2.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.add_copy,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Experience',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inverseSurface
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(EducationModel experience, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${experience.company} | ${experience.location}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  experience.dateRange,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: false,
                    context: context,
                    builder: (context) => EducationBottomsheet(
                      closeBottomSheet: () {
                        Navigator.pop(context);
                      },
                      onSave: (updatedExperience) {
                        _editWorkExperience(index, updatedExperience);
                      },
                      initialData: experience,
                    ),
                  );
                },
                icon: const Icon(
                  CupertinoIcons.pencil_outline,
                  color: Color(0xFF4E6BF5),
                  size: 32,
                ),
              ),
              IconButton(
                onPressed: () => _deleteWorkExperience(index),
                icon: const Icon(
                  CupertinoIcons.trash_circle,
                  color: Color(0xFF4E6BF5),
                  size: 36,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}