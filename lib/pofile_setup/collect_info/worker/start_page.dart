import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key,});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
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
              'How would you like to tell us about yourself?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We need to get a sense of your education, experience and skills. It\'s quickest to import your information - you can edit it before your profile goes live.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.inverseSurface
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
