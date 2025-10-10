import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/models/detailed_job_model.dart';

class JobCard extends StatefulWidget {
  final String jobTitle;
  final String companyName;
  final String location;
  final String salary;
  final String jobType;
  final String postedBy;
  final String publishedDate;
  final String description;
  final List<String> tags;
  final String postedTime;

  const JobCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.postedBy,
    required this.publishedDate,
    required this.description,
    required this.tags,
    required this.postedTime,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  final List<String> svgPaths = [
    'assets/icon/appcode-svgrepo-com.svg',
  ];

  late String randomSvg;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    randomSvg = _getRandomSvg();
  }

  String _getRandomSvg() {
    return svgPaths[random.nextInt(svgPaths.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        //border: Border.all(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildJobInfo(),
            const SizedBox(height: 16),
            _buildPriceAndButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture/Company Logo
        SvgPicture.asset(
          randomSvg,
          width: 50,
          height: 50,
        ),
        const SizedBox(width: 12),
        // Job Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.jobTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              //const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Iconsax.location,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.location,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              /*Row(
                children: [
                  const Icon(
                    Iconsax.calendar_1,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.postedTime,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),*/
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Posted in category
        Expanded(
          child: Text(
            widget.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rs ${widget.salary}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Per Day',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
        // Buttons
        Row(
          children: [
            // View Details button
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => JobDetailsBottomSheet(
                    companyName: widget.companyName,
                    jobTitle: widget.jobTitle,
                    location: widget.location,
                    salaryRange: widget.salary,
                    jobType: widget.jobType,
                    workingModel: 'Remote',
                    level: 'Mid-level',
                    aboutCompany: widget.description,
                    jobDescriptionPoints: const [
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    ],
                    onApply: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Application submitted!')),
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                elevation: 0,
              ),
              child: Icon(
                Iconsax.eye,
                size: 20,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            // Apply button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application submitted!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E6BF5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 0,
              ),
              child: Text(
                'Apply Job',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}