import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/daily_target_repository.dart';
import '../domain/daily_target.dart';

final dailyTargetRepositoryProvider = Provider<DailyTargetRepository>((ref) {
  return DailyTargetRepository(apiClient: ref.watch(apiClientProvider));
});

final dailyTargetListProvider = FutureProvider.autoDispose<List<DailyTarget>>((
  ref,
) {
  return ref.watch(dailyTargetRepositoryProvider).list();
});
