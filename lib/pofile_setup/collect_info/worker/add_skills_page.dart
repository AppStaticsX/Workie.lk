import 'package:flutter/material.dart';

class AddSkillsPage extends StatefulWidget {
  const AddSkillsPage({super.key});

  @override
  State<AddSkillsPage> createState() => _AddSkillsPageState();
}

class _AddSkillsPageState extends State<AddSkillsPage> {
  final int maxSkills = 15;
  final TextEditingController _skillController = TextEditingController();

  List<String> selectedSkills = [
    'Android App Development',
    'App Development',
    'Mobile App Development',
    'Mobile App',
  ];

  List<String> suggestedSkills = [
    'Mobile Game',
    'iOS Development',
    'Smartphone',
    'Construction Document Preparation',
    'Specifications',
    'Web Application',
  ];

  void _addSkill(String skill) {
    if (selectedSkills.length >= maxSkills) return;
    setState(() {
      selectedSkills.add(skill);
      suggestedSkills.remove(skill);
    });
    _skillController.clear();
  }

  void _removeSkill(String skill) {
    setState(() {
      selectedSkills.remove(skill);
      // Optionally, add back to suggestions if you want
      if (!suggestedSkills.contains(skill)) {
        suggestedSkills.add(skill);
      }
    });
  }

  void _onSkillInput(String value) {
    if (value.trim().isEmpty) return;
    if (selectedSkills.length >= maxSkills) return;
    if (selectedSkills.contains(value.trim())) return;
    setState(() {
      selectedSkills.add(value.trim());
    });
    _skillController.clear();
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
              'Nearly there! What work are you here to do?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your skills show clients what you can offer, and help us choose which jobs to recommend to you. Add or remove the ones we\'ve suggested, or start typing to pick more. It\'s up to you.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface
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
                  color: Colors.white.withValues(alpha: 0.4),
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
                        labelStyle: const TextStyle(color: Colors.white),
                        backgroundColor: Colors.transparent,
                        shape: StadiumBorder(
                          side: BorderSide(color: Colors.white, width: 1.5),
                        ),
                        deleteIcon: const Icon(Icons.close, color: Colors.white),
                        onDeleted: () => _removeSkill(skill),
                      );
                    }).toList(),
                  ),
                  if (selectedSkills.length < maxSkills)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: _skillController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter skills here',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
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
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          skill,
                          style: const TextStyle(color: Colors.white),
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