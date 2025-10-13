import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secrets/app_secrets.dart';

class AddSkillsService {
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
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      if (kDebugMode) print('Error getting current user ID: $e');
      return null;
    }
  }

  // Replace all skills in user profile
  static Future<Map<String, dynamic>?> replaceSkillsInProfile({
    required String userId,
    required List<String> skills,
    String defaultLevel = 'beginner',
    int defaultExperience = 0,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Prepare skills data for replacement
      final skillsData = skills.map((skillName) => {
        'name': skillName.trim(),
        'level': defaultLevel,
        'yearsOfExperience': defaultExperience,
      }).toList();

      // Update the entire profile with new skills (replacing existing ones)
      final uri = Uri.parse('$_baseUrl/api/profiles/$userId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'skills': skillsData,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Skills replaced successfully: ${skills.join(', ')}');
          print('Response: $responseData');
        }
        return {
          'success': true,
          'message': 'Skills replaced successfully',
          'data': responseData['data'],
          'replaced': skills.length,
          'skills': skills,
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to replace skills');
      }
    } catch (e) {
      if (kDebugMode) print('Error replacing skills: $e');
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  // Add multiple skills to user profile
  static Future<Map<String, dynamic>?> addSkillsToProfile({
    required String userId,
    required List<String> skills,
    String defaultLevel = 'beginner',
    int defaultExperience = 0,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      if (skills.isEmpty) {
        throw Exception('No skills provided');
      }

      // Get current profile to check existing skills
      final currentProfile = await _getCurrentProfile(userId);
      final existingSkills = currentProfile?['skills'] as List<dynamic>? ?? [];
      final existingSkillNames = existingSkills
          .map((skill) => skill['name']?.toString().toLowerCase())
          .where((name) => name != null)
          .toSet();

      // Filter out skills that already exist
      final newSkills = skills
          .where((skill) => !existingSkillNames.contains(skill.toLowerCase()))
          .toList();

      if (newSkills.isEmpty) {
        if (kDebugMode) print('All skills already exist in profile');
        return {
          'success': true,
          'message': 'All skills already exist in profile',
          'data': currentProfile,
          'skipped': skills.length,
          'added': 0
        };
      }

      // Prepare skills data for bulk update
      final skillsData = newSkills.map((skillName) => {
        'name': skillName.trim(),
        'level': defaultLevel,
        'yearsOfExperience': defaultExperience,
      }).toList();

      // Add all skills to the existing skills array
      final updatedSkills = [
        ...existingSkills,
        ...skillsData,
      ];

      // Update the entire profile with new skills
      final uri = Uri.parse('$_baseUrl/api/profiles/$userId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'skills': updatedSkills,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Skills added successfully: ${newSkills.join(', ')}');
          print('Response: $responseData');
        }
        return {
          'success': true,
          'message': 'Skills added successfully',
          'data': responseData['data'],
          'added': newSkills.length,
          'skipped': skills.length - newSkills.length,
          'addedSkills': newSkills,
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add skills');
      }
    } catch (e) {
      if (kDebugMode) print('Error adding skills: $e');
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  // Add a single skill to user profile
  static Future<Map<String, dynamic>?> addSingleSkill({
    required String userId,
    required String skillName,
    String level = 'beginner',
    int yearsOfExperience = 0,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      if (skillName.trim().isEmpty) {
        throw Exception('Skill name cannot be empty');
      }

      final uri = Uri.parse('$_baseUrl/api/profiles/$userId/skills');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': skillName.trim(),
          'level': level,
          'yearsOfExperience': yearsOfExperience,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) print('Skill added successfully: $skillName');
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add skill');
      }
    } catch (e) {
      if (kDebugMode) print('Error adding skill: $e');
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  // Get current profile data
  static Future<Map<String, dynamic>?> _getCurrentProfile(String userId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
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
        // Backend returns data in format: { success: true, data: { user: {...}, profile: {...} } }
        // We need to return the profile part specifically
        final profileData = responseData['data']['profile'];
        if (kDebugMode) print('Profile data retrieved: ${profileData != null ? 'Found' : 'Not found'}');
        return profileData;
      } else {
        if (kDebugMode) print('Profile not found, will create new one');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting current profile: $e');
      return null;
    }
  }

  // Remove a skill from user profile
  static Future<Map<String, dynamic>?> removeSkill({
    required String userId,
    required String skillId,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$_baseUrl/api/profiles/$userId/skills/$skillId');
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) print('Skill removed successfully');
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to remove skill');
      }
    } catch (e) {
      if (kDebugMode) print('Error removing skill: $e');
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  // Update an existing skill
  static Future<Map<String, dynamic>?> updateSkill({
    required String userId,
    required String skillId,
    String? name,
    String? level,
    int? yearsOfExperience,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final updateData = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) updateData['name'] = name.trim();
      if (level != null) updateData['level'] = level;
      if (yearsOfExperience != null) updateData['yearsOfExperience'] = yearsOfExperience;

      if (updateData.isEmpty) {
        throw Exception('No update data provided');
      }

      final uri = Uri.parse('$_baseUrl/api/profiles/$userId/skills/$skillId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) print('Skill updated successfully');
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update skill');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating skill: $e');
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  // Get user skills from profile
  static Future<List<Map<String, dynamic>>?> getUserSkills(String userId) async {
    try {
      if (kDebugMode) print('Fetching skills for user: $userId');
      
      final profile = await _getCurrentProfile(userId);
      if (profile != null) {
        final skills = profile['skills'];
        if (kDebugMode) print('Skills found: ${skills != null ? skills.length : 0} skills');
        
        if (skills != null) {
          final skillsList = List<Map<String, dynamic>>.from(skills);
          if (kDebugMode) {
            final skillNames = skillsList.map((skill) => skill['name']).toList();
            print('User skills: $skillNames');
          }
          return skillsList;
        }
      } else {
        if (kDebugMode) print('No profile found for user: $userId');
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('Error getting user skills: $e');
      return null;
    }
  }

  // Validate skills before saving
  static bool validateSkills(List<String> skills) {
    if (skills.isEmpty) return false;

    // Check for empty or whitespace-only skills
    return skills.every((skill) => skill.trim().isNotEmpty);
  }

  // Test method to check if the service is working properly
  static Future<Map<String, dynamic>> testGetUserSkills() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'No user ID found',
          'data': null,
        };
      }

      final skills = await getUserSkills(userId);
      return {
        'success': true,
        'message': 'Skills fetched successfully',
        'data': {
          'userId': userId,
          'skills': skills,
          'skillCount': skills?.length ?? 0,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Test failed: $e',
        'data': null,
      };
    }
  }
}