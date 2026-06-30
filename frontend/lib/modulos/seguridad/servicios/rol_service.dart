import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class RolService {
  RolService._();

  /// Fetches all roles from the backend.
  static Future<List<Map<String, dynamic>>> obtenerRoles() async {
    try {
      final response = await ApiClient.get('/cerro-verde/roles/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((r) => r as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener roles: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new role.
  static Future<Map<String, dynamic>> crearRol(Map<String, dynamic> rolData) async {
    try {
      final response = await ApiClient.post('/cerro-verde/roles/', body: rolData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al crear rol: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing role.
  static Future<Map<String, dynamic>> actualizarRol(Map<String, dynamic> rolData) async {
    try {
      final response = await ApiClient.put('/cerro-verde/roles/', body: rolData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al actualizar rol: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a role by ID.
  static Future<void> eliminarRol(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/roles/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar rol: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
