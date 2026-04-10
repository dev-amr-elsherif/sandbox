import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import '../../../data/providers/firebase_provider.dart';
import '../../../data/models/invitation_model.dart';
import 'dart:async';
import '../dev_dashboard/developer_dashboard_view.dart';
import '../dev_projects/projects_view.dart';
import '../dev_matches/matches_view.dart';
import '../dev_profile/profile_view.dart';
import '../owner_dashboard/owner_dashboard_view.dart';
import '../owner_create/create_project_view.dart';
import '../owner_projects/my_projects_view.dart';
import '../owner_profile/owner_profile_view.dart';

class MainShellController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseProvider _firebaseProvider = FirebaseProvider();
  StreamSubscription? _invitationSubscription;

  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _startInvitationListener();
  }

  @override
  void onClose() {
    _invitationSubscription?.cancel();
    super.onClose();
  }

  void _startInvitationListener() {
    final user = _authController.currentUser.value;
    if (user == null || user.role != 'developer') return;

    _invitationSubscription = _firebaseProvider.streamInvitations(user.uid).listen((invitations) {
      if (invitations.isNotEmpty) {
        final latest = invitations.first;
        _showInvitationNotification(latest);
      }
    });
  }

  void _showInvitationNotification(InvitationModel invitation) {
    Get.snackbar(
      'New Project Invitation! 🚀',
      '${invitation.senderName} wants you for "${invitation.projectTitle}"',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blueAccent.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          // Future: Navigate to invitation details
          Get.back();
        },
        child: const Text('VIEW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  List<Widget> get pages {
    final role = _authController.currentUser.value?.role;
    if (role == 'developer') {
      return [
        const DeveloperDashboardView(),
        const ProjectsView(),
        const MatchesView(),
        const ProfileView(),
      ];
    } else {
      return [
        const OwnerDashboardView(),
        const CreateProjectView(),
        const MyProjectsView(),
        const OwnerProfileView(),
      ];
    }
  }

  List<BottomNavigationBarItem> get navItems {
    final role = _authController.currentUser.value?.role;
    if (role == 'developer') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.work_rounded), label: 'Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'Matches'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded), label: 'Create'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'My Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ];
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
