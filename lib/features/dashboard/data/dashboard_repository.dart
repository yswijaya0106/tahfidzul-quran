import '../../../core/network/api_client.dart';
import '../domain/location_dashboard.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({required this._apiClient});

  Future<LocationDashboard> getLocationDashboard(String locationId) async {
    final response = await _apiClient.get('/dashboard/locations/$locationId');
    return LocationDashboard.fromJson(response['data'] as Map<String, dynamic>);
  }
}
