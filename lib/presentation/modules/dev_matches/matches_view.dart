import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MatchesView extends StatelessWidget {
  const MatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          const SafeArea(
            child: Center(
              child: Text(
                'AI Matches',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
