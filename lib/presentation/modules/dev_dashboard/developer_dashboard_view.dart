import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/project_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../../../data/services/gemini_service.dart';
import '../../widgets/match_score_badge.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/skill_chip.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/stat_card.dart';
import '../auth/auth_controller.dart';
import '../dev_projects/dev_invitations_controller.dart';
import 'developer_controller.dart';

class DeveloperDashboardView extends GetView<DeveloperController> {
  const DeveloperDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: controller.refreshMatches,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(),
                  _buildStatsRow(),
                  _buildMatchesSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    final user = Get.find<AuthController>().currentUser.value;
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => Get.find<AuthController>().signOut(),
          icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, ${user?.name.split(' ').first ?? 'Developer'} 👋',
              style: AppTheme.headlineLarge.copyWith(fontSize: 18),
            ),
            Text(
              'Your personalized AI career matches.',
              style: AppTheme.bodyMedium.copyWith(fontSize: 10, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return SliverToBoxAdapter(
      child: Obx(() {
        final invitesController = Get.find<DevInvitationsController>();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatCard(
                    label: 'Match Score',
                    value: controller.matches.isNotEmpty ? '${(controller.matches.first['score']).toInt()}%' : '0%',
                    icon: Icons.auto_awesome_rounded,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    label: 'Active Jobs',
                    value: '${invitesController.activeProjectsCount}',
                    icon: Icons.work_history_rounded,
                    color: AppTheme.secondary,
                  ),
                ],
              ),
              if (invitesController.activeProjectsCount > 0) ...[
                const SizedBox(height: 24),
                _buildRecentActivity(invitesController),
              ],
            ],
          ).animate().fadeIn().slideY(begin: 0.1),
        );
      }),
    );
  }

  Widget _buildRecentActivity(DevInvitationsController invitesController) {
    final activeProjects = invitesController.invitations.where((i) => i.status == 'accepted').toList();
    if (activeProjects.isEmpty) return const SizedBox.shrink();
    
    final latest = activeProjects.first;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RESUME WORK', style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            const Icon(Icons.keyboard_arrow_right_rounded, color: AppTheme.textMuted, size: 16),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          borderColor: AppTheme.secondary.withValues(alpha: 0.3),
          onTap: () async {
             final project = await invitesController.fetchProject(latest.projectId);
             if (project != null) Get.toNamed('/project-details', arguments: project);
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.secondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(latest.projectTitle, style: AppTheme.titleLarge.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('TAP TO OPEN WORKSPACE', style: AppTheme.bodySmall.copyWith(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesSection() {
    return Obx(() {
      if (controller.isLoading.value && controller.matches.isEmpty) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: MatchCardShimmer(),
            ),
            childCount: 5,
          ),
        );
      }

      if (controller.hasError.value) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Oops! Something went wrong',
              subtitle: 'We couldn\'t load your matches. Please try again.',
              action: OutlinedButton(
                onPressed: controller.loadInitialData,
                child: const Text('RETRY'),
              ),
            ),
          ),
        );
      }

      if (controller.matches.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: Icons.search_off_rounded,
            title: 'No Matches Yet',
            subtitle: 'Complete your profile or explore public projects to get started.',
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final match = controller.matches[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _MatchCard(match: match, index: index),
            );
          },
          childCount: controller.matches.length,
        ),
      );
    });
  }
}

class _MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final int index;

  const _MatchCard({required this.match, required this.index});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = match['project'];
    final double score = match['score'];

    return GestureDetector(
      onTap: () => Get.toNamed('/project-details', arguments: project),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.title, style: AppTheme.headlineMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('By ${project.ownerName}', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MatchScoreBadge(score: score / 100),
                    const SizedBox(height: 6),
                    StatusBadge.projectStatus(project.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (project.techStack.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: project.techStack
                    .take(4)
                    .map((skill) => SkillChip(label: skill))
                    .toList(),
              ),
            ],
            const Divider(height: 32, color: Colors.white10),
            Row(
              children: [
                Text('AI Accuracy Feedback', style: AppTheme.bodySmall.copyWith(fontSize: 10, color: AppTheme.textMuted)),
                const Spacer(),
                _FeedbackIcon(matchId: project.id, isUp: true),
                const SizedBox(width: 8),
                _FeedbackIcon(matchId: project.id, isUp: false),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (100 * index).ms).fadeIn().slideY(begin: 0.1);
  }
}

class _FeedbackIcon extends StatelessWidget {
  final String matchId;
  final bool isUp;
  const _FeedbackIcon({required this.matchId, required this.isUp});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<GeminiService>().logMatchFeedback(matchId, isUp);
        Get.snackbar('Feedback Received', 'Thanks for the feedback!', 
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1), colorText: Colors.white);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
        child: Icon(isUp ? Icons.thumb_up_alt_rounded : Icons.thumb_down_alt_rounded, size: 14, color: AppTheme.textSecondary),
      ),
    );
  }
}
