import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tahfidzul_quran/core/providers.dart';
import 'package:tahfidzul_quran/core/storage/secure_token_storage.dart';
import 'package:tahfidzul_quran/main.dart';

/// In-memory stand-in for the platform secure storage channel, so widget
/// tests don't depend on a real Keychain/Keystore being available.
class _FakeSecureStorage extends FlutterSecureStoragePlatform {
  final Map<String, String> _values = {};

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _values[key];

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _values[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _values.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _values.containsKey(key);

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.unmodifiable(_values);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async =>
      _values.clear();
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStorage();
  });

  testWidgets('renders the login screen when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStorageProvider.overrideWithValue(
            SecureTokenStorage(storage: const FlutterSecureStorage()),
          ),
        ],
        child: const TahfidzQuranApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AL-HISAN'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Telepon atau email'),
      findsOneWidget,
    );
  });
}
