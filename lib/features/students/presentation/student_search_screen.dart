import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../application/student_providers.dart';
import '../domain/student.dart';

/// "Pencarian" tab: search students by name across every location. Tapping
/// a result selects it and switches to the "Profil" tab to view it.
class StudentSearchScreen extends ConsumerStatefulWidget {
  const StudentSearchScreen({super.key});

  @override
  ConsumerState<StudentSearchScreen> createState() =>
      _StudentSearchScreenState();
}

class _StudentSearchScreenState extends ConsumerState<StudentSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(studentSearchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(studentSearchResultsProvider);
    final hasQuery = ref.watch(studentSearchQueryProvider).trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Pencarian Siswa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari nama siswa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _debounce?.cancel();
                          ref.read(studentSearchQueryProvider.notifier).state =
                              '';
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: !hasQuery
                ? const _SearchPrompt()
                : AsyncValueView(
                    value: results,
                    onRetry: () => ref.invalidate(studentSearchResultsProvider),
                    isEmpty: (result) => result.data.isEmpty,
                    empty: (_) => const _NoResults(),
                    data: (context, result) => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: result.data.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _StudentResultTile(
                        student: result.data[index],
                        color: _resultColors[index % _resultColors.length],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

const _resultColors = [
  AppColors.deepGreen,
  AppColors.gold,
  AppColors.navy,
  AppColors.maroon,
];

class _StudentResultTile extends ConsumerWidget {
  final Student student;
  final Color color;

  const _StudentResultTile({required this.student, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: AppIconTile(
          icon: Icons.person_outline,
          iconColor: color,
          title: student.fullName,
          subtitle: student.studentCode,
          onTap: () {
            ref.read(selectedProfileStudentIdProvider.notifier).state =
                student.id;
            final shell = StatefulNavigationShell.maybeOf(context);
            if (shell != null) {
              shell.goBranch(2); // Profil tab
            } else {
              context.push('/students/${student.id}');
            }
          },
        ),
      ),
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Ketik nama siswa untuk mulai mencari.'),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Tidak ada siswa dengan nama tersebut.'),
      ),
    );
  }
}
