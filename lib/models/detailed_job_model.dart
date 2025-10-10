import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class JobDetailsBottomSheet extends StatefulWidget {
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
  State<JobDetailsBottomSheet> createState() => _JobDetailsBottomSheetState();
}

class _JobDetailsBottomSheetState extends State<JobDetailsBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

              // Company logo and info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: widget.logoBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.logoText,
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
                        widget.jobTitle,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        widget.companyName,
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
                            widget.location,
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
              ),

              const SizedBox(height: 24),

              // Job details grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        context,
                        icon: Iconsax.money_3,
                        label: 'Salary (LKR)',
                        value: widget.salaryRange,
                        valueColor: const Color(0xFF4E6BF5),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailCard(
                        context,
                        icon: Iconsax.briefcase,
                        label: 'Job Type',
                        value: widget.jobType,
                        valueColor: const Color(0xFF4E6BF5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Color(0xFF4E6BF5).withValues(alpha: 0.4),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF4E6BF5),
                          width: 2,
                        ),
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Company'),
                      Tab(text: 'Review'),
                    ],
                  ),
                ),
              ),

              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // About Tab
                    _buildAboutTab(scrollController),
                    // Company Tab
                    _buildCompanyTab(scrollController),
                    // Review Tab
                    _buildReviewTab(scrollController),
                  ],
                ),
              ),

              // Apply button
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: widget.onApply,
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

  Widget _buildAboutTab(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            widget.aboutCompany,
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
          ...widget.jobDescriptionPoints.map(
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
    );
  }

  Widget _buildCompanyTab(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Company',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Company information will be displayed here.',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildReviewTab(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Company reviews will be displayed here.',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
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
}