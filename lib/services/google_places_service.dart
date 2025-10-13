import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:workie/secrets/app_secrets.dart';

class GooglePlacesService {
  // TODO: Replace with your actual Google Places API key
  // You can get this from: https://console.cloud.google.com/
  // Make sure to enable Places API and restrict the key appropriately
  static const String _apiKey = APIKEYS.GOOGLE_MAPS_API_KEY;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // Singleton pattern
  static final GooglePlacesService _instance = GooglePlacesService._internal();
  factory GooglePlacesService() => _instance;
  GooglePlacesService._internal();

  /// Search for educational institutions using Google Places API
  Future<List<PlaceAutocomplete>> getSchoolSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      // Using Place Autocomplete API with type 'establishment' and keywords for educational institutions
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/autocomplete/json'
          '?input=$query'
          '&types=establishment'
          '&components=country:lk' // Restrict to Sri Lanka, change as needed
          '&key=$_apiKey'
        ),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          List<dynamic> predictions = data['predictions'] ?? [];
          
          // Filter results to prioritize educational institutions
          List<PlaceAutocomplete> filteredResults = predictions
              .where((prediction) => _isEducationalInstitution(prediction['description']))
              .map((prediction) => PlaceAutocomplete.fromJson(prediction))
              .toList();
          
          // If no educational institutions found, return all results
          if (filteredResults.isEmpty) {
            filteredResults = predictions
                .map((prediction) => PlaceAutocomplete.fromJson(prediction))
                .toList();
          }
          
          return filteredResults.take(5).toList(); // Limit to 5 results
        } else {
          print('Google Places API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching school suggestions: $e');
      return [];
    }
  }

  /// Search for companies and organizations using Google Places API
  Future<List<PlaceAutocomplete>> getCompanySuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      // Using Place Autocomplete API with type 'establishment' for companies/organizations
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/autocomplete/json'
          '?input=$query'
          '&types=establishment'
          '&components=country:lk' // Restrict to Sri Lanka, change as needed
          '&key=$_apiKey'
        ),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          List<dynamic> predictions = data['predictions'] ?? [];
          
          // Filter results to prioritize business establishments
          List<PlaceAutocomplete> filteredResults = predictions
              .where((prediction) => _isBusinessEstablishment(prediction['description'], prediction['types']))
              .map((prediction) => PlaceAutocomplete.fromJson(prediction))
              .toList();
          
          // If no business establishments found, return all results
          if (filteredResults.isEmpty) {
            filteredResults = predictions
                .map((prediction) => PlaceAutocomplete.fromJson(prediction))
                .toList();
          }
          
          return filteredResults.take(5).toList(); // Limit to 5 results
        } else {
          print('Google Places API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching company suggestions: $e');
      return [];
    }
  }

  /// Helper method to identify educational institutions
  bool _isEducationalInstitution(String description) {
    final educationalKeywords = [
      'school', 'college', 'university', 'institute', 'academy', 'campus',
      'educational', 'training', 'vocational', 'technical', 'polytechnic',
      'learning', 'center', 'centre', 'education'
    ];
    
    final lowerDescription = description.toLowerCase();
    return educationalKeywords.any((keyword) => lowerDescription.contains(keyword));
  }

  /// Helper method to identify business establishments
  bool _isBusinessEstablishment(String description, List<dynamic> types) {
    // Exclude educational institutions and residential areas
    final excludeKeywords = [
      'school', 'college', 'university', 'institute', 'academy', 'campus',
      'house', 'home', 'residence', 'apartment', 'flat'
    ];
    
    final businessTypes = [
      'establishment', 'point_of_interest', 'store', 'finance',
      'health', 'food', 'lodging', 'gas_station', 'shopping_mall'
    ];
    
    final lowerDescription = description.toLowerCase();
    final typeStrings = types.map((type) => type.toString().toLowerCase()).toList();
    
    // Exclude if contains exclude keywords
    if (excludeKeywords.any((keyword) => lowerDescription.contains(keyword))) {
      return false;
    }
    
    // Include if matches business types
    return businessTypes.any((type) => typeStrings.contains(type));
  }

  /// Search for cities and towns using Google Places API
  Future<List<PlaceAutocomplete>> getCitySuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      // Using Place Autocomplete API with type '(cities)' for cities/towns
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/autocomplete/json'
          '?input=$query'
          '&types=(cities)'
          '&components=country:lk' // Restrict to Sri Lanka, change as needed
          '&key=$_apiKey'
        ),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          List<dynamic> predictions = data['predictions'] ?? [];
          
          // Convert predictions to PlaceAutocomplete objects
          List<PlaceAutocomplete> results = predictions
              .map((prediction) => PlaceAutocomplete.fromJson(prediction))
              .toList();
          
          return results.take(5).toList(); // Limit to 5 results
        } else {
          print('Google Places API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching city suggestions: $e');
      return [];
    }
  }

  /// Get detailed information about a place (optional, for future use)
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/details/json'
          '?place_id=$placeId'
          '&fields=name,formatted_address,geometry,types'
          '&key=$_apiKey'
        ),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching place details: $e');
      return null;
    }
  }
}

/// Model class for autocomplete suggestions
class PlaceAutocomplete {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  PlaceAutocomplete({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
  });

  factory PlaceAutocomplete.fromJson(Map<String, dynamic> json) {
    return PlaceAutocomplete(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? json['description'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }

  @override
  String toString() => description;
}

/// Model class for detailed place information
class PlaceDetails {
  final String name;
  final String formattedAddress;
  final double? latitude;
  final double? longitude;
  final List<String> types;

  PlaceDetails({
    required this.name,
    required this.formattedAddress,
    this.latitude,
    this.longitude,
    required this.types,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']?['location'];
    return PlaceDetails(
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      latitude: location?['lat']?.toDouble(),
      longitude: location?['lng']?.toDouble(),
      types: List<String>.from(json['types'] ?? []),
    );
  }
}