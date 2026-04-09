import 'package:get/get.dart';
import 'dart:async';

class ManagerController extends GetxController {
  // ─── Reactive Variables ───────────────────────────────────────────────────

  /// قائمة رسائل الشات — كل map فيها 'role' ('user' أو 'bot') و 'text'
  final chatMessages = <Map<String, String>>[].obs;

  /// حالة التحميل لما الـ AI بيشتغل
  final isAnalyzing = false.obs;

  /// النتائج النهائية اللي الـ AI طلعها بعد التحليل
  final projectRequirements = <String, dynamic>{}.obs;

  /// حالة عرض الـ workspace (بعد ما الـ specs تتولد)
  final hasGeneratedSpecs = false.obs;

  // ─── Suggested Prompts ────────────────────────────────────────────────────

  final List<String> suggestedPrompts = [
    "What is the best tech stack for an e-commerce app?",
    "I need a real-time chat app for 10,000 users",
    "Help me define requirements for a Flutter delivery app",
    "Estimate timeline for a social media MVP",
    "What backend suits a fintech startup?",
  ];

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

  /// إضافة رسالة المدير وتوليد رد الـ AI
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // أضف رسالة المدير
    chatMessages.add({'role': 'user', 'text': message.trim()});

    // ابدأ حالة التحليل
    isAnalyzing.value = true;

    // محاكاة delay الـ AI (هيتاستبدل بـ Gemini API لاحقاً)
    await Future.delayed(const Duration(milliseconds: 1200));

    // رد الـ AI المحاكى
    final botReply = _generateSimulatedResponse(message);
    chatMessages.add({'role': 'bot', 'text': botReply});

    isAnalyzing.value = false;
  }

  /// توليد specs المشروع من كل الشات (هيتربط بـ Gemini لاحقاً)
  Future<void> generateProjectSpecs() async {
    if (chatMessages.isEmpty) return;

    isAnalyzing.value = true;
    await Future.delayed(const Duration(milliseconds: 2000));

    // محاكاة الـ JSON اللي Gemini هيرجعه
    projectRequirements.value = {
      'project_name': 'AI-Defined Project',
      'summary':
          'A cross-platform mobile application with AI-powered features, real-time data sync, and secure authentication.',
      'tech_stack': {
        'frontend': 'Flutter (Dart)',
        'backend': 'Firebase (Firestore + Cloud Functions)',
        'ai': 'Gemini 1.5 Flash',
        'auth': 'Firebase Auth + GitHub OAuth',
      },
      'timeline': '6 weeks',
      'budget_estimate': '\$3,000 – \$8,000',
      'required_skills': [
        'Flutter',
        'Firebase',
        'REST APIs',
        'AI Integration',
        'Git',
      ],
      'complexity': 'Medium-High',
      'team_size': '3–5 developers',
      'milestones': [
        'Week 1–2: Auth + Core Architecture',
        'Week 3–4: Main Features + AI Integration',
        'Week 5–6: Testing + Launch',
      ],
    };

    hasGeneratedSpecs.value = true;
    isAnalyzing.value = false;

    // إضافة رسالة تأكيد في الشات
    chatMessages.add({
      'role': 'bot',
      'text':
          '✅ Project specifications generated successfully! Navigate to your workspace to view the full breakdown and matched developers.',
    });
  }

  /// محاكاة ردود AI ذكية بناءً على كلام المدير
  String _generateSimulatedResponse(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('tech stack') || msg.contains('technology')) {
      return '🔧 Based on your requirements, I recommend:\n\n'
          '• **Frontend**: Flutter for cross-platform reach\n'
          '• **Backend**: Firebase for real-time + scalability\n'
          '• **AI Layer**: Gemini 1.5 Flash for smart features\n\n'
          'This stack ensures fast development with a small team. Want me to elaborate on any part?';
    }

    if (msg.contains('timeline') || msg.contains('deadline') || msg.contains('weeks')) {
      return '📅 Based on typical project complexity, I estimate:\n\n'
          '• **MVP**: 4–6 weeks with a team of 3–5\n'
          '• **Full Product**: 8–12 weeks\n\n'
          'Key milestones would be Auth (Week 1), Core Features (Weeks 2–4), and Polish + Launch (Weeks 5–6).\n\nShall I break this down further?';
    }

    if (msg.contains('budget') || msg.contains('cost') || msg.contains('price')) {
      return '💰 Here\'s a rough budget breakdown:\n\n'
          '• **Development**: \$2,000–\$6,000\n'
          '• **Firebase (monthly)**: \$25–\$150\n'
          '• **AI API (Gemini)**: Free tier available\n'
          '• **App Store fees**: \$125/year\n\n'
          'Total MVP estimate: **\$2,500–\$7,000**. Adjust based on team size.';
    }

    if (msg.contains('e-commerce') || msg.contains('shop') || msg.contains('store')) {
      return '🛒 For an e-commerce app, you\'ll need:\n\n'
          '• Product catalog with search & filters\n'
          '• Cart & checkout flow\n'
          '• Payment gateway (Stripe or local)\n'
          '• Order tracking\n'
          '• Admin dashboard\n\n'
          'Recommended stack: **Flutter + Firebase + Stripe**. Want me to estimate the full spec?';
    }

    if (msg.contains('chat') || msg.contains('real-time') || msg.contains('messaging')) {
      return '💬 Real-time chat at scale needs:\n\n'
          '• **Firebase Realtime DB** or Firestore with listeners\n'
          '• Push notifications (FCM)\n'
          '• Message encryption for privacy\n'
          '• Typing indicators & read receipts\n\n'
          'For 10K+ users, Cloud Functions will handle the heavy lifting. Shall I define the data model?';
    }

    // رد افتراضي ذكي
    return '🤔 Interesting! Based on what you\'ve described, this sounds like a **${_guessProjectType(msg)}** project.\n\n'
        'To define precise requirements, tell me:\n'
        '1. Who are the target users?\n'
        '2. What\'s your timeline?\n'
        '3. Any specific technical constraints?\n\n'
        'The more context you share, the better I can tailor the architecture for you.';
  }

  String _guessProjectType(String msg) {
    if (msg.contains('delivery') || msg.contains('food')) return 'Delivery & Logistics';
    if (msg.contains('social') || msg.contains('friend')) return 'Social Platform';
    if (msg.contains('health') || msg.contains('medical')) return 'HealthTech';
    if (msg.contains('education') || msg.contains('learn')) return 'EdTech';
    if (msg.contains('finance') || msg.contains('payment')) return 'FinTech';
    return 'Mobile Application';
  }

  /// مسح كل الشات والـ specs
  void resetSession() {
    chatMessages.clear();
    projectRequirements.clear();
    hasGeneratedSpecs.value = false;
    isAnalyzing.value = false;
  }
}
