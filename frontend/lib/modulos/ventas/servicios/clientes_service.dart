import 'dart:convert';
import '../../../core/network/api_client.dart';

class ClientesService {
  ClientesService._();

  /// Obtiene clientes con paginación server-side.
  /// Retorna un Map con 'items', 'totalElements' y 'totalPages'.
  static Future<Map<String, dynamic>> obtenerClientes({int page = 0, int size = 10}) async {
    try {
      final response = await ApiClient.get('/cerro-verde/clientes?page=$page&size=$size');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'items': body['content'] as List<dynamic>,
          'totalElements': body['totalElements'] as int,
          'totalPages': body['totalPages'] as int,
        };
      }
      throw Exception('Error al obtener clientes: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> crearCliente(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.post(
        '/cerro-verde/clientes',
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al crear cliente: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> actualizarCliente(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.put(
        '/cerro-verde/clientes',
        body: body,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al actualizar cliente: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> eliminarCliente(int id) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/clientes/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar cliente: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
