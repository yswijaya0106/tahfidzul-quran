import 'user.dart';

abstract class AuthRepository {
  Future<AppUser> login({required String identifier, required String password});
  Future<void> logout();
  Future<void> logoutAllDevices();
  Future<AppUser?> restoreSession();
}
