import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secrets/app_secrets.dart';

class GoogleTranslateService {
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  static const String _detectUrl = 'https://translation.googleapis.com/language/translate/v2/detect';
  
  /// Translate text to user's preferred language
  /// Returns null if translation is not needed (same language) or if error occurs
  static Future<String?> translatePostContent({
    required String content,
    required String userPreferredLanguage,
  }) async {
    try {
      // First detect the source language
      final detectedLanguage = await _detectLanguage(content);
      
      if (detectedLanguage == null) {
        print('🔍 Could not detect language for content');
        return null;
      }
      
      print('🔍 Detected language: $detectedLanguage, User preferred: $userPreferredLanguage');
      
      // If detected language is same as user preferred, no translation needed
      if (detectedLanguage == userPreferredLanguage) {
        print('✅ Content is already in user\'s preferred language');
        return null;
      }
      
      // Perform translation
      final translatedText = await _translateText(
        text: content,
        targetLanguage: userPreferredLanguage,
        sourceLanguage: detectedLanguage,
      );
      
      return translatedText;
    } catch (e) {
      print('❌ Translation error: $e');
      return null;
    }
  }
  
  /// Detect the language of given text
  static Future<String?> _detectLanguage(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_detectUrl?key=${APIKEYS.GOOGLE_MAPS_API_KEY}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'q': text,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detections = data['data']['detections'][0];
        if (detections != null && detections.isNotEmpty) {
          final detectedLanguage = detections[0]['language'];
          final confidence = detections[0]['confidence'];
          
          print('🔍 Language detection: $detectedLanguage (confidence: $confidence)');
          return detectedLanguage;
        }
      } else {
        print('❌ Language detection failed: ${response.statusCode} - ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('❌ Language detection error: $e');
      return null;
    }
  }
  
  /// Translate text from source language to target language
  static Future<String?> _translateText({
    required String text,
    required String targetLanguage,
    required String sourceLanguage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=${APIKEYS.GOOGLE_MAPS_API_KEY}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'q': text,
          'source': sourceLanguage,
          'target': targetLanguage,
          'format': 'text',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translations = data['data']['translations'];
        
        if (translations != null && translations.isNotEmpty) {
          final translatedText = translations[0]['translatedText'];
          print('✅ Translation successful');
          return translatedText;
        }
      } else {
        print('❌ Translation failed: ${response.statusCode} - ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('❌ Translation error: $e');
      return null;
    }
  }
  
  /// Get user's preferred language from LanguageProvider
  static Future<String> getUserPreferredLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      return languageCode;
    } catch (e) {
      print('❌ Error getting user preferred language: $e');
      return 'en'; // Default to English
    }
  }
  
  /// Convert language codes to display names
  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'si':
        return 'Sinhala';
      case 'ta':
        return 'Tamil';
      case 'hi':
        return 'Hindi';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'zh':
        return 'Chinese';
      case 'ar':
        return 'Arabic';
      case 'ru':
        return 'Russian';
      case 'pt':
        return 'Portuguese';
      case 'it':
        return 'Italian';
      case 'nl':
        return 'Dutch';
      default:
        return languageCode.toUpperCase();
    }
  }
  
  /// Check if translation is supported for given language code
  static bool isLanguageSupported(String languageCode) {
    // Google Translate supports 100+ languages
    // Here we list the common ones, but Google Translate API supports many more
    const supportedLanguages = [
      'en', 'si', 'ta', 'hi', 'es', 'fr', 'de', 'ja', 'ko', 'zh', 'ar', 'ru',
      'pt', 'it', 'nl', 'pl', 'tr', 'vi', 'th', 'id', 'ms', 'sw', 'he',
      'fa', 'ur', 'bn', 'gu', 'mr', 'te', 'kn', 'ml', 'or', 'pa', 'as',
      'ne', 'my', 'km', 'lo', 'ka', 'am', 'is', 'mt', 'cy', 'ga', 'eu',
      'ca', 'gl', 'sv', 'da', 'no', 'fi', 'et', 'lv', 'lt', 'sk', 'cs',
      'hu', 'ro', 'bg', 'hr', 'sr', 'bs', 'mk', 'sq', 'sl', 'uk', 'be',
      'az', 'kk', 'ky', 'uz', 'tg', 'mn', 'hy', 'yo', 'ig', 'ha', 'zu',
      'af', 'sq', 'ny'
    ];
    
    return supportedLanguages.contains(languageCode);
  }
}