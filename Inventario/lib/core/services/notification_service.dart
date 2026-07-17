// lib/core/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:inventario/core/providers/notificacion_provider.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  int _idCounter = 0;
  String _generarId() {
    _idCounter++;
    return 'notif_${DateTime.now().millisecondsSinceEpoch}_$_idCounter';
  }

  void exito(BuildContext context, String mensaje) {
    final provider = Provider.of<NotificacionProvider>(context, listen: false);
    provider.agregarNotificacion(
      Notificacion(
        id: _generarId(),
        titulo: 'Éxito',
        mensaje: mensaje,
        icono: Icons.check_circle_rounded,
        color: Colors.green,
      ),
    );
  }

  void error(BuildContext context, String mensaje) {
    final provider = Provider.of<NotificacionProvider>(context, listen: false);
    provider.agregarNotificacion(
      Notificacion(
        id: _generarId(),
        titulo: '❌ Error',
        mensaje: mensaje,
        icono: Icons.error_rounded,
        color: Colors.red,
      ),
    );
  }

  void stockBajo(BuildContext context, String nombreMaterial, double cantidad) {
    final provider = Provider.of<NotificacionProvider>(context, listen: false);
    provider.agregarNotificacion(
      Notificacion(
        id: _generarId(),
        titulo: 'Stock Bajo',
        mensaje:
            '$nombreMaterial tiene ${cantidad.toStringAsFixed(1)} unidades disponibles',
        icono: Icons.warning_amber_rounded,
        color: Colors.orange,
      ),
    );
  }

  void advertencia(BuildContext context, String mensaje) {
    final provider = Provider.of<NotificacionProvider>(context, listen: false);
    provider.agregarNotificacion(
      Notificacion(
        id: _generarId(),
        titulo: 'Advertencia',
        mensaje: mensaje,
        icono: Icons.warning_amber_rounded,
        color: Colors.orange,
      ),
    );
  }

  void informacion(BuildContext context, String mensaje) {
    final provider = Provider.of<NotificacionProvider>(context, listen: false);
    provider.agregarNotificacion(
      Notificacion(
        id: _generarId(),
        titulo: 'Información',
        mensaje: mensaje,
        icono: Icons.info_rounded,
        color: Colors.blue,
      ),
    );
  }

  void produccionCreada(BuildContext context, int ordenId, int cantidad) {
    final provider = Provider.of<NotificacionProvider>(context, listen: false);
    provider.agregarNotificacion(
      Notificacion(
        id: _generarId(),
        titulo: 'Producción',
        mensaje: 'Orden #$ordenId creada con $cantidad pares',
        icono: Icons.factory_rounded,
        color: Colors.purple,
      ),
    );
  }

  void ventaRealizada(BuildContext context, int ventaId, double total) {
    final provider = Provider.of<NotificacionProvider>(context, listen: false);
    provider.agregarNotificacion(
      Notificacion(
        id: _generarId(),
        titulo: 'Venta',
        mensaje: 'Venta #$ventaId por S/. ${total.toStringAsFixed(2)}',
        icono: Icons.shopping_cart_rounded,
        color: Colors.green,
      ),
    );
  }
}
