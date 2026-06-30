import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class UsuarioService {
  UsuarioService._();

  /// Fetches a list of all registered users from the backend.
  static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    try {
      final response = await ApiClient.get('/cerro-verde/usuarios/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((u) => u as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener la lista de usuarios: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
