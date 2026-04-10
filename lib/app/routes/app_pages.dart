import 'package:get/get.dart';
import '../../presentation/modules/auth/auth_binding.dart';
import '../../presentation/modules/auth/login_view.dart';
import '../../presentation/modules/auth/role_selection_view.dart';
import '../../presentation/modules/dev_dashboard/developer_binding.dart';
import '../../presentation/modules/dev_dashboard/developer_dashboard_view.dart';
import '../../presentation/modules/owner_dashboard/owner_binding.dart';
import '../../presentation/modules/owner_dashboard/owner_dashboard_view.dart';
import '../../presentation/modules/main_shell/main_shell_view.dart';
import '../../presentation/modules/main_shell/main_shell_binding.dart';
import '../../presentation/modules/matches/match_results_view.dart';
import '../../presentation/modules/matches/match_results_binding.dart';
import '../../presentation/modules/dev_profile/public_profile_view.dart';

class AppPages {
  static const INITIAL = '/login';

  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/role-selection',
      page: () => const RoleSelectionView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/dev-dashboard',
      page: () => const DeveloperDashboardView(),
      binding: DeveloperBinding(),
    ),
    GetPage(
      name: '/owner-dashboard',
      page: () => const OwnerDashboardView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: '/main-shell',
      page: () => const MainShellView(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: '/match-results',
      page: () => const MatchResultsView(),
      binding: MatchResultsBinding(),
    ),
    GetPage(
      name: '/public-profile',
      page: () => const PublicProfileView(),
    ),
  ];
}
