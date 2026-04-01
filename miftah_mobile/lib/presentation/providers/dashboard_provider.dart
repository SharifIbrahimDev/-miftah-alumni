import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _stats;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get stats => _stats;

  Future<void> fetchDashboardData(String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // API call will go here
      // For now, let's pretend we have data
      await Future.delayed(const Duration(seconds: 1));
      _stats = {
        'total_members': 150,
        'monthly_collected': 250000,
        'project_raised': 1200000,
        'total_expenses': 45000,
      };
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
