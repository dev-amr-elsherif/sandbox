import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/providers/firebase_provider.dart';
import '../../../../data/services/gemini_service.dart';
import '../../../../data/services/analytics_service.dart';
import '../../../../data/services/github_service.dart';
import '../auth/auth_controller.dart';

class DeveloperController extends GetxController {
  // المحركات الأساسية لجلب البيانات وحساب المطابقة
  final FirebaseProvider _firebaseProvider = Get.find<FirebaseProvider>();
  final GeminiService _geminiService = Get.find<GeminiService>();
  final AnalyticsService _analytics = Get.find<AnalyticsService>();
  final GithubService _githubService = GithubService();

  // ─── State ────────────────────────────────────────────────────────
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final RxList<Map<String, dynamic>> matches = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  UserModel? _developer;

  @override
  void onInit() {
    super.onInit();
    _developer = Get.find<AuthController>().currentUser.value;
    loadInitialData();
  }

  // ─── Initial Load ─────────────────────────────────────────────────
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      projects.clear();
      matches.clear();

      // جلب المشاريع من FirebaseProvider (بشكل مبسط حالياً)
      // ملاحظة: سنحتاج لإضافة getProjects في FirebaseProvider
      // سأقوم بإضافتها في الخطوة التالية أو كتابتها هنا كمثال
      // حالياً سأفترض وجودها كما في النسخة القديمة ولكن مبسطة
      
      // Fetching projects
      final snapshot = await _firebaseProvider.getProjects();
      // فلتر فقط المشاريع النشطة — لا تظهر المشاريع المنتهية/الملغاة
      projects.assignAll(snapshot.where((p) => p.status == 'active').toList());

      if (_developer != null && projects.isNotEmpty) {
        await _runAIMatching();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // تشغيل الذكاء الاصطناعي لمطابقة المطور مع المشاريع المتوفرة مع مراعاة نشاط GitHub
  Future<void> _runAIMatching() async {
    if (_developer == null) return;
    await _analytics.logAIMatchRequested();

    // جلب نشاط GitHub إذا كان متوفراً (اسم المستخدم مخزن حالياً في الاسم للحكاية، أو كحقل إضافي)
    // سنفترض وجود حقل Github في البروفايل أو نستخدم الاسم كافتراض للمثال
    final githubActivity = await _githubService.getUserActivity(_developer!.name.replaceAll(' ', ''));

    final List<Map<String, dynamic>> results = [];
    for (var project in projects) {
      final score = await _geminiService.calculateMatch(
        _developer!.skills.join(', '),
        project.description,
        githubActivity: githubActivity,
      );
      results.add({
        'project': project,
        'score': score,
      });
    }
    
    // Sort by score descending
    results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    matches.assignAll(results);
  }

  Future<void> refreshMatches() async {
    await _analytics.logProfileRefreshed();
    await loadInitialData();
  }

  UserModel? get developer => _developer;
}
