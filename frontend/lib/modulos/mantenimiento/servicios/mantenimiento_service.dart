import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class MantenimientoService {
  MantenimientoService._();

  // ==========================================
  // LIMPIEZAS (CLEANING) ENDPOINTS
  // ==========================================

  /// Obtiene la lista de todas las tareas de limpieza.
  static Future<List<Map<String, dynamic>>> obtenerLimpiezas() async {
    try {
      final response = await ApiClient.get('/cerro-verde/limpiezas/ver');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((l) => l as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener limpiezas: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Registra una nueva tarea de limpieza.
  static Future<Map<String, dynamic>> registrarLimpieza(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/limpiezas/registrar',
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al registrar limpieza: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza una tarea de limpieza existente.
  static Future<void> actualizarLimpieza(int id, Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.put(
        '/cerro-verde/limpiezas/actualizar/$id',
        body: body,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al actualizar limpieza: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina una tarea de limpieza.
  static Future<void> eliminarLimpieza(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/limpiezas/eliminar/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar limpieza: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene la lista de todo el personal de limpieza.
  static Future<List<Map<String, dynamic>>> obtenerPersonalLimpieza() async {
    try {
      final response = await ApiClient.get('/cerro-verde/personallimpieza/ver');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener personal de limpieza: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // INCIDENCIAS (INCIDENTS) ENDPOINTS
  // ==========================================

  /// Obtiene la lista de todas las incidencias.
  static Future<List<Map<String, dynamic>>> obtenerIncidencias() async {
    try {
      final response = await ApiClient.get('/cerro-verde/incidencias/ver');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((i) => i as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener incidencias: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Registra una nueva incidencia.
  static Future<Map<String, dynamic>> registrarIncidencia(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/incidencias/registrar',
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al registrar incidencia: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza una incidencia existente.
  static Future<void> actualizarIncidencia(int id, Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.put(
        '/cerro-verde/incidencias/actualizar/$id',
        body: body,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al actualizar incidencia: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina una incidencia por su ID.
  static Future<void> eliminarIncidencia(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/incidencias/eliminar/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar incidencia: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene la lista de tipos de incidencia.
  static Future<List<Map<String, dynamic>>> obtenerTiposIncidencia() async {
    try {
      final response = await ApiClient.get('/cerro-verde/tipoincidencia/ver');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((t) => t as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener tipos de incidencia: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene la lista de áreas del hotel.
  static Future<List<Map<String, dynamic>>> obtenerAreasHotel() async {
    try {
      final response = await ApiClient.get('/cerro-verde/areashotel/ver');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((a) => a as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener áreas del hotel: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
