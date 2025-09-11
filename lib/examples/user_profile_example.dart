import 'package:flutter/material.dart';
import '../services/pull_data/get_user_data.dart';

/// Example widget demonstrating how to use GetUserDataService
class UserProfileExample extends StatefulWidget {
  const UserProfileExample({super.key});

  @override
  State<UserProfileExample> createState() => _UserProfileExampleState();
}

class _UserProfileExampleState extends State<UserProfileExample> {
  UserData? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await GetUserDataService.getCurrentUserData();
      setState(() {
        userData = data;
        isLoading = false;
        if (data == null) {
          errorMessage = 'Failed to load user data';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _updateUserExample() async {
    if (userData == null) return;

    // Example of updating user data
    final updateData = UserUpdateData(
      firstName: 'Updated First Name',
      lastName: 'Updated Last Name',
      phone: '+94771234567',
    );

    final success = await GetUserDataService.updateCurrentUserData(updateData);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data updated successfully')),
      );
      _loadUserData(); // Reload data to show changes
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            onPressed: _loadUserData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: userData != null
          ? FloatingActionButton(
              onPressed: _updateUserExample,
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (userData == null) {
      return const Center(
        child: Text('No user data available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          if (userData!.profilePicture != null && userData!.profilePicture!.isNotEmpty)
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(userData!.profilePicture!),
              ),
            )
          else
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Basic Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Full Name', userData!.fullName),
                  _buildInfoRow('Email', userData!.email),
                  if (userData!.phone != null)
                    _buildInfoRow('Phone', userData!.phone!),
                  if (userData!.userType != null)
                    _buildInfoRow('User Type', userData!.userType!),
                  _buildInfoRow('Verified', userData!.isVerified ? 'Yes' : 'No'),
                  _buildInfoRow('Active', userData!.isActive ? 'Yes' : 'No'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Address Information
          if (userData!.address != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (userData!.address!.street != null)
                      _buildInfoRow('Street', userData!.address!.street!),
                    if (userData!.address!.city != null)
                      _buildInfoRow('City', userData!.address!.city!),
                    if (userData!.address!.state != null)
                      _buildInfoRow('Province/State', userData!.address!.state!),
                    if (userData!.address!.zipCode != null)
                      _buildInfoRow('Zip Code', userData!.address!.zipCode!),
                    if (userData!.address!.country != null)
                      _buildInfoRow('Country', userData!.address!.country!),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Profile Information (if available)
          if (userData!.profile != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (userData!.profile!.bio != null)
                      _buildInfoRow('Bio', userData!.profile!.bio!),
                    if (userData!.profile!.workerCategories != null)
                      _buildInfoRow('Categories', userData!.profile!.workerCategories!.join(', ')),
                    if (userData!.profile!.completedJobs != null)
                      _buildInfoRow('Completed Jobs', userData!.profile!.completedJobs.toString()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
