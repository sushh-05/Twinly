import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/backend_health.dart';
import '../../models/fit_report.dart';
import '../../models/garment.dart';
import '../config/api_config.dart';

class TwinlyApiService {
  TwinlyApiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<BackendHealth> getHealth() async =>
      BackendHealth.fromJson(await _getObject('/api/health'));
  Future<List<Garment>> getGarments() async {
    final response = await _client
        .get(Uri.parse('$apiBaseUrl/api/garments'))
        .timeout(const Duration(seconds: 5));
    _check(response);
    return (jsonDecode(response.body) as List<dynamic>)
        .map((item) => Garment.fromApi(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Garment> getGarmentById(String id) async =>
      Garment.fromApi(await _getObject('/api/garments/$id'));
  Future<FitReport> getFitReport({
    required String garmentId,
    required double bustCm,
    required double waistCm,
    required double hipCm,
    required String preferredFit,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$apiBaseUrl/api/fit-report'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'garmentId': garmentId,
            'bustCm': bustCm,
            'waistCm': waistCm,
            'hipCm': hipCm,
            'preferredFit': preferredFit,
          }),
        )
        .timeout(const Duration(seconds: 5));
    _check(response);
    return FitReport.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> _getObject(String path) async {
    final response = await _client
        .get(Uri.parse('$apiBaseUrl$path'))
        .timeout(const Duration(seconds: 5));
    _check(response);
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;
}
