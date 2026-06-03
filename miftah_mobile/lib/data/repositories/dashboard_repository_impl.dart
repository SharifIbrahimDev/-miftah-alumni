import 'dart:convert';
import '../datasources/remote_data_source.dart';

class DashboardRepository {
  final RemoteDataSource remoteDataSource;

  DashboardRepository({required this.remoteDataSource});

  Future<Map<String, dynamic>?> getDashboardStats() async {
    final response = await remoteDataSource.get('/dashboard');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
