import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/surah_verse_selector.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/domain/quran_surah.dart';
import '../application/daily_target_providers.dart';
import '../domain/daily_target.dart';

/// Create/edit form for one day of the 300-day target schedule. Pass
/// [target] to edit an existing day (dayNumber becomes read-only); omit it
/// to add a day that was previously deleted.
class DailyTargetFormScreen extends ConsumerStatefulWidget {
  final DailyTarget? target;

  const DailyTargetFormScreen({super.key, this.target});

  @override
  ConsumerState<DailyTargetFormScreen> createState() =>
      _DailyTargetFormScreenState();
}

class _DailyTargetFormScreenState extends ConsumerState<DailyTargetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _dayNumberController = TextEditingController(
    text: widget.target?.dayNumber.toString(),
  );

  int? _startSurah;
  int? _startVerse;
  int? _endSurah;
  int? _endVerse;

  bool _submitting = false;
  Map<String, String>? _serverFieldErrors;

  bool get _isEditing => widget.target != null;

  @override
  void initState() {
    super.initState();
    _startSurah = widget.target?.startSurahNumber;
    _startVerse = widget.target?.startVerseNumber;
    _endSurah = widget.target?.endSurahNumber;
    _endVerse = widget.target?.endVerseNumber;
  }

  @override
  void dispose() {
    _dayNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _serverFieldErrors = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_startSurah == null ||
        _startVerse == null ||
        _endSurah == null ||
        _endVerse == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final repository = ref.read(dailyTargetRepositoryProvider);
      if (_isEditing) {
        await repository.update(
          widget.target!.dayNumber,
          startSurahNumber: _startSurah,
          startVerseNumber: _startVerse,
          endSurahNumber: _endSurah,
          endVerseNumber: _endVerse,
        );
      } else {
        await repository.create(
          dayNumber: int.parse(_dayNumberController.text.trim()),
          startSurahNumber: _startSurah!,
          startVerseNumber: _startVerse!,
          endSurahNumber: _endSurah!,
          endVerseNumber: _endVerse!,
        );
      }
      ref.invalidate(dailyTargetListProvider);
      if (mounted) context.pop(true);
    } on AppException catch (error) {
      setState(() => _serverFieldErrors = error.fields);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(quranSurahsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Target Harian' : 'Tambah Target Harian'),
      ),
      body: AsyncValueView(
        value: surahsAsync,
        onRetry: () => ref.invalidate(quranSurahsProvider),
        data: (context, surahs) => _buildForm(context, surahs),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<QuranSurah> surahs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _dayNumberController,
              enabled: !_isEditing,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Hari ke- (1-300)',
                errorText: _serverFieldErrors?['dayNumber'],
                prefixIcon: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.gold,
                ),
              ),
              validator: (value) {
                final parsed = int.tryParse(value?.trim() ?? '');
                if (parsed == null || parsed < 1 || parsed > 300) {
                  return 'Masukkan angka 1-300';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const SectionHeader(
              icon: Icons.flag_circle_rounded,
              title: 'Posisi awal',
              color: AppColors.deepGreen,
            ),
            const SizedBox(height: 10),
            SurahVerseSelector(
              surahs: surahs,
              surahNumber: _startSurah,
              verseNumber: _startVerse,
              errorText:
                  _serverFieldErrors?['startSurahNumber'] ??
                  _serverFieldErrors?['startVerseNumber'],
              onSurahChanged: (value) => setState(() {
                _startSurah = value;
                _startVerse = null;
              }),
              onVerseChanged: (value) => setState(() => _startVerse = value),
            ),
            const SizedBox(height: 20),
            const SectionHeader(
              icon: Icons.sports_score_rounded,
              title: 'Posisi akhir',
              color: AppColors.navy,
            ),
            const SizedBox(height: 10),
            SurahVerseSelector(
              surahs: surahs,
              surahNumber: _endSurah,
              verseNumber: _endVerse,
              errorText:
                  _serverFieldErrors?['endSurahNumber'] ??
                  _serverFieldErrors?['endVerseNumber'],
              onSurahChanged: (value) => setState(() {
                _endSurah = value;
                _endVerse = null;
              }),
              onVerseChanged: (value) => setState(() => _endVerse = value),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Simpan perubahan' : 'Simpan target'),
            ),
          ],
        ),
      ),
    );
  }
}
