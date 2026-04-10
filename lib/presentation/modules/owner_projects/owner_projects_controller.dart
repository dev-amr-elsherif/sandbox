import 'package:get/get.dart';
import '../../../../data/models/invitation_model.dart';
import '../../../../data/providers/firebase_provider.dart';
import '../auth/auth_controller.dart';

class OwnerProjectsController extends GetxController {
  final FirebaseProvider _firebaseProvider = FirebaseProvider();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<InvitationModel> sentInvitations = <InvitationModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToSentInvitations();
  }

  void _listenToSentInvitations() {
    final user = _authController.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    sentInvitations.bindStream(_firebaseProvider.streamSentInvitations(user.uid));
    
    ever(sentInvitations, (_) => isLoading.value = false);
  }
}
