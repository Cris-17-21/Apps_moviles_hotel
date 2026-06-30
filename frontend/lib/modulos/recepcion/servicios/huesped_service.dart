import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class HuespedService {
  HuespedService._();

  /// Obtiene la lista de todos los huéspedes.
  static Future<List<Map<String, dynamic>>> obtenerHuespedes() async {
    try {
      final response = await ApiClient.get('/cerro-verde/recepcion/huespedes');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((h) => h as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener huéspedes: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Guarda un nuevo huésped (o lo asocia).
  static Future<Map<String, dynamic>> guardarHuesped(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/recepcion/huespedes',
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al guardar huésped: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene un huésped por su ID.
  static Future<Map<String, dynamic>> obtenerHuesped(int id) async {
    try {
      final response = await ApiClient.get('/cerro-verde/recepcion/huespedes/$id');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al obtener huésped: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina un huésped por su ID.
  static Future<void> eliminarHuesped(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/recepcion/huespedes/eliminar/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar huésped: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
