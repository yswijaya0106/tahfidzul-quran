import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/dashboard_repository.dart';
import '../domain/location_dashboard.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(apiClient: ref.watch(apiClientProvider));
});

final locationDashboardProvider = FutureProvider.autoDispose
    .family<LocationDashboard, String>(
      (ref, locationId) => ref
          .watch(dashboardRepositoryProvider)
          .getLocationDashboard(locationId),
    );

/// Admin-only cross-location progress overview for today.
final locationsOverviewProvider = FutureProvider.autoDispose<LocationsOverview>(
  (ref) => ref.watch(dashboardRepositoryProvider).getLocationsOverview(),
);

/// Admin-only list of students who submitted new memorization today.
final memorizationProgressProvider =
    FutureProvider.autoDispose<MemorizationProgressOverview>(
      (ref) => ref.watch(dashboardRepositoryProvider).getMemorizationProgress(),
    );

/// Admin-only, school-wide leaderboard ranking students by achievement vs.
/// their daily target — either aggregated since program start or scoped to
/// today's submissions.
final leaderboardProvider = FutureProvider.autoDispose
    .family<LeaderboardOverview, LeaderboardScope>(
      (ref, scope) =>
          ref.watch(dashboardRepositoryProvider).getLeaderboard(scope: scope),
    );

/// Admin-only feed of today's activity photos across every location.
final todayActivityPhotosProvider =
    FutureProvider.autoDispose<TodayActivityPhotosOverview>(
      (ref) =>
          ref.watch(dashboardRepositoryProvider).getTodayActivityPhotos(),
    );
