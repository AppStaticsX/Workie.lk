import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:workie/secrets/apikeys.dart';

class CompanyLogoService {
  // Google Places API key - same as used for schools
  static const String _googleApiKey = APIKEYS.GOOGLE_MAPS_API_KEY;
  
  /// Fetch company information including logo URL from Google Places API
  static Future<CompanyInfo> getCompanyInfo(String companyName) async {
    try {
      // Step 1: Get place ID from company name
      final placeId = await _getPlaceId(companyName);
      if (placeId == null) {
        return CompanyInfo(
          name: companyName,
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

      return CompanyInfo(
        name: companyName,
        logoUrl: logoUrl,
        website: details['website'],
        placeId: placeId,
        found: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching company info for $companyName: $e');
      }
      return CompanyInfo(
        name: companyName,
        logoUrl: null,
        website: null,
        found: false,
      );
    }
  }

  /// Get multiple company logos in batch
  static Future<Map<String, CompanyInfo>> getMultipleCompanyLogos(List<String> companyNames) async {
    Map<String, CompanyInfo> results = {};
    
    for (String companyName in companyNames) {
      if (companyName.isNotEmpty) {
        results[companyName] = await getCompanyInfo(companyName);
        // Add small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    
    return results;
  }

  /// Search for place ID using company name
  static Future<String?> _getPlaceId(String companyName) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
      "?input=${Uri.encodeComponent(companyName)}"
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
        print('Error getting place ID for $companyName: $e');
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

  /// Fallback method to get logo from company name using alternative services
  static String getFallbackLogoUrl(String companyName) {
    // Use Google's favicon service as fallback
    final searchQuery = Uri.encodeComponent('$companyName official website');
    return "https://www.google.com/s2/favicons?domain=${Uri.encodeComponent(companyName)}&sz=64";
  }
}

/// Model class for company information
class CompanyInfo {
  final String name;
  final String? logoUrl;
  final String? website;
  final String? placeId;
  final bool found;

  CompanyInfo({
    required this.name,
    this.logoUrl,
    this.website,
    this.placeId,
    required this.found,
  });

  @override
  String toString() {
    return 'CompanyInfo(name: $name, logoUrl: $logoUrl, website: $website, found: $found)';
  }
}