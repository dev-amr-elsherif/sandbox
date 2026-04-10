import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  // معلومات المستخدم الحالي (تتحدث تلقائياً عند تغيير الحالة)
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isGoogleLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupAuthListener();
  }

  // 🧭 المايسترو: المسؤول الوحيد عن مراقبة الحالة والتنقل
  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      print('DEBUG: authStateChanges emitted. User: ${firebaseUser?.uid}');
      
      if (firebaseUser != null) {
        print('DEBUG: User is authenticated. Fetching profile from Firestore...');
        
        try {
          // جلب بيانات المستخدم من Firestore للتأكد من وجوده ودوره مع إضافة مهلة زمنية
          final userModel = await _firebaseProvider.getUser(firebaseUser.uid)
              .timeout(const Duration(seconds: 10));
          
          if (userModel != null) {
            print('DEBUG: Profile found. Role: ${userModel.role}');
            // دائماً نقوم بتحديث الاسم والصورة من جوجل لضمان تطابق البيانات
            final updatedUser = UserModel(
              uid: userModel.uid,
              email: firebaseUser.email ?? userModel.email,
              name: firebaseUser.displayName ?? userModel.name,
              photoUrl: firebaseUser.photoURL ?? userModel.photoUrl,
              role: userModel.role,
              skills: userModel.skills,
            );
            currentUser.value = updatedUser;
            
            // تحديث في Firestore لضمان المزامنة
            _firebaseProvider.saveUser(updatedUser);
            
            _navigateBasedOnRole(updatedUser);
          } else {
            print('DEBUG: Profile not found in Firestore. Handling as new user.');
            _handleNewUser(firebaseUser);
          }
        } catch (e) {
          print('DEBUG: Error or timeout fetching profile: $e');
          // في حالة فشل الاتصال بقاعدة البيانات أو التأخر، نستخدم fallback لتجنب التعليق
          _handleNewUser(firebaseUser);
        }
        
        // تحديث معلومات التحليلات
        _analytics.setUserId(firebaseUser.uid);
      } else {
        print('DEBUG: User is null (signed out).');
        currentUser.value = null;
        // إذا كنا لسنا في صفحة الدخول، نعود إليها
        if (Get.currentRoute != '/login') {
          print('DEBUG: Redirecting to login screen.');
          Get.offAllNamed('/login');
        }
      }
    });
  }

  void _handleNewUser(User firebaseUser) {
    currentUser.value = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
      role: 'unknown',
    );
    print('DEBUG: Navigating to role-selection (new user or profile error).');
    Get.offAllNamed('/role-selection');
  }

  // 🔑 تسجيل الدخول: مهمتها فقط المصادقة، والتنقل يتم عبر الـ Listener
  Future<void> loginWithGoogle() async {
    try {
      print('DEBUG: Starting loginWithGoogle process...');
      isGoogleLoading.value = true;
      errorMessage.value = '';

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('DEBUG: Google Sign-In cancelled by user.');
        return;
      }

      print('DEBUG: Google user obtained: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('DEBUG: Signing into Firebase with credentials...');
      // بمجرد نجاح هذا السطر، سيقوم _setupAuthListener بالباقي
      await _auth.signInWithCredential(credential);
      print('DEBUG: Firebase sign-in successful.');
      
      await _analytics.logGoogleLogin();
      
    } catch (e) {
      print('DEBUG: Error in loginWithGoogle: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Auth Error', 'Failed to sign in with Google');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // 🎭 اختيار الدور: تحديث البيانات في Firestore والملاحة
  Future<void> selectRole(UserRole role) async {
    final user = currentUser.value;
    if (user == null) {
      Get.snackbar('Error', 'User session not found');
      return;
    }

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
      
      // حفظ في Firestore
      await _firebaseProvider.saveUser(updatedUser);
      
      // تحديث الحالة المحلية والملاحة
      currentUser.value = updatedUser;
      await _analytics.logRoleSelected(role.name);
      _navigateBasedOnRole(updatedUser);
      
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to save role');
    } finally {
      isLoading.value = false;
    }
  }

  // 🚪 تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    currentUser.value = null;
    // الـ Listener سيتكفل بالباقي، لكن تأكيدا للملاحة:
    Get.offAllNamed('/login');
  }

  // 🧭 مساعد الملاحة بناءً على الدور
  void _navigateBasedOnRole(UserModel user) {
    print('DEBUG: Navigating based on role: ${user.role}');
    // All roles now go to MainShell, which handles the internal logic
    Get.offAllNamed('/main-shell');
  }

  bool get isLoggedIn => currentUser.value != null;
}
