import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/models/invitation_model.dart';
import '../../../../data/providers/firebase_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../auth/auth_controller.dart';

class PublicProfileView extends StatefulWidget {
  const PublicProfileView({super.key});

  @override
  State<PublicProfileView> createState() => _PublicProfileViewState();
}

class _PublicProfileViewState extends State<PublicProfileView> {
  final FirebaseProvider _firebaseProvider = FirebaseProvider();
  final UserModel developer = Get.arguments['developer'];
  final ProjectModel? projectContext = Get.arguments['project'];
  
  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text('Developer Portfolio', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildBioCard(),
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final displayName = (developer.name.isNotEmpty) 
        ? developer.name 
        : (developer.githubUrl?.split('/').last ?? 'Developer');

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
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
              radius: 60,
              backgroundColor: AppTheme.cardBg,
              backgroundImage: developer.photoUrl != null && developer.photoUrl!.isNotEmpty ? NetworkImage(developer.photoUrl!) : null,
              child: developer.photoUrl == null || developer.photoUrl!.isEmpty ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          displayName,
          style: AppTheme.headlineLarge.copyWith(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (developer.githubSeniority != null) ...[
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
                  developer.githubSeniority!.toUpperCase(),
                  style: const TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          developer.email,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBioCard() {
    final skills = (developer.topAiSkills != null && developer.topAiSkills!.isNotEmpty) 
        ? developer.topAiSkills! 
        : developer.skills;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (developer.publicRepos != null || developer.followers != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (developer.publicRepos != null)
                  _buildStatColumn(Icons.source_rounded, 'Projects', developer.publicRepos!.toString()),
                if (developer.followers != null)
                  _buildStatColumn(Icons.people_alt_rounded, 'Followers', developer.followers!.toString()),
                if (developer.accountAgeYears != null && developer.accountAgeYears! > 0)
                  _buildStatColumn(Icons.calendar_today_rounded, 'Years Exp', developer.accountAgeYears!.toString()),
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
                  developer.aiBio ?? 'Experienced developer specialized in building high-performance applications.',
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (projectContext != null)
          DevSyncButton(
            id: 'btn_send_invite',
            onPressed: isSending ? null : _handleSendInvitation,
            isLoading: isSending,
            gradient: AppTheme.primaryGradient,
            child: const Text('Send Project Invitation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
             Get.snackbar('Coming Soon', 'Interactive Chat is under development.');
          },
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: const Text('Send Direct Message'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: const BorderSide(color: Colors.white24),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendInvitation() async {
    if (projectContext == null) return;
    
    final currentUser = Get.find<AuthController>().currentUser.value;
    if (currentUser == null) return;

    setState(() => isSending = true);

    try {
      final invitation = InvitationModel(
        id: '', 
        senderId: currentUser.uid,
        senderName: currentUser.name,
        senderPhotoUrl: currentUser.photoUrl,
        receiverId: developer.uid,
        receiverName: developer.name,
        receiverPhotoUrl: developer.photoUrl,
        projectId: projectContext!.id,
        projectTitle: projectContext!.title,
        timestamp: DateTime.now(),
      );

      await _firebaseProvider.sendInvitation(invitation);
      
      Get.back();
      Get.snackbar(
        'Success', 
        'Invitation sent to ${developer.name}!',
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send invitation: $e');
    } finally {
      setState(() => isSending = false);
    }
  }
}
