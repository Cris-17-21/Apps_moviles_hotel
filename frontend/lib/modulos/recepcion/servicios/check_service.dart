import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class CheckService {
  CheckService._();

  /// Obtiene la lista de todos los registros de check-in / check-out.
  static Future<List<Map<String, dynamic>>> obtenerChecks() async {
    try {
      final response = await ApiClient.get('/cerro-verde/recepcion/checks');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((c) => c as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener registros de check: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Realiza un check-in.
  static Future<Map<String, dynamic>> realizarCheckIn(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/recepcion/checks',
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al registrar check-in: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Realiza un check-out (actualiza el check).
  static Future<Map<String, dynamic>> realizarCheckOut(int id, Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.put(
        '/cerro-verde/recepcion/checks/$id',
        body: body,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al registrar check-out: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina un registro de check por su ID.
  static Future<void> eliminarCheck(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/recepcion/checks/eliminar/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar registro de check: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
