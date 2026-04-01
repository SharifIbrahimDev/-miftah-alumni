import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository repo;
  List<User> _users = [];
  bool _isLoading = false;

  UserProvider({required this.repo});

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await repo.getUsers();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addUser(Map<String, dynamic> data) async {
    final user = await repo.createUser(data);
    if (user != null) {
      _users.insert(0, user);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateUserRole(int id, String role) async {
    final user = await repo.updateUser(id, {'role': role});
    if (user != null) {
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = user;
        notifyListeners();
      }
      return true;
    }
    return false;
  }
}
