import 'package:flutter/material.dart';

import '../../features/quran/domain/quran_surah.dart';

/// Paired surah/verse dropdowns: picking a surah repopulates the verse
/// dropdown with exactly that surah's verse count, so an invalid verse can
/// never be selected. Shared by any form that records a Quran position
/// (assessments, daily targets, ...).
class SurahVerseSelector extends StatelessWidget {
  final List<QuranSurah> surahs;
  final int? surahNumber;
  final int? verseNumber;
  final String? errorText;
  final ValueChanged<int?> onSurahChanged;
  final ValueChanged<int?> onVerseChanged;

  const SurahVerseSelector({
    super.key,
    required this.surahs,
    required this.surahNumber,
    required this.verseNumber,
    required this.errorText,
    required this.onSurahChanged,
    required this.onVerseChanged,
  });

  @override
  Widget build(BuildContext context) {
    final matches = surahs.where((s) => s.surahNumber == surahNumber);
    final selectedSurah = matches.isEmpty ? null : matches.first;
    final maxVerse = selectedSurah?.verseCount ?? 0;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<int>(
            initialValue: surahNumber,
            decoration: InputDecoration(
              labelText: 'Surah',
              errorText: errorText,
            ),
            isExpanded: true,
            items: surahs
                .map(
                  (s) => DropdownMenuItem(
                    value: s.surahNumber,
                    child: Text(s.displayLabel),
                  ),
                )
                .toList(),
            onChanged: onSurahChanged,
            validator: (value) => value == null ? 'Wajib diisi' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<int>(
            initialValue: verseNumber,
            decoration: const InputDecoration(labelText: 'Ayat'),
            isExpanded: true,
            items: selectedSurah == null
                ? const []
                : List.generate(
                    maxVerse,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
            onChanged: selectedSurah == null ? null : onVerseChanged,
            validator: (value) => value == null ? 'Wajib diisi' : null,
          ),
        ),
      ],
    );
  }
}
