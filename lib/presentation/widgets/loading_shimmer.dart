import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';

class MatchCardShimmer extends StatelessWidget {
  const MatchCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceLight,
      highlightColor: AppTheme.cardBg,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(width: 160, height: 16),
                      const SizedBox(height: 8),
                      _ShimmerBox(width: 100, height: 12),
                    ],
                  ),
                ),
                _ShimmerBox(width: 56, height: 56, radius: 28),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ShimmerBox(width: 60, height: 22, radius: 11),
                const SizedBox(width: 8),
                _ShimmerBox(width: 80, height: 22, radius: 11),
                const SizedBox(width: 8),
                _ShimmerBox(width: 50, height: 22, radius: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
