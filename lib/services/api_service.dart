import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://192.168.254.7/ms_flora_api/api';

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = '$baseUrl/$endpoint';

    print('========================================');
    print('API POST START');
    print('URL: $url');
    print('DATA: ${jsonEncode(data)}');
    print('========================================');

    try {
      final uri = Uri.parse(url);

      print('Sending POST request...');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      print('========================================');
      print('API POST RESPONSE');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('========================================');

      if (response.body.trim().isEmpty) {
        throw Exception(
          'Server returned an empty response.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Invalid response from PHP server.',
        );
      }

      final result =
          Map<String, dynamic>.from(decoded);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return result;
      }

      throw Exception(
        result['message']?.toString() ??
            'Server request failed.',
      );
    } on http.ClientException catch (e) {
      print('========================================');
      print('HTTP CLIENT ERROR');
      print(e);
      print('========================================');

      throw Exception(
        'Unable to connect to the API: $e',
      );
    } on FormatException catch (e) {
      print('========================================');
      print('JSON FORMAT ERROR');
      print(e);
      print('========================================');

      throw Exception(
        'Invalid response from server.',
      );
    } catch (e) {
      print('========================================');
      print('API POST ERROR');
      print(e);
      print('========================================');

      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint,
  ) async {
    final url = '$baseUrl/$endpoint';

    print('========================================');
    print('API GET START');
    print('URL: $url');
    print('========================================');

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      print('========================================');
      print('API GET RESPONSE');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('========================================');

      if (response.body.trim().isEmpty) {
        throw Exception(
          'Server returned an empty response.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Invalid response from PHP server.',
        );
      }

      final result =
          Map<String, dynamic>.from(decoded);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return result;
      }

      throw Exception(
        result['message']?.toString() ??
            'Server request failed.',
      );
    } on http.ClientException catch (e) {
      print('========================================');
      print('HTTP CLIENT ERROR');
      print(e);
      print('========================================');

      throw Exception(
        'Unable to connect to the API: $e',
      );
    } on FormatException catch (e) {
      print('========================================');
      print('JSON FORMAT ERROR');
      print(e);
      print('========================================');

      throw Exception(
        'Invalid response from server.',
      );
    } catch (e) {
      print('========================================');
      print('API GET ERROR');
      print(e);
      print('========================================');

      rethrow;
    }
  }
}

