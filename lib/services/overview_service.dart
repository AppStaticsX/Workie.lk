import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OverviewService {
  static const String baseUrl = 'https://workie-lk-backend.onrender.com';

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
