import '../../../core/network/api_client.dart';
import '../../../core/pagination/page_result.dart';
import '../domain/activity.dart';
import '../domain/activity_photo_input.dart';

class ActivityRepository {
  final ApiClient _apiClient;

  ActivityRepository({required this._apiClient});

  Future<PageResult<Activity>> listForLocation(
    String locationId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/locations/$locationId/activities',
      query: {'page': page, 'pageSize': pageSize},
    );
    return PageResult.fromJson(response, Activity.fromJson);
  }

  Future<Activity> create({
    required String locationId,
    required String title,
    String? description,
    required DateTime activityDate,
    List<ActivityPhotoInput> photos = const [],
  }) async {
    final response = await _apiClient.post(
      '/locations/$locationId/activities',
      data: {
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        'activityDate': activityDate.toUtc().toIso8601String(),
        'photos': photos.map((photo) => photo.toJson()).toList(),
      },
    );
    return Activity.fromJson(response['data'] as Map<String, dynamic>);
  }
}
