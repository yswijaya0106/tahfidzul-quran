import '../../../core/network/api_client.dart';
import '../domain/quran_surah.dart';

/// The client must fetch the 114-surah reference list from the API and never
/// duplicate it in Dart (CLAUDE.md: "never duplicate the Quran dataset in
/// client code"). The result is cached in memory for the app session since
/// the dataset is immutable during normal operation.
class QuranRepository {
  final ApiClient _apiClient;
  List<QuranSurah>? _cache;

  QuranRepository({required this._apiClient});

  Future<List<QuranSurah>> listSurahs({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;

    final response = await _apiClient.get('/quran/surahs');
    final rawData = response['data'] as List<dynamic>;
    final surahs = rawData
        .map((item) => QuranSurah.fromJson(item as Map<String, dynamic>))
        .toList();
    _cache = surahs;
    return surahs;
  }
}
