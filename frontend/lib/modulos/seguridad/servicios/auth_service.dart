import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';
import 'package:hoteleria_erp/core/storage/session_storage.dart';

class AuthService {
  AuthService._();

  static Map<String, dynamic>? _currentUser;

  /// Retrieves cached in-memory current user details.
  static Map<String, dynamic>? get currentUser => _currentUser;

  /// Logs in using username and password.
  /// Saves the token on success and fetches the current user info.
  static Future<bool> login(String username, String password) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/generar-token',
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await SessionStorage.saveToken(token);
          // Fetch current user details
          return await fetchCurrentUser();
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fetches the details of the currently logged-in user.
  static Future<bool> fetchCurrentUser() async {
    try {
      final response = await ApiClient.get('/cerro-verde/usuario-actual');
      if (response.statusCode == 200) {
        _currentUser = jsonDecode(response.body);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Clears in-memory and stored token session.
  static Future<void> logout() async {
    _currentUser = null;
    await SessionStorage.deleteToken();
  }
}
