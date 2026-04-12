import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import 'ai_chat_controller.dart';
import '../auth/auth_controller.dart';

class AIChatView extends GetView<AIChatController> {
  const AIChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final authController = Get.find<AuthController>();
    final isOwner = authController.currentUser.value?.role == 'owner';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.history.length,
              itemBuilder: (context, index) {
                final message = controller.history[index];
                return _buildMessageBubble(message);
              },
            )),
          ),
          
          // منطقة عرض المقترح في حال تم توليده
          Obx(() {
            final proposal = controller.proposedProject;
            if (proposal.isEmpty) return const SizedBox.shrink();
            return _buildProposalCard(proposal);
          }),

          // زر إنهاء النقاش وتوليد المشروع (خاص بصاحب المشروع)
          if (isOwner) 
            Obx(() => controller.proposedProject.isEmpty 
              ? _buildFinalizeButton() 
              : const SizedBox.shrink()),

          _buildInputArea(textController),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
          const SizedBox(width: 12),
          Text('Project Architect', style: AppTheme.headlineMedium),
          const Spacer(),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Content content) {
    final bool isModel = content.role == 'model';
    final String text = content.parts.whereType<TextPart>().map((e) => e.text).join();

    return Align(
      alignment: isModel ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: isModel ? Colors.white.withValues(alpha: 0.05) : AppTheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isModel ? Radius.zero : const Radius.circular(16),
            bottomRight: isModel ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildProposalCard(Map<String, dynamic> proposal) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rocket_launch_rounded, color: AppTheme.primary, size: 20),
                SizedBox(width: 8),
                Text('Proposed Project', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(proposal['title'] ?? '', style: AppTheme.headlineMedium.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              proposal['description'] ?? '',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.confirmAndCreateProject(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm & Create Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalizeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton.icon(
        onPressed: () => controller.finalizeProject(),
        icon: const Icon(Icons.task_alt_rounded),
        label: const Text('Finalize Concept & Generate Project'),
        style: TextButton.styleFrom(foregroundColor: AppTheme.primaryLight),
      ),
    );
  }

  Widget _buildInputArea(TextEditingController textController) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Discuss project dimensions...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) {
                  controller.sendMessage(val);
                  textController.clear();
                },
              ),
            ),
            Obx(() => controller.isLoading.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    onPressed: () {
                      controller.sendMessage(textController.text);
                      textController.clear();
                    },
                    icon: const Icon(Icons.send_rounded, color: AppTheme.primary),
                  )),
          ],
        ),
      ),
    );
  }
}
