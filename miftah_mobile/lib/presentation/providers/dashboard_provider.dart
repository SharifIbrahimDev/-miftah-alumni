import 'package:flutter/material.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository repo;

  DashboardProvider({required this.repo});

  bool _isLoading = false;
  Map<String, dynamic>? _stats;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get stats => _stats;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await repo.getDashboardStats();
    } catch (e) {
      // Handle error quietly for now
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
