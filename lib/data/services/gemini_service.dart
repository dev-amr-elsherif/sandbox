import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  // خدمة بسيطة للتعامل مع الذكاء الاصطناعي
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: ApiConstants.geminiApiKey,
  );

  // بدء جلسة شات جديدة مع تذكر السياق
  ChatSession startChat({List<Content>? history}) {
    return _model.startChat(history: history);
  }

  // استخراج مقترح مشروع كامل بناءً على المحادثة
  Future<Map<String, dynamic>?> extractProjectProposal(List<Content> history) async {
    try {
      final prompt = '''
Based on the conversation above, extract a formal project proposal in JSON format.
If details are missing, use your best estimation to fill them based on context.
Return ONLY a valid JSON object with these keys:
"title": (string)
"description": (string short overview)
"techStack": (list of strings)
"ownerRequirements": (string)

Ensure the JSON is strictly correctly formatted.
''';
      
      // نرسل البرومبت كرسالة أخيرة في سياق المحادثة
      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(prompt));
      
      final text = response.text;
      if (text == null) return null;

      // تنظيف النص لاستخراج الـ JSON فقط في حال وجود نص إضافي
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) return null;
      
      final cleanJson = text.substring(jsonStart, jsonEnd + 1);
      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('DEBUG: Gemini extraction error: $e');
      return null;
    }
  }

  // حساب نسبة التطابق مع دمج نشاط GitHub لزيادة الدقة
  Future<double> calculateMatch(
    String skills, 
    String projectDescription, {
    Map<String, dynamic>? githubActivity,
  }) async {
    try {
      String githubContext = '';
      if (githubActivity != null && githubActivity['error'] == null) {
        githubContext = '''
User GitHub Activity:
- Top Languages: ${githubActivity['top_languages']?.join(', ') ?? 'N/A'}
- Recent Repos: ${githubActivity['recent_repos']?.join(', ') ?? 'N/A'}
''';
      }

      final prompt = '''
$githubContext
Rate the match between these developer skills: "$skills" and this project description: "$projectDescription".
Consider the GitHub activity if provided as a signal of proven expertise.
Return only a number between 0 and 100.
''';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return double.tryParse(response.text ?? '0.0') ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // ميزة تحسين الخوارزمية بناءً على رأي المستخدم (Feedback Loop)
  Future<void> logMatchFeedback(String matchId, bool isAccurate) async {
    // التوثيق للأغراض التحليلية لتحسين البرومبت في المستقبل
    debugPrint('DEBUG: Match $matchId marked as ${isAccurate ? 'Accurate' : 'Inaccurate'}');
    // Future: Save to Firestore for batch prompt tuning
  }

  // ميزة "مهندس المشاريع" - تحويل فكرة بسيطة إلى مشروع متكامل
  Future<Map<String, dynamic>?> expandProjectIdea(String miniConcept) async {
    try {
      final prompt = '''
        Analyze the following project idea: "$miniConcept".
        Expand it into a professional project draft for a developer recruitment platform.
        Return ONLY a JSON object with:
        "title": (A refined professional name)
        "description": (A detailed 3-4 sentence scope of work)
        "techStack": (A list of 5-8 relevant modern technologies)
        
        Ensure the output is strictly valid JSON.
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text;
      if (text == null) return null;

      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) return null;
      
      final cleanJson = text.substring(jsonStart, jsonEnd + 1);
      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('DEBUG: Gemini expansion error: $e');
      return null;
    }
  }
}
