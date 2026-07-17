import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProduccionProvider extends ChangeNotifier {
  final String _baseUrl = "http://192.168.100.122:3000/api";

  List<dynamic> _calzadosConReceta = [];
  List<Map<String, dynamic>> _materialesValidacion = [];
  bool _cargando = false;
  bool _cargandoValidacion = false;
  bool _enviando = false;
  String _error = '';
  bool _puedeProducir = false;
  String _ultimoCalzadoValidado = '';

  // Getters
  List<dynamic> get calzadosConReceta => _calzadosConReceta;
  List<Map<String, dynamic>> get materialesValidacion => _materialesValidacion;
  bool get cargando => _cargando;
  bool get cargandoValidacion => _cargandoValidacion;
  bool get enviando => _enviando;
  String get error => _error;
  bool get puedeProducir => _puedeProducir;

  // Cargar calzados con receta
  Future<void> cargarCalzadosConReceta() async {
    _cargando = true;
    _error = '';
    _materialesValidacion = [];
    _puedeProducir = false;
    _ultimoCalzadoValidado = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/produccion/calzados-con-receta"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _calzadosConReceta = data['data'] ?? [];
        _error = '';
      } else {
        _error = 'Error al cargar calzados con receta';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }

    _cargando = false;
    notifyListeners();
  }

  // Validar stock para producción
  Future<bool> validarStock(String calzadoCodigo, int cantidadPares) async {
    // Si es un calzado diferente, limpiar validación anterior
    if (_ultimoCalzadoValidado != calzadoCodigo) {
      _materialesValidacion = [];
      _puedeProducir = false;
    }

    _cargandoValidacion = true;
    _error = '';
    _ultimoCalzadoValidado = calzadoCodigo;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/produccion/validar-stock"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'calzadoCodigo': calzadoCodigo,
          'cantidadPares': cantidadPares,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _materialesValidacion = List<Map<String, dynamic>>.from(
          data['data']['materiales'] ?? [],
        );
        _puedeProducir = data['data']['puedeProducir'] ?? false;
        _error = '';
        _cargandoValidacion = false;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['mensaje'] ?? 'Error al validar stock';
        _cargandoValidacion = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _cargandoValidacion = false;
      notifyListeners();
      return false;
    }
  }

  // Registrar producción
  Future<Map<String, dynamic>> registrarProduccion(
    String calzadoCodigo,
    int cantidadPares,
    String usuarioID,
  ) async {
    _enviando = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/produccion/registrar"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'calzadoCodigo': calzadoCodigo,
          'cantidadPares': cantidadPares,
          'usuarioID': usuarioID,
        }),
      );

      final data = json.decode(response.body);
      _enviando = false;
      notifyListeners();

      if (response.statusCode == 200 && data['estatus'] == 'success') {
        // Limpiar después de una producción exitosa
        _materialesValidacion = [];
        _puedeProducir = false;
        _ultimoCalzadoValidado = '';
        notifyListeners();
        return {
          'success': true,
          'mensaje': data['mensaje'],
          'ordenID': data['data']['ordenID'],
          'cantidadPares': data['data']['cantidadPares'],
        };
      } else {
        return {
          'success': false,
          'mensaje': data['mensaje'] ?? 'Error al registrar producción',
          'tipo': data['tipo'] ?? 'ERROR',
        };
      }
    } catch (e) {
      _enviando = false;
      notifyListeners();
      return {
        'success': false,
        'mensaje': 'Error de conexión: $e',
        'tipo': 'ERROR',
      };
    }
  }

  // Limpiar validación
  void limpiarValidacion() {
    _materialesValidacion = [];
    _puedeProducir = false;
    _ultimoCalzadoValidado = '';
    notifyListeners();
  }

  // Resetear estado
  void resetear() {
    _calzadosConReceta = [];
    _materialesValidacion = [];
    _cargando = false;
    _cargandoValidacion = false;
    _enviando = false;
    _error = '';
    _puedeProducir = false;
    _ultimoCalzadoValidado = '';
    notifyListeners();
  }
}
