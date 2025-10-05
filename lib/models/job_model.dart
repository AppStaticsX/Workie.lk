import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/models/detailed_job_model.dart';
import 'package:workie/values/color.dart';

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
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 8,
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
            const SizedBox(height: 12),
            _buildJobDetails(color: const Color(0xFF10B981)),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF4E6BF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Iconsax.building_3,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      widget.jobTitle,
                      style: Theme.of(context).textTheme.titleLarge?.
                      copyWith(
                          fontWeight: FontWeight.bold
                      )
                  ),
                  _buildDetailItem(Iconsax.location, widget.location),
                  _buildAuthorInfo()
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        // Action buttons
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isSaved = !isSaved;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(10)
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isSaved ? Iconsax.bookmark_2 : Iconsax.bookmark_2_copy,
                  color: isSaved ? const Color(0xFF4E6BF5) : Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthorInfo() {
    return Row(
      children: [
        const Icon(
          Iconsax.calendar_1,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
            'Published on ${widget.publishedDate}',
            style: Theme.of(context).textTheme.titleSmall?.
            copyWith(color: AppColors.textSilver
            )
        ),
      ],
    );
  }

  Widget _buildJobDetails({
    required Color color,
  }) {
    return Row(
      children: [
        Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: _buildDetailItem(
                Iconsax.timer, widget.jobType
            )
        ),
        const SizedBox(width: 20),
        _buildDetailItem(CupertinoIcons.money_dollar_circle_fill, widget.salary),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.
            copyWith(color: AppColors.textSilver
            )
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.description,
      style: TextStyle(
        color: Theme.of(context).colorScheme.inverseSurface,
        fontSize: 16,
        height: 1.4,
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            try {
              // Method 1: Try using the static show method
              JobDetailsBottomSheet.show(
                context,
                companyName: widget.companyName,
                jobTitle: widget.jobTitle,
                location: widget.location,
                salaryRange: widget.salary,
                jobType: widget.jobType,
                workingModel: 'Remote',
                level: 'Mid-level',
                aboutCompany: widget.description,
                jobDescriptionPoints: [
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                ],
                onApply: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application submitted!')),
                  );
                },
              );
            } catch (e) {
              // Method 2: Fallback - use showModalBottomSheet directly
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
                  jobDescriptionPoints: [
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
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('View-Job'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application submitted!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E6BF5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Apply Now',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white,),
            ),
          ),
        ),
      ],
    );
  }
}