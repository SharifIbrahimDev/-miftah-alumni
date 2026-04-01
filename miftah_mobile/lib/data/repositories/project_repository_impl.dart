import 'dart:convert';
import '../../domain/entities/contribution.dart';
import '../datasources/remote_data_source.dart';

class ProjectRepository {
  final RemoteDataSource remoteDataSource;

  ProjectRepository({required this.remoteDataSource});

  Future<List<Project>> getAllProjects() async {
    final response = await remoteDataSource.get('/projects');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Project.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> createProject(String name, String description, double targetAmount) async {
    final response = await remoteDataSource.post('/projects', {
      'name': name,
      'description': description,
      'target_amount': targetAmount,
    });
    return response.statusCode == 201;
  }

  Future<bool> recordProjectContribution(int projectId, int userId, double amount) async {
    final response = await remoteDataSource.post('/project-contributions', {
      'project_id': projectId,
      'user_id': userId,
      'amount': amount,
    });
    return response.statusCode == 201;
  }
}

