import 'package:get/get.dart';
import '../../../../data/models/invitation_model.dart';
import '../../../../data/providers/firebase_provider.dart';
import '../auth/auth_controller.dart';

class DevInvitationsController extends GetxController {
  final FirebaseProvider _firebaseProvider = FirebaseProvider();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<InvitationModel> invitations = <InvitationModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToInvitations();
  }

  void _listenToInvitations() {
    final user = _authController.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    invitations.bindStream(_firebaseProvider.streamInvitations(user.uid));
    
    // Once stream starts, we set loading to false
    ever(invitations, (_) => isLoading.value = false);
  }

  Future<void> acceptInvitation(InvitationModel invitation) async {
    try {
      await _firebaseProvider.updateInvitationStatus(invitation.id, 'accepted');
      Get.snackbar('Success', 'Project invitation accepted! 🚀');
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept invitation');
    }
  }

  Future<void> declineInvitation(InvitationModel invitation) async {
    try {
      await _firebaseProvider.updateInvitationStatus(invitation.id, 'declined');
      Get.snackbar('Declined', 'Invitation was declined.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to decline invitation');
    }
  }
}
