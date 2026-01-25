import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<List<Map<String, dynamic>>> generateDateSuggestions(
    List<String> interests,
  ) async {
    final prompt = _buildPrompt(interests);
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
      return _parseSuggestions(text);
    } else {
      throw Exception('Failed to get suggestions from Gemini AI');
    }
  }

  String _buildPrompt(List<String> interests) {
    return '''
  You are an expert date planner for couples. Take the following interests: ${interests.join(", ")}, and provide as many creative, fun, and couple-friendly date ideas as you can think of. 

  Each suggestion should have:
  - A short, catchy title
  - A playful, engaging description that explains the idea and why it would be enjoyable for a couple with these interests

  Format your response as a numbered list, with each number representing a unique date idea. Do not limit yourself to a specific number—be as creative and thorough as possible.
  ''';
  }

  List<Map<String, dynamic>> _parseSuggestions(String text) {
    final lines = text.split(RegExp(r'\n|\r\n'));
    final suggestions = <Map<String, dynamic>>[];
    for (var line in lines) {
      final match = RegExp(r'\d+\.\s*(.+?):\s*(.+)').firstMatch(line);
      if (match != null) {
        suggestions.add({
          'title': match.group(1)?.trim() ?? '',
          'desc': match.group(2)?.trim() ?? '',
        });
      }
    }
    return suggestions;
  }
}
