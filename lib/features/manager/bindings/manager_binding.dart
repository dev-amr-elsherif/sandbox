import 'package:get/get.dart';
import '../controllers/manager_controller.dart';

class ManagerBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy singleton — يتعمل مرة واحدة بس لما الـ feature تتفتح
    Get.lazyPut<ManagerController>(() => ManagerController());
  }
}
