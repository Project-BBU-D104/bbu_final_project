import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = dotenv.env['API_URL']!;

  Map<String, String> get headers => {
        "Content-Type": "application/json",
      };

  /// GET ALL
  // Future<dynamic> get(String endpoint) async {
  //   final response = await http.get(
  //     Uri.parse("$baseUrl$endpoint"),
  //     headers: headers,
  //   );

  //   return _handleResponse(response);
  // }

  /// GET ALL
Future<dynamic> get(String endpoint) async {
  final response = await http.get(
    Uri.parse("$baseUrl$endpoint/"),   // ✅ add trailing slash here
    headers: headers,
  );

  return _handleResponse(response);
}

  /// GET BY ID
  Future<dynamic> getById(
    String endpoint,
    String id,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint/$id"),
      headers: headers,
    );

    return _handleResponse(response);
  }

  /// POST
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint/"),
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  /// PUT
  Future<dynamic> put(
    String endpoint,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl$endpoint/$id"),
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  /// DELETE
  Future<dynamic> delete(
    String endpoint,
    String id,
  ) async {
    final response = await http.delete(
      Uri.parse("$baseUrl$endpoint/$id"),
      headers: headers,
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return body;
    } else {
      throw Exception(
        body["detail"] ?? "API Error",
      );
    }
  }
}