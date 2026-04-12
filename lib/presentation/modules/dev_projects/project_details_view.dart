import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/project_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/advanced_networking_animation.dart';

class ProjectDetailsView extends StatelessWidget {
  const ProjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          CustomScrollView(
            slivers: [
              _buildAppBar(project),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AdvancedNetworkingAnimation(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOwnerInfo(project),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Project Description'),
                        const SizedBox(height: 12),
                        _buildDescription(project.description),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Required Tech Stack'),
                        const SizedBox(height: 16),
                        _buildTechStack(project.techStack),
                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildBottomAction(project),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(ProjectModel project) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          project.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppTheme.surface.withValues(alpha: 0.5)),
            const Center(
              child: Icon(Icons.code_rounded, size: 80, color: Colors.white10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfo(ProjectModel project) {
    return GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project Owner', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
              Text(project.ownerName, style: AppTheme.headlineMedium.copyWith(fontSize: 18)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.headlineMedium.copyWith(fontSize: 20, color: AppTheme.primaryLight),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: AppTheme.bodyMedium.copyWith(height: 1.6, color: Colors.white70),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildTechStack(List<String> skills) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: skills.map((skill) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Text(skill, style: const TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.w500)),
      )).toList(),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildBottomAction(ProjectModel project) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5);
  }
}
