import 'package:get/get.dart';
import '../../../core/services/ai_service.dart';
import '../controllers/manager_controller.dart';

class ManagerBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<AIService>(() => AIService());

    // Controllers
    Get.lazyPut<ManagerController>(() => ManagerController());
  }
}
