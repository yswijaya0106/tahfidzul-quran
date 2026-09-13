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

/// List of students who submitted new memorization on a chosen date. Pass
/// `locationId` for a single rumah tahfidz (open to that location's
/// operator); omit it for the admin-only, school-wide list.
final memorizationProgressProvider = FutureProvider.autoDispose
    .family<MemorizationProgressOverview, ({String? date, String? locationId})>(
      (ref, params) => ref
          .watch(dashboardRepositoryProvider)
          .getMemorizationProgress(date: params.date, locationId: params.locationId),
    );

/// Leaderboard ranking students by achievement vs. their daily target,
/// either aggregated since program start or scoped to today's submissions.
/// Pass `locationId` for a single rumah tahfidz's leaderboard (open to that
/// location's operator); omit it for the admin-only, school-wide one.
final leaderboardProvider = FutureProvider.autoDispose
    .family<LeaderboardOverview, ({LeaderboardScope scope, String? locationId})>(
      (ref, params) => ref
          .watch(dashboardRepositoryProvider)
          .getLeaderboard(scope: params.scope, locationId: params.locationId),
    );

/// Feed of activity photos uploaded on a chosen date. Pass `locationId` for
/// a single rumah tahfidz (open to that location's operator); omit it for
/// the admin-only, school-wide feed.
final todayActivityPhotosProvider = FutureProvider.autoDispose
    .family<TodayActivityPhotosOverview, ({String? date, String? locationId})>(
      (ref, params) => ref
          .watch(dashboardRepositoryProvider)
          .getTodayActivityPhotos(date: params.date, locationId: params.locationId),
    );
