import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetUserSkillsService {
  static const String _baseUrl = 'https://workie-lk-backend.onrender.com';
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

  // Get current user's skills from their profile
  static Future<Map<String, dynamic>> getCurrentUserSkills() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      return await getUserSkills(userId);
    } catch (e) {
      if (kDebugMode) print('Error getting current user skills: $e');
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
        'skills': <Map<String, dynamic>>[],
      };
    }
  }

  // Get skills for a specific user by user ID
  static Future<Map<String, dynamic>> getUserSkills(String userId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      if (userId.trim().isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      final uri = Uri.parse('$_baseUrl/api/profiles/$userId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final profileData = responseData['data'];
        final skillsData = profileData['profile']?['skills'] ?? [];
        
        if (kDebugMode) {
          print('Successfully fetched user skills');
          print('Skills count: ${skillsData.length}');
        }

        return {
          'success': true,
          'message': 'Skills fetched successfully',
          'data': profileData,
          'skills': List<Map<String, dynamic>>.from(skillsData),
          'skillsCount': skillsData.length,
        };
      } else if (response.statusCode == 404) {
        if (kDebugMode) print('User profile not found');
        return {
          'success': true,
          'message': 'No profile found for this user',
          'data': null,
          'skills': <Map<String, dynamic>>[],
          'skillsCount': 0,
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch user skills');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching user skills: $e');
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
        'skills': <Map<String, dynamic>>[],
        'skillsCount': 0,
      };
    }
  }

  // Get skills as a simple list of skill names
  static Future<List<String>> getCurrentUserSkillNames() async {
    try {
      final result = await getCurrentUserSkills();
      if (result['success'] == true && result['skills'] != null) {
        final skills = result['skills'] as List<Map<String, dynamic>>;
        return skills
            .map((skill) => skill['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error getting skill names: $e');
      return [];
    }
  }

  // Get skills with detailed information
  static Future<List<Map<String, dynamic>>> getCurrentUserSkillsDetailed() async {
    try {
      final result = await getCurrentUserSkills();
      if (result['success'] == true && result['skills'] != null) {
        return List<Map<String, dynamic>>.from(result['skills']);
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error getting detailed skills: $e');
      return [];
    }
  }

  // Check if user has a specific skill
  static Future<bool> hasSkill(String skillName) async {
    try {
      final skillNames = await getCurrentUserSkillNames();
      return skillNames
          .any((name) => name.toLowerCase() == skillName.toLowerCase());
    } catch (e) {
      if (kDebugMode) print('Error checking if user has skill: $e');
      return false;
    }
  }

  // Get skills by level (beginner, intermediate, advanced, expert)
  static Future<List<Map<String, dynamic>>> getSkillsByLevel(String level) async {
    try {
      final skills = await getCurrentUserSkillsDetailed();
      return skills
          .where((skill) => 
              skill['level']?.toString().toLowerCase() == level.toLowerCase())
          .toList();
    } catch (e) {
      if (kDebugMode) print('Error getting skills by level: $e');
      return [];
    }
  }

  // Get skills with experience years filter
  static Future<List<Map<String, dynamic>>> getSkillsByExperience({
    int? minYears,
    int? maxYears,
  }) async {
    try {
      final skills = await getCurrentUserSkillsDetailed();
      return skills.where((skill) {
        final experience = skill['yearsOfExperience'] as int? ?? 0;
        
        bool matchesMin = minYears == null || experience >= minYears;
        bool matchesMax = maxYears == null || experience <= maxYears;
        
        return matchesMin && matchesMax;
      }).toList();
    } catch (e) {
      if (kDebugMode) print('Error filtering skills by experience: $e');
      return [];
    }
  }

  // Get user profile with all data (not just skills)
  static Future<Map<String, dynamic>> getUserProfile([String? userId]) async {
    try {
      final targetUserId = userId ?? await _getCurrentUserId();
      if (targetUserId == null) {
        throw Exception('User ID not found');
      }

      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$_baseUrl/api/profiles/$targetUserId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) print('Successfully fetched user profile');
        return {
          'success': true,
          'message': 'Profile fetched successfully',
          'data': responseData['data'],
        };
      } else if (response.statusCode == 404) {
        if (kDebugMode) print('User profile not found');
        return {
          'success': true,
          'message': 'No profile found for this user',
          'data': null,
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch user profile');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching user profile: $e');
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  // Search skills by name pattern
  static Future<List<Map<String, dynamic>>> searchSkills(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return await getCurrentUserSkillsDetailed();
      }

      final skills = await getCurrentUserSkillsDetailed();
      final lowerSearchTerm = searchTerm.toLowerCase();
      
      return skills.where((skill) {
        final skillName = skill['name']?.toString().toLowerCase() ?? '';
        return skillName.contains(lowerSearchTerm);
      }).toList();
    } catch (e) {
      if (kDebugMode) print('Error searching skills: $e');
      return [];
    }
  }

  // Get skills statistics
  static Future<Map<String, dynamic>> getSkillsStatistics() async {
    try {
      final skills = await getCurrentUserSkillsDetailed();
      
      if (skills.isEmpty) {
        return {
          'totalSkills': 0,
          'averageExperience': 0.0,
          'skillsByLevel': <String, int>{},
          'maxExperience': 0,
          'minExperience': 0,
        };
      }

      // Calculate statistics
      final totalSkills = skills.length;
      final experiences = skills
          .map((skill) => skill['yearsOfExperience'] as int? ?? 0)
          .toList();
      
      final totalExperience = experiences.reduce((a, b) => a + b);
      final averageExperience = totalExperience / totalSkills;
      final maxExperience = experiences.reduce((a, b) => a > b ? a : b);
      final minExperience = experiences.reduce((a, b) => a < b ? a : b);

      // Group by level
      final skillsByLevel = <String, int>{};
      for (final skill in skills) {
        final level = skill['level']?.toString() ?? 'beginner';
        skillsByLevel[level] = (skillsByLevel[level] ?? 0) + 1;
      }

      return {
        'totalSkills': totalSkills,
        'averageExperience': averageExperience,
        'skillsByLevel': skillsByLevel,
        'maxExperience': maxExperience,
        'minExperience': minExperience,
      };
    } catch (e) {
      if (kDebugMode) print('Error calculating skills statistics: $e');
      return {
        'totalSkills': 0,
        'averageExperience': 0.0,
        'skillsByLevel': <String, int>{},
        'maxExperience': 0,
        'minExperience': 0,
      };
    }
  }
}