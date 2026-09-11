import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/quran_repository.dart';
import '../domain/quran_surah.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(apiClient: ref.watch(apiClientProvider));
});

final quranSurahsProvider = FutureProvider<List<QuranSurah>>((ref) {
  return ref.watch(quranRepositoryProvider).listSurahs();
});
