import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

// Lanzada cuando la API devuelve 401 — el token expiró o es inválido.
class UnauthorizedException implements Exception {}

class ApiService {
  // Callback registrado en main.dart para redirigir a Login al recibir 401.
  static void Function()? onUnauthorized;

  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      await _auth.logout();
      onUnauthorized?.call();
      throw UnauthorizedException();
    }
    return response;
  }

  Future<http.Response> get(String path) async {
    final headers = await _headers();
    final response = await http.get(Uri.parse('$BASE_URL$path'), headers: headers);
    return _handleResponse(response);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$BASE_URL$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('$BASE_URL$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<http.Response> delete(String path) async {
    final headers = await _headers();
    final response = await http.delete(Uri.parse('$BASE_URL$path'), headers: headers);
    return _handleResponse(response);
  }
}
