import 'dart:convert';
import 'package:hoteleria_erp/core/config/constants.dart';
import 'package:hoteleria_erp/core/network/api_client.dart';

class PosService {
  PosService._();

  /// Fetches the active products catalog (full list, backward compatible).
  static Future<List<Map<String, dynamic>>> obtenerProductos() async {
    try {
      final response = await ApiClient.get('/cerro-verde/productos');
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = body['content'] as List<dynamic>;
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener catálogo de productos: ${response.statusCode}');
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
      // Intentar extraer mensaje de error del backend
      String mensajeError;
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        mensajeError = body['error']?.toString() ?? '(sin detalle)';
      } catch (_) {
        mensajeError = response.statusCode.toString();
      }
      throw Exception('Error al registrar venta: $mensajeError');
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
