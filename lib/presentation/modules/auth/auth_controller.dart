import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../../../../core/services/github_analyzer_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/providers/firebase_provider.dart';
import '../../../../data/services/analytics_service.dart';

class AuthController extends GetxController {
  final FirebaseProvider _firebaseProvider = Get.find<FirebaseProvider>();
  final AnalyticsService _analytics = Get.find<AnalyticsService>();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      debugPrint('DEBUG: authStateChanges emitted. User: ${firebaseUser?.uid}');
      
      if (firebaseUser != null) {
        // Prevent race condition: if a manual login is in progress (fetching AI data), 
        // let the manual login function handle the profile sync and navigation.
        if (!isLoading.value) {
          await _syncUserProfile(firebaseUser);
          _analytics.setUserId(firebaseUser.uid);
        }
      } else {
        currentUser.value = null;
        if (Get.currentRoute != '/onboarding') {
          Get.offAllNamed('/onboarding');
        }
      }
    });
  }

  Future<void> _syncUserProfile(User firebaseUser) async {
    try {
      final userModel = await _firebaseProvider.getUser(firebaseUser.uid);
      if (userModel != null) {
        // User already exists, just update local state and navigate
        currentUser.value = userModel;
        _navigateBasedOnRole(userModel);
      }
    } catch (e) {
      debugPrint('Error syncing profile: $e');
    }
  }

  Future<void> loginAsDeveloper() async {
    try {
      isLoading.value = true;
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      
      final UserCredential credential = await _auth.signInWithProvider(githubProvider);
      
      if (credential.user != null) {
        String? token;
        String? githubUsername;
        
        if (credential.credential != null && credential.credential is OAuthCredential) {
          final oauthCred = credential.credential as OAuthCredential;
          token = oauthCred.accessToken;
          githubUsername = credential.additionalUserInfo?.profile?['login']?.toString();
          debugPrint('DEBUG: GitHub Login Success. Token: ${token != null ? 'EXISTS' : 'NULL'}, Username: $githubUsername');
        } else {
          debugPrint('DEBUG: credential.credential is null or not OAuthCredential. It is: ${credential.credential.runtimeType}');
        }

        Map<String, dynamic>? aiAnalysis;
        
        if (token != null && githubUsername != null) {
          try {
            final analyzer = GithubAnalyzerService();
            aiAnalysis = await analyzer.analyzeProfile(githubUsername, token);
            Get.snackbar('Success', 'AI Portfolio built successfully!');
          } catch (backendError) {
            debugPrint('GitHub analysis failed: $backendError');
            
            // Abort the login process
            await _auth.signOut();
            
            Get.snackbar(
              'GitHub Error', 
              'Failed to analyze your GitHub profile. Check your internet connection or GitHub status.',
              backgroundColor: const Color(0xFFB00020).withValues(alpha: 0.8),
              colorText: const Color(0xFFFFFFFF),
              duration: const Duration(seconds: 6),
            );
            return; // Stop the flow
          }
        }

        // Force create/update profile as Developer
        await _createOrUpdateProfile(credential.user!, 'developer', aiAnalysis: aiAnalysis);
      }
    } catch (e) {
      debugPrint('GitHub Login Error: $e');
      Get.snackbar('Authentication Failed', 'Could not sign in with GitHub: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginAsOwner() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // User canceled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCred = await _auth.signInWithCredential(credential);
      
      if (userCred.user != null) {
        await _analytics.logGoogleLogin();
        // Force create/update profile as Owner
        await _createOrUpdateProfile(userCred.user!, 'owner');
      }
    } catch (e) {
      debugPrint('Google Login Error: $e');
      Get.snackbar('Authentication Failed', 'Could not sign in with Google: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createOrUpdateProfile(User firebaseUser, String role, {Map<String, dynamic>? aiAnalysis}) async {
    try {
      final existingUser = await _firebaseProvider.getUser(firebaseUser.uid);
      
      final UserModel userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? existingUser?.email ?? '',
        name: firebaseUser.displayName ?? existingUser?.name ?? '',
        photoUrl: firebaseUser.photoURL ?? existingUser?.photoUrl,
        role: role, 
        skills: existingUser?.skills ?? [],
        githubUrl: aiAnalysis?['githubUrl'] ?? existingUser?.githubUrl,
        aiBio: aiAnalysis?['aiBio'] ?? existingUser?.aiBio,
        githubSeniority: aiAnalysis?['githubSeniority'] ?? existingUser?.githubSeniority,
        topAiSkills: aiAnalysis != null ? List<String>.from(aiAnalysis['topAiSkills'] ?? []) : existingUser?.topAiSkills,
      );

      await _firebaseProvider.saveUser(userModel);
      currentUser.value = userModel;
      await _analytics.logRoleSelected(role);
      
      _navigateBasedOnRole(userModel);
    } catch (e) {
      debugPrint('Error creating profile: $e');
      Get.snackbar('Error', 'Failed to configure your profile.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    currentUser.value = null;
    Get.offAllNamed('/onboarding');
  }

  void _navigateBasedOnRole(UserModel user) {
    if (user.role == 'developer' || user.role == 'owner') {
      Get.offAllNamed('/main-shell');
    } else {
      // Fallback if role is somehow invalid
      Get.offAllNamed('/onboarding');
    }
  }

  bool get isLoggedIn => currentUser.value != null;
}
