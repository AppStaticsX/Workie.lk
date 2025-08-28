import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workie/values/color.dart';

class WorkerCollectInfoStartPage extends StatefulWidget {
  const WorkerCollectInfoStartPage({super.key,});

  @override
  State<WorkerCollectInfoStartPage> createState() => _WorkerCollectInfoStartPage();
}

class _WorkerCollectInfoStartPage extends State<WorkerCollectInfoStartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            SvgPicture.asset(
              'assets/icon/undraw_add-information_06qr.svg',
              height: 180,
              width: 180,
            ),
            const SizedBox(height: 30),
            Text(
              'Tell us a little about yourself',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We need to know your skills, past work, and education. The fastest way is to add your details here. Don’t worry, you can update or edit them anytime before your profile is shown to others.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSilver,
                height: 1.3
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
