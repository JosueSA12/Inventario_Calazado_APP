import 'package:flutter/material.dart';

class Notificacion {
  final String titulo;
  final String mensaje;
  final IconData icono;
  final Color color;
  final DateTime timestamp;
  bool leida;

  Notificacion({
    required this.titulo,
    required this.mensaje,
    required this.icono,
    required this.color,
    DateTime? timestamp,
    this.leida = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Notificacion copyWith({bool? leida}) {
    return Notificacion(
      titulo: titulo,
      mensaje: mensaje,
      icono: icono,
      color: color,
      timestamp: timestamp,
      leida: leida ?? this.leida,
    );
  }
}

class NotificacionProvider extends ChangeNotifier {
  final List<Notificacion> _notificaciones = [];

  List<Notificacion> get notificaciones => _notificaciones;
  bool get tieneNotificaciones => _notificaciones.isNotEmpty;

  void agregarNotificacion(Notificacion notificacion) {
    _notificaciones.insert(0, notificacion); // Nueva al principio
    notifyListeners();
  }

  void marcarComoLeida(int index) {
    if (index < 0 || index >= _notificaciones.length) return;

    _notificaciones[index] = _notificaciones[index].copyWith(leida: true);
    notifyListeners();
  }

  void eliminarNotificacion(int index) {
    if (index < 0 || index >= _notificaciones.length) return;

    _notificaciones.removeAt(index);
    notifyListeners();
  }

  void limpiarNotificaciones() {
    _notificaciones.clear();
    notifyListeners();
  }

  void marcarTodasComoLeidas() {
    for (int i = 0; i < _notificaciones.length; i++) {
      _notificaciones[i] = _notificaciones[i].copyWith(leida: true);
    }
    notifyListeners();
  }

  int get cantidadNoLeidas => _notificaciones.where((n) => !n.leida).length;
}
