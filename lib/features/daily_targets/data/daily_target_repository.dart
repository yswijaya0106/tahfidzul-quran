import '../../../core/network/api_client.dart';
import '../domain/daily_target.dart';

class DailyTargetRepository {
  final ApiClient _apiClient;

  DailyTargetRepository({required this._apiClient});

  Future<List<DailyTarget>> list() async {
    final response = await _apiClient.get('/daily-targets');
    final rawData = response['data'] as List<dynamic>;
    return rawData
        .map((item) => DailyTarget.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<DailyTarget> getByDayNumber(int dayNumber) async {
    final response = await _apiClient.get('/daily-targets/$dayNumber');
    return DailyTarget.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<DailyTarget> create({
    required int dayNumber,
    required int startSurahNumber,
    required int startVerseNumber,
    required int endSurahNumber,
    required int endVerseNumber,
  }) async {
    final response = await _apiClient.post(
      '/daily-targets',
      data: {
        'dayNumber': dayNumber,
        'startSurahNumber': startSurahNumber,
        'startVerseNumber': startVerseNumber,
        'endSurahNumber': endSurahNumber,
        'endVerseNumber': endVerseNumber,
      },
    );
    return DailyTarget.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<DailyTarget> update(
    int dayNumber, {
    int? startSurahNumber,
    int? startVerseNumber,
    int? endSurahNumber,
    int? endVerseNumber,
  }) async {
    final response = await _apiClient.patch(
      '/daily-targets/$dayNumber',
      data: {
        'startSurahNumber': ?startSurahNumber,
        'startVerseNumber': ?startVerseNumber,
        'endSurahNumber': ?endSurahNumber,
        'endVerseNumber': ?endVerseNumber,
      },
    );
    return DailyTarget.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int dayNumber) async {
    await _apiClient.delete('/daily-targets/$dayNumber');
  }
}
