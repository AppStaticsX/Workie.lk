import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background image container
                    Container(
                      height: 105,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://media.licdn.com/dms/image/v2/D4D16AQHrBrDSwm9uUA/profile-displaybackgroundimage-shrink_350_1400/B4DZdYDluIGUAg-/0/1749529055481?e=1757548800&v=beta&t=VMqdwj6S_Hd7ZVakDwCwL7sslXcX92VDaSXmJYAGTjU',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Edit button for background
                    Positioned(
                      top: 8,
                      right: 16,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Profile picture
                    Positioned(
                      left: 16,
                      top: 54, // Position to overlap background
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/President_Dr_Muizzu_meets_Sri_Lankan_President_Ranil_Wickremesinghe_%28cropped%29.jpg/500px-President_Dr_Muizzu_meets_Sri_Lankan_President_Ranil_Wickremesinghe_%28cropped%29.jpg',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 125, // Position to overlap background
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E6BF5),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(Iconsax.user_edit_copy, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            ),
                          )
                        ),
                      ),
                    ),
                    // Edit button for profile picture
                    Positioned(
                      left: 110, // Position relative to profile picture
                      top: 140,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E6BF5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: const Icon(
                            Iconsax.camera,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Profile content section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and title section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'John Wickramasinghe',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Iconsax.verify)
                      ],
                    ),
                    Text(
                      'Master Carpenter & Welder',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                            Iconsax.location,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Maradana, Colombo 3',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}