class QuranSurah {
  final int surahNumber;
  final String arabicName;
  final String latinName;
  final int verseCount;

  const QuranSurah({
    required this.surahNumber,
    required this.arabicName,
    required this.latinName,
    required this.verseCount,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> json) => QuranSurah(
    surahNumber: json['surahNumber'] as int,
    arabicName: json['arabicName'] as String,
    latinName: json['latinName'] as String,
    verseCount: json['verseCount'] as int,
  );

  String get displayLabel => '$surahNumber. $latinName';
}
