import '../../../core/network/api_client.dart';
import '../domain/location_dashboard.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({required this._apiClient});

  Future<LocationDashboard> getLocationDashboard(String locationId) async {
    final response = await _apiClient.get('/dashboard/locations/$locationId');
    return LocationDashboard.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<LocationsOverview> getLocationsOverview({String? date}) async {
    final response = await _apiClient.get(
      '/dashboard/overview',
      query: date == null ? null : {'date': date},
    );
    return LocationsOverview.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<MemorizationProgressOverview> getMemorizationProgress({
    String? date,
    String? locationId,
  }) async {
    final response = await _apiClient.get(
      '/dashboard/memorization-progress',
      query: {
        if (date != null) 'date': date,
        if (locationId != null) 'locationId': locationId,
      },
    );
    return MemorizationProgressOverview.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  Future<LeaderboardOverview> getLeaderboard({
    required LeaderboardScope scope,
    String? date,
    String? locationId,
  }) async {
    final response = await _apiClient.get(
      '/dashboard/leaderboard',
      query: {
        'scope': leaderboardScopeToApi(scope),
        if (date != null) 'date': date,
        if (locationId != null) 'locationId': locationId,
      },
    );
    return LeaderboardOverview.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<TodayActivityPhotosOverview> getTodayActivityPhotos({
    String? date,
    String? locationId,
  }) async {
    final response = await _apiClient.get(
      '/dashboard/today-activity-photos',
      query: {
        if (date != null) 'date': date,
        if (locationId != null) 'locationId': locationId,
      },
    );
    return TodayActivityPhotosOverview.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }
}
