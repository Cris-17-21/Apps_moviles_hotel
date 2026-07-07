import 'dart:convert';
import 'dart:typed_data';
import 'package:hoteleria_erp/core/network/api_client.dart';

class ReportesService {
  ReportesService._();

  // =========== COMPRAS / PROVEEDORES ===========

  static Future<List<Map<String, dynamic>>> obtenerReporteProductos(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/productos?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> obtenerReporteProveedores(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/proveedores?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // =========== VENTAS ===========

  static Future<List<Map<String, dynamic>>> obtenerVentasProductos(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/ventas/productos?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> obtenerClientesFrecuentes(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/ventas/clientes?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> obtenerVentasHabitaciones(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/ventas/habitaciones?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> obtenerVentasSalones(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/ventas/salones?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> obtenerMetodosPago(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/ventas/metodos-pago?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // Detallado endpoints

  static Future<List<Map<String, dynamic>>> obtenerSalonesDetallado(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/ventas/salones/detallado?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> obtenerHabitacionesDetallado(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/ventas/habitaciones/detallado?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> obtenerMetodosPagoDetallado(
      String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/ventas/metodos-pago/detallado?desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> obtenerReservasPorMes(
      String tipo, String desde, String hasta) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/ventas/reservas-por-mes?tipo=$tipo&desde=$desde&hasta=$hasta');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // =========== CAJA ===========

  static Future<List<Map<String, dynamic>>> obtenerResumenCaja(
      String desde, String hasta, String tipos) async {
    final response = await ApiClient.get(
        '/cerro-verde/reportes/caja/resumen?desde=$desde&hasta=$hasta&tipos=$tipos');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // =========== DOWNLOADS ===========

  static Future<Uint8List> descargarPDF(String url) async {
    return await ApiClient.getBytes(url);
  }

  static Future<Uint8List> descargarExcel(String url) async {
    return await ApiClient.getBytes(url);
  }
}
