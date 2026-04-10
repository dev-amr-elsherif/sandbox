import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/providers/firebase_provider.dart';
import '../../../../data/services/gemini_service.dart';
import '../../../../data/services/analytics_service.dart';
import '../auth/auth_controller.dart';

class OwnerController extends GetxController {
  // المحركات الأساسية لجلب البيانات وحساب المطابقة
  final FirebaseProvider _firebaseProvider = Get.find<FirebaseProvider>();
  final GeminiService _geminiService = Get.find<GeminiService>();
  final AnalyticsService _analytics = Get.find<AnalyticsService>();

  // ─── State ────────────────────────────────────────────────────────
  final RxList<ProjectModel> myProjects = <ProjectModel>[].obs;
  final RxList<Map<String, dynamic>> developerMatches = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isFindingDevelopers = false.obs;
  final RxBool isCreatingProject = false.obs;
  final Rx<ProjectModel?> selectedProject = Rx<ProjectModel?>(null);

  // ─── Form State ───────────────────────────────────────────────────
  final RxString projectTitle = ''.obs;
  final RxString projectDescription = ''.obs;
  final RxList<String> techStack = <String>[].obs;

  UserModel? _owner;

  @override
  void onInit() {
    super.onInit();
    _owner = Get.find<AuthController>().currentUser.value;
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      isLoading.value = true;
      final projects = await _firebaseProvider.getProjects();
      myProjects.assignAll(
        projects.where((p) => p.ownerId == _owner?.uid).toList(),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load projects');
    } finally {
      isLoading.value = false;
    }
  }

  // إنشاء مشروع جديد وحفظه في الفايربيز
  Future<void> createProject() async {
    if (projectTitle.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a project title');
      return;
    }
    if (_owner == null) return;

    try {
      isCreatingProject.value = true;
      final project = ProjectModel(
        id: '',
        ownerId: _owner!.uid,
        ownerName: _owner!.name,
        ownerPhotoUrl: _owner!.photoUrl,
        title: projectTitle.value.trim(),
        description: projectDescription.value.trim(),
        techStack: List.from(techStack),
      );

      final created = await _firebaseProvider.createProject(project);
      myProjects.insert(0, created);
      await _analytics.logProjectCreated(created.title);

      // Reset form
      projectTitle.value = '';
      projectDescription.value = '';
      techStack.clear();

      Get.snackbar('Success', 'Project created! finding best developers...',
          duration: const Duration(seconds: 2));

      // Navigate to recommendation results
      Get.toNamed('/match-results', arguments: created);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create project: $e');
    } finally {
      isCreatingProject.value = false;
    }
  }

  // ─── AI Developer Matching ────────────────────────────────────────
  Future<void> findDevelopersForProject(ProjectModel project) async {
    try {
      isFindingDevelopers.value = true;
      selectedProject.value = project;
      developerMatches.clear();

      final developers = await _firebaseProvider.getDevelopers();
      if (developers.isEmpty) return;

      final List<Map<String, dynamic>> results = [];
      for (var dev in developers) {
        final score = await _geminiService.calculateMatch(
          dev.skills.join(', '),
          project.description,
        );
        results.add({
          'developer': dev,
          'score': score,
        });
      }
      
      results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
      developerMatches.assignAll(results);
      await _analytics.logDeveloperSuggested();
    } catch (e) {
      Get.snackbar('AI Error', 'Matching temporarily unavailable');
    } finally {
      isFindingDevelopers.value = false;
    }
  }

  // ─── Tech Stack Management ────────────────────────────────────────
  void addTech(String tech) {
    final cleaned = tech.trim();
    if (cleaned.isNotEmpty && !techStack.contains(cleaned)) {
      techStack.add(cleaned);
    }
  }

  void removeTech(String tech) => techStack.remove(tech);

  UserModel? get owner => _owner;
}
