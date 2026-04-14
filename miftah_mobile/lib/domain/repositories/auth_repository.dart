import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<bool> register(String name, String email, String phone, String gender, String password);
  Future<void> logout();
  Future<User?> updateProfile({String? name, String? email, String? phone, String? gender, String? oldPassword, String? password, String? passwordConfirmation});
  Future<User?> getMe();
}
