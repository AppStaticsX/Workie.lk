import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: const Color(0xFF4E6BF5),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Iconsax.arrow_left_2_copy),
          color: Colors.white,
        ),
        title: Text(
          'Messages & Notifications',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              Theme.of(context).brightness == Brightness.dark
                ? 'assets/animation/lottie_empty_state_inbox_light.json'
                : 'assets/animation/lottie_empty_state_inbox_dark.json',
              width: 300,
              height: 300,
              frameRate: FrameRate(120)
            ),
            Text(
              'No messages yet.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              )
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                  textAlign: TextAlign.center,
                  'Don\'t worry, You\'ll find your notifications & messages all right here.',
                  style: TextStyle(
                      fontSize: 17,
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
