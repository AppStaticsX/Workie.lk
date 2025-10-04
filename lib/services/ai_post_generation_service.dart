import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../secrets/apikeys.dart';
class AIPostGenerationService {
  // Multiple API endpoints for redundancy (as suggested in Puter tutorial)
  static const List<Map<String, String>> _apiEndpoints = [
    {
      'name': 'Puter AI (Free)',
      'url': 'https://api.puter.com/drivers/openai/v1/chat/completions',
      'apiKey': '', // Puter provides free access without API key
      'model': 'gpt-4o-mini',
    },
    // Add more endpoints as backup
    {
      'name': 'OpenRouter (DeepSeek R1)',
      'url': 'https://openrouter.ai/api/v1/chat/completions',
      'apiKey': APIKEYS.DEEPSEEK_R1_API_KEY,
      'model': 'deepseek/deepseek-r1:free',
    },
  ];

  static const Duration _requestTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  /// Generate a post using AI with multiple fallback options
  static Future<AIPostResponse> generatePost({
    required String prompt,
    PostType postType = PostType.general,
    String? tone,
    int? maxLength,
    List<String>? hashtags,
  }) async {
    String systemPrompt = _buildSystemPrompt(postType, tone, maxLength, hashtags);
    
    for (int endpointIndex = 0; endpointIndex < _apiEndpoints.length; endpointIndex++) {
      final endpoint = _apiEndpoints[endpointIndex];
      
      if (kDebugMode) {
        print('Trying ${endpoint['name']} (${endpointIndex + 1}/${_apiEndpoints.length})');
      }
      
      for (int retry = 0; retry < _maxRetries; retry++) {
        try {
          final response = await _makeApiRequest(
            endpoint: endpoint,
            systemPrompt: systemPrompt,
            userPrompt: prompt,
          );
          
          if (response != null) {
            return AIPostResponse(
              success: true,
              generatedContent: response,
              apiUsed: endpoint['name']!,
              message: 'Content generated successfully',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Attempt ${retry + 1} failed for ${endpoint['name']}: $e');
            print('   URL: ${endpoint['url']}');
            print('   Model: ${endpoint['model']}');
            print('   Has API Key: ${endpoint['apiKey']!.isNotEmpty}');
          }
          
          if (retry == _maxRetries - 1) {
            if (kDebugMode) {
              print('🚫 All retries exhausted for ${endpoint['name']}');
            }
          } else {
            // Wait before retry with exponential backoff
            final delaySeconds = (retry + 1) * 2;
            if (kDebugMode) {
              print('⏳ Retrying in ${delaySeconds}s...');
            }
            await Future.delayed(Duration(seconds: delaySeconds));
          }
        }
      }
    }
    
    return AIPostResponse(
      success: false,
      generatedContent: '',
      apiUsed: 'None',
      message: 'All API endpoints failed. Please try again later.',
    );
  }

  /// Make API request to specific endpoint
  static Future<String?> _makeApiRequest({
    required Map<String, String> endpoint,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final headers = _buildHeaders(endpoint);
    final body = _buildRequestBody(endpoint, systemPrompt, userPrompt);

    try {
      final response = await http.post(
        Uri.parse(endpoint['url']!),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (kDebugMode) {
          print('API Response: ${response.body}');
        }
        
        // Handle OpenAI/Puter format
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final choice = data['choices'][0];
          if (choice['message'] != null && choice['message']['content'] != null) {
            final content = choice['message']['content'];
            return _cleanupContent(content.toString());
          }
        }
        
        // Alternative response format (for some APIs)
        if (data['response'] != null) {
          return _cleanupContent(data['response'].toString());
        }
        
        // Direct content field
        if (data['content'] != null) {
          return _cleanupContent(data['content'].toString());
        }
        
        if (kDebugMode) {
          print('Unexpected response format: $data');
        }
        throw Exception('Unexpected response format: ${data.keys.join(', ')}');
      } else {
        if (kDebugMode) {
          print('HTTP Error ${response.statusCode}: ${response.body}');
        }
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API request error: $e');
      }
      rethrow;
    }
  }

  /// Build headers for API request
  static Map<String, String> _buildHeaders(Map<String, String> endpoint) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add authorization if API key is provided
    if (endpoint['apiKey']!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${endpoint['apiKey']}';
    }

    // Add specific headers based on API
    if (endpoint['url']!.contains('openrouter.ai')) {
      headers['HTTP-Referer'] = 'https://workie.lk';
      headers['X-Title'] = 'Workie - AI Post Generator';
    } else if (endpoint['url']!.contains('puter.com')) {
      headers['User-Agent'] = 'Workie/1.0';
      // Puter doesn't require Authorization header when no API key
      if (endpoint['apiKey']!.isEmpty) {
        headers.remove('Authorization');
      }
    }

    return headers;
  }

  /// Build request body for API
  static Map<String, dynamic> _buildRequestBody(
    Map<String, String> endpoint,
    String systemPrompt,
    String userPrompt,
  ) {
    return {
      'model': endpoint['model'],
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'max_tokens': 500,
      'temperature': 0.7,
      'top_p': 0.9,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    };
  }

