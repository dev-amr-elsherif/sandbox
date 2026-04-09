import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manager_controller.dart';

class AiArchitectChatView extends GetView<ManagerController> {
  AiArchitectChatView({super.key});

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ─── Colors (من AppTheme) ─────────────────────────────────────────────────
  static const _bg = Color(0xFF121212);
  static const _surface = Color(0xFF1E1E1E);
  static const _surfaceLight = Color(0xFF2A2A2A);
  static const _primary = Color(0xFF412991);
  static const _primaryLight = Color(0xFF5B3DB8);
  static const _accent = Color(0xFF02569B);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFF9E9E9E);
  static const _botBubble = Color(0xFF252535);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildChatArea()),
          _buildSuggestedPrompts(),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: _textPrimary,
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, _accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Architect',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Powered by Gemini 1.5 Flash',
                style: TextStyle(color: _textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Obx(
          () => controller.chatMessages.isNotEmpty
              ? TextButton.icon(
                  onPressed: controller.isAnalyzing.value
                      ? null
                      : controller.generateProjectSpecs,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                  label: const Text('Generate Specs'),
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryLight,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─── Chat Area ────────────────────────────────────────────────────────────

  Widget _buildChatArea() {
    return Obx(() {
      // auto-scroll لأسفل عند أي رسالة جديدة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      if (controller.chatMessages.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount:
            controller.chatMessages.length +
            (controller.isAnalyzing.value ? 1 : 0),
        itemBuilder: (context, index) {
          // Typing indicator في آخر العناصر
          if (index == controller.chatMessages.length &&
              controller.isAnalyzing.value) {
            return _buildTypingIndicator();
          }
          final msg = controller.chatMessages[index];
          final isUser = msg['role'] == 'user';
          return _buildMessageBubble(text: msg['text'] ?? '', isUser: isUser);
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF412991), Color(0xFF02569B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI Project Architect',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe your project idea in plain language.\nThe AI will analyze and define the full specs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildFeatureTag('🔧 Tech Stack'),
                _buildFeatureTag('📅 Timeline'),
                _buildFeatureTag('💰 Budget'),
                _buildFeatureTag('👥 Team Size'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: _primaryLight, fontSize: 12),
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, _accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                color: isUser ? _primary : _botBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: !isUser
                    ? Border.all(color: _primary.withValues(alpha: 0.2))
                    : null,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : _textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: _textSecondary,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, _accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _botBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: _primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _buildDot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: Duration(milliseconds: 600 + index * 200),
      curve: Curves.easeInOut,
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      child: Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: const BoxDecoration(
          color: _primaryLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ─── Suggested Prompts ────────────────────────────────────────────────────

  Widget _buildSuggestedPrompts() {
    return Obx(() {
      if (controller.chatMessages.isNotEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 42,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.suggestedPrompts.length,
          itemBuilder: (_, i) {
            final prompt = controller.suggestedPrompts[i];
            return GestureDetector(
              onTap: () {
                _inputController.text = prompt;
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _primary.withValues(alpha: 0.25)),
                ),
                child: Text(
                  prompt,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ─── Input Bar ────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _surfaceLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _primary.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _inputController,
                style: const TextStyle(color: _textPrimary, fontSize: 14),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Describe your project idea...',
                  hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Obx(() {
                return controller.isAnalyzing.value
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    controller.sendMessage(text);
  }
}
