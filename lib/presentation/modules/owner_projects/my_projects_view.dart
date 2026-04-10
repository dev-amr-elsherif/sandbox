import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/invitation_model.dart';
import '../../widgets/glass_card.dart';
import 'owner_projects_controller.dart';

class MyProjectsView extends StatelessWidget {
  const MyProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OwnerProjectsController());

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(child: _buildTrackingList(controller)),
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
            'Recruitment Tracker',
            style: AppTheme.headlineLarge.copyWith(fontSize: 28),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
          const SizedBox(height: 8),
          Text(
            'Track the status of invitations sent to developers.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
        ],
      ),
    );
  }

  Widget _buildTrackingList(OwnerProjectsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.sentInvitations.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_ind_outlined, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text('No invitations sent yet', style: TextStyle(color: Colors.white60)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.sentInvitations.length,
        itemBuilder: (context, index) {
          final invite = controller.sentInvitations[index];
          return _TrackingCard(invite: invite, index: index);
        },
      );
    });
  }
}

class _TrackingCard extends StatelessWidget {
  final InvitationModel invite;
  final int index;

  const _TrackingCard({required this.invite, required this.index});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (invite.status) {
      case 'accepted':
        statusColor = Colors.greenAccent;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Accepted';
        break;
      case 'declined':
        statusColor = AppTheme.error;
        statusIcon = Icons.cancel_rounded;
        statusText = 'Declined';
        break;
      default:
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.hourglass_empty_rounded;
        statusText = 'Pending';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invite.projectTitle, style: const TextStyle(color: AppTheme.primaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Invited: ${invite.receiverId.substring(0, 8)}...', style: AppTheme.headlineMedium.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Sent: ${invite.timestamp.day}/${invite.timestamp.month}', style: TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 8),
                  Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.1);
  }
}
