import 'package:flutter/material.dart';
import 'package:inventario/core/services/reporte_service.dart';

class ReporteProvider extends ChangeNotifier {
  final ReporteService _service = ReporteService();

  // Estados de carga
  bool _loadingVentas = false;
  bool _loadingProduccion = false;
  bool _loadingComparativo = false;
  bool _loadingStock = false;
  bool _loadingDetalle = false;

  int _version = 0;

  // Datos
  Map<String, dynamic>? _ventasData;
  Map<String, dynamic>? _produccionData;
  Map<String, dynamic>? _comparativoData;
  Map<String, dynamic>? _stockData;
  Map<String, dynamic>? _ventasDetalleData;
  Map<String, dynamic>? _produccionDetalleData;

  // Filtros
  String _tipoFiltro = 'MES';
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _usuarioID;
  String _tipoStock = 'CALZADO';

  // Getters
  bool get loadingVentas => _loadingVentas;
  bool get loadingProduccion => _loadingProduccion;
  bool get loadingComparativo => _loadingComparativo;
  bool get loadingStock => _loadingStock;
  bool get loadingDetalle => _loadingDetalle;
  int get version => _version;

  Map<String, dynamic>? get ventasData => _ventasData;
  Map<String, dynamic>? get produccionData => _produccionData;
  Map<String, dynamic>? get comparativoData => _comparativoData;
  Map<String, dynamic>? get stockData => _stockData;
  Map<String, dynamic>? get ventasDetalleData => _ventasDetalleData;
  Map<String, dynamic>? get produccionDetalleData => _produccionDetalleData;

  String get tipoFiltro => _tipoFiltro;
  DateTime? get fechaInicio => _fechaInicio;
  DateTime? get fechaFin => _fechaFin;
  String get tipoStock => _tipoStock;

  String? _filtroActual;
  String? get filtroActual => _filtroActual;

  // ==========================================
  // SETTERS
  // ==========================================
  void setFiltro(String tipo) {
    _tipoFiltro = tipo;
    _filtroActual = tipo;
    _version++;
    notifyListeners();
  }

  void setFechas(DateTime? inicio, DateTime? fin) {
    _fechaInicio = inicio;
    _fechaFin = fin;
    _version++;
    notifyListeners();
  }

  void setUsuario(String? usuarioID) {
    _usuarioID = usuarioID;
    notifyListeners();
  }

  void setTipoStock(String tipo) {
    if (_tipoStock != tipo) {
      _tipoStock = tipo;
      notifyListeners();
    }
  }

  // ==========================================
  // OBTENER REPORTE DE VENTAS
  // ==========================================
  Future<void> cargarReporteVentas() async {
    _loadingVentas = true;
    notifyListeners();

    try {
      _ventasData = await _service.getReporteVentas(
        fechaInicio: _fechaInicio?.toIso8601String().split('T').first,
        fechaFin: _fechaFin?.toIso8601String().split('T').first,
        tipoFiltro: _tipoFiltro,
        usuarioID: _usuarioID,
      );
    } catch (e) {
      _ventasData = {"error": e.toString()};
    } finally {
      _loadingVentas = false;
      _version++;
      notifyListeners();
    }
  }

  // ==========================================
  // OBTENER REPORTE DE PRODUCCIÓN
  // ==========================================
  Future<void> cargarReporteProduccion() async {
    _loadingProduccion = true;
    notifyListeners();

    try {
      _produccionData = await _service.getReporteProduccion(
        fechaInicio: _fechaInicio?.toIso8601String().split('T').first,
        fechaFin: _fechaFin?.toIso8601String().split('T').first,
        tipoFiltro: _tipoFiltro,
        usuarioID: _usuarioID,
      );
    } catch (e) {
      _produccionData = {"error": e.toString()};
    } finally {
      _loadingProduccion = false;
      _version++;
      notifyListeners();
    }
  }

  // ==========================================
  // OBTENER REPORTE COMPARATIVO
  // ==========================================
  Future<void> cargarReporteComparativo() async {
    _loadingComparativo = true;
    notifyListeners();

    try {
      _comparativoData = await _service.getReporteComparativo(
        fechaInicio: _fechaInicio?.toIso8601String().split('T').first,
        fechaFin: _fechaFin?.toIso8601String().split('T').first,
      );
    } catch (e) {
      _comparativoData = {"error": e.toString()};
    } finally {
      _loadingComparativo = false;
      _version++;
      notifyListeners();
    }
  }

  // ==========================================
  // OBTENER REPORTE DE STOCK
  // ==========================================
  Future<void> cargarReporteStock({String tipo = 'TODOS'}) async {
    _loadingStock = true;
    if (tipo != 'TODOS') {
      setTipoStock(tipo);
    }
    notifyListeners();

    try {
      _stockData = await _service.getReporteStock(tipo: tipo);
      if (_stockData != null) {
        _stockData!['tipo'] = _tipoStock;
      }
    } catch (e) {
      _stockData = {"error": e.toString()};
    } finally {
      _loadingStock = false;
      notifyListeners();
    }
  }

  // ==========================================
  // OBTENER DETALLE DE VENTAS (PDF)
  // ==========================================
  Future<void> cargarDetalleVentas() async {
    _loadingDetalle = true;
    notifyListeners();

    try {
      _ventasDetalleData = await _service.getReporteVentasDetalle(
        fechaInicio: _fechaInicio?.toIso8601String().split('T').first,
        fechaFin: _fechaFin?.toIso8601String().split('T').first,
        usuarioID: _usuarioID,
      );
    } catch (e) {
      _ventasDetalleData = {"error": e.toString()};
    } finally {
      _loadingDetalle = false;
      _version++;

      notifyListeners();
    }
  }

  // ==========================================
  // OBTENER DETALLE DE PRODUCCIÓN (PDF)
  // ==========================================
  Future<void> cargarDetalleProduccion() async {
    _loadingDetalle = true;
    notifyListeners();

    try {
      _produccionDetalleData = await _service.getReporteProduccionDetalle(
        fechaInicio: _fechaInicio?.toIso8601String().split('T').first,
        fechaFin: _fechaFin?.toIso8601String().split('T').first,
        usuarioID: _usuarioID,
      );
    } catch (e) {
      _produccionDetalleData = {"error": e.toString()};
    } finally {
      _loadingDetalle = false;
      notifyListeners();
    }
  }

  // ==========================================
  // CARGAR TODOS LOS REPORTES
  // ==========================================
  Future<void> cargarTodosLosReportes() async {
    await Future.wait([
      cargarReporteVentas(),
      cargarReporteProduccion(),
      cargarReporteComparativo(),
      cargarReporteStock(),
    ]);
  }

  // ==========================================
  // LIMPIAR DATOS
  // ==========================================
  void limpiarDatos() {
    _ventasData = null;
    _produccionData = null;
    _comparativoData = null;
    _stockData = null;
    _ventasDetalleData = null;
    _produccionDetalleData = null;
    notifyListeners();
  }
}
