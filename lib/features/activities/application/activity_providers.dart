import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/page_result.dart';
import '../../../core/providers.dart';
import '../data/activity_repository.dart';
import '../domain/activity.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(apiClient: ref.watch(apiClientProvider));
});

final activityListProvider = FutureProvider.autoDispose
    .family<PageResult<Activity>, String>(
      (ref, locationId) =>
          ref.watch(activityRepositoryProvider).listForLocation(locationId),
    );
