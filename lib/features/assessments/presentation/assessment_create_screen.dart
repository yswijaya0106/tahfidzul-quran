import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/widgets/async_value_view.dart';
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
  AssessmentGrade _grade = AssessmentGrade.jayyid;
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
      appBar: AppBar(title: const Text('New assessment')),
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
              title: const Text('Assessment date'),
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
                  label: Text('New memorization'),
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
              'Start position',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            _SurahVerseSelector(
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
            Text('End position', style: Theme.of(context).textTheme.titleSmall),
            _SurahVerseSelector(
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
            DropdownButtonFormField<AssessmentGrade>(
              initialValue: _grade,
              decoration: const InputDecoration(labelText: 'Grade'),
              items: AssessmentGrade.values
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
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
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
                  : const Text('Save assessment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahVerseSelector extends StatelessWidget {
  final List<QuranSurah> surahs;
  final int? surahNumber;
  final int? verseNumber;
  final String? errorText;
  final ValueChanged<int?> onSurahChanged;
  final ValueChanged<int?> onVerseChanged;

  const _SurahVerseSelector({
    required this.surahs,
    required this.surahNumber,
    required this.verseNumber,
    required this.errorText,
    required this.onSurahChanged,
    required this.onVerseChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedSurah = surahs
        .where((s) => s.surahNumber == surahNumber)
        .firstOrNull;
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
            validator: (value) => value == null ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<int>(
            initialValue: verseNumber,
            decoration: const InputDecoration(labelText: 'Verse'),
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
            validator: (value) => value == null ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
