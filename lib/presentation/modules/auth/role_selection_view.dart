import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/user_model.dart';
import 'auth_controller.dart';

class RoleSelectionView extends GetView<AuthController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // ── Header ──────────────────────────────────────
                  Text(AppStrings.chooseRole, style: AppTheme.displayMedium)
                      .animate()
                      .fadeIn(duration: 700.ms)
                      .slideX(begin: -0.2),
                  const SizedBox(height: 8),
                  Text(AppStrings.roleSelectionSubtitle, style: AppTheme.bodyLarge)
                      .animate()
                      .fadeIn(duration: 700.ms, delay: 100.ms)
                      .slideX(begin: -0.2),

                  const SizedBox(height: 56),

                  // ── Role Cards ──────────────────────────────────
                  _RoleCard(
                    id: 'card_role_developer',
                    role: UserRole.developer,
                    title: AppStrings.developer,
                    description: AppStrings.developerDesc,
                    icon: Icons.code_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3D3BF3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    delay: 300,
                  ),

                  const SizedBox(height: 20),

                  _RoleCard(
                    id: 'card_role_owner',
                    role: UserRole.owner,
                    title: AppStrings.projectOwner,
                    description: AppStrings.projectOwnerDesc,
                    icon: Icons.rocket_launch_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    delay: 450,
                  ),

                  const Spacer(),

                  // ── Loading indicator ───────────────────────────
                  Obx(() => controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : const SizedBox.shrink()),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String id;
  final UserRole role;
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final int delay;

  const _RoleCard({
    required this.id,
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.delay,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleController.reverse();
  void _onTapUp(_) => _scaleController.forward();
  void _onTapCancel() => _scaleController.forward();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        key: ValueKey(widget.id),
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () => controller.selectRole(widget.role),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              // Icon Box
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.colors.first.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: AppTheme.headlineMedium),
                    const SizedBox(height: 6),
                    Text(widget.description, style: AppTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 700.ms, delay: Duration(milliseconds: widget.delay))
        .slideX(begin: 0.15, curve: Curves.easeOutQuart);
  }
}
