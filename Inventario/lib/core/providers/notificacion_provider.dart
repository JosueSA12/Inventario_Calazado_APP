import 'package:flutter/material.dart';

class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final IconData icono;
  final Color color;
  final DateTime timestamp;
  bool leida;

  Notificacion({
    String? id, // ✅ Ahora es opcional
    required this.titulo,
    required this.mensaje,
    required this.icono,
    required this.color,
    DateTime? timestamp,
    this.leida = false,
  }) : id =
           id ??
           'notif_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
       timestamp = timestamp ?? DateTime.now();

  Notificacion copyWith({bool? leida}) {
    return Notificacion(
      id: id,
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
  final Set<String> _idsMostrados = {};

  static const Duration _tiempoVida = Duration(seconds: 120);

  List<Notificacion> get notificaciones => _notificaciones;
  bool get tieneNotificaciones => _notificaciones.isNotEmpty;

  void agregarNotificacion(Notificacion notificacion) {
    if (_idsMostrados.contains(notificacion.id)) {
      return;
    }

    final existe = _notificaciones.any(
      (n) =>
          n.titulo == notificacion.titulo && n.mensaje == notificacion.mensaje,
    );
    if (existe) return;

    _idsMostrados.add(notificacion.id);
    _notificaciones.insert(0, notificacion);
    notifyListeners();

    Future.delayed(_tiempoVida, () {
      _eliminarNotificacionPorId(notificacion.id);
    });
  }

  void _eliminarNotificacionPorId(String id) {
    final index = _notificaciones.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notificaciones.removeAt(index);
      _idsMostrados.remove(id);
      notifyListeners();
    }
  }

  void marcarComoLeida(int index) {
    if (index < 0 || index >= _notificaciones.length) return;
    _notificaciones[index] = _notificaciones[index].copyWith(leida: true);
    notifyListeners();
  }

  void eliminarNotificacion(int index) {
    if (index < 0 || index >= _notificaciones.length) return;
    final id = _notificaciones[index].id;
    _notificaciones.removeAt(index);
    _idsMostrados.remove(id);
    notifyListeners();
  }

  void limpiarNotificaciones() {
    _notificaciones.clear();
    _idsMostrados.clear();
    notifyListeners();
  }

  void marcarTodasComoLeidas() {
    for (int i = 0; i < _notificaciones.length; i++) {
      _notificaciones[i] = _notificaciones[i].copyWith(leida: true);
    }
    notifyListeners();
  }

  int get cantidadNoLeidas => _notificaciones.where((n) => !n.leida).length;

  void limpiarAntiguas() {
    final ahora = DateTime.now();
    _notificaciones.removeWhere((n) {
      final diferencia = ahora.difference(n.timestamp);
      return diferencia > const Duration(minutes: 5);
    });
    notifyListeners();
  }
}
