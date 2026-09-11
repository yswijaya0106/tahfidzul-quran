import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/page_result.dart';
import '../../../core/providers.dart';
import '../data/location_repository.dart';
import '../domain/location.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(apiClient: ref.watch(apiClientProvider));
});

final locationListProvider =
    FutureProvider.autoDispose<PageResult<TahfidzLocation>>((ref) {
      return ref.watch(locationRepositoryProvider).list();
    });

final locationDetailProvider = FutureProvider.autoDispose
    .family<TahfidzLocation, String>(
      (ref, id) => ref.watch(locationRepositoryProvider).getById(id),
    );

/// The location the user is currently working within (selected after login).
final selectedLocationIdProvider = StateProvider<String?>((ref) => null);
