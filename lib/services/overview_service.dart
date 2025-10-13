import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secrets/app_secrets.dart';

class OverviewService {
  static const String baseUrl = SERVER.serverURL;

  // Get existing overview/bio from the profile
  static Future<String?> getOverview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String? userId = prefs.getString('USER_ID');
      if (token == null || userId == null) {
        if (kDebugMode) print('Authentication failed: token=$token, userId=$userId');
        throw Exception('Not authenticated');
      }

      if (kDebugMode) print('Fetching profile for userId: $userId');
      final uri = Uri.parse('$baseUrl/api/profiles/$userId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (kDebugMode) print('Profile API response status: ${response.statusCode}');
      if (kDebugMode) print('Profile API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          // Try direct path first (bio at root level of profile)
          var bio = responseData['data']['bio'];
          
          // If not found, try nested path (bio under profile object)
          if (bio == null) {
            bio = responseData['data']['profile']?['bio'];
          }
          
          if (kDebugMode) print('Bio found: $bio');
          return bio;
        } else {
          if (kDebugMode) print('API response unsuccessful or no data');
        }
      } else {
        if (kDebugMode) print('API call failed with status: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error fetching overview: $e');
      return null;
    }
  }

  // Save overview as bio in the profile
  static Future<bool> saveOverview(String overview) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String? userId = prefs.getString('USER_ID');
      if (token == null || userId == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('$baseUrl/api/profiles/$userId');
      final body = jsonEncode({'bio': overview});
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      final responseData = jsonDecode(response.body);
      return response.statusCode == 200 && responseData['success'] == true;
    } catch (e) {
      print('Error saving overview as bio: $e');
      return false;
    }
  }
}
