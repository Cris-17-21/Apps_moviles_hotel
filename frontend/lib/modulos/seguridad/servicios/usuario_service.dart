import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class UsuarioService {
  UsuarioService._();

  /// Fetches a list of all registered users from the backend.
  static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    try {
      final response = await ApiClient.get('/cerro-verde/usuarios/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((u) => u as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener la lista de usuarios: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new user.
  static Future<Map<String, dynamic>> crearUsuario(Map<String, dynamic> usuarioData) async {
    try {
      final response = await ApiClient.post('/cerro-verde/usuarios/', body: usuarioData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al crear usuario: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing user by ID.
  static Future<Map<String, dynamic>> actualizarUsuario(int id, Map<String, dynamic> usuarioData) async {
    try {
      final response = await ApiClient.put('/cerro-verde/usuarios/$id', body: usuarioData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al actualizar usuario: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a user by ID.
  static Future<void> eliminarUsuario(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/usuarios/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar usuario: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
