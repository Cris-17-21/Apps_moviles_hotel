import 'dart:convert';
import '../../../core/network/api_client.dart';

class ClientesService {
  ClientesService._();

  static Future<List<Map<String, dynamic>>> obtenerClientes() async {
    try {
      final response = await ApiClient.get('/cerro-verde/clientes');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((c) => c as Map<String, dynamic>).toList();
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
