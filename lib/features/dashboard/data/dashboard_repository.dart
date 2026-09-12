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
  }) async {
    final response = await _apiClient.get(
      '/dashboard/memorization-progress',
      query: date == null ? null : {'date': date},
    );
    return MemorizationProgressOverview.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  Future<TodayActivityPhotosOverview> getTodayActivityPhotos({String? date}) async {
    final response = await _apiClient.get(
      '/dashboard/today-activity-photos',
      query: date == null ? null : {'date': date},
    );
    return TodayActivityPhotosOverview.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }
}
