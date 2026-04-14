import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required this.authRepository});

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await authRepository.login(email, password);
      if (user != null) {
        _user = user;
      } else {
        _error = 'Invalid email or password';
      }
    } catch (e) {
      _error = 'An error occurred during login: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String phone, String gender, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await authRepository.register(name, email, phone, gender, password);
      if (!success) {
        _error = 'Registration failed. Please check your details.';
      }
    } catch (e) {
      _error = 'An error occurred during registration: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> checkStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await authRepository.getMe();
    } catch (_) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({String? name, String? email, String? phone, String? gender, String? oldPassword, String? password, String? passwordConfirmation}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedUser = await authRepository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        gender: gender,
        oldPassword: oldPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (updatedUser != null) {
        _user = updatedUser;
        return true;
      } else {
        _error = 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _error = 'An error occurred while updating profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
