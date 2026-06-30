import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class HabitacionService {
  HabitacionService._();

  /// Obtiene la lista de todas las habitaciones.
  static Future<List<Map<String, dynamic>>> obtenerHabitaciones() async {
    try {
      final response = await ApiClient.get('/cerro-verde/recepcion/habitaciones');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((h) => h as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener habitaciones: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Guarda una nueva habitación.
  static Future<Map<String, dynamic>> guardarHabitacion(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/recepcion/habitaciones',
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al guardar habitación: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza los datos de una habitación existente.
  static Future<Map<String, dynamic>> actualizarHabitacion(int id, Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.put(
        '/cerro-verde/recepcion/habitaciones/$id',
        body: body,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al actualizar habitación: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina una habitación por su ID.
  static Future<void> eliminarHabitacion(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/recepcion/habitaciones/eliminar/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar habitación: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene la lista de todas las sucursales (para el formulario de habitaciones).
  static Future<List<Map<String, dynamic>>> obtenerSucursales() async {
    try {
      final response = await ApiClient.get('/cerro-verde/sucursales');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((s) => s as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener sucursales: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene la lista de todos los pisos.
  static Future<List<Map<String, dynamic>>> obtenerPisos() async {
    try {
      final response = await ApiClient.get('/cerro-verde/recepcion/pisos');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener pisos: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene la lista de todos los tipos de habitación.
  static Future<List<Map<String, dynamic>>> obtenerTiposHabitacion() async {
    try {
      final response = await ApiClient.get('/cerro-verde/recepcion/habitaciones/tipo');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((t) => t as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener tipos de habitación: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
