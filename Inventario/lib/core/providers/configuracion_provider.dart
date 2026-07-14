import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracionProvider extends ChangeNotifier {
  bool _notificaciones = true;
  bool _modoOscuro = false;
  bool _sincronizacion = true;

  bool get notificaciones => _notificaciones;
  bool get modoOscuro => _modoOscuro;
  bool get sincronizacion => _sincronizacion;

  ConfiguracionProvider() {
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificaciones = prefs.getBool('notificaciones') ?? true;
      _modoOscuro = prefs.getBool('modo_oscuro') ?? false;
      _sincronizacion = prefs.getBool('sincronizacion') ?? true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _guardarConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificaciones', _notificaciones);
      await prefs.setBool('modo_oscuro', _modoOscuro);
      await prefs.setBool('sincronizacion', _sincronizacion);
    } catch (_) {}
  }

  void setNotificaciones(bool value) {
    _notificaciones = value;
    _guardarConfiguracion();
    notifyListeners();
  }

  void setModoOscuro(bool value) {
    _modoOscuro = value;
    _guardarConfiguracion();
    notifyListeners();
  }

  void setSincronizacion(bool value) {
    _sincronizacion = value;
    _guardarConfiguracion();
    notifyListeners();
  }
}
