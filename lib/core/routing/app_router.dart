import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/presentation/activity_create_screen.dart';
import '../../features/activities/presentation/activity_list_screen.dart';
import '../../features/assessments/presentation/assessment_create_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/location_dashboard_screen.dart';
import '../../features/locations/presentation/location_selector_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/students/presentation/student_create_screen.dart';
import '../../features/students/presentation/student_detail_screen.dart';
import '../../features/students/presentation/student_list_screen.dart';
import '../../features/users/presentation/user_admin_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState.isLoading) return null;
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/locations';
      return null;
    },
    refreshListenable: _AuthStateListenable(ref),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/locations',
        builder: (context, state) => const LocationSelectorScreen(),
      ),
      GoRoute(
        path: '/locations/:locationId/dashboard',
        builder: (context, state) => LocationDashboardScreen(
          locationId: state.pathParameters['locationId']!,
        ),
      ),
      GoRoute(
        path: '/locations/:locationId/students',
        builder: (context, state) =>
            StudentListScreen(locationId: state.pathParameters['locationId']!),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => StudentCreateScreen(
              locationId: state.pathParameters['locationId']!,
            ),
          ),
          GoRoute(
            path: ':studentId',
            builder: (context, state) => StudentDetailScreen(
              studentId: state.pathParameters['studentId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/students/:studentId/assessments/new',
        builder: (context, state) => AssessmentCreateScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: '/locations/:locationId/activities',
        builder: (context, state) =>
            ActivityListScreen(locationId: state.pathParameters['locationId']!),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => ActivityCreateScreen(
              locationId: state.pathParameters['locationId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserAdminListScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod's AsyncValue-based auth state to go_router's
/// Listenable-based refresh mechanism so navigation reacts to login/logout.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}
