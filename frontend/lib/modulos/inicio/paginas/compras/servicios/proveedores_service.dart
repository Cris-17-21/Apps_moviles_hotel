import 'dart:convert';
import 'package:hoteleria_erp/core/network/api_client.dart';

class ProveedoresService {
  ProveedoresService._();

  /// Fetches all suppliers from the backend.
  static Future<List<Map<String, dynamic>>> obtenerProveedores() async {
    try {
      final response = await ApiClient.get('/cerro-verde/proveedores');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => p as Map<String, dynamic>).toList();
      }
      throw Exception('Error al obtener proveedores: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new supplier.
  static Future<Map<String, dynamic>> crearProveedor(
      Map<String, dynamic> proveedorData) async {
    try {
      final response =
          await ApiClient.post('/cerro-verde/proveedores', body: proveedorData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al crear proveedor: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing supplier.
  static Future<Map<String, dynamic>> actualizarProveedor(
      Map<String, dynamic> proveedorData) async {
    try {
      final response =
          await ApiClient.put('/cerro-verde/proveedores', body: proveedorData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error al actualizar proveedor: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a supplier by RUC (String PK).
  static Future<void> eliminarProveedor(String ruc) async {
    try {
      final response = await ApiClient.delete('/cerro-verde/proveedores/$ruc');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar proveedor: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
