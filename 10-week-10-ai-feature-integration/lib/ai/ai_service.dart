import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiService {
  final _storage = const FlutterSecureStorage();
  static const _apiKeyFromEnvironment = String.fromEnvironment(
    'GEMINI_API_KEY',
  );
  final _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.0-flash:generateContent';

  Future<String> ask(String question) async {
    final storedApiKey = await _storage.read(key: 'ai_api_key');
    final apiKey = _apiKeyFromEnvironment.isNotEmpty
        ? _apiKeyFromEnvironment
        : storedApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key belum diatur.');
    }

    final response = await http.post(
      Uri.parse('$_apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': question},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      var details = response.body;
      try {
        final error =
            (jsonDecode(response.body) as Map<String, dynamic>)['error']
                as Map<String, dynamic>?;
        details = error?['message']?.toString() ?? details;
      } on FormatException {
        // Keep the raw response when Gemini returns a non-JSON error.
      }
      throw Exception('Gemini gagal (${response.statusCode}): $details');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    final text = candidates?.isNotEmpty == true
        ? (candidates!.first as Map<String, dynamic>)['content']
              as Map<String, dynamic>?
        : null;
    final parts = text?['parts'] as List<dynamic>?;
    final answer = parts?.isNotEmpty == true
        ? (parts!.first as Map<String, dynamic>)['text'] as String?
        : null;
    if (answer == null || answer.isEmpty) {
      throw Exception('AI tidak mengembalikan jawaban.');
    }
    return answer;
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'ai_api_key', value: key);
  }
}
