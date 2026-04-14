import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/shared_prefs_manager.dart';

class RemoteDataSource {
  final String baseUrl = 'https://miftah-alumni.onrender.com/api';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (SharedPrefsManager.getToken() != null)
          'Authorization': 'Bearer ${SharedPrefsManager.getToken()}'
      };

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
  }

  Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
  }

  Future<http.Response> delete(String endpoint) async {
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));
  }
}
