import '../../domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User?> createUser(Map<String, dynamic> data);
  Future<User?> updateUser(int id, Map<String, dynamic> data);
  Future<bool> deleteUser(int id);
}