  /// Build system prompt based on post requirements
  static String _buildSystemPrompt(
    PostType postType,
    String? tone,
    int? maxLength,
    List<String>? hashtags,
  ) {
    String basePrompt = '''You are an expert social media content creator for Workie, a professional platform for skilled workers and job seekers.

Create engaging, professional social media posts that:
- Are authentic and relatable
- Include relevant emojis naturally
- Use proper grammar and formatting
- Are optimized for engagement''';

    // Add post type specific instructions
    switch (postType) {
      case PostType.job:
        basePrompt += '\n- Focus on job opportunities, career advice, or professional development';
        break;
      case PostType.achievement:
        basePrompt += '\n- Celebrate accomplishments and milestones professionally';
        break;
      case PostType.tip:
        basePrompt += '\n- Share valuable tips, insights, or industry knowledge';
        break;
      case PostType.question:
        basePrompt += '\n- Engage the community with thoughtful questions';
        break;
      case PostType.general:
        basePrompt += '\n- Create general professional content suitable for the platform';
        break;
    }

    // Add tone specification
    if (tone != null && tone.isNotEmpty) {
      basePrompt += '\n- Use a $tone tone throughout the post';
    }

    // Add length constraint
    if (maxLength != null) {
      basePrompt += '\n- Keep the post under $maxLength characters';
    }

    // Add hashtag guidance
    if (hashtags != null && hashtags.isNotEmpty) {
      basePrompt += '\n- Consider incorporating these hashtags naturally: ${hashtags.join(', ')}';
    }

    basePrompt += '''\n\nRules:
- Do NOT include hashtags in the generated content (they will be added separately)
- Do NOT use quotation marks around the entire post
- Do NOT add meta-commentary like "Here's your post:"
- Return ONLY the post content, nothing else
- Keep it engaging but professional''';

    return basePrompt;
  }

  /// Clean up the generated content
  static String _cleanupContent(String content) {
    // Remove common unwanted patterns
    content = content.trim();
    
    // Remove quotes if the entire content is wrapped in quotes
    if ((content.startsWith('"') && content.endsWith('"')) ||
        (content.startsWith("'") && content.endsWith("'"))) {
      content = content.substring(1, content.length - 1);
    }
    
    // Remove meta-commentary patterns
    final metaPatterns = [
      RegExp(r"^Here's your post:?\s*", caseSensitive: false),
      RegExp(r"^Here's a post:?\s*", caseSensitive: false),
      RegExp(r'^Post:?\s*', caseSensitive: false),
      RegExp(r'^Here you go:?\s*', caseSensitive: false),
    ];
    
    for (final pattern in metaPatterns) {
      content = content.replaceFirst(pattern, '');
    }
    
    return content.trim();
  }

  /// Generate hashtag suggestions based on content
  static Future<List<String>> generateHashtagSuggestions({
    required String content,
    int maxSuggestions = 10,
  }) async {
    try {
      final prompt = '''Based on this post content, suggest $maxSuggestions relevant hashtags for a professional platform like LinkedIn. 

Post content: "$content"

Return only the hashtags (without # symbol), one per line, no additional text or formatting.''';

      final response = await generatePost(
        prompt: prompt,
        postType: PostType.general,
      );

      if (response.success) {
        return response.generatedContent
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .map((line) => line.replaceAll('#', '').trim())
            .where((tag) => tag.isNotEmpty)
            .take(maxSuggestions)
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating hashtag suggestions: $e');
      }
    }
    
    return [];
  }

  /// Check if any API endpoint is available
  static Future<bool> checkApiAvailability() async {
    for (final endpoint in _apiEndpoints) {
      try {
        if (kDebugMode) {
          print('🔍 Testing ${endpoint['name']}...');
        }
        
        final response = await _makeApiRequest(
          endpoint: endpoint,
          systemPrompt: 'You are a helpful assistant.',
          userPrompt: 'Say "OK" if you can respond.',
        ).timeout(Duration(seconds: 10));
        
        if (response != null) {
          if (kDebugMode) {
            print('✅ ${endpoint['name']} is working');
          }
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ ${endpoint['name']} failed: $e');
        }
        continue;
      }
    }
    if (kDebugMode) {
      print('🚫 No API endpoints are available');
    }
    return false;
  }

  /// Test a specific endpoint (for debugging)
  static Future<String?> testEndpoint(String endpointName) async {
    final endpoint = _apiEndpoints.firstWhere(
      (e) => e['name'] == endpointName,
      orElse: () => _apiEndpoints.first,
    );
    
    try {
      if (kDebugMode) {
        print('🧪 Testing $endpointName with simple prompt...');
      }
      
      return await _makeApiRequest(
        endpoint: endpoint,
        systemPrompt: 'You are a helpful assistant.',
        userPrompt: 'Say "Hello World" in a friendly way.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Test failed for $endpointName: $e');
      }
      rethrow;
    }
  }
}

/// Enum for different post types
enum PostType {
  general,
  job,
  achievement,
  tip,
  question,
}

/// Response model for AI post generation
class AIPostResponse {
  final bool success;
  final String generatedContent;
  final String apiUsed;
  final String message;

  AIPostResponse({
    required this.success,
    required this.generatedContent,
    required this.apiUsed,
    required this.message,
  });

  @override
  String toString() {
    return 'AIPostResponse(success: $success, apiUsed: $apiUsed, message: $message)';
  }
}

/// Extension for easy post type conversion
extension PostTypeExtension on PostType {
  String get displayName {
    switch (this) {
      case PostType.general:
        return 'General';
      case PostType.job:
        return 'Job/Career';
      case PostType.achievement:
        return 'Achievement';
      case PostType.tip:
        return 'Tip/Advice';
      case PostType.question:
        return 'Question';
    }
  }

  String get description {
    switch (this) {
      case PostType.general:
        return 'General professional content';
      case PostType.job:
        return 'Job opportunities and career content';
      case PostType.achievement:
        return 'Celebrate accomplishments';
      case PostType.tip:
        return 'Share valuable insights';
      case PostType.question:
        return 'Engage with questions';
    }
  }
}