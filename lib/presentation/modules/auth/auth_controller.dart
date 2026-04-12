import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/providers/firebase_provider.dart';
import '../../../../data/services/analytics_service.dart';

class AuthController extends GetxController {
  // المحرك الأساسي للتعامل مع قاعدة البيانات
  final FirebaseProvider _firebaseProvider = Get.find<FirebaseProvider>();
  // لتتبع حركات المستخدم وتحسين التجربة
  final AnalyticsService _analytics = Get.find<AnalyticsService>();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── State ────────────────────────────────────────────────────────
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isGoogleLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _configureFirebaseUI();
    _setupAuthListener();
  }

  void _configureFirebaseUI() {
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      GoogleProvider(clientId: 'GOOGLE_CLIENT_ID'), // Placeholder, actual client id managed by google-services.json on Android
    ]);
  }

  // 🧭 المايسترو: المسؤول الوحيد عن مراقبة الحالة والتنقل
  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      debugPrint('DEBUG: authStateChanges emitted. User: ${firebaseUser?.uid}');
      
      if (firebaseUser != null) {
        // Always try to fetch/create profile when user is authenticated
        _syncUserProfile(firebaseUser);
        _analytics.setUserId(firebaseUser.uid);
      } else {
        debugPrint('DEBUG: User is null (signed out).');
        currentUser.value = null;
        if (Get.currentRoute != '/login') {
          Get.offAllNamed('/login');
        }
      }
    });
  }

  Future<void> _syncUserProfile(User firebaseUser) async {
    try {
      final userModel = await _firebaseProvider.getUser(firebaseUser.uid)
          .timeout(const Duration(seconds: 10));
      
      if (userModel != null) {
        final updatedUser = UserModel(
          uid: userModel.uid,
          email: firebaseUser.email ?? userModel.email,
          name: firebaseUser.displayName ?? userModel.name,
          photoUrl: firebaseUser.photoURL ?? userModel.photoUrl,
          role: userModel.role,
          skills: userModel.skills,
        );
        currentUser.value = updatedUser;
        _firebaseProvider.saveUser(updatedUser);
        _navigateBasedOnRole(updatedUser);
      } else {
        _handleNewUser(firebaseUser);
      }
    } catch (e) {
      _handleNewUser(firebaseUser);
    }
  }

  void _handleNewUser(User firebaseUser) {
    currentUser.value = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
      role: 'unknown',
    );
    Get.offAllNamed('/role-selection');
  }

  // 🔑 تسجيل الدخول اليدوي (اختياري بجانب Firebase UI)
  Future<void> loginWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      await _analytics.logGoogleLogin();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> selectRole(UserRole role) async {
    final user = currentUser.value;
    if (user == null) return;

    try {
      isLoading.value = true;
      final updatedUser = UserModel(
        uid: user.uid,
        email: user.email,
        name: user.name,
        photoUrl: user.photoUrl,
        role: role.name,
        skills: user.skills,
      );
      
      await _firebaseProvider.saveUser(updatedUser);
      currentUser.value = updatedUser;
      await _analytics.logRoleSelected(role.name);
      _navigateBasedOnRole(updatedUser);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    currentUser.value = null;
    Get.offAllNamed('/login');
  }

  void _navigateBasedOnRole(UserModel user) {
    if (user.role == 'unknown') {
      Get.offAllNamed('/role-selection');
    } else {
      Get.offAllNamed('/main-shell');
    }
  }

  bool get isLoggedIn => currentUser.value != null;
}
