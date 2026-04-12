import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/invitation_model.dart';
import '../../widgets/glass_card.dart';
import 'owner_project_manage_controller.dart';

class OwnerProjectManageView extends StatelessWidget {
  const OwnerProjectManageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OwnerProjectManageController());

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(controller),
                Expanded(child: _buildMainContent(controller)),
                _buildBottomActions(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(OwnerProjectManageController controller) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 16),
          Text(
            controller.project.title,
            style: AppTheme.headlineLarge.copyWith(fontSize: 26),
          ).animate().fadeIn().slideX(begin: -0.2),
          const SizedBox(height: 4),
          Text(
            'Recruitment Management Hub',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(OwnerProjectManageController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(controller),
            const SizedBox(height: 32),
            Text('Invited Developers', style: AppTheme.headlineMedium),
            const SizedBox(height: 16),
            ...controller.invitations.map((invite) => _DeveloperStatusItem(invite: invite, controller: controller)),
            if (controller.invitations.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(child: Text('No developers invited yet', style: TextStyle(color: Colors.white24))),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStatsSection(OwnerProjectManageController controller) {
    return Row(
      children: [
        _StatBox(label: 'Invited', value: controller.invitations.length.toString(), color: AppTheme.primary),
        const SizedBox(width: 12),
        _StatBox(label: 'Accepted', value: controller.acceptedCount.value.toString(), color: AppTheme.success),
        const SizedBox(width: 12),
        _StatBox(label: 'Pending', value: controller.pendingCount.value.toString(), color: AppTheme.warning),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildBottomActions(OwnerProjectManageController controller) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Obx(() => ElevatedButton(
        onPressed: controller.acceptedCount.value > 0 ? null : controller.deleteEntireProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error.withValues(alpha: 0.2),
          foregroundColor: AppTheme.error,
          minimumSize: const Size(double.infinity, 56),
          disabledBackgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3))),
        ),
        child: Text(
          controller.acceptedCount.value > 0 ? 'Cannot Delete (Active Developers)' : 'Hard Delete Project',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        child: Column(
          children: [
            Text(value, style: AppTheme.headlineLarge.copyWith(color: color, fontSize: 24)),
            const SizedBox(height: 2),
            Text(label, style: AppTheme.bodySmall.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _DeveloperStatusItem extends StatelessWidget {
  final InvitationModel invite;
  final OwnerProjectManageController controller;

  const _DeveloperStatusItem({required this.invite, required this.controller});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (invite.status) {
      case 'accepted': statusColor = AppTheme.success; break;
      case 'declined': statusColor = AppTheme.error; break;
      case 'cancellation_proposed': statusColor = Colors.purpleAccent; break;
      case 'cancelled': statusColor = Colors.grey; break;
      default: statusColor = AppTheme.warning;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.surfaceLight,
              child: const Icon(Icons.person, size: 20, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.developerNames[invite.receiverId] ?? 'Loading...', 
                    style: AppTheme.titleLarge.copyWith(fontSize: 14)
                  ),
                  Text(
                    invite.status.capitalizeFirst!, 
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)
                  ),
                ],
              )),
            ),
            if (invite.status == 'accepted')
              IconButton(
                onPressed: () => _showApologyDialog(context),
                icon: const Icon(Icons.cancel_schedule_send_rounded, color: AppTheme.error),
                tooltip: 'Request Cancellation',
              ),
          ],
        ),
      ),
    );
  }

  void _showApologyDialog(BuildContext context) {
    final apologyController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Send Apology & Request Cancellation', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('To delete this project, you must first get approval from the accepted developer.', style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: apologyController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write your apology note here...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (apologyController.text.isNotEmpty) {
                controller.sendApology(invite.id, apologyController.text);
                Get.back();
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}
