import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../data/models/invitation_model.dart';
import '../../../../data/providers/firebase_provider.dart';
import '../auth/auth_controller.dart';

class DevInvitationsController extends GetxController {
  final FirebaseProvider _firebaseProvider = FirebaseProvider();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<InvitationModel> invitations = <InvitationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenToInvitations();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _listenToInvitations() {
    final user = _authController.currentUser.value;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    
    _subscription?.cancel();
    _subscription = _firebaseProvider.streamInvitations(user.uid).listen(
      (data) {
        invitations.assignAll(data);
        isLoading.value = false;
      },
      onError: (error) {
        debugPrint('Error fetching invitations: $error');
        hasError.value = true;
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  void retry() => _listenToInvitations();

  Future<void> viewProjectDetails(String projectId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final project = await _firebaseProvider.getProject(projectId);
      Get.back(); // Close loading dialog
      
      if (project != null) {
        Get.toNamed('/project-details', arguments: project);
      } else {
        Get.snackbar('Error', 'Project not found');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to fetch project details');
    }
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

  // الموافقة على طلب الإلغاء من المالك
  Future<void> approveCancellation(InvitationModel invite) async {
    try {
      await _firebaseProvider.respondToCancellation(invite.id, true);
      Get.snackbar('Project Cancelled', 'You have agreed to cancel this project.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve cancellation');
    }
  }

  // رفض طلب الإلغاء (التمسك بالعمل)
  Future<void> declineCancellation(InvitationModel invite) async {
    try {
      await _firebaseProvider.respondToCancellation(invite.id, false);
      Get.snackbar('Feedback Sent', 'The owner has been notified that you wish to continue.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to decline cancellation');
    }
  }
}
