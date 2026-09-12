import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/presentation/activity_create_screen.dart';
import '../../features/activities/presentation/activity_detail_screen.dart';
import '../../features/activities/presentation/activity_list_screen.dart';
import '../../features/activities/presentation/admin_activities_screen.dart';
import '../../features/admin/presentation/admin_home_screen.dart';
import '../../features/admin/presentation/admin_home_shell.dart';
import '../../features/angkatan/domain/angkatan.dart';
import '../../features/angkatan/presentation/admin_angkatan_screen.dart';
import '../../features/angkatan/presentation/angkatan_form_screen.dart';
import '../../features/angkatan/presentation/angkatan_list_screen.dart';
import '../../features/assessments/presentation/assessment_create_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/domain/user.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/daily_targets/domain/daily_target.dart';
import '../../features/daily_targets/presentation/daily_target_form_screen.dart';
import '../../features/daily_targets/presentation/daily_target_list_screen.dart';
import '../../features/dashboard/presentation/location_dashboard_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/locations/application/location_providers.dart';
import '../../features/locations/domain/location.dart';
import '../../features/locations/presentation/location_detail_screen.dart';
import '../../features/locations/presentation/location_form_screen.dart';
import '../../features/locations/presentation/location_selector_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/students/presentation/admin_student_profile_screen.dart';
import '../../features/students/presentation/student_create_screen.dart';
import '../../features/students/presentation/student_detail_screen.dart';
import '../../features/students/presentation/student_list_screen.dart';
import '../../features/students/presentation/student_search_screen.dart';
import '../../features/users/presentation/user_admin_list_screen.dart';
import '../../features/users/presentation/user_create_screen.dart';

const _shellPaths = [
  '/dashboard',
  '/students',
  '/activities',
  '/angkatan',
  '/settings',
];

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAdmin = user?.role == UserRole.admin;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSelectingLocation = state.matchedLocation == '/locations';
      final isAdminHome = state.matchedLocation == '/admin/home';
      final hasLocation = ref.read(selectedLocationIdProvider) != null;
      final needsLocation = _shellPaths.any(
        (path) => state.matchedLocation.startsWith(path),
      );

      if (authState.isLoading) return null;
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return isAdmin ? '/admin/home' : '/locations';
      if (isLoggedIn &&
          isAdmin &&
          !isAdminHome &&
          !isSelectingLocation &&
          needsLocation &&
          !hasLocation) {
        return '/admin/home';
      }
      if (isLoggedIn &&
          !isAdmin &&
          !isSelectingLocation &&
          needsLocation &&
          !hasLocation) {
        return '/locations';
      }
      return null;
    },
    refreshListenable: _AuthStateListenable(ref),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Admin's main bottom-nav shell: Rumah Tahfidz / Pencarian / Profil /
      // Kegiatan, each tab keeping its own stack via
      // StatefulShellRoute.indexedStack.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdminHomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/home',
                builder: (context, state) => const AdminHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/search',
                builder: (context, state) => const StudentSearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                builder: (context, state) => const AdminStudentProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/activities',
                builder: (context, state) => const AdminActivitiesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/angkatan',
                builder: (context, state) => const AdminAngkatanScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/locations',
        builder: (context, state) {
          final redirectPath = state.uri.queryParameters['redirect'];
          return LocationSelectorScreen(
            redirectPath: redirectPath ?? '/dashboard',
          );
        },
      ),
      GoRoute(
        path: '/locations/new',
        builder: (context, state) => const LocationFormScreen(),
      ),
      GoRoute(
        path: '/locations/:id/edit',
        builder: (context, state) =>
            LocationFormScreen(location: state.extra as TahfidzLocation?),
      ),
      GoRoute(
        path: '/locations/:id',
        builder: (context, state) => LocationDetailScreen(
          locationId: state.pathParameters['id']!,
        ),
      ),

      GoRoute(
        path: '/angkatan/new',
        builder: (context, state) =>
            AngkatanFormScreen(locationId: state.extra as String),
      ),
      GoRoute(
        path: '/angkatan/:id/edit',
        builder: (context, state) {
          final extra = state.extra as Map<String, Object?>;
          return AngkatanFormScreen(
            locationId: extra['locationId'] as String,
            angkatan: extra['angkatan'] as Angkatan,
          );
        },
      ),

      // Bottom-nav shell: Beranda / Siswa / Aktivitas / Angkatan / Pengaturan,
      // each tab keeping its own stack via StatefulShellRoute.indexedStack. Tabs read
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
                path: '/angkatan',
                builder: (context, state) => const AngkatanListScreen(),
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
        path: '/activities/:activityId',
        builder: (context, state) => ActivityDetailScreen(
          activityId: state.pathParameters['activityId']!,
        ),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserAdminListScreen(),
      ),
      GoRoute(
        path: '/users/new',
        builder: (context, state) => const UserCreateScreen(),
      ),
      GoRoute(
        path: '/daily-targets',
        builder: (context, state) => const DailyTargetListScreen(),
      ),
      GoRoute(
        path: '/daily-targets/new',
        builder: (context, state) => const DailyTargetFormScreen(),
      ),
      GoRoute(
        path: '/daily-targets/:dayNumber/edit',
        builder: (context, state) =>
            DailyTargetFormScreen(target: state.extra as DailyTarget?),
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
