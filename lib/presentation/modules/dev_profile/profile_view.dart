import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../auth/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final user = controller.currentUser.value;

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(user),
                  const SizedBox(height: 32),
                  _buildProfileCard(user),
                  const SizedBox(height: 40),
                  _buildRefreshButton(controller),
                  const SizedBox(height: 16),
                  _buildLogoutButton(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(user) {
    final displayName = (user?.name != null && user!.name!.isNotEmpty) 
        ? user.name! 
        : (user?.githubUrl?.split('/').last ?? 'Developer');

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2),
                ],
              ),
            ),
            CircleAvatar(
              radius: 56,
              backgroundColor: AppTheme.cardBg,
              backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty ? NetworkImage(user.photoUrl!) : null,
              child: user?.photoUrl == null || user!.photoUrl!.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          displayName,
          style: AppTheme.headlineMedium.copyWith(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.military_tech_rounded, color: AppTheme.primaryLight, size: 18),
              const SizedBox(width: 8),
              Text(
                user?.githubSeniority?.toUpperCase() ?? 'DEVELOPER',
                style: const TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
        if (user?.role == 'developer' && user?.ratingCount != null && user!.ratingCount > 0) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < user.avgRating.floor() ? Icons.star_rounded : (index < user.avgRating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                  color: Colors.amber,
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${user.avgRating.toStringAsFixed(1)} (${user.ratingCount} reviews)',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryLight, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(
          user?.email ?? '',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildProfileCard(user) {
    final skills = (user?.topAiSkills != null && user!.topAiSkills!.isNotEmpty) 
        ? user.topAiSkills! 
        : (user?.skills ?? []);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user?.publicRepos != null || user?.followers != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (user?.publicRepos != null)
                  _buildStatColumn(Icons.source_rounded, 'Projects', user!.publicRepos!.toString()),
                if (user?.followers != null)
                  _buildStatColumn(Icons.people_alt_rounded, 'Followers', user!.followers!.toString()),
                if (user?.accountAgeYears != null && user!.accountAgeYears! > 0)
                  _buildStatColumn(Icons.calendar_today_rounded, 'Years Exp', user!.accountAgeYears!.toString()),
              ],
            ),
            const SizedBox(height: 32),
          ],
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2D3E), Color(0xFF1E202C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 10),
                    const Text('AI Developer Summary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ]
                ),
                const SizedBox(height: 12),
                Text(
                  user?.aiBio ?? 'No AI summary available yet. Tap "Refresh AI Portfolio" below to generate one.',
                  style: AppTheme.bodyMedium.copyWith(height: 1.6, color: Colors.white70),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            children: [
              const Icon(Icons.code_rounded, color: AppTheme.primaryLight, size: 22),
              const SizedBox(width: 8),
              const Text('Top Technologies', style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          if (skills.isEmpty)
             Text('No technologies detected.', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: skills.map<Widget>((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withValues(alpha: 0.1), blurRadius: 8, spreadRadius: 1)
                  ],
                ),
                child: Text(skill, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryLight, size: 28),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.headlineMedium.copyWith(fontSize: 20)),
        Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildRefreshButton(AuthController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => controller.refreshDeveloperPortfolio(),
        icon: const Icon(Icons.sync_rounded),
        label: const Text('Refresh AI Portfolio'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthController controller) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => controller.signOut(),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.error,
          side: const BorderSide(color: AppTheme.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
