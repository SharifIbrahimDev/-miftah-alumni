import 'dart:convert';
import '../../domain/entities/contribution.dart';
import '../datasources/remote_data_source.dart';

class ContributionRepository {
  final RemoteDataSource remoteDataSource;

  ContributionRepository({required this.remoteDataSource});

  Future<List<Expense>> getExpenses() async {
    final response = await remoteDataSource.get('/expenses');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Expense.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<MonthlyContribution>> getMyMonthlyContributions() async {
    final response = await remoteDataSource.get('/my-contributions');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => MonthlyContribution.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<MonthlyContribution>> getAllMonthlyContributions() async {
    final response = await remoteDataSource.get('/monthly-contributions');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((json) => MonthlyContribution.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> recordMonthlyContribution(int userId, double amount, String month, String status) async {
    final response = await remoteDataSource.post('/monthly-contributions', {
      'user_id': userId,
      'amount': amount,
      'month': month,
      'status': status,
    });
    return response.statusCode == 201;
  }

  Future<bool> recordExpense(String description, double amount, String category) async {
    final response = await remoteDataSource.post('/expenses', {
      'description': description,
      'amount': amount,
      'category': category,
    });
    return response.statusCode == 201;
  }
}
