import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class CajaService {
  CajaService._();

  /// Checks the status of the current cash register.
  static Future<Map<String, dynamic>> obtenerEstadoCaja() async {
    try {
      final response = await ApiClient.get('/cerro-verde/caja');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      if (response.statusCode == 204) {
        throw Exception('No tiene una caja asignada. Contacte al administrador.');
      }
      throw Exception('Error al obtener estado de caja: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Opens the cash register with a starting amount.
  static Future<Map<String, dynamic>> aperturarCaja(double montoApertura) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/caja/aperturar',
        body: {
          'montoApertura': montoApertura,
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al aperturar caja: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Closes the cash register with the physical cash counted.
  static Future<Map<String, dynamic>> cerrarCaja(double montoCierre) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/caja/cerrar',
        body: {
          'montoCierre': montoCierre,
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al cerrar caja: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches cash register transactions with server-side pagination.
  /// Retorna un Map con 'items', 'totalElements' y 'totalPages'.
  static Future<Map<String, dynamic>> obtenerTransacciones({int page = 0, int size = 10}) async {
    try {
      final response = await ApiClient.get('/cerro-verde/caja/transacciones/all?page=$page&size=$size');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'items': body['content'] as List<dynamic>,
          'totalElements': body['totalElements'] as int,
          'totalPages': body['totalPages'] as int,
        };
      }
      throw Exception('Error al obtener transacciones: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Saves a new egress / ingress transaction.
  /// tipoId: 1 for INGRESO, 2 for EGRESO
  static Future<bool> guardarTransaccion({
    required double montoTransaccion,
    required String motivo,
    required int tipoId,
  }) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/caja/transacciones/guardar',
        body: {
          'montoTransaccion': montoTransaccion,
          'motivo': motivo,
          'tipo': {
            'id': tipoId,
          },
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Obtiene las denominaciones de billetes/monedas desde el backend.
  static Future<List<Map<String, dynamic>>> obtenerDenominaciones() async {
    final response = await ApiClient.get('/cerro-verde/caja/arqueo/denominaciones');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
    }
    throw Exception('Error al obtener denominaciones: ${response.statusCode}');
  }

  /// Guarda un arqueo en el backend.
  /// [detalles] es una lista de Map con 'cantidad' y 'denominacion' (con 'id').
  static Future<Map<String, dynamic>> guardarArqueo({
    required List<Map<String, dynamic>> detalles,
    String? observaciones,
  }) async {
    final response = await ApiClient.post(
      '/cerro-verde/caja/arqueo/crear',
      body: {
        'detalles': detalles,
        if (observaciones != null) 'observaciones': observaciones,
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Error al guardar arqueo: ${response.statusCode}');
  }
}
