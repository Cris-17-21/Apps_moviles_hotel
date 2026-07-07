import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class ProductosService {
  ProductosService._();

  /// Fetches all products from the backend (full list, backward compatible).
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

  /// Fetches products with server-side pagination.
  /// Retorna un Map con 'items', 'totalElements' y 'totalPages'.
  static Future<Map<String, dynamic>> obtenerProductosPaginados({int page = 0, int size = 10}) async {
    try {
      final response = await ApiClient.get('/cerro-verde/productos?page=$page&size=$size');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'items': body['content'] as List<dynamic>,
          'totalElements': body['totalElements'] as int,
          'totalPages': body['totalPages'] as int,
        };
      }
      throw Exception('Error al obtener productos: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new product.
  static Future<Map<String, dynamic>> crearProducto(
      Map<String, dynamic> productoData) async {
    try {
      final response =
          await ApiClient.post('/cerro-verde/productos', body: productoData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al crear producto: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing product.
  static Future<Map<String, dynamic>> actualizarProducto(
      Map<String, dynamic> productoData) async {
    try {
      final response =
          await ApiClient.put('/cerro-verde/productos', body: productoData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al actualizar producto: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a product by ID (int PK).
  static Future<void> eliminarProducto(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/productos/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar producto: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
