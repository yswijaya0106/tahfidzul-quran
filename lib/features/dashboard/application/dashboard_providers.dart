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
