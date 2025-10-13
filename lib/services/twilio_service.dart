import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secrets/app_secrets.dart';

class TwilioService {
  
  static const String _verificationCodeKey = 'verification_code';
  static const String _phoneNumberKey = 'verification_phone_number';
  
  /// Generates a 5-digit verification code
  String _generateVerificationCode() {
    final random = Random();
    final code = random.nextInt(90000) + 10000; // Generates 10000-99999
    return code.toString();
  }
  
  /// Saves verification code and phone number to SharedPreferences
  Future<void> _saveVerificationData(String code, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verificationCodeKey, code);
    await prefs.setString(_phoneNumberKey, phoneNumber);
  }
  
  /// Retrieves saved verification code from SharedPreferences
  Future<String?> _getSavedVerificationCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_verificationCodeKey);
  }
  
  /// Retrieves saved phone number from SharedPreferences
  Future<String?> _getSavedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneNumberKey);
  }
  
  /// Clears verification data from SharedPreferences
  Future<void> _clearVerificationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_verificationCodeKey);
    await prefs.remove(_phoneNumberKey);
  }
  
  /// Sends SMS verification code via Twilio
  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      // Generate 5-digit code
      final verificationCode = _generateVerificationCode();
      
      // Save to SharedPreferences
      await _saveVerificationData(verificationCode, phoneNumber);
      
      // Format phone number (ensure it starts with country code)
      String formattedPhoneNumber = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        // Remove leading zero if present and add country code
        formattedPhoneNumber = '${TwilioConfig.defaultCountryCode}${phoneNumber.replaceFirst(RegExp(r'^0'), '')}';
      }
      
      // Prepare Twilio API request
      final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/${TwilioConfig.accountSid}/Messages.json');
      
      // Create basic auth header
      final credentials = base64Encode(utf8.encode('${TwilioConfig.accountSid}:${TwilioConfig.authToken}'));
      
      // Prepare message body
      final messageBody = TwilioConfig.messageTemplate.replaceAll('{code}', verificationCode);
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': TwilioConfig.fromPhoneNumber,
          'To': formattedPhoneNumber,
          'Body': messageBody,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('SMS sent successfully');
        return true;
      } else {
        print('Failed to send SMS: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }
  
  /// Verifies the entered code against the saved code
  Future<VerificationResult> verifyCode(String enteredCode, String phoneNumber) async {
    try {
      final savedCode = await _getSavedVerificationCode();
      final savedPhoneNumber = await _getSavedPhoneNumber();
      
      if (savedCode == null || savedPhoneNumber == null) {
        return VerificationResult(
          isSuccess: false,
          message: 'No verification code found. Please request a new code.',
        );
      }
      
      // Check if phone numbers match
      if (savedPhoneNumber != phoneNumber) {
        return VerificationResult(
          isSuccess: false,
          message: 'Phone number mismatch. Please request a new code.',
        );
      }
      
      // Check if codes match
      if (savedCode == enteredCode) {
        // Clear verification data after successful verification
        await _clearVerificationData();
        return VerificationResult(
          isSuccess: true,
          message: 'Phone number verified successfully!',
        );
      } else {
        return VerificationResult(
          isSuccess: false,
          message: 'Invalid verification code. Please try again.',
        );
      }
    } catch (e) {
      print('Error verifying code: $e');
      return VerificationResult(
        isSuccess: false,
        message: 'An error occurred during verification. Please try again.',
      );
    }
  }
  
  /// Resends verification code
  Future<bool> resendVerificationCode(String phoneNumber) async {
    // Clear previous code and send new one
    await _clearVerificationData();
    return await sendVerificationCode(phoneNumber);
  }
}

/// Result class for verification operations
class VerificationResult {
  final bool isSuccess;
  final String message;
  
  VerificationResult({
    required this.isSuccess,
    required this.message,
  });
}