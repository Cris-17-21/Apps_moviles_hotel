import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class AlmacenService {
  AlmacenService._();

  /// Fetches inventory movements with server-side pagination.
  /// Retorna un Map con 'items', 'totalElements' y 'totalPages'.
  static Future<Map<String, dynamic>> obtenerMovimientos({int page = 0, int size = 10}) async {
    try {
      final response =
          await ApiClient.get('/cerro-verde/movimientosinventario?page=$page&size=$size');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'items': body['content'] as List<dynamic>,
          'totalElements': body['totalElements'] as int,
          'totalPages': body['totalPages'] as int,
        };
      }
      throw Exception(
          'Error al obtener movimientos: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new inventory movement.
  static Future<Map<String, dynamic>> crearMovimiento(
      Map<String, dynamic> movimientoData) async {
    try {
      final response = await ApiClient.post(
          '/cerro-verde/movimientosinventario',
          body: movimientoData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(
          'Error al crear movimiento: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing inventory movement.
  static Future<Map<String, dynamic>> actualizarMovimiento(
      Map<String, dynamic> movimientoData) async {
    try {
      final response = await ApiClient.put(
          '/cerro-verde/movimientosinventario',
          body: movimientoData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(
          'Error al actualizar movimiento: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes an inventory movement by ID (int PK).
  static Future<void> eliminarMovimiento(int id) async {
    try {
      final response =
          await ApiClient.delete('/cerro-verde/movimientosinventario/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Error al eliminar movimiento: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches all products for the product picker dialog.
  static Future<List<Map<String, dynamic>>> obtenerProductos() async {
    try {
      final response = await ApiClient.get('/cerro-verde/productos');
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = body['content'] as List<dynamic>;
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener productos: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
