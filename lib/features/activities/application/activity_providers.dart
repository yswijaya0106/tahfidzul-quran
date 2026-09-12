import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/page_result.dart';
import '../../../core/providers.dart';
import '../data/activity_repository.dart';
import '../domain/activity.dart';
import '../domain/activity_photo.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(apiClient: ref.watch(apiClientProvider));
});

final activityListProvider = FutureProvider.autoDispose
    .family<PageResult<Activity>, String>(
      (ref, locationId) =>
          ref.watch(activityRepositoryProvider).listForLocation(locationId),
    );

/// Only fetched when a widget actually watches it (e.g. after the user taps
/// "Lihat foto" on one activity), so photos aren't loaded for every activity
/// up front.
final activityPhotosProvider = FutureProvider.autoDispose
    .family<List<ActivityPhoto>, String>(
      (ref, activityId) =>
          ref.watch(activityRepositoryProvider).getPhotos(activityId),
    );

final activityDetailProvider = FutureProvider.autoDispose
    .family<Activity, String>(
      (ref, activityId) =>
          ref.watch(activityRepositoryProvider).getById(activityId),
    );
