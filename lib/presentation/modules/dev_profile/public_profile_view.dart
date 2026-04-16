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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 2),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: developer.photoUrl != null ? NetworkImage(developer.photoUrl!) : null,
            child: developer.photoUrl == null ? const Icon(Icons.person, size: 60) : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          developer.name,
          style: AppTheme.headlineLarge,
        ),
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
          if (developer.githubSeniority != null) ...[
            Row(
              children: [
                const Icon(Icons.military_tech_rounded, color: AppTheme.primary, size: 24),
                const SizedBox(width: 8),
                Text('GitHub Seniority: ${developer.githubSeniority}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ]
            ),
            const Divider(color: Colors.white10, height: 32),
          ],
          
          if (developer.publicRepos != null || developer.followers != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (developer.publicRepos != null)
                  _buildStatColumn(Icons.source_rounded, 'Repos', developer.publicRepos!.toString()),
                if (developer.followers != null)
                  _buildStatColumn(Icons.people_alt_rounded, 'Followers', developer.followers!.toString()),
                if (developer.accountAgeYears != null && developer.accountAgeYears! > 0)
                  _buildStatColumn(Icons.calendar_today_rounded, 'Years', developer.accountAgeYears!.toString()),
              ],
            ),
            const Divider(color: Colors.white10, height: 32),
          ],
          
          const Text('Technical Expertise', style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (skills.isEmpty)
             Text('Not set', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map<Widget>((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Text(skill, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
              )).toList(),
            ),
            
          const Divider(color: Colors.white10, height: 40),
          Row(
            children: [
              Text(developer.aiBio != null ? 'GitHub Bio' : 'Bio', style: const TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
              if (developer.aiBio != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 16),
              ]
            ]
          ),
          const SizedBox(height: 8),
          Text(
            developer.aiBio ?? 'Experienced developer specialized in building high-performance applications.',
            style: AppTheme.bodyMedium,
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
