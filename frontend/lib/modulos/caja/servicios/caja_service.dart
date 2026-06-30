import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class CajaService {
  CajaService._();

  /// Checks the status of the current cash register.
  static Future<Map<String, dynamic>> obtenerEstadoCaja() async {
    try {
      final response = await ApiClient.get('/cerro-verde/caja');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
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
        body: montoCierre,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al cerrar caja: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches cash register transactions.
  static Future<List<Map<String, dynamic>>> obtenerTransacciones() async {
    try {
      final response = await ApiClient.get('/cerro-verde/caja/transacciones');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((t) => t as Map<String, dynamic>).toList();
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
}
