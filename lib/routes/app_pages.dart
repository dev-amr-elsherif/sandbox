import 'package:get/get.dart';

import '../features/auth/bindings/auth_binding.dart';
import '../features/manager/bindings/manager_binding.dart';
// 💡 ملاحظة: هتحتاج تعمل import للشاشات والـ Bindings بتاعتك هنا
// إحنا عملنا شوية ملفات وهمية (Dummy) في الخطوة اللي فاتت، هنربطهم كبداية:
import '../features/auth/views/login_view.dart';
import '../features/developer/views/dev_workspace_view.dart';
import '../features/manager/views/ai_architect_chat_view.dart';
import '../features/manager/views/manager_workspace_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  // أول مسار هيفتح مع التطبيق (ممكن نخليه Splash بعدين)
  static const initial = AppRoutes.login;

  static final routes = [
    // ==========================================
    // 🛡️ Auth Feature
    // ==========================================
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn, // حركة انتقال الشاشة
    ),

    // ==========================================
    // 🧠 Manager Feature
    // ==========================================
    GetPage(
      name: AppRoutes.aiArchitectChat,
      page: () => AiArchitectChatView(),
      binding: ManagerBinding(),
    ),
    GetPage(
      name: AppRoutes.managerWorkspace,
      page: () => ManagerWorkspaceView(),
      binding: ManagerBinding(),
    ),

    // ==========================================
    // 👨‍💻 Developer Feature
    // ==========================================
    GetPage(
      name: AppRoutes.devWorkspace,
      page: () => const DevWorkspaceView(),
      // binding: DeveloperBinding(),
    ),

    // 💡 تقدر تضيف باقي الشاشات هنا بنفس الطريقة لما تبدأ تبني الـ UI بتاعهم
  ];
}
