import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/models/job_model.dart';

class ExploreTabPage extends StatelessWidget {
  const ExploreTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: const Color(0xFF4E6BF5),
        leading: Icon(
          Iconsax.briefcase_copy,
          size: 26,
        ),
        title: Text(
          'Explore Jobs',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
                color: Theme
                    .of(context)
                    .colorScheme
                    .surface,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      JobCard(
                        jobTitle: 'Skilled Masons',
                        companyName: 'GenBuild Pvt.LTD',
                        location: 'Colombo, Sri Lanka',
                        salary: 'Rs 60,000 - Rs 80,000',
                        jobType: 'Full Time',
                        postedBy: 'Rajesh Perera',
                        publishedDate: '2025-01-06',
                        description: 'We are looking for skilled Mason specialists to join our construction project...',
                        tags: ['Mason', 'Bricks', 'Tile work'],
                        postedTime: '2 days ago',
                      ),
                      JobCard(
                        jobTitle: 'Experienced Carpenters',
                        companyName: 'WoodMasters Lanka',
                        location: 'Galle, Sri Lanka',
                        salary: 'Rs 55,000 - Rs 70,000',
                        jobType: 'Contract',
                        postedBy: 'Saman Wijesinghe',
                        publishedDate: '2025-01-10',
                        description: 'We are hiring carpenters skilled in furniture making and interior fittings...',
                        tags: ['Carpentry', 'Furniture', 'Woodwork'],
                        postedTime: '1 day ago',
                      ),

                      JobCard(
                        jobTitle: 'Welders & Fabricators',
                        companyName: 'SteelWorks Ceylon',
                        location: 'Kandy, Sri Lanka',
                        salary: 'Rs 65,000 - Rs 90,000',
                        jobType: 'Full Time',
                        postedBy: 'Chathura Fernando',
                        publishedDate: '2025-01-08',
                        description: 'Looking for welders with MIG/TIG experience for metal structure fabrication...',
                        tags: ['Welding', 'Steel', 'Fabrication'],
                        postedTime: '3 days ago',
                      ),

                      JobCard(
                        jobTitle: 'General Helpers',
                        companyName: 'BuildRight Constructions',
                        location: 'Negombo, Sri Lanka',
                        salary: 'Rs 40,000 - Rs 55,000',
                        jobType: 'Part Time',
                        postedBy: 'Nuwan Silva',
                        publishedDate: '2025-01-09',
                        description: 'We need reliable general helpers for construction site support and material handling...',
                        tags: ['Helper', 'Construction', 'Labor'],
                        postedTime: '12 hours ago',
                      ),

                    ],
                  ),
                ),
              )
          )
        ],
      )
    );
  }
}