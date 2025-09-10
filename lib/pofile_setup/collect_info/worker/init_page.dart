import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/pofile_setup/collect_info/worker/page_setup.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: Colors.transparent,
        leading: const Icon(
          CupertinoIcons.person_crop_circle_badge_plus,
          color: Colors.white,
          size: 36,
        ),
        title: Text('Create & Verify Your Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              color: Colors.white
            )
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), child: const SizedBox(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Hey, Are you ready for your next big opportunities?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )
            ),
            const SizedBox(height: 44),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Iconsax.user_edit_copy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Answer a few questions and start building your profile.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    )
                  ),
                )
              ],
            ),
            const SizedBox(height: 36),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Iconsax.shield_tick_copy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Verify your profile for make clients can put trust on you.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    )
                  ),
                )
              ],
            ),
            const SizedBox(height: 36),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Iconsax.tick_circle_copy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'You are good to go. 🚀',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    )
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),
            Divider(
              thickness: 0.4,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    'It only takes 5-10 minutes and you can edit it later. We\'ll save as you go.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSetup()));
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E6BF5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
              child: Text(
                'Get Started',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
          ),
        ),
      ),
    );
  }
}