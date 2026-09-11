import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/page_result.dart';
import '../../../core/providers.dart';
import '../data/student_repository.dart';
import '../domain/student.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(apiClient: ref.watch(apiClientProvider));
});

class StudentListParams {
  final String locationId;
  final String? name;

  const StudentListParams({required this.locationId, this.name});

  @override
  bool operator ==(Object other) =>
      other is StudentListParams &&
      other.locationId == locationId &&
      other.name == name;

  @override
  int get hashCode => Object.hash(locationId, name);
}

final studentListProvider = FutureProvider.autoDispose
    .family<PageResult<Student>, StudentListParams>(
      (ref, params) => ref
          .watch(studentRepositoryProvider)
          .list(locationId: params.locationId, name: params.name),
    );

final studentDetailProvider = FutureProvider.autoDispose
    .family<Student, String>(
      (ref, id) => ref.watch(studentRepositoryProvider).getById(id),
    );
