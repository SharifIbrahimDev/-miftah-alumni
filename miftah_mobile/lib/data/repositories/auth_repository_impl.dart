import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_data_source.dart';
import '../../core/utils/shared_prefs_manager.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User?> login(String email, String password) async {
    final response = await remoteDataSource.post('/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final user = User.fromJson(body['user']);
      await SharedPrefsManager.saveAuthData(
        token: body['token'],
        role: user.role,
        id: user.id,
        name: user.name,
      );
      return user;
    }
    return null;
  }

  @override
  Future<bool> register(String name, String email, String phone, String gender, String password) async {
    final response = await remoteDataSource.post('/register', {
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'password': password,
    });

    return response.statusCode == 201 || response.statusCode == 200;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.post('/logout', {});
    await SharedPrefsManager.clearAuthData();
  }

  @override
  Future<User?> getMe() async {
    final response = await remoteDataSource.get('/me');
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  @override
  Future<User?> updateProfile({String? name, String? email, String? phone, String? gender, String? oldPassword, String? password, String? passwordConfirmation}) async {
    final response = await remoteDataSource.put('/profile', {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (oldPassword != null) 'old_password': oldPassword,
      if (password != null) 'password': password,
      if (passwordConfirmation != null) 'password_confirmation': passwordConfirmation,
    });

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      await SharedPrefsManager.saveAuthData(
        token: SharedPrefsManager.getToken() ?? '',
        role: user.role,
        id: user.id,
        name: user.name,
      );
      return user;
    }
    return null;
  }
}
