import 'package:get/get.dart';
import '../../../../data/models/invitation_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/providers/firebase_provider.dart';

class OwnerProjectManageController extends GetxController {
  final FirebaseProvider _firebaseProvider = FirebaseProvider();
  
  late ProjectModel project;
  final RxList<InvitationModel> invitations = <InvitationModel>[].obs;
  final RxMap<String, String> developerNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  // Stats
  final RxInt pendingCount = 0.obs;
  final RxInt acceptedCount = 0.obs;
  final RxInt declinedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    project = Get.arguments;
    _loadProjectInvitations();
  }

  Future<void> _loadProjectInvitations() async {
    isLoading.value = true;
    try {
      final list = await _firebaseProvider.getInvitationsByProject(project.id);
      invitations.assignAll(list);
      _updateStats();
      
      // Fetch names for all receivers
      for (var invite in list) {
        if (!developerNames.containsKey(invite.receiverId)) {
          final user = await _firebaseProvider.getUser(invite.receiverId);
          developerNames[invite.receiverId] = user != null ? user.name : 'Unknown Developer';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load recruitment data');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStats() {
    pendingCount.value = invitations.where((i) => i.status == 'pending').length;
    acceptedCount.value = invitations.where((i) => i.status == 'accepted').length;
    declinedCount.value = invitations.where((i) => i.status == 'declined').length;
  }

  Future<void> deleteEntireProject() async {
    // إذا كان هناك مقبولين، يجب إرسال اعتذار أولاً لكل واحد
    if (acceptedCount.value > 0) {
      Get.snackbar('Important', 'You must settle with all accepted developers before deletion');
      return;
    }

    try {
      await _firebaseProvider.hardDeleteProject(project.id);
      Get.back();
      Get.snackbar('Success', 'Project deleted from database');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete project');
    }
  }

  Future<void> sendApology(String invitationId, String apology) async {
    try {
      await _firebaseProvider.proposeCancellation(invitationId, apology);
      await _loadProjectInvitations(); // Refresh
      Get.snackbar('Success', 'Apology sent to developer');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send apology');
    }
  }
}
