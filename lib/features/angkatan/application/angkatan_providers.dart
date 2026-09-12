import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/page_result.dart';
import '../../../core/providers.dart';
import '../data/angkatan_repository.dart';
import '../domain/angkatan.dart';

final angkatanRepositoryProvider = Provider<AngkatanRepository>((ref) {
  return AngkatanRepository(apiClient: ref.watch(apiClientProvider));
});

final angkatanListProvider = FutureProvider.autoDispose
    .family<PageResult<Angkatan>, String>(
      (ref, locationId) =>
          ref.watch(angkatanRepositoryProvider).listForLocation(locationId),
    );

final angkatanDetailProvider = FutureProvider.autoDispose
    .family<Angkatan, String>(
      (ref, id) => ref.watch(angkatanRepositoryProvider).getById(id),
    );
