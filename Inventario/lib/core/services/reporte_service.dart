import 'dart:convert';
import 'package:http/http.dart' as http;

class ReporteService {
  final String _baseUrl = "http://192.168.100.122:3000/api";

  // ==========================================
  // REPORTE DE VENTAS - RESUMEN
  // ==========================================
  Future<Map<String, dynamic>> getReporteVentas({
    String? fechaInicio,
    String? fechaFin,
    String tipoFiltro = 'MES',
    String? usuarioID,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/reportes/ventas"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fechaInicio": fechaInicio,
          "fechaFin": fechaFin,
          "tipoFiltro": tipoFiltro,
          "usuarioID": usuarioID,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error al obtener reporte de ventas");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  // ==========================================
  // REPORTE DE PRODUCCIÓN - RESUMEN
  // ==========================================
  Future<Map<String, dynamic>> getReporteProduccion({
    String? fechaInicio,
    String? fechaFin,
    String tipoFiltro = 'MES',
    String? usuarioID,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/reportes/produccion"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fechaInicio": fechaInicio,
          "fechaFin": fechaFin,
          "tipoFiltro": tipoFiltro,
          "usuarioID": usuarioID,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error al obtener reporte de producción");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  // ==========================================
  // REPORTE COMPARATIVO VENTAS VS PRODUCCIÓN
  // ==========================================
  Future<Map<String, dynamic>> getReporteComparativo({
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/reportes/comparativo"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"fechaInicio": fechaInicio, "fechaFin": fechaFin}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error al obtener reporte comparativo");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  // ==========================================
  // REPORTE DE STOCK
  // ==========================================
  Future<Map<String, dynamic>> getReporteStock({
    String tipo = 'TODOS', // TODOS, CALZADO, MATERIAL
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/reportes/stock"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tipo": tipo}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error al obtener reporte de stock");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  // ==========================================
  // REPORTE DE VENTAS DETALLADO (PARA PDF)
  // ==========================================
  Future<Map<String, dynamic>> getReporteVentasDetalle({
    String? fechaInicio,
    String? fechaFin,
    String? usuarioID,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/reportes/ventas-detalle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fechaInicio": fechaInicio,
          "fechaFin": fechaFin,
          "usuarioID": usuarioID,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error al obtener detalle de ventas");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  // ==========================================
  // REPORTE DE PRODUCCIÓN DETALLADO (PARA PDF)
  // ==========================================
  Future<Map<String, dynamic>> getReporteProduccionDetalle({
    String? fechaInicio,
    String? fechaFin,
    String? usuarioID,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/reportes/produccion-detalle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fechaInicio": fechaInicio,
          "fechaFin": fechaFin,
          "usuarioID": usuarioID,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error al obtener detalle de producción");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }
}
