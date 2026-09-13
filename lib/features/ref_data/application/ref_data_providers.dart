import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/ref_data_repository.dart';
import '../domain/ref_data.dart';

final refDataRepositoryProvider = Provider<RefDataRepository>((ref) {
  return RefDataRepository(apiClient: ref.watch(apiClientProvider));
});

/// All Indonesian provinces. Static reference data — kept alive for the app
/// session instead of autoDispose, since every location form re-fetching
/// the same ~34 rows on every open would be wasteful.
final provincesProvider = FutureProvider<List<RefProvince>>(
  (ref) => ref.watch(refDataRepositoryProvider).listProvinces(),
);

/// Regencies/cities for one province. `null` returns every city (used only
/// when the caller hasn't narrowed by province yet).
final citiesProvider = FutureProvider.autoDispose.family<List<RefCity>, int?>(
  (ref, provinceId) =>
      ref.watch(refDataRepositoryProvider).listCities(provinceId: provinceId),
);
