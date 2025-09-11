import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetUserDataService {
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

  /// Get current user's basic information
  /// 
  /// Returns a UserData object containing firstName, lastName, email, phone, etc.
  /// Returns null if the request fails or user is not found.
  static Future<UserData?> getCurrentUserData() async {
    try {
      // Get the current user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) print('Error: User ID not found');
        return null;
      }

      return await getUserDataById(userId);
    } catch (e) {
      if (kDebugMode) print('Error getting current user data: $e');
      return null;
    }
  }

  /// Get user data by user ID
  /// 
  /// [userId] - The ID of the user to fetch data for
  /// 
  /// Returns a UserData object containing user information.
  /// Returns null if the request fails or user is not found.
  static Future<UserData?> getUserDataById(String userId) async {
    try {
      // Get the auth token
      final token = await _getAuthToken();
      if (token == null) {
        if (kDebugMode) print('Error: Auth token not found');
        return null;
      }

      if (kDebugMode) {
        print('Fetching user data for user ID: $userId');
      }

      // Make the API request
      final uri = Uri.parse('$_baseUrl/api/users/$userId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Get user data API Response Status: ${response.statusCode}');
        print('Get user data API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          final userData = UserData.fromJson(data['user'], data['profile']);
          
          if (kDebugMode) {
            print('User data retrieved successfully: ${userData.firstName} ${userData.lastName}');
          }
          
          return userData;
        } else {
          if (kDebugMode) print('API returned success: false - ${responseData['message']}');
          return null;
        }
      } else {
        final errorData = json.decode(response.body);
        if (kDebugMode) {
          print('Failed to get user data: ${response.statusCode}');
          print('Error message: ${errorData['message']}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting user data: $e');
      return null;
    }
  }

  /// Get user's address information specifically
  /// 
  /// Returns an AddressData object containing city, province, etc.
  /// Returns null if the request fails or address is not found.
  static Future<AddressData?> getCurrentUserAddress() async {
    try {
      final userData = await getCurrentUserData();
      if (userData?.address != null) {
        return userData!.address;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting user address: $e');
      return null;
    }
  }

  /// Get user's profile and cover photo links
  /// 
  /// Returns a Map containing 'profilePicture' and 'coverPhoto' URLs.
  /// Returns null if the request fails or user is not found.
  static Future<Map<String, String?>?> getCurrentUserPhotos() async {
    try {
      final userData = await getCurrentUserData();
      if (userData != null) {
        return {
          'profilePicture': userData.profilePicture,
          'coverPhoto': userData.coverPhoto,
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting user photos: $e');
      return null;
    }
  }

  /// Update current user's basic information
  /// 
  /// [userData] - UserUpdateData object containing fields to update
  /// 
  /// Returns true if the update was successful, false otherwise.
  static Future<bool> updateCurrentUserData(UserUpdateData userData) async {
    try {
      // Get the current user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        if (kDebugMode) print('Error: User ID not found');
        return false;
      }

      // Get the auth token
      final token = await _getAuthToken();
      if (token == null) {
        if (kDebugMode) print('Error: Auth token not found');
        return false;
      }

      // Prepare the request body
      final Map<String, dynamic> requestBody = userData.toJson();

      if (kDebugMode) {
        print('Updating user data for user ID: $userId');
        print('Update data: $requestBody');
      }

      // Make the API request
      final uri = Uri.parse('$_baseUrl/api/users/$userId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (kDebugMode) {
        print('Update user data API Response Status: ${response.statusCode}');
        print('Update user data API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (kDebugMode) print('User data updated successfully');
          return true;
        } else {
          if (kDebugMode) print('API returned success: false - ${responseData['message']}');
          return false;
        }
      } else {
        final errorData = json.decode(response.body);
        if (kDebugMode) {
          print('Failed to update user data: ${response.statusCode}');
          print('Error message: ${errorData['message']}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Error updating user data: $e');
      return false;
    }
  }

  /// Check if user is authenticated
  static Future<bool> isUserAuthenticated() async {
    final token = await _getAuthToken();
    final userId = await _getCurrentUserId();
    return token != null && token.isNotEmpty && userId != null && userId.isNotEmpty;
  }
}

/// Model class for user data
class UserData {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? userType;
  final String? profilePicture;
  final String? coverPhoto;
  final bool isVerified;
  final bool isActive;
  final DateTime? dateOfBirth;
  final AddressData? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileData? profile;

  UserData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.userType,
    this.profilePicture,
    this.coverPhoto,
    required this.isVerified,
    required this.isActive,
    this.dateOfBirth,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
  });

  factory UserData.fromJson(Map<String, dynamic> userJson, Map<String, dynamic>? profileJson) {
    return UserData(
      id: userJson['_id'] ?? '',
      firstName: userJson['firstName'] ?? '',
      lastName: userJson['lastName'] ?? '',
      email: userJson['email'] ?? '',
      phone: userJson['phone'],
      userType: userJson['userType'],
      profilePicture: userJson['profilePicture'],
      coverPhoto: userJson['coverPhoto'],
      isVerified: userJson['isVerified'] ?? false,
      isActive: userJson['isActive'] ?? true,
      dateOfBirth: userJson['dateOfBirth'] != null 
          ? DateTime.parse(userJson['dateOfBirth']) 
          : null,
      address: userJson['address'] != null 
          ? AddressData.fromJson(userJson['address']) 
          : null,
      createdAt: DateTime.parse(userJson['createdAt']),
      updatedAt: DateTime.parse(userJson['updatedAt']),
      profile: profileJson != null 
          ? ProfileData.fromJson(profileJson) 
          : null,
    );
  }

  String get fullName => '$firstName $lastName';
}

/// Model class for address data
class AddressData {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  AddressData({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}

/// Model class for profile data
class ProfileData {
  final String? bio;
  final List<String>? workerCategories;
  final Map<String, dynamic>? ratings;
  final int? completedJobs;

  ProfileData({
    this.bio,
    this.workerCategories,
    this.ratings,
    this.completedJobs,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      bio: json['bio'],
      workerCategories: json['workerCategories'] != null 
          ? List<String>.from(json['workerCategories']) 
          : null,
      ratings: json['ratings'],
      completedJobs: json['completedJobs'],
    );
  }
}

/// Model class for user update data
class UserUpdateData {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profilePicture;
  final String? coverPhoto;
  final AddressData? address;

  UserUpdateData({
    this.firstName,
    this.lastName,
    this.phone,
    this.profilePicture,
    this.coverPhoto,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (profilePicture != null) data['profilePicture'] = profilePicture;
    if (coverPhoto != null) data['coverPhoto'] = coverPhoto;
    if (address != null) data['address'] = address!.toJson();
    
    return data;
  }
}
