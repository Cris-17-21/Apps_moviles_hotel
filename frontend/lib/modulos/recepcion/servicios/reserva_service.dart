import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class ReservaService {
  ReservaService._();

  /// Obtiene la lista de todas las reservas (full list, backward compatible).
  static Future<List<Map<String, dynamic>>> obtenerReservas() async {
    try {
      final response = await ApiClient.get('/cerro-verde/recepcion/reservas');
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = body['content'] as List<dynamic>;
        return data.map((r) => r as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener reservas: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene reservas con paginación server-side.
  /// Retorna un Map con 'items', 'totalElements' y 'totalPages'.
  static Future<Map<String, dynamic>> obtenerReservasPaginados({int page = 0, int size = 10}) async {
    try {
      final response = await ApiClient.get('/cerro-verde/recepcion/reservas?page=$page&size=$size');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'items': body['content'] as List<dynamic>,
          'totalElements': body['totalElements'] as int,
          'totalPages': body['totalPages'] as int,
        };
      }
      throw Exception('Error al obtener reservas: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Crea una nueva reserva.
  static Future<Map<String, dynamic>> crearReserva(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/recepcion/reservas',
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al crear reserva: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza una reserva existente.
  static Future<Map<String, dynamic>> actualizarReserva(int id, Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.put(
        '/cerro-verde/recepcion/reservas/$id',
        body: body,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al actualizar reserva: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina una reserva (lógicamente) por su ID.
  static Future<void> eliminarReserva(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/recepcion/reservas/eliminar/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar reserva: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cancela una reserva por su ID.
  static Future<Map<String, dynamic>> cancelarReserva(int id) async {
    try {
      final response = await ApiClient.put('/cerro-verde/recepcion/cancelar/$id');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al cancelar reserva: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene la lista de todos los clientes (para el formulario de reservas).
  static Future<List<Map<String, dynamic>>> obtenerClientes() async {
    try {
      final response = await ApiClient.get('/cerro-verde/clientes');
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = body['content'] as List<dynamic>;
        return data.map((c) => c as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener clientes: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
