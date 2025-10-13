import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secrets/app_secrets.dart';

class GetCurrentUserProfileDataService {
  static const String _baseUrl = SERVER.serverURL;
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'USER_ID';

  // Get auth token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      if (kDebugMode) print('Error getting auth token: $e');
      return null;
    }
  }

  // Get current user ID from SharedPreferences
  static Future<String?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      if (kDebugMode) print('Error getting current user ID: $e');
      return null;
    }
  }

  // Get current user's complete profile data
  static Future<Map<String, dynamic>?> getCurrentUserProfileData() async {
    try {
      // Get user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) print('User ID not found');
        return null;
      }

      // Get auth token (optional for this endpoint as it's public, but good for user verification)
      final token = await _getAuthToken();

      // Make API request
      final uri = Uri.parse('$_baseUrl/api/profiles/$userId');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(uri, headers: headers);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'];
      } else {
        throw Exception(responseData['message'] ?? 'Failed to get profile data');
      }
    } catch (e) {
      if (kDebugMode) print('Error getting current user profile data: $e');
      return null;
    }
  }

  // Get only user data from the profile response
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final profileData = await getCurrentUserProfileData();
      if (profileData != null && profileData.containsKey('user')) {
        return profileData['user'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting current user data: $e');
      return null;
    }
  }

  // Get only profile data from the response
  static Future<Map<String, dynamic>?> getCurrentProfileData() async {
    try {
      final profileData = await getCurrentUserProfileData();
      if (profileData != null && profileData.containsKey('profile')) {
        return profileData['profile'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting current profile data: $e');
      return null;
    }
  }

  // Check if current user has a complete profile
  static Future<bool> hasCompleteProfile() async {
    try {
      final profileData = await getCurrentUserProfileData();
      if (profileData == null) return false;

      final user = profileData['user'];
      final profile = profileData['profile'];

      // Check if essential user data exists
      if (user == null || 
          user['firstName'] == null || 
          user['lastName'] == null || 
          user['email'] == null) {
        return false;
      }

      // Check if profile exists and has basic information
      if (profile == null) return false;

      // You can add more specific checks based on your requirements
      return true;
    } catch (e) {
      if (kDebugMode) print('Error checking profile completeness: $e');
      return false;
    }
  }

  // Get user's profile picture URL
  static Future<String?> getCurrentUserProfilePicture() async {
    try {
      final userData = await getCurrentUserData();
      if (userData != null && userData.containsKey('profilePicture')) {
        return userData['profilePicture'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting profile picture: $e');
      return null;
    }
  }

  // Get user's cover photo URL
  static Future<String?> getCurrentUserCoverPhoto() async {
    try {
      final userData = await getCurrentUserData();
      if (userData != null && userData.containsKey('coverPhoto')) {
        return userData['coverPhoto'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting cover photo: $e');
      return null;
    }
  }

  // Get user's full name
  static Future<String?> getCurrentUserFullName() async {
    try {
      final userData = await getCurrentUserData();
      if (userData != null) {
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        return '$firstName $lastName'.trim();
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting full name: $e');
      return null;
    }
  }

  // Get user's skills
  static Future<List<Map<String, dynamic>>?> getCurrentUserSkills() async {
    try {
      final profileData = await getCurrentProfileData();
      if (profileData != null && profileData.containsKey('skills')) {
        return List<Map<String, dynamic>>.from(profileData['skills']);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting user skills: $e');
      return null;
    }
  }

  // Get user's experience
  static Future<List<Map<String, dynamic>>?> getCurrentUserExperience() async {
    try {
      final profileData = await getCurrentProfileData();
      if (profileData != null && profileData.containsKey('experience')) {
        return List<Map<String, dynamic>>.from(profileData['experience']);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting user experience: $e');
      return null;
    }
  }

  // Get user's portfolio
  static Future<List<Map<String, dynamic>>?> getCurrentUserPortfolio() async {
    try {
      final profileData = await getCurrentProfileData();
      if (profileData != null && profileData.containsKey('portfolio')) {
        return List<Map<String, dynamic>>.from(profileData['portfolio']);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting user portfolio: $e');
      return null;
    }
  }

  // Get user's ratings
  static Future<Map<String, dynamic>?> getCurrentUserRatings() async {
    try {
      final profileData = await getCurrentProfileData();
      if (profileData != null && profileData.containsKey('ratings')) {
        return Map<String, dynamic>.from(profileData['ratings']);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting user ratings: $e');
      return null;
    }
  }

  // Get user's availability status
  static Future<Map<String, dynamic>?> getCurrentUserAvailability() async {
    try {
      final profileData = await getCurrentProfileData();
      if (profileData != null && profileData.containsKey('availability')) {
        return Map<String, dynamic>.from(profileData['availability']);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting user availability: $e');
      return null;
    }
  }

  // Get user type (worker/client)
  static Future<String?> getCurrentUserType() async {
    try {
      final userData = await getCurrentUserData();
      if (userData != null && userData.containsKey('userType')) {
        return userData['userType'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting user type: $e');
      return null;
    }
  }

  // Get user's verification status
  static Future<bool> isCurrentUserVerified() async {
    try {
      final userData = await getCurrentUserData();
      if (userData != null && userData.containsKey('isVerified')) {
        return userData['isVerified'] ?? false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error getting verification status: $e');
      return false;
    }
  }

  // Refresh and cache profile data locally (optional enhancement)
  static Future<bool> refreshProfileData() async {
    try {
      final profileData = await getCurrentUserProfileData();
      if (profileData != null) {
        // You can implement local caching here using SharedPreferences
        // or any other local storage solution
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_profile_data', json.encode(profileData));
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error refreshing profile data: $e');
      return false;
    }
  }

  // Get cached profile data (optional enhancement)
  static Future<Map<String, dynamic>?> getCachedProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_profile_data');
      if (cachedData != null) {
        return json.decode(cachedData);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting cached profile data: $e');
      return null;
    }
  }

  // Clear cached profile data
  static Future<void> clearCachedProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_profile_data');
    } catch (e) {
      if (kDebugMode) print('Error clearing cached profile data: $e');
    }
  }

  // Get user's profile statistics (ratings, completed jobs, earnings)
  static Future<Map<String, dynamic>?> getCurrentUserStats() async {
    try {
      final profileData = await getCurrentProfileData();
      if (profileData == null) return null;

      return {
        'ratings': profileData['ratings'] ?? {'average': 0, 'count': 0},
        'completedJobs': profileData['completedJobs'] ?? 0,
        'totalEarnings': profileData['totalEarnings'] ?? 0,
      };
    } catch (e) {
      if (kDebugMode) print('Error getting user stats: $e');
      return null;
    }
  }

  // Get user's average rating
  static Future<double> getCurrentUserAverageRating() async {
    try {
      final ratings = await getCurrentUserRatings();
      if (ratings != null && ratings.containsKey('average')) {
        return (ratings['average'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      if (kDebugMode) print('Error getting average rating: $e');
      return 0.0;
    }
  }

  // Get user's rating count
  static Future<int> getCurrentUserRatingCount() async {
    try {
      final ratings = await getCurrentUserRatings();
      if (ratings != null && ratings.containsKey('count')) {
        return (ratings['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) print('Error getting rating count: $e');
      return 0;
    }
  }

  // Get user's completed jobs count
  static Future<int> getCurrentUserCompletedJobs() async {
    try {
      final profileData = await getCurrentProfileData();
      if (profileData != null && profileData.containsKey('completedJobs')) {
        return (profileData['completedJobs'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) print('Error getting completed jobs: $e');
      return 0;
    }
  }

  // Get user's total earnings
  static Future<double> getCurrentUserTotalEarnings() async {
    try {
      final profileData = await getCurrentProfileData();
      if (profileData != null && profileData.containsKey('totalEarnings')) {
        return (profileData['totalEarnings'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      if (kDebugMode) print('Error getting total earnings: $e');
      return 0.0;
    }
  }

  // Get formatted rating display (e.g., "4.5/5")
  static Future<String> getFormattedRating() async {
    try {
      final rating = await getCurrentUserAverageRating();
      return '${rating.toStringAsFixed(1)}/5';
    } catch (e) {
      if (kDebugMode) print('Error formatting rating: $e');
      return '0.0/5';
    }
  }

  // Get formatted earnings display (e.g., "Rs. 25,000")
  static Future<String> getFormattedEarnings() async {
    try {
      final earnings = await getCurrentUserTotalEarnings();
      return 'Rs. ${earnings.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    } catch (e) {
      if (kDebugMode) print('Error formatting earnings: $e');
      return 'Rs. 0';
    }
  }
}