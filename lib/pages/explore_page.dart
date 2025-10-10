import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/models/job_model.dart';
import 'package:workie/services/get_jobs_service.dart';
import '../widgets/custom_icon_button.dart';
import '../widgets/custom_textfield.dart';

class ExploreTabPage extends StatefulWidget {
  const ExploreTabPage({super.key});

  @override
  State<ExploreTabPage> createState() => _ExploreTabPageState();
}

class _ExploreTabPageState extends State<ExploreTabPage> {
  List<Map<String, dynamic>> jobs = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 1;
  bool hasMoreJobs = true;
  Map<String, dynamic>? paginationInfo;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 1;
        jobs.clear();
        hasMoreJobs = true;
        hasError = false;
      });
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await GetJobsService.getAllJobs(
        page: currentPage,
        limit: 10,
        status: 'open',
      );

      if (result['success'] == true) {
        setState(() {
          if (refresh) {
            jobs = List<Map<String, dynamic>>.from(result['jobs'] ?? []);
          } else {
            jobs.addAll(List<Map<String, dynamic>>.from(result['jobs'] ?? []));
          }
          paginationInfo = result['pagination'];
          hasMoreJobs = paginationInfo?['hasNextPage'] ?? false;
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = result['message'] ?? 'Failed to load jobs';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Network error: $e';
      });
    }
  }

  Future<void> _loadMoreJobs() async {
    if (!hasMoreJobs || isLoading) return;
    
    currentPage++;
    await _loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E6BF5),
        surfaceTintColor: const Color(0xFF4E6BF5),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            CupertinoIcons.briefcase_fill,
            size: 26,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Explore Jobs',
          style: TextStyle(
              fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _WidgetSearchBar(),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: _buildJobsList(),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildJobsList() {
    if (hasError) {
      return _buildErrorWidget();
    }

    if (isLoading && jobs.isEmpty) {
      return _buildLoadingWidget();
    }

    if (jobs.isEmpty) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: () => _loadJobs(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              hasMoreJobs &&
              !isLoading) {
            _loadMoreJobs();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: jobs.length + (hasMoreJobs ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == jobs.length) {
              return _buildLoadMoreWidget();
            }

            final job = jobs[index];
            return JobCard(
              jobTitle: job['title'] ?? 'No Title',
              companyName: job['companyName'] ?? 'Unknown Company',
              location: job['location']?['address'] ?? 'Unknown Location',
              salary: job['budget']?['amount']?.toString() ?? 'Negotiable',
              jobType: job['jobType'] ?? 'Full Time',
              postedBy: job['postedBy']?['name'] ?? 'Unknown Poster',
              publishedDate: _formatDate(job['createdAt']),
              description: job['description'] ?? 'No description available',
              tags: List<String>.from(job['skills'] ?? []),
              postedTime: _getTimeAgo(job['createdAt']),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF4E6BF5),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadJobs(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E6BF5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.briefcase,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No jobs available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new opportunities',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4E6BF5),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown Date';
    }
  }

  String _getTimeAgo(String? dateString) {
    if (dateString == null) return 'Unknown time';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}

class _WidgetSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF4E6BF5),
        borderRadius: const BorderRadius.only(), // You may want to add specific corners here
      ),
      padding: EdgeInsets.only(top: 12.0, bottom: 16.0, left: 8.0, right: 16.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CustomTextfield(
                  obscureText: false,
                  prefixIconData: const Icon(Iconsax.search_normal_copy),
                  hintText: 'Search',
                ),
              ),
            ),
          ),
          CustomIconButton(
            iconData: Iconsax.setting_4_copy,
            color: const Color(0xFFFFD542),
            width: 52,
            height: 52,
            size: 26,
            iconColor: Colors.black,
          ),
        ],
      ),
    );
  }
}