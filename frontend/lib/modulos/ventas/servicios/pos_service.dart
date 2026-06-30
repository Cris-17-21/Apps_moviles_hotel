import 'dart:convert';
import 'package:hoteleria_erp/core/config/constants.dart';
import 'package:hoteleria_erp/core/network/api_client.dart';

class PosService {
  PosService._();

  /// Fetches the active products catalog.
  static Future<List<Map<String, dynamic>>> obtenerProductos() async {
    try {
      final response = await ApiClient.get('/cerro-verde/productos');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener catálogo de productos: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Registers a new sale transaction in the backend.
  static Future<Map<String, dynamic>> registrarVenta(Map<String, dynamic> ventaPayload) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/venta/productos',
        body: ventaPayload,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al registrar venta: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Generates the absolute URL for downloading the PDF receipt.
  static String obtenerUrlPdfRecibo(int ventaId) {
    return '${AppConstants.baseUrl}/cerro-verde/pdf/$ventaId';
  }

  /// Fetches the receipt PDF bytes.
  static Future<List<int>> obtenerPdfReciboBytes(int ventaId) async {
    try {
      final response = await ApiClient.get('/cerro-verde/pdf/$ventaId');
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw Exception('Error al descargar PDF del recibo: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
