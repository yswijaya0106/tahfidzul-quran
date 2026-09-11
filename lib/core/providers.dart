import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network/api_client.dart';
import 'storage/secure_token_storage.dart';

/// Shared, app-wide dependency providers. Feature-level providers live under
/// each feature's application/ folder and depend only on these.
final secureTokenStorageProvider = Provider<SecureTokenStorage>(
  (ref) => SecureTokenStorage(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(secureTokenStorageProvider));
});
