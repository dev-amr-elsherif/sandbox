import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import 'auth_controller.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AnimatedBackground(),
          
          Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: Theme.of(context).inputDecorationTheme,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            child: ui.SignInScreen(
              providers: [
                ui.EmailAuthProvider(),
                GoogleProvider(clientId: 'GOOGLE_CLIENT_ID'),
              ],
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: _buildHeader()),
                );
              },
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: action == ui.AuthAction.signIn
                      ? const Text('Welcome back to DevSync!')
                      : const Text('Join the premium AI dev network.'),
                );
              },
              footerBuilder: (context, action) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    AppStrings.privacyNote,
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text('DevSync', style: AppTheme.displayMedium.copyWith(fontSize: 24)),
      ],
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
