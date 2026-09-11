import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/presentation/activity_create_screen.dart';
import '../../features/activities/presentation/activity_list_screen.dart';
import '../../features/assessments/presentation/assessment_create_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/location_dashboard_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/locations/application/location_providers.dart';
import '../../features/locations/presentation/location_selector_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/students/presentation/student_create_screen.dart';
import '../../features/students/presentation/student_detail_screen.dart';
import '../../features/students/presentation/student_list_screen.dart';
import '../../features/users/presentation/user_admin_list_screen.dart';

const _shellPaths = ['/dashboard', '/students', '/activities', '/settings'];

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSelectingLocation = state.matchedLocation == '/locations';
      final hasLocation = ref.read(selectedLocationIdProvider) != null;
      final needsLocation = _shellPaths.any(
        (path) => state.matchedLocation.startsWith(path),
      );

      if (authState.isLoading) return null;
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/locations';
      if (isLoggedIn && !isSelectingLocation && needsLocation && !hasLocation) {
        return '/locations';
      }
      return null;
    },
    refreshListenable: _AuthStateListenable(ref),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/locations',
        builder: (context, state) => const LocationSelectorScreen(),
      ),

      // Bottom-nav shell: Beranda / Siswa / Aktivitas / Pengaturan, each tab
      // keeping its own stack via StatefulShellRoute.indexedStack. Tabs read
      // the active location from selectedLocationIdProvider rather than a
      // path segment, since a shell branch's default route can't carry a
      // required path parameter.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const LocationDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/students',
                builder: (context, state) => const StudentListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activities',
                builder: (context, state) => const ActivityListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen routes (pushed over the shell, no bottom nav) for
      // create/detail flows that don't belong on a persistent tab.
      GoRoute(
        path: '/students/new',
        builder: (context, state) => const StudentCreateScreen(),
      ),
      GoRoute(
        path: '/students/:studentId',
        builder: (context, state) =>
            StudentDetailScreen(studentId: state.pathParameters['studentId']!),
      ),
      GoRoute(
        path: '/students/:studentId/assessments/new',
        builder: (context, state) => AssessmentCreateScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: '/activities/new',
        builder: (context, state) => const ActivityCreateScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserAdminListScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod's AsyncValue-based auth state to go_router's
/// Listenable-based refresh mechanism so navigation reacts to login/logout.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
    ref.listen(selectedLocationIdProvider, (_, _) => notifyListeners());
  }
}
