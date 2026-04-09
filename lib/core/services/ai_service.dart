import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  AIService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are an expert Software Architect AI. Your mission is to help a Project Manager define technical requirements for their app idea.\n\n'
        'INSTRUCTIONS:\n'
        '1. In regular chat: Be helpful, professional, and ask clarifying questions about features, tech stack, and timeline.\n'
        '2. AT THE END OF EVERY MESSAGE (except when generating specs): You MUST provide exactly 3 suggested short user replies for the next step. Format them at the very end like this: [[Suggest: Option 1 | Option 2 | Option 3]]\n'
        '3. When the user asks to "Generate Specs" or similar finalization: You MUST return a valid JSON object matching this schema exactly:\n'
        '{\n'
        '  "project_name": "String",\n'
        '  "summary": "String",\n'
        '  "tech_stack": {\n'
        '    "frontend": "String",\n'
        '    "backend": "String",\n'
        '    "ai": "String",\n'
        '    "auth": "String"\n'
        '  },\n'
        '  "timeline": "String",\n'
        '  "budget_estimate": "String",\n'
        '  "required_skills": ["String"],\n'
        '  "complexity": "Low|Medium|High",\n'
        '  "team_size": "String",\n'
        '  "milestones": ["String"]\n'
        '}\n'
        'Do not include any text outside the JSON block when generating specs.',
      ),
    );
  }

  /// Start or resume a chat session
  ChatSession get chat {
    _chatSession ??= _model.startChat();
    return _chatSession!;
  }

  /// Send a message and get a stream of response chunks for real-time UI
  Stream<String> sendMessageStream(String message) {
    try {
      final stream = chat.sendMessageStream(Content.text(message));
      return stream.map((response) => response.text ?? "");
    } catch (e) {
      rethrow;
    }
  }

  /// Send a message and get a response with Retry Logic for 503/429 errors
  Future<String> sendMessage(String message, {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final response = await chat.sendMessage(Content.text(message));
        return response.text ?? "I couldn't process that. Please try again.";
      } catch (e) {
        attempts++;
        final errorString = e.toString();
        
        // Only retry if it's a server busy (503) or rate limit (429) error
        if (attempts < maxRetries && (errorString.contains('503') || errorString.contains('429'))) {
          print("🕒 Gemini Busy (Attempt $attempts)... Retrying in 2 seconds...");
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        rethrow; // Final attempt failed or other type of error
      }
    }
    throw Exception("Service temporarily unavailable after $maxRetries attempts.");
  }

  /// Generate structured project specs from the current context
  Future<Map<String, dynamic>> generateSpecs({int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
        final jsonModel = GenerativeModel(
          model: 'gemini-flash-latest',
          apiKey: apiKey,
          generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );

        final history = _chatSession?.history.toList() ?? [];
        history.add(Content.text("Generate the final project specifications in JSON format based on our discussion."));

        final response = await jsonModel.generateContent(history);
        
        final text = response.text ?? "{}";
        final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
        
        return jsonDecode(cleanJson) as Map<String, dynamic>;
      } catch (e) {
        attempts++;
        final errorString = e.toString();
        
        if (attempts < maxRetries && (errorString.contains('503') || errorString.contains('429'))) {
          print("🕒 Gemini Busy during Specs Generation (Attempt $attempts)... Retrying in 3s...");
          await Future.delayed(const Duration(seconds: 3));
          continue;
        }
        rethrow;
      }
    }
    return {};
  }

  /// Reset the conversation
  void reset() {
    _chatSession = null;
  }
}
