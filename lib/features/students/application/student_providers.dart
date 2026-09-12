import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/page_result.dart';
import '../../../core/providers.dart';
import '../data/student_repository.dart';
import '../domain/student.dart';
import '../domain/student_profile.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(apiClient: ref.watch(apiClientProvider));
});

class StudentListParams {
  /// Null searches across every location (admin-only cross-location search).
  final String? locationId;
  final String? name;

  const StudentListParams({this.locationId, this.name});

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

final studentProfileProvider = FutureProvider.autoDispose
    .family<StudentProfile, String>(
      (ref, id) => ref.watch(studentRepositoryProvider).getProfile(id),
    );

/// Free-text query for the cross-location student search (Pencarian tab).
final studentSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// The student currently shown on the Profil tab, set when a search result
/// is tapped. Null shows an empty "search first" prompt.
final selectedProfileStudentIdProvider = StateProvider<String?>((ref) => null);

/// Cross-location search results for the current query. Skips the request
/// entirely for a blank query rather than listing every student.
final studentSearchResultsProvider =
    FutureProvider.autoDispose<PageResult<Student>>((ref) {
      final query = ref.watch(studentSearchQueryProvider).trim();
      if (query.isEmpty) {
        return const PageResult(data: [], meta: PageMeta(page: 1, pageSize: 20, total: 0));
      }
      return ref.watch(studentRepositoryProvider).list(name: query);
    });
