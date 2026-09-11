import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../application/student_providers.dart';
import '../domain/student.dart';

class StudentListScreen extends ConsumerStatefulWidget {
  final String locationId;

  const StudentListScreen({super.key, required this.locationId});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  final _searchController = TextEditingController();
  String? _searchTerm;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = StudentListParams(
      locationId: widget.locationId,
      name: _searchTerm,
    );
    final students = ref.watch(studentListProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/locations/${widget.locationId}/students/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add student'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) =>
                  setState(() => _searchTerm = value.trim()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(studentListProvider(params).future),
              child: AsyncValueView(
                value: students,
                onRetry: () => ref.invalidate(studentListProvider(params)),
                isEmpty: (result) => result.data.isEmpty,
                empty: (_) => const Center(child: Text('No students found.')),
                data: (context, result) => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: result.data.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _StudentTile(
                    student: result.data[index],
                    locationId: widget.locationId,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Student student;
  final String locationId;

  const _StudentTile({required this.student, required this.locationId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 16,
      title: Text(student.fullName),
      subtitle: Text(student.studentCode),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          context.push('/locations/$locationId/students/${student.id}'),
    );
  }
}
