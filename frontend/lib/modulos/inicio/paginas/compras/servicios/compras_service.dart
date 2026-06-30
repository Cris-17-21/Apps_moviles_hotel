import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class ComprasService {
  ComprasService._();

  /// Fetches all purchases from the backend.
  /// Each compra includes proveedor, detalleCompra[], etc.
  static Future<List<Map<String, dynamic>>> obtenerCompras() async {
    try {
      final response = await ApiClient.get('/cerro-verde/compras');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((c) => c as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener compras: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new purchase with detalleCompra[] line items.
  static Future<Map<String, dynamic>> crearCompra(
      Map<String, dynamic> compraData) async {
    try {
      final response =
          await ApiClient.post('/cerro-verde/compras', body: compraData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al crear compra: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a purchase by ID.
  static Future<void> eliminarCompra(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/compras/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar compra: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches the correlative number/series for a new purchase.
  /// GET /cerro-verde/datos-nuevacompra
  static Future<Map<String, dynamic>> getCorrelativo() async {
    try {
      final response =
          await ApiClient.get('/cerro-verde/datos-nuevacompra');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(
          'Error al obtener correlativo: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
