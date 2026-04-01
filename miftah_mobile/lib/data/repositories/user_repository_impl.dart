import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<User>> getUsers() async {
    final response = await remoteDataSource.get('/users');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((json) => User.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<User?> createUser(Map<String, dynamic> data) async {
    final response = await remoteDataSource.post('/users', data);
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  @override
  Future<User?> updateUser(int id, Map<String, dynamic> data) async {
    final response = await remoteDataSource.put('/users/$id', data);
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  @override
  Future<bool> deleteUser(int id) async {
    final response = await remoteDataSource.delete('/users/$id');
    return response.statusCode == 200;
  }
}

