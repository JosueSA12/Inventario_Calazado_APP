import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inventario/models/actividad_item.dart';

class DashboardProvider extends ChangeNotifier {
  final String baseUrl = "http://192.168.100.122:3000/api/dashboard";

  List<ActividadItem> _actividad = [];
  bool _cargando = false;
  String _error = '';

  List<ActividadItem> get actividad => _actividad;
  bool get cargando => _cargando;
  String get error => _error;

  Future<void> cargarActividad({String filtro = 'TODOS'}) async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      final url = filtro == "TODOS"
          ? "$baseUrl/actividad"
          : "$baseUrl/filtrar-movimientos?tipo=$filtro";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _actividad = data.map((e) => ActividadItem.fromJson(e)).toList();
        _error = '';
      } else {
        _error = 'Error en el servidor: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }

    _cargando = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> obtenerDetalle(ActividadItem item) async {
    if (!item.tieneDetalle) {
      throw Exception('Esta actividad no tiene detalle disponible');
    }

    if (item.esVenta) {
      final url =
          "http://192.168.100.122:3000/api/ventas/detalle/${item.referenciaId}";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'tipo': 'VENTA', 'data': data};
      } else {
        throw Exception(
          'Error al obtener detalle de la venta: ${response.statusCode}',
        );
      }
    } else if (item.esProduccion) {
      final url =
          "http://192.168.100.122:3000/api/produccion/detalle/${item.referenciaId}";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'tipo': 'PRODUCCION', 'data': data};
      } else {
        throw Exception(
          'Error al obtener detalle de producción: ${response.statusCode}',
        );
      }
    } else {
      return {
        'tipo': 'MATERIAL',
        'data': {
          'fecha': item.fecha.toIso8601String(),
          'descripcion': item.descripcion,
          'cantidad': item.cantidad,
          'movimiento': item.movimiento,
          'encargado': item.encargado,
        },
      };
    }
  }

  void limpiar() {
    _actividad = [];
    _error = '';
    _cargando = false;
    notifyListeners();
  }
}
