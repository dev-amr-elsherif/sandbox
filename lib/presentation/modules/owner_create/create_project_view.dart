import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../owner_dashboard/owner_controller.dart';

class CreateProjectView extends GetView<OwnerController> {
  const CreateProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    final techController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildManualForm(techController),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manual Project Creation',
          style: AppTheme.headlineLarge.copyWith(fontSize: 28),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
        const SizedBox(height: 8),
        Text(
          'Define your project requirements precisely and find the best developers.',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
      ],
    );
  }

  Widget _buildManualForm(TextEditingController techController) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Project Title'),
          TextField(
            onChanged: (v) => controller.projectTitle.value = v,
            decoration: InputDecoration(
              hintText: 'e.g. Fintech Mobile App',
              hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 24),
          
          _buildLabel('Description'),
          TextField(
            onChanged: (v) => controller.projectDescription.value = v,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe what you want to build...',
              hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 24),

          _buildLabel('Required Skills / Tech Stack'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: techController,
                  onSubmitted: (v) {
                    controller.addTech(v);
                    techController.clear();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Add a skill (e.g. Flutter)...',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  controller.addTech(techController.text);
                  techController.clear();
                },
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.techStack.map((tech) => _SkillChip(
              label: tech,
              onDelete: () => controller.removeTech(tech),
            )).toList(),
          )),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 800.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.primaryLight,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => DevSyncButton(
      id: 'btn_manual_create',
      onPressed: controller.isCreatingProject.value ? null : controller.createProject,
      isLoading: controller.isCreatingProject.value,
      gradient: AppTheme.primaryGradient,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rocket_launch_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Create & Match Developers',
            style: AppTheme.headlineMedium.copyWith(fontSize: 16),
          ),
        ],
      ),
    )).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _SkillChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
          const SizedBox(width: 4),
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded, size: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
