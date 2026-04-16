import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/invitation_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_empty_state.dart';
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
                Expanded(child: _buildBody(controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recruitment Tracker', style: AppTheme.headlineLarge.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'Monitor incoming requests and sent invitations.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildBody(OwnerProjectsController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.sentInvitations.isEmpty && controller.receivedJoinRequests.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.secondary));
      }

      final hasRequests = controller.receivedJoinRequests.isNotEmpty;
      final hasSent = controller.sentInvitations.isNotEmpty;

      if (!hasRequests && !hasSent) {
        return AppEmptyState(
          icon: Icons.assignment_ind_outlined,
          title: 'No Recruitment Activity',
          subtitle: 'This is your Recruitment Hub. Monitor developer join requests and invitations you\'ve sent. Once there is activity, it will appear here.',
        );
      }

      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (hasRequests) ...[
            _SectionHeader(title: 'Incoming Join Requests', icon: Icons.move_to_inbox_rounded, color: AppTheme.secondary),
            const SizedBox(height: 12),
            ...controller.receivedJoinRequests.asMap().entries.map(
              (e) => _TrackingCard(invitation: e.value, isIncoming: true, index: e.key),
            ),
            const SizedBox(height: 24),
          ],
          if (hasSent) ...[
            _SectionHeader(title: 'Invitations Sent', icon: Icons.outbox_rounded, color: AppTheme.primary),
            const SizedBox(height: 12),
            ...controller.sentInvitations.asMap().entries.map(
              (e) => _TrackingCard(invitation: e.value, isIncoming: false, index: e.key),
            ),
            const SizedBox(height: 24),
          ],
        ],
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(title, style: AppTheme.titleLarge.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _TrackingCard extends StatelessWidget {
  final InvitationModel invitation;
  final bool isIncoming;
  final int index;

  const _TrackingCard({required this.invitation, required this.isIncoming, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OwnerProjectsController>();
    final String name = isIncoming ? invitation.senderName : (invitation.receiverName ?? 'Developer');
    final String? photoUrl = isIncoming ? invitation.senderPhotoUrl : invitation.receiverPhotoUrl;
    final bool isJoinRequest = invitation.status == 'join_request';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderColor: isJoinRequest ? AppTheme.secondary.withValues(alpha: 0.2) : null,
        child: Column(
          children: [
            InkWell(
              onTap: () => Get.toNamed('/owner_project_manage', arguments: invitation.projectId),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          backgroundColor: AppTheme.surfaceLight,
                          child: photoUrl == null ? const Icon(Icons.person, size: 20) : null,
                        ),
                        if (isJoinRequest)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppTheme.secondary,
                                border: Border.all(color: AppTheme.surface, width: 2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTheme.titleLarge.copyWith(fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            invitation.projectTitle,
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    StatusBadge.invitationStatus(invitation.status),
                  ],
                ),
              ),
            ),
            if (isJoinRequest) ...[
              const Divider(color: Colors.white10, height: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => controller.respondToJoinRequest(invitation.id, false),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                        child: const Text('Decline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.respondToJoinRequest(invitation.id, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
                          foregroundColor: AppTheme.secondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (invitation.status == 'accepted')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('TAP TO MANAGE', style: AppTheme.bodySmall.copyWith(color: AppTheme.secondary, letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 9)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, color: AppTheme.secondary, size: 10),
                  ],
                ),
              ),
          ],
        ),
      ),
    ).animate(delay: (80 * index).ms).fadeIn().slideX(begin: 0.1);
  }
}
