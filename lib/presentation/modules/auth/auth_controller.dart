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
        // Migration check: saveUser will move them to the correct collection if they aren't there
        await _firebaseProvider.saveUser(userModel);
        
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
      debugPrint('DEBUG: Starting GitHub Login flow...');
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      
      final UserCredential credential = await _auth.signInWithProvider(githubProvider);
      debugPrint('DEBUG: FirebaseAuth signIn success. UID: ${credential.user?.uid}');
      
      if (credential.user != null) {
        final profile = credential.additionalUserInfo?.profile;
        Map<String, dynamic>? aiAnalysis;
        
        if (profile != null) {
          debugPrint('DEBUG: GitHub Profile found. Login: ${profile['login']}');
          try {
            final analyzer = GithubAnalyzerService();
            aiAnalysis = analyzer.analyzeProfileData(profile);
            debugPrint('DEBUG: Local GitHub profile analysis success');
            Get.snackbar('Success', 'Profile analyzed successfully!');
          } catch (e) {
            debugPrint('DEBUG: GitHub analysis failed: $e');
          }
        } else {
          debugPrint('DEBUG: WARNING - AdditionalUserInfo profile is null');
        }

        // Force create/update profile as Developer
        debugPrint('DEBUG: Saving profile to developers collection...');
        await _createOrUpdateProfile(credential.user!, 'developer', aiAnalysis: aiAnalysis);
        debugPrint('DEBUG: Profile saved successfully');
      }
    } catch (e) {
      debugPrint('DEBUG: GitHub Login Error - Type: ${e.runtimeType}, Details: $e');
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
      debugPrint('DEBUG: Fetching existing user for UID: ${firebaseUser.uid}');
      UserModel? existingUser;
      try {
        existingUser = await _firebaseProvider.getUser(firebaseUser.uid);
        debugPrint('DEBUG: Existing user check complete. Found: ${existingUser != null}');
      } catch (e) {
        debugPrint('DEBUG: Non-fatal error fetching existing user: $e');
      }
      
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
        publicRepos: aiAnalysis?['publicRepos'] ?? existingUser?.publicRepos,
        followers: aiAnalysis?['followers'] ?? existingUser?.followers,
        accountAgeYears: aiAnalysis?['accountAgeYears'] ?? existingUser?.accountAgeYears,
      );

      debugPrint('DEBUG: Attempting to save user to collection: ${role == 'owner' ? 'owners' : 'developers'}');
      await _firebaseProvider.saveUser(userModel);
      debugPrint('DEBUG: User saved successfully to Firestore');

      currentUser.value = userModel;
      await _analytics.logRoleSelected(role);
      
      _navigateBasedOnRole(userModel);
    } catch (e) {
      debugPrint('DEBUG: CRITICAL ERROR in _createOrUpdateProfile: $e');
      if (e.toString().contains('permission-denied')) {
        Get.snackbar('Database Error', 'Permission denied. Please check Firestore rules.', 
          backgroundColor: Colors.red.withValues(alpha: 0.1), colorText: Colors.red);
      } else {
        Get.snackbar('Error', 'Failed to configure your profile: $e');
      }
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
