import 'package:flutter/material.dart';
import '../../domain/entities/contribution.dart';
import '../../data/repositories/project_repository_impl.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepository repo;
  List<Project> _projects = [];
  bool _isLoading = false;

  ProjectProvider({required this.repo});

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  Future<void> fetchProjects() async {
    _isLoading = true;
    notifyListeners();
    _projects = await repo.getAllProjects();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addProject(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    final success = await repo.createProject(
        data['title'] ?? data['name'], data['description'], data['target_amount']);
    if (success) await fetchProjects();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> recordContribution(int projectId, int userId, double amount) async {
    _isLoading = true;
    notifyListeners();
    final success = await repo.recordProjectContribution(projectId, userId, amount);
    if (success) await fetchProjects();
    _isLoading = false;
    notifyListeners();
    return success;
  }
}

