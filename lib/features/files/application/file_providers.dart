import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/file_repository.dart';

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepository(apiClient: ref.watch(apiClientProvider));
});
