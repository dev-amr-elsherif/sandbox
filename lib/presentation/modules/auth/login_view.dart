import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import 'auth_controller.dart';
import '../../widgets/custom_button.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Animated Background ──────────────────────────────────
          const _AnimatedBackground(),

          // ── Main Content ─────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 80),
                      // ── Logo + Title ───────────────────────────
                      _buildHeader()
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 200.ms)
                          .slideY(begin: -0.3, curve: Curves.easeOutCubic),

                      const Spacer(),

                      // ── Glass Card ─────────────────────────────
                      _buildLoginCard(context)
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 500.ms)
                          .slideY(begin: 0.3, curve: Curves.easeOutCubic),

                      const SizedBox(height: 24),

                      // ── Privacy Note ───────────────────────────
                      Center(
                        child: Text(
                          AppStrings.privacyNote,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
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
        // Glowing icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text(AppStrings.loginTitle, style: AppTheme.displayMedium),
        const SizedBox(height: 8),
        Text(AppStrings.loginSubtitle, style: AppTheme.bodyLarge),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      decoration: AppTheme.glassMorphismDecoration(
        borderRadius: 28,
        borderColor: Colors.white.withValues(alpha: 0.15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Google Button ──────────────────────────────────
              Obx(() => DevSyncButton(
                    id: 'btn_google_login',
                    onPressed: controller.isGoogleLoading.value
                        ? null
                        : controller.loginWithGoogle,
                    isLoading: controller.isGoogleLoading.value,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A5F), Color(0xFF1a2e4a)],
                    ),
                    borderColor: AppTheme.primary.withValues(alpha: 0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _GoogleIcon(),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.continueWithGoogle,
                          style: AppTheme.labelLarge,
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animated Background ──────────────────────────────────────────────────────
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: CustomPaint(
            painter: _OrbPainter(_controller.value),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double progress;
  _OrbPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Primary orb
    final x1 = size.width * 0.3 +
        math.sin(progress * 2 * math.pi) * size.width * 0.1;
    final y1 = size.height * 0.3 +
        math.cos(progress * 2 * math.pi) * size.height * 0.05;
    paint.shader = RadialGradient(
      colors: [
        AppTheme.primary.withValues(alpha: 0.25),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
        center: Offset(x1, y1), radius: size.width * 0.4));
    canvas.drawCircle(Offset(x1, y1), size.width * 0.4, paint);

    // Secondary orb
    final x2 = size.width * 0.7 +
        math.cos(progress * 2 * math.pi + math.pi) * size.width * 0.1;
    final y2 = size.height * 0.7 +
        math.sin(progress * 2 * math.pi + math.pi) * size.height * 0.05;
    paint.shader = RadialGradient(
      colors: [
        AppTheme.secondary.withValues(alpha: 0.15),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
        center: Offset(x2, y2), radius: size.width * 0.35));
    canvas.drawCircle(Offset(x2, y2), size.width * 0.35, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.progress != progress;
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
