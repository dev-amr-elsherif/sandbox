import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/project_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/match_score_badge.dart';
import '../auth/auth_controller.dart';
import 'owner_controller.dart';

class OwnerDashboardView extends GetView<OwnerController> {
  const OwnerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildAddProjectButton(),
                _buildProjectsList(),
                _buildDeveloperMatchesSection(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
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
              '${user?.name.split(' ').first ?? "Owner"}\'s Projects 🚀',
              style: AppTheme.headlineLarge.copyWith(fontSize: 18),
            ),
            Text(AppStrings.ownerDashboardTitle,
                style: AppTheme.bodyMedium.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProjectButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: DevSyncButton(
          id: 'btn_add_project',
          onPressed: () => _showCreateProjectSheet(Get.context!),
          gradient: AppTheme.primaryGradient,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(AppStrings.addProject, style: AppTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: MatchCardShimmer(),
            ),
            childCount: 3,
          ),
        );
      }

      if (controller.myProjects.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.folder_open_rounded,
                      size: 64, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text('No projects yet', style: AppTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Tap "Add Project" to get started',
                      style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            final project = controller.myProjects[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _ProjectCard(project: project, index: i),
            );
          },
          childCount: controller.myProjects.length,
        ),
      );
    });
  }

  Widget _buildDeveloperMatchesSection() {
    return Obx(() {
      if (controller.selectedProject.value == null) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.suggestedDevelopers,
                  style: AppTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'For "${controller.selectedProject.value!.title}"',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              if (controller.isFindingDevelopers.value)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.secondary),
                      SizedBox(height: 12),
                      Text('AI is finding best developers...',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              else
                ...controller.developerMatches.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _DeveloperMatchCard(
                          match: e.value,
                          index: e.key,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }

  void _showCreateProjectSheet(BuildContext context) {
    final techController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.createProject, style: AppTheme.headlineLarge),
              const SizedBox(height: 20),

              // Title
              TextField(
                onChanged: (v) => controller.projectTitle.value = v,
                decoration: const InputDecoration(
                  labelText: 'Project Title *',
                  hintText: 'e.g. E-commerce Mobile App',
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                onChanged: (v) => controller.projectDescription.value = v,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What are you building?',
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),

              // Tech Stack
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: techController,
                      decoration: const InputDecoration(
                        labelText: 'Tech Stack',
                        hintText: 'Flutter, Firebase...',
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                      onSubmitted: (v) {
                        controller.addTech(v);
                        techController.clear();
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.addTech(techController.text);
                      techController.clear();
                    },
                    icon: const Icon(Icons.add_circle_rounded,
                        color: AppTheme.primary),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.techStack
                        .map((t) => Chip(
                              label: Text(t,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 12)),
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                              deleteIconColor: AppTheme.textMuted,
                              onDeleted: () => controller.removeTech(t),
                              side: BorderSide.none,
                            ))
                        .toList(),
                  )),

              const SizedBox(height: 24),
              Obx(() => DevSyncButton(
                    id: 'btn_create_project',
                    onPressed: controller.isCreatingProject.value
                        ? null
                        : controller.createProject,
                    isLoading: controller.isCreatingProject.value,
                    gradient: AppTheme.primaryGradient,
                    child: Text(AppStrings.findDevelopers,
                        style: AppTheme.labelLarge),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final int index;

  const _ProjectCard({required this.project, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.find<OwnerController>().findDevelopersForProject(project),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(project.title, style: AppTheme.headlineMedium),
                ),
                _StatusBadge(status: project.status),
              ],
            ),
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                project.description,
                style: AppTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (project.techStack.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: project.techStack
                    .take(4)
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                               horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.secondary.withValues(alpha: 0.3)),
                          ),
                          child: Text(t,
                               style: AppTheme.codeMono.copyWith(fontSize: 10)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text('Tap to find developers',
                    style: AppTheme.bodyMedium.copyWith(
                      fontSize: 11,
                      color: AppTheme.primary,
                    )),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    if (status == 'active') {
      color = AppTheme.success;
      label = 'Active';
    } else if (status == 'paused') {
      color = AppTheme.warning;
      label = 'Paused';
    } else if (status == 'completed') {
      color = AppTheme.textMuted;
      label = 'Done';
    } else {
      color = AppTheme.textMuted;
      label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: AppTheme.bodyMedium.copyWith(color: color, fontSize: 11)),
    );
  }
}

class _DeveloperMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final int index;

  const _DeveloperMatchCard({required this.match, required this.index});

  @override
  Widget build(BuildContext context) {
    final UserModel developer = match['developer'];
    final double score = match['score'];

    return GestureDetector(
      onTap: () => Get.toNamed(
        '/public-profile', 
        arguments: {
          'developer': developer, 
          'project': Get.find<OwnerController>().selectedProject.value
        }
      ),
      child: GlassCard(
        borderColor: AppTheme.secondary.withValues(alpha: 0.2),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
              backgroundImage: developer.photoUrl != null
                  ? NetworkImage(developer.photoUrl!)
                  : null,
              child: developer.photoUrl == null
                  ? Text(
                      developer.name.isNotEmpty
                          ? developer.name[0].toUpperCase()
                          : '?',
                      style: AppTheme.headlineMedium,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(developer.name, style: AppTheme.titleLarge),
                  const SizedBox(height: 4),
                  if (developer.skills.isNotEmpty) ...[
                    Text(
                      developer.skills.take(3).join(' • '),
                      style: AppTheme.bodyMedium.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            MatchScoreBadge(score: score / 100, size: 52),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.1);
  }
}
