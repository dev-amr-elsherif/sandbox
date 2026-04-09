import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/manager_controller.dart';

class ManagerWorkspaceView extends GetView<ManagerController> {
  const ManagerWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (!controller.hasGeneratedSpecs.value) {
          return _buildEmptyState();
        }
        return _buildWorkspaceContent();
      }),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      title: Text(
        'Project Workspace',
        style: GoogleFonts.inter(
          color: AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondaryColor),
          onPressed: controller.resetSession,
        ),
      ],
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.architecture_rounded,
            size: 80,
            color: AppTheme.primaryColor.withAlpha(100),
          ),
          const SizedBox(height: 24),
          Text(
            'No Project Specs Found',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Go to the AI Architect Chat to define your project requirements first.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.textSecondaryColor),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Back to Chat'),
          ),
        ],
      ),
    );
  }

  // ─── Workspace Content ────────────────────────────────────────────────────

  Widget _buildWorkspaceContent() {
    final specs = controller.projectRequirements;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectSummary(specs),
          const SizedBox(height: 24),
          _buildSectionTitle('Technical Stack'),
          const SizedBox(height: 12),
          _buildTechStack(specs['tech_stack'] ?? {}),
          const SizedBox(height: 24),
          _buildSectionTitle('Developer Matches'),
          const SizedBox(height: 12),
          _buildDevelopersMatched(),
          const SizedBox(height: 24),
          _buildSectionTitle('Project Milestones'),
          const SizedBox(height: 12),
          _buildMilestones(specs['milestones'] ?? []),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimaryColor,
      ),
    );
  }

  Widget _buildProjectSummary(Map<String, dynamic> specs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20)),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withAlpha(30),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  specs['project_name'] ?? 'Untitled Project',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            specs['summary'] ?? 'No summary available.',
            style: GoogleFonts.inter(
              color: AppTheme.textSecondaryColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoBadge(Icons.timer_outlined, specs['timeline'] ?? 'N/A'),
              _buildInfoBadge(Icons.payments_outlined, specs['budget_estimate'] ?? 'N/A'),
              _buildInfoBadge(Icons.groups_outlined, specs['team_size'] ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTechStack(Map<dynamic, dynamic> tech) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tech.entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTechIcon(e.key.toString()),
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '${e.key}: ${e.value}',
                style: GoogleFonts.inter(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getTechIcon(String key) {
    switch (key.toLowerCase()) {
      case 'frontend': return Icons.phone_android_rounded;
      case 'backend': return Icons.storage_rounded;
      case 'ai': return Icons.psychology_rounded;
      case 'auth': return Icons.lock_person_rounded;
      default: return Icons.code_rounded;
    }
  }

  Widget _buildDevelopersMatched() {
    return Column(
      children: controller.matchedDevelopers.map((dev) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  dev['avatar'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dev['name'],
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      (dev['skills'] as List).join(', '),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${dev['score']}%',
                    style: GoogleFonts.inter(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    'Match',
                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondaryColor),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMilestones(List<dynamic> milestones) {
    return Column(
      children: milestones.map((m) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  m.toString(),
                  style: GoogleFonts.inter(color: AppTheme.textSecondaryColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Bottom Actions ───────────────────────────────────────────────────────

  Widget _buildBottomActions() {
    return Obx(() {
      if (!controller.hasGeneratedSpecs.value) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Invite Team'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_task_rounded, color: AppTheme.textPrimaryColor),
                onPressed: () {},
              ),
            ),
          ],
        ),
      );
    });
  }
}