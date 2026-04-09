import 'package:get/get.dart';
import '../../../core/services/ai_service.dart';

class ManagerController extends GetxController {
  final AIService _aiService = Get.find<AIService>();

  // ─── Reactive Variables ───────────────────────────────────────────────────

  /// قائمة رسائل الشات — كل map فيها 'role' ('user' أو 'bot') و 'text'
  final chatMessages = <Map<String, String>>[].obs;

  /// حالة التحميل لما الـ AI بيشتغل
  final isAnalyzing = false.obs;

  /// النتائج النهائية اللي الـ AI طلعها بعد التحليل
  final projectRequirements = <String, dynamic>{}.obs;

  /// حالة عرض الـ workspace (بعد ما الـ specs تتولد)
  final hasGeneratedSpecs = false.obs;

  /// قائمة الاقتراحات التفاعلية (Quick Replies)
  final dynamicSuggestions = <String>[].obs;

  // ─── Suggested Prompts ────────────────────────────────────────────────────

  final List<String> suggestedPrompts = [
    "What is the best tech stack for an e-commerce app?",
    "I need a real-time chat app for 10,000 users",
    "Help me define requirements for a Flutter delivery app",
    "Estimate timeline for a social media MVP",
    "What backend suits a fintech startup?",
  ];

  // ─── Simulated Developer Matches ─────────────────────────────────────────
  // ─── Simulated Developer Matches ─────────────────────────────────────────

  final List<Map<String, dynamic>> matchedDevelopers = [
    {
      'name': 'Ahmed K.',
      'avatar': 'AK',
      'score': 94,
      'skills': ['Flutter', 'Firebase', 'Dart'],
      'github': 'github.com/ahmedk',
    },
    {
      'name': 'Sara M.',
      'avatar': 'SM',
      'score': 88,
      'skills': ['Flutter', 'Node.js', 'MongoDB'],
      'github': 'github.com/saram',
    },
    {
      'name': 'Omar F.',
      'avatar': 'OF',
      'score': 81,
      'skills': ['React Native', 'Firebase', 'TypeScript'],
      'github': 'github.com/omarf',
    },
  ];

  // ─── Methods ─────────────────────────────────────────────────────────────

  /// إضافة رسالة المدير وتوليد رد الـ AI في الوقت الحقيقي (Streaming)
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // أضف رسالة المدير
    chatMessages.add({'role': 'user', 'text': message.trim()});
    dynamicSuggestions.clear(); // مسح الاقتراحات السابقة

    // أضف مكان لرد الـ AI (رسالة فارغة سيتم تحديثها)
    final int botMessageIndex = chatMessages.length;
    chatMessages.add({'role': 'bot', 'text': ''});

    // ابدأ حالة التحليل
    isAnalyzing.value = true;

    String fullResponse = '';

    try {
      // المحاولة الأولى: البث المباشر (أسرع وأفضل تجربة مستخدم)
      print("🚀 Attempting to stream AI response...");
      final stream = _aiService.sendMessageStream(message.trim());
      
      await for (final chunk in stream) {
        fullResponse += chunk;
        chatMessages[botMessageIndex] = {'role': 'bot', 'text': fullResponse};
      }

      // إذا اكتمل البث بنجاح، نعالج الاقتراحات
      final cleanText = _handleDynamicSuggestions(fullResponse);
      chatMessages[botMessageIndex] = {'role': 'bot', 'text': cleanText};

    } catch (e) {
      print("⚠️ Streaming failed: $e. Falling back to normal request...");
      
      try {
        // المحاولة الثانية (Fallback): الطلب العادي مع الـ Retry Logic
        final botReply = await _aiService.sendMessage(message.trim());
        
        final cleanText = _handleDynamicSuggestions(botReply);
        chatMessages[botMessageIndex] = {'role': 'bot', 'text': cleanText};
        
      } catch (e2) {
        print("❌ All AI attempts failed: $e2");
        
        String errorMessage = '❌ Something went wrong.';
        final errorString = e2.toString();

        if (errorString.contains('503')) {
          errorMessage = '🕒 Gemini is currently busy. Please try again in a few seconds.';
        } else if (errorString.contains('429')) {
          errorMessage = '⚠️ API Rate limit reached.';
        } else {
          errorMessage = '❌ Error: $errorString';
        }

        chatMessages[botMessageIndex] = {
          'role': 'bot',
          'text': errorMessage,
        };
      }
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// تنظيف نص الـ AI واستخراج الاقتراحات [[Suggest: Opt1 | Opt2]]
  String _handleDynamicSuggestions(String text) {
    final regExp = RegExp(r'\[\[Suggest:\s*(.*?)\s*\]\]');
    final match = regExp.firstMatch(text);
    
    if (match != null) {
      final suggestionsText = match.group(1);
      if (suggestionsText != null) {
        final options = suggestionsText.split('|').map((e) => e.trim()).toList();
        dynamicSuggestions.assignAll(options);
      }
      // إزالة التاج من النص لكي لا يظهر للمستخدم بشكل خام
      return text.replaceFirst(regExp, '').trim();
    }
    
    return text;
  }

  /// توليد specs المشروع الحقيقية (JSON) من Gemini
  Future<void> generateProjectSpecs() async {
    if (chatMessages.isEmpty) return;

    isAnalyzing.value = true;
    
    try {
      final specs = await _aiService.generateSpecs();
      
      if (specs.isNotEmpty) {
        projectRequirements.value = specs;
        hasGeneratedSpecs.value = true;
        
        chatMessages.add({
          'role': 'bot',
          'text': '✅ Project specifications generated successfully! Navigate to your workspace to view the full breakdown and matched developers.',
        });

        Get.toNamed('/manager-workspace');
      } else {
        chatMessages.add({
          'role': 'bot',
          'text': '⚠️ The AI returned an empty response. Please try adding more details about your project first.',
        });
      }
    } catch (e) {
      final errorStr = e.toString();
      String userFriendlyError = '❌ Failed to generate specs: $errorStr';
      
      if (errorStr.contains('429')) {
        userFriendlyError = '⚠️ Quota Exceeded. Please wait about 60 seconds and try clicking "Generate Specs" again.';
      } else if (errorStr.contains('503')) {
        userFriendlyError = '🕒 Servers are busy. Please try again in a few moments.';
      }

      chatMessages.add({
        'role': 'bot',
        'text': userFriendlyError,
      });
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// مسح كل الشات والـ specs
  void resetSession() {
    chatMessages.clear();
    projectRequirements.clear();
    hasGeneratedSpecs.value = false;
    isAnalyzing.value = false;
    _aiService.reset();
  }
}
