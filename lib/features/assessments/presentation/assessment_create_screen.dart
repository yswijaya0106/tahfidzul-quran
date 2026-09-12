import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/surah_verse_selector.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/domain/quran_surah.dart';
import '../application/assessment_providers.dart';
import '../domain/assessment.dart';

class AssessmentCreateScreen extends ConsumerStatefulWidget {
  final String studentId;

  const AssessmentCreateScreen({super.key, required this.studentId});

  @override
  ConsumerState<AssessmentCreateScreen> createState() =>
      _AssessmentCreateScreenState();
}

class _AssessmentCreateScreenState
    extends ConsumerState<AssessmentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _assessmentDate = DateTime.now();
  AssessmentType _assessmentType = AssessmentType.newMemorization;
  Grade _grade = Grade.jayyid;
  int? _startSurah;
  int? _startVerse;
  int? _endSurah;
  int? _endVerse;

  bool _submitting = false;
  Map<String, String>? _serverFieldErrors;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assessmentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _assessmentDate = picked);
  }

  Future<void> _submit(List<QuranSurah> surahs) async {
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
      await ref
          .read(assessmentRepositoryProvider)
          .create(
            studentId: widget.studentId,
            assessmentDate: _assessmentDate,
            assessmentType: _assessmentType,
            startSurahNumber: _startSurah!,
            startVerseNumber: _startVerse!,
            endSurahNumber: _endSurah!,
            endVerseNumber: _endVerse!,
            grade: _grade,
            notes: _notesController.text.trim(),
          );

      ref.invalidate(assessmentHistoryProvider(widget.studentId));
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
      appBar: AppBar(title: const Text('Setoran Baru')),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal setoran'),
              subtitle: Text(
                _assessmentDate.toLocal().toString().split(' ').first,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            SegmentedButton<AssessmentType>(
              segments: const [
                ButtonSegment(
                  value: AssessmentType.newMemorization,
                  label: Text('Hafalan baru'),
                ),
                ButtonSegment(
                  value: AssessmentType.murojaah,
                  label: Text('Murojaah'),
                ),
              ],
              selected: {_assessmentType},
              onSelectionChanged: (selection) =>
                  setState(() => _assessmentType = selection.first),
            ),
            const SizedBox(height: 16),
            Text(
              'Posisi awal',
              style: Theme.of(context).textTheme.titleSmall,
            ),
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
            const SizedBox(height: 16),
            Text('Posisi akhir', style: Theme.of(context).textTheme.titleSmall),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<Grade>(
              initialValue: _grade,
              decoration: const InputDecoration(labelText: 'Nilai'),
              items: Grade.values
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(assessmentGradeLabel(g)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _grade = value ?? _grade),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : () => _submit(surahs),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan setoran'),
            ),
          ],
        ),
      ),
    );
  }
}
