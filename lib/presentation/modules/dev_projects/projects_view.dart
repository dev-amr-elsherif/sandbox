import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/invitation_model.dart';
import '../../widgets/glass_card.dart';
import 'dev_invitations_controller.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    // We put the controller here since this view is used in the main shell
    final controller = Get.put(DevInvitationsController());

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(child: _buildInvitationsList(controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Invitations',
            style: AppTheme.headlineLarge.copyWith(fontSize: 28),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
          const SizedBox(height: 8),
          Text(
            'Direct recruitment requests from project owners.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
        ],
      ),
    );
  }

  Widget _buildInvitationsList(DevInvitationsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.invitations.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline_rounded, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text('No invitations yet', style: TextStyle(color: Colors.white60)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.invitations.length,
        itemBuilder: (context, index) {
          final invite = controller.invitations[index];
          return _InvitationCard(invite: invite, controller: controller, index: index);
        },
      );
    });
  }
}

class _InvitationCard extends StatelessWidget {
  final InvitationModel invite;
  final DevInvitationsController controller;
  final int index;

  const _InvitationCard({required this.invite, required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: invite.senderPhotoUrl != null ? NetworkImage(invite.senderPhotoUrl!) : null,
                  child: invite.senderPhotoUrl == null ? const Icon(Icons.person, size: 20) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invite.senderName, style: const TextStyle(color: AppTheme.primaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(invite.projectTitle, style: AppTheme.headlineMedium.copyWith(fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.declineInvitation(invite),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.acceptInvitation(invite),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
                      foregroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideY(begin: 0.1);
  }
}
