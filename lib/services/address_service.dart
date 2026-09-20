import 'dart:convert';

import 'package:http/http.dart' as http;

class AddressService {
  static const String baseUrl =
      'http://192.168.254.7/ms_flora_api/api';

  static Future<List<Map<String, dynamic>>> getProvinces() async {
    final response = await http
        .get(Uri.parse('$baseUrl/provinces.php'))
        .timeout(const Duration(seconds: 15));

    return _parseList(response);
  }

  static Future<List<Map<String, dynamic>>> getDistricts(
    int provinceId,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/districts.php?province_id=$provinceId',
          ),
        )
        .timeout(const Duration(seconds: 15));

    return _parseList(response);
  }

  static Future<List<Map<String, dynamic>>> getLocalGovernments(
    int districtId,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/local_governments.php?district_id=$districtId',
          ),
        )
        .timeout(const Duration(seconds: 15));

    return _parseList(response);
  }

  static Future<List<Map<String, dynamic>>> getWards(
    int localGovernmentId,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/wards.php?local_government_id=$localGovernmentId',
          ),
        )
        .timeout(const Duration(seconds: 15));

    return _parseList(response);
  }

  static List<Map<String, dynamic>> _parseList(
    http.Response response,
  ) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Server error: HTTP ${response.statusCode}',
      );
    }

    if (response.body.trim().isEmpty) {
      throw Exception('Empty response from server');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid server response');
    }

    if (decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ??
            'Failed to load address data',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }
}