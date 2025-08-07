import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PostTabPage extends StatelessWidget {
  const PostTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.add_square_copy, size: 80, color: Color(0xFF4E6BF5)),
          SizedBox(height: 16),
          Text(
            'Create Post',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Share your thoughts with the world',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}