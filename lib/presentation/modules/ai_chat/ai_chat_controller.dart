import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../data/services/gemini_service.dart';
import '../auth/auth_controller.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/providers/firebase_provider.dart';

class AIChatController extends GetxController {
  final GeminiService _geminiService = Get.find<GeminiService>();
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseProvider _firebaseProvider = Get.find<FirebaseProvider>();

  final RxList<Content> history = <Content>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> proposedProject = <String, dynamic>{}.obs;

  late ChatSession _chatSession;

  @override
  void onInit() {
    super.onInit();
    _chatSession = _geminiService.startChat(history: history);
    
    // Initial greeting based on role
    _sendInitialGreeting();
  }

  void _sendInitialGreeting() async {
    final role = _authController.currentUser.value?.role;
    String greeting;
    if (role == 'owner') {
      greeting = "Hello! I am your Project Architect. Let's discuss your next big idea. What kind of project do you have in mind?";
    } else {
      greeting = "Hi there! I'm your DevSync assistant. How can I help you improve your profile or find the right project today?";
    }
    
    history.add(Content('model', [TextPart(greeting)]));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      isLoading.value = true;
      history.add(Content('user', [TextPart(text)]));
      
      final response = await _chatSession.sendMessage(Content.text(text));
      if (response.text != null) {
        history.add(Content('model', [TextPart(response.text!)]));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> finalizeProject() async {
    try {
      isLoading.value = true;
      final proposal = await _geminiService.extractProjectProposal(history);
      if (proposal != null) {
        proposedProject.assignAll(proposal);
      } else {
        Get.snackbar('AI Architect', 'I need a bit more information to define the project. Let\'s keep talking!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate proposal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmAndCreateProject() async {
    final proposal = proposedProject;
    if (proposal.isEmpty) return;

    try {
      isLoading.value = true;
      final user = _authController.currentUser.value;
      if (user == null) return;

      final project = ProjectModel(
        id: '', // Firestore will generate
        ownerId: user.uid,
        ownerName: user.name,
        ownerPhotoUrl: user.photoUrl,
        title: proposal['title'] ?? 'Untitled Project',
        description: proposal['description'] ?? '',
        techStack: List<String>.from(proposal['techStack'] ?? []),
        status: 'active',
      );

      final createdProject = await _firebaseProvider.createProject(project);
      proposedProject.clear(); // Reset
      
      Get.back(); // Close chat
      Get.snackbar('Success', 'Project "${createdProject.title}" has been created!');
      
      // Navigate to recommendation results
      Get.toNamed('/match-results', arguments: createdProject);
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to create project: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
