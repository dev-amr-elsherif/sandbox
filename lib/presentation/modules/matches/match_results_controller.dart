import 'package:get/get.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/providers/firebase_provider.dart';
import '../../../../data/services/gemini_service.dart';

class MatchResultsController extends GetxController {
  final FirebaseProvider _firebaseProvider = FirebaseProvider();
  final GeminiService _geminiService = GeminiService();

  final RxList<Map<String, dynamic>> rankedDevelopers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  
  late ProjectModel project;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ProjectModel) {
      project = Get.arguments;
      _loadAndRankDevelopers();
    } else {
      Get.back();
      Get.snackbar('Error', 'Project data not found');
    }
  }

  Future<void> _loadAndRankDevelopers() async {
    try {
      isLoading.value = true;
      rankedDevelopers.clear();

      // 1. Fetch all developers
      final developers = await _firebaseProvider.getDevelopers();
      
      // 2. Rank each developer
      final List<Map<String, dynamic>> results = [];
      
      for (final dev in developers) {
        final skillsString = dev.skills.join(', ');
        final score = await _geminiService.calculateMatch(
          skillsString, 
          '${project.title}: ${project.description}'
        );
        
        results.add({
          'developer': dev,
          'score': score,
        });
      }

      // 3. Sort by score descending
      results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
      
      rankedDevelopers.assignAll(results);
    } catch (e) {
      Get.snackbar('Error', 'Failed to rank developers: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
