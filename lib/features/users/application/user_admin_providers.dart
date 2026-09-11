import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/page_result.dart';
import '../../../core/providers.dart';
import '../data/user_admin_repository.dart';
import '../domain/app_user_summary.dart';

final userAdminRepositoryProvider = Provider<UserAdminRepository>((ref) {
  return UserAdminRepository(apiClient: ref.watch(apiClientProvider));
});

final userAdminListProvider =
    FutureProvider.autoDispose<PageResult<AppUserSummary>>((ref) {
      return ref.watch(userAdminRepositoryProvider).list();
    });
