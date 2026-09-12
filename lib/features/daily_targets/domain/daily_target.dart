/// One day (1-300) of the "Target Tilawah/Tahfidz 300 Hari" reference
/// schedule: the Quran range a student following the program should reach by
/// that day.
class DailyTarget {
  final int dayNumber;
  final int startSurahNumber;
  final int startVerseNumber;
  final int endSurahNumber;
  final int endVerseNumber;

  const DailyTarget({
    required this.dayNumber,
    required this.startSurahNumber,
    required this.startVerseNumber,
    required this.endSurahNumber,
    required this.endVerseNumber,
  });

  factory DailyTarget.fromJson(Map<String, dynamic> json) => DailyTarget(
    dayNumber: json['dayNumber'] as int,
    startSurahNumber: json['startSurahNumber'] as int,
    startVerseNumber: json['startVerseNumber'] as int,
    endSurahNumber: json['endSurahNumber'] as int,
    endVerseNumber: json['endVerseNumber'] as int,
  );
}
