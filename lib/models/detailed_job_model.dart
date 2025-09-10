import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class JobDetailsBottomSheet extends StatelessWidget {
  final String companyName;
  final String jobTitle;
  final String location;
  final String salaryRange;
  final String jobType;
  final String workingModel;
  final String level;
  final String aboutCompany;
  final List<String> jobDescriptionPoints;
  final VoidCallback? onApply;
  final String logoText;
  final Color logoBackgroundColor;

  const JobDetailsBottomSheet({
    super.key,
    required this.companyName,
    required this.jobTitle,
    required this.location,
    required this.salaryRange,
    required this.jobType,
    required this.workingModel,
    required this.level,
    required this.aboutCompany,
    required this.jobDescriptionPoints,
    this.onApply,
    this.logoText = 'B.',
    this.logoBackgroundColor = const Color(0xFF4C63F2),
  });

  static void show(
      BuildContext context, {
        required String companyName,
        required String jobTitle,
        required String location,
        required String salaryRange,
        required String jobType,
        required String workingModel,
        required String level,
        required String aboutCompany,
        required List<String> jobDescriptionPoints,
        VoidCallback? onApply,
        String logoText = 'B.',
        Color logoBackgroundColor = const Color(0xFF4C63F2),
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDetailsBottomSheet(
        companyName: companyName,
        jobTitle: jobTitle,
        location: location,
        salaryRange: salaryRange,
        jobType: jobType,
        workingModel: workingModel,
        level: level,
        aboutCompany: aboutCompany,
        jobDescriptionPoints: jobDescriptionPoints,
        onApply: onApply,
        logoText: logoText,
        logoBackgroundColor: logoBackgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with back button and actions
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Iconsax.arrow_left_2_copy, color: Theme.of(context).colorScheme.inverseSurface),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Iconsax.bookmark_2_copy, color: Theme.of(context).colorScheme.inverseSurface,),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Iconsax.send_1_copy, color: Theme.of(context).colorScheme.inverseSurface),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company logo and info
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: logoBackgroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  logoText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              jobTitle,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.inverseSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              companyName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Iconsax.location,
                                  size: 18,
                                  color: Color(0xFF4C63F2),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).colorScheme.inverseSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Job details grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              context,
                              icon: Iconsax.money_3,
                              label: 'Salary (LKR)',
                              value: salaryRange,
                              valueColor: const Color(0xFF4E6BF5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailCard(
                              context,
                              icon: Iconsax.briefcase,
                              label: 'Job Type',
                              value: jobType,
                              valueColor: const Color(0xFF4E6BF5),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /*Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              context,
                              icon: Iconsax.building_4,
                              label: 'Working Model',
                              value: workingModel,
                              valueColor: const Color(0xFF4E6BF5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailCard(
                              context,
                              icon: Iconsax.chart_3,
                              label: 'Level',
                              value: level,
                              valueColor: const Color(0xFF4E6BF5),
                            ),
                          ),
                        ],
                      ),*/


                      // Tab bar
                      Row(
                        children: [
                          _buildTab(context, 'About', true, 12, 0),
                          _buildTab(context, 'Company', false, 0, 0),
                          _buildTab(context, 'Review', false, 0, 12),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // About this Job section
                      Text(
                        'About this Job',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        aboutCompany,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Read more',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4E6BF5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Job Description section
                      Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...jobDescriptionPoints.map(
                            (point) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 6, right: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.inverseSurface,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  point,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Apply button
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E6BF5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply for Job',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color valueColor,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFF4E6BF5),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, bool isActive, double tlRadius, double trRadius) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive? Color(0xFF4E6BF5).withValues(alpha: 0.4) : Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(tlRadius), topRight: Radius.circular(trRadius)),
          border: isActive
              ? const Border(
            bottom: BorderSide(
              color: Color(0xFF4E6BF5),
              width: 2,
            ),
          ) : Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 2
            )
          )
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}