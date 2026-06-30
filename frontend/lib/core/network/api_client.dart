import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hoteleria_erp/app.dart';
import 'package:hoteleria_erp/core/config/constants.dart';
import 'package:hoteleria_erp/core/storage/session_storage.dart';
import 'package:hoteleria_erp/rutas/nombres_rutas.dart';

class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();

  /// Gets the headers for requests, injecting the Bearer Token if it exists.
  static Future<Map<String, String>> _getHeaders({Map<String, String>? additionalHeaders}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await SessionStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Sends a GET request to the backend.
  static Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$path');
    final mergedHeaders = await _getHeaders(additionalHeaders: headers);
    
    try {
      final response = await _client.get(url, headers: mergedHeaders);
      _handleResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a POST request to the backend.
  static Future<http.Response> post(String path, {dynamic body, Map<String, String>? headers}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$path');
    final mergedHeaders = await _getHeaders(additionalHeaders: headers);
    final String stringBody = body is Map || body is List ? jsonEncode(body) : body?.toString() ?? '';

    try {
      final response = await _client.post(
        url,
        headers: mergedHeaders,
        body: stringBody.isEmpty ? null : stringBody,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a PUT request to the backend.
  static Future<http.Response> put(String path, {dynamic body, Map<String, String>? headers}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$path');
    final mergedHeaders = await _getHeaders(additionalHeaders: headers);
    final String stringBody = body is Map || body is List ? jsonEncode(body) : body?.toString() ?? '';

    try {
      final response = await _client.put(
        url,
        headers: mergedHeaders,
        body: stringBody.isEmpty ? null : stringBody,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a DELETE request to the backend.
  static Future<http.Response> delete(String path, {Map<String, String>? headers}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$path');
    final mergedHeaders = await _getHeaders(additionalHeaders: headers);

    try {
      final response = await _client.delete(url, headers: mergedHeaders);
      _handleResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Intercepts response to handle auth errors (e.g. 401).
  static void _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      _logoutAndRedirect();
    }
  }

  /// Clears user session storage, displays feedback, and redirects to the login page.
  static void _logoutAndRedirect() {
    SessionStorage.deleteToken();
    
    final context = MyApp.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión expirada. Inicie sesión nuevamente'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }

    final navigatorState = MyApp.navigatorKey.currentState;
    if (navigatorState != null) {
      navigatorState.pushNamedAndRemoveUntil(
        NombresRutas.login,
        (route) => false,
      );
    }
  }
}
