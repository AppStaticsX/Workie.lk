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
  List<EducationModel> educationExperiences = [];

  void _addEducationExperience(EducationModel experience) {
    setState(() {
      educationExperiences.add(experience);
    });
    // Notify parent about the change
    if (widget.onEducationChanged != null) {
      widget.onEducationChanged!(educationExperiences.isNotEmpty);
    }
  }

  void _editEducationExperience(int index, EducationModel updatedExperience) {
    setState(() {
      educationExperiences[index] = updatedExperience;
    });
    // Notify parent about the change
    if (widget.onEducationChanged != null) {
      widget.onEducationChanged!(educationExperiences.isNotEmpty);
    }
  }

  void _deleteEducationExperience(int index) {
    setState(() {
      educationExperiences.removeAt(index);
    });
    // Notify parent about the change
    if (widget.onEducationChanged != null) {
      widget.onEducationChanged!(educationExperiences.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Text(
              'Clients like to know what you know - add your education here.',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You don\'t have to have a degree/diploma. Adding any relevant education helps make your profile more visible.',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .inverseSurface
              ),
            ),
            const SizedBox(height: 32),

            // Display education experiences
            if (educationExperiences.isNotEmpty) ...[
              ...educationExperiences
                  .asMap()
                  .entries
                  .map((entry) {
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
                    builder: (context) =>
                        EducationBottomsheet(
                          closeBottomSheet: () {
                            Navigator.pop(context);
                          },
                          onSave: _addEducationExperience,
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
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.add_copy,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .inverseSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Education',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .inverseSurface
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .tertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme
              .of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.school,
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${experience.course} | ${experience.fieldOfStudy}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .inverseSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      experience.dateRange,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .inverseSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    if (experience.hasCertificate) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            _getCertificateIcon(experience.certificateFileName!),
                            color: Colors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Certificate attached',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  experience.certificateFileName!,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
                        builder: (context) =>
                            EducationBottomsheet(
                              closeBottomSheet: () {
                                Navigator.pop(context);
                              },
                              onSave: (updatedExperience) {
                                _editEducationExperience(
                                    index, updatedExperience);
                              },
                              initialData: experience,
                            ),
                      );
                    },
                    icon: const Icon(
                      CupertinoIcons.pencil_outline,
                      color: Color(0xFF4E6BF5),
                      size: 28,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteEducationExperience(index),
                    icon: const Icon(
                      CupertinoIcons.trash_circle,
                      color: Color(0xFF4E6BF5),
                      size: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Certificate section
        ],
      ),
    );
  }

  IconData _getCertificateIcon(String fileName) {
    String extension = fileName
        .split('.')
        .last
        .toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.description;
    }
  }
}