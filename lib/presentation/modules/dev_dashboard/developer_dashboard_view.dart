import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/project_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/match_score_badge.dart';
import '../auth/auth_controller.dart';
import 'developer_controller.dart';

class DeveloperDashboardView extends GetView<DeveloperController> {
  const DeveloperDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              onRefresh: controller.refreshMatches,
              child: CustomScrollView(
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
      expandedHeight: 130,
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
            Text(AppStrings.devDashboardSubtitle,
                style: AppTheme.bodyMedium.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return SliverToBoxAdapter(
      child: Obx(() {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              _StatChip(
                  label: 'Matches',
                  value: '${controller.matches.length}',
                  icon: Icons.hub_rounded,
                  highlight: true),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMatchesSection() {
    return Obx(() {
      if (controller.isLoading.value) {
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
        return SliverFillRemaining(
          child: _ErrorState(onRetry: controller.loadInitialData),
        );
      }

      if (controller.matches.isEmpty) {
        return const SliverFillRemaining(child: _EmptyState());
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

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: AppTheme.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.ownerName,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MatchScoreBadge(score: score / 100),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            project.description,
            style: AppTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (project.techStack.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.techStack
                  .take(5)
                  .map((skill) => _SkillChip(skill: skill))
                  .toList(),
            ),
          ],
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, curve: Curves.easeOutQuart);
  }
}

class _SkillChip extends StatelessWidget {
  final String skill;
  const _SkillChip({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(skill,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryLight,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          )),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: highlight
              ? AppTheme.primary.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlight
                ? AppTheme.primary.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 18,
                color: highlight ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(height: 6),
            Text(value,
                style: AppTheme.headlineMedium.copyWith(
                  color: highlight ? AppTheme.primary : AppTheme.textPrimary,
                )),
            Text(label,
                style: AppTheme.bodyMedium.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(AppStrings.noMatchesYet, style: AppTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(AppStrings.noMatchesSubtitle,
              style: AppTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(AppStrings.errorGeneric, style: AppTheme.headlineMedium),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRetry, child: Text(AppStrings.retryButton)),
        ],
      ),
    );
  }
}
