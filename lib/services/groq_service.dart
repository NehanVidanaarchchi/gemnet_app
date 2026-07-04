import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  /// Change this single constant if Groq deprecates the model.
  static const String visionModel = 'qwen/qwen3.6-27b';

  final String apiKey;

  GroqService({required this.apiKey});

  static const String _systemPrompt = '''
You are a professional gemologist assistant. You will be shown a photo of a
loose gemstone. Analyze it carefully and respond with ONLY a raw JSON object
(no markdown fences, no commentary, no preamble) with exactly these keys:

{
  "type": string,            // best-guess gem species, e.g. "Blue Sapphire", "Ruby", "Cats Eye Chrysoberyl"
  "color": string,           // precise color description, e.g. "Cornflower blue"
  "estimatedWeightCarat": number, // best-effort numeric estimate, e.g. 2.35 (use 0 if impossible to estimate)
  "cut": string,             // e.g. "Oval mixed cut", "Cushion", "Cabochon"
  "clarityNotes": string,    // short clarity/inclusion observations
  "transparency": string,    // "Transparent" | "Translucent" | "Opaque" | "Semi-transparent"
  "originGuess": string,     // best-effort likely origin/region, e.g. "Possibly Sri Lanka (Ceylon)" — always caveat as a guess
  "confidence": number,      // your own confidence in this analysis, 0-100
  "description": string      // a 2-3 sentence natural-language summary suitable for a listing
}

Always fill every field with your best estimate — never leave a field empty.
If you are unsure, make a clearly-labeled best guess rather than omitting it.
Respond with raw JSON only.
''';

  /// Sends the image to Groq and returns a parsed map of gem fields.
  /// Throws an [Exception] with a user-readable message on failure.
  Future<Map<String, dynamic>> analyzeGemImage(File imageFile) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Groq API key is not configured. Add it in lib/config/app_config.dart');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode({
      'model': visionModel,
      'temperature': 0.2,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Analyze this gemstone photo and return the JSON as instructed.'},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
            },
          ],
        },
      ],
    });

    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw Exception('Could not reach Groq API. Check your internet connection. ($e)');
    }

    if (response.statusCode != 200) {
      throw Exception('Groq API error (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final content = decoded['choices']?[0]?['message']?['content'];
    if (content == null) {
      throw Exception('Groq API returned an unexpected response shape.');
    }

    String cleaned = content.toString().trim();
    // Defensive cleanup in case the model wraps the JSON in markdown fences.
    cleaned = cleaned.replaceAll(RegExp(r'^```json'), '').replaceAll(RegExp(r'^```'), '').replaceAll(RegExp(r'```$'), '').trim();

    try {
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      return parsed;
    } catch (e) {
      throw Exception('Could not parse Groq AI response as JSON: $cleaned');
    }
  }
}
