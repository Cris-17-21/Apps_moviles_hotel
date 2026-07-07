import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class PermisoService {
  PermisoService._();

  /// Obtiene todos los módulos con sus permisos.
  static Future<List<Map<String, dynamic>>> obtenerModulos() async {
    try {
      final response = await ApiClient.get('/cerro-verde/modulos/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((m) => m as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener módulos: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene todos los permisos disponibles.
  static Future<List<Map<String, dynamic>>> obtenerPermisos() async {
    try {
      final response = await ApiClient.get('/cerro-verde/permisos/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener permisos: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene los permisos de un módulo específico.
  static Future<List<Map<String, dynamic>>> obtenerPermisosPorModulo(int idModulo) async {
    try {
      final response = await ApiClient.get('/cerro-verde/modulos/$idModulo/permisos');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener permisos del módulo: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
