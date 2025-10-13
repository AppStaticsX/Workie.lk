import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:workie/secrets/app_secrets.dart';

class SchoolLogoService {
  // TODO: Replace with your actual Google Places API key
  // Get it from: https://console.cloud.google.com/apis/credentials
  static const String _googleApiKey = APIKEYS.GOOGLE_MAPS_API_KEY;
  
  /// Fetch school information including logo URL from Google Places API
  static Future<SchoolInfo> getSchoolInfo(String schoolName) async {
    try {
      // Step 1: Get place ID from school name
      final placeId = await _getPlaceId(schoolName);
      if (placeId == null) {
        return SchoolInfo(
          name: schoolName,
          logoUrl: null,
          website: null,
          found: false,
        );
      }

      // Step 2: Get detailed information including website
      final details = await _getPlaceDetails(placeId);
      
      // Step 3: Generate logo URL from website domain
      String? logoUrl;
      if (details['website'] != null) {
        logoUrl = _generateLogoUrl(details['website']);
      }

      return SchoolInfo(
        name: schoolName,
        logoUrl: logoUrl,
        website: details['website'],
        placeId: placeId,
        found: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching school info for $schoolName: $e');
      }
      return SchoolInfo(
        name: schoolName,
        logoUrl: null,
        website: null,
        found: false,
      );
    }
  }

  /// Get multiple school logos in batch
  static Future<Map<String, SchoolInfo>> getMultipleSchoolLogos(List<String> schoolNames) async {
    Map<String, SchoolInfo> results = {};
    
    for (String schoolName in schoolNames) {
      if (schoolName.isNotEmpty) {
        results[schoolName] = await getSchoolInfo(schoolName);
        // Add small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    
    return results;
  }

  /// Search for place ID using school name
  static Future<String?> _getPlaceId(String schoolName) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
      "?input=${Uri.encodeComponent(schoolName)}"
      "&types=establishment"
      "&components=country:lk" // Restrict to Sri Lanka, change as needed
      "&key=$_googleApiKey",
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data["status"] == "OK" && data["predictions"].isNotEmpty) {
          // Get the first (most relevant) result
          return data["predictions"][0]["place_id"];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting place ID for $schoolName: $e');
      }
    }
    
    return null;
  }

  /// Get detailed place information including website
  static Future<Map<String, dynamic>> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json"
      "?place_id=$placeId"
      "&fields=name,website,formatted_address,types"
      "&key=$_googleApiKey",
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data["status"] == "OK") {
          return data["result"] ?? {};
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting place details for $placeId: $e');
      }
    }
    
    return {};
  }

  /// Generate logo URL from website domain using Clearbit Logo API
  static String _generateLogoUrl(String website) {
    try {
      final uri = Uri.parse(website.startsWith('http') ? website : 'https://$website');
      final domain = uri.host;
      return "https://logo.clearbit.com/$domain";
    } catch (e) {
      if (kDebugMode) {
        print('Error generating logo URL for $website: $e');
      }
      return "";
    }
  }

  /// Fallback method to get logo from school name using alternative services
  static String getFallbackLogoUrl(String schoolName) {
    // Use Google's favicon service as fallback
    final searchQuery = Uri.encodeComponent('$schoolName official website');
    return "https://www.google.com/s2/favicons?domain=${Uri.encodeComponent(schoolName)}&sz=64";
  }
}

/// Model class for school information
class SchoolInfo {
  final String name;
  final String? logoUrl;
  final String? website;
  final String? placeId;
  final bool found;

  SchoolInfo({
    required this.name,
    this.logoUrl,
    this.website,
    this.placeId,
    required this.found,
  });

  @override
  String toString() {
    return 'SchoolInfo(name: $name, logoUrl: $logoUrl, website: $website, found: $found)';
  }
}