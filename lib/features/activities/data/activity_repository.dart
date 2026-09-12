import '../../../core/network/api_client.dart';
import '../../../core/pagination/page_result.dart';
import '../domain/activity.dart';
import '../domain/activity_photo.dart';
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

  Future<Activity> getById(String activityId) async {
    final response = await _apiClient.get('/activities/$activityId');
    return Activity.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<ActivityPhoto>> getPhotos(String activityId) async {
    final response = await _apiClient.get('/activities/$activityId/photos');
    final rawData = response['data'] as List<dynamic>;
    return rawData
        .map((item) => ActivityPhoto.fromJson(item as Map<String, dynamic>))
        .toList();
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
