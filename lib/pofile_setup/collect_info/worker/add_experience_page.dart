import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/pofile_setup/collect_info/worker/components/work_experience_bottomsheet.dart';

class AddExperiencePage extends StatelessWidget {
  const AddExperiencePage({super.key});

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
              'If you have relevant work experience, add it here.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Workers who add their experience are twice as likely to win work. But if you\'re just starting out, you can still create a great profile. just head on to the next page.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: false,
                      context: context,
                      builder: (context) => WorkExperienceBottomsheet(
                          closeBottomSheet: () {
                            Navigator.pop(context);
                          }
                      )
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: const Color(0xFF4E6BF5),
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
}
