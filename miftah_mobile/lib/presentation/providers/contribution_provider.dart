import 'package:flutter/material.dart';
import '../../domain/entities/contribution.dart';
import '../../data/repositories/contribution_repository_impl.dart';

class ContributionProvider extends ChangeNotifier {
  final ContributionRepository repo;
  List<MonthlyContribution> _myContributions = [];
  List<MonthlyContribution> _allContributions = [];
  List<Expense> _expenses = [];
  double _standardMonthlyDue = 2500;
  String _effectiveMonth = 'January';
  int _effectiveYear = 2026;
  bool _isLoading = false;

  ContributionProvider({required this.repo});

  List<MonthlyContribution> get myContributions => _myContributions;
  List<MonthlyContribution> get allContributions => _allContributions;
  List<Expense> get expenses => _expenses;
  double get standardMonthlyDue => _standardMonthlyDue;
  String get effectiveMonth => _effectiveMonth;
  int get effectiveYear => _effectiveYear;
  bool get isLoading => _isLoading;

  double getAmountForMonth(String month, int year) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final effectiveIdx = months.indexOf(_effectiveMonth);
    final targetIdx = months.indexOf(month);

    if (year > _effectiveYear || (year == _effectiveYear && targetIdx >= effectiveIdx)) {
      return _standardMonthlyDue;
    }
    return 2500; // Old default
  }

  Future<void> updateStandardDue(double amount, String month, int year) async {
    _standardMonthlyDue = amount;
    _effectiveMonth = month;
    _effectiveYear = year;
    notifyListeners();
  }

  Future<void> fetchMyContributions() async {
    _isLoading = true;
    notifyListeners();
    _myContributions = await repo.getMyMonthlyContributions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllContributions() async {
    _isLoading = true;
    notifyListeners();
    _allContributions = await repo.getAllMonthlyContributions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    _expenses = await repo.getExpenses();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> recordContribution(int userId, double amount, String month, String status) async {
    _isLoading = true;
    notifyListeners();
    final success = await repo.recordMonthlyContribution(userId, amount, month, status);
    if (success) {
      await fetchAllContributions();
      await fetchExpenses();
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> recordExpense(String description, double amount, String category) async {
    _isLoading = true;
    notifyListeners();
    final success = await repo.recordExpense(description, amount, category);
    if (success) {
      await fetchExpenses();
      await fetchAllContributions();
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
