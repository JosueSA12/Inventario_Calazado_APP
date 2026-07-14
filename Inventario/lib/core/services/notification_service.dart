import 'package:flutter/material.dart';
import 'package:inventario/core/providers/notificacion_provider.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  // ==========================================
  // MÉTODOS DE NOTIFICACIÓN
  // ==========================================

  void _notificar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    IconData icono = Icons.info_outline,
    Color color = Colors.blue,
    bool showSnackBar = true,
    Duration? duration,
  }) {
    final provider = Provider.of<NotificacionProvider>(context, listen: false);

    // Crear la notificación con el nuevo modelo
    final notificacion = Notificacion(
      titulo: titulo,
      mensaje: mensaje,
      icono: icono,
      color: color,
      timestamp: DateTime.now(),
      leida: false,
    );

    // Agregar al provider
    provider.agregarNotificacion(notificacion);

    // Mostrar SnackBar
    if (showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icono, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: duration ?? const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ==========================================
  // NOTIFICACIONES DE ÉXITO
  // ==========================================
  void exito(BuildContext context, String mensaje) {
    _notificar(
      context,
      titulo: 'Éxito',
      mensaje: mensaje,
      icono: Icons.check_circle_rounded,
      color: Colors.green,
    );
  }

  // ==========================================
  // NOTIFICACIONES DE ERROR
  // ==========================================
  void error(BuildContext context, String mensaje) {
    _notificar(
      context,
      titulo: 'Error',
      mensaje: mensaje,
      icono: Icons.error_rounded,
      color: Colors.red,
    );
  }

  // ==========================================
  // NOTIFICACIONES DE ADVERTENCIA
  // ==========================================
  void advertencia(BuildContext context, String mensaje) {
    _notificar(
      context,
      titulo: 'Advertencia',
      mensaje: mensaje,
      icono: Icons.warning_amber_rounded,
      color: Colors.orange,
    );
  }

  // ==========================================
  // NOTIFICACIONES DE INFORMACIÓN
  // ==========================================
  void info(BuildContext context, String mensaje) {
    _notificar(
      context,
      titulo: 'Información',
      mensaje: mensaje,
      icono: Icons.info_outline,
      color: Colors.blue,
    );
  }

  // ==========================================
  // NOTIFICACIONES DE STOCK
  // ==========================================
  void stockBajo(BuildContext context, String producto, double cantidad) {
    _notificar(
      context,
      titulo: 'Stock Bajo',
      mensaje: '$producto tiene solo $cantidad unidades disponibles',
      icono: Icons.inventory_2_rounded,
      color: Colors.orange,
    );
  }

  void sinStock(BuildContext context, String producto) {
    _notificar(
      context,
      titulo: 'Sin Stock',
      mensaje: '$producto se ha agotado',
      icono: Icons.inventory_2_rounded,
      color: Colors.red,
    );
  }

  // ==========================================
  // NOTIFICACIONES DE VENTAS
  // ==========================================
  void ventaRealizada(BuildContext context, int ventaId, double total) {
    _notificar(
      context,
      titulo: '🛒 Venta Realizada',
      mensaje: 'Venta #$ventaId por S/. ${total.toStringAsFixed(2)}',
      icono: Icons.shopping_cart_rounded,
      color: Colors.green,
    );
  }

  // ==========================================
  // NOTIFICACIONES DE PRODUCCIÓN
  // ==========================================
  void produccionCreada(BuildContext context, int ordenId, int pares) {
    _notificar(
      context,
      titulo: 'Producción Registrada',
      mensaje: 'Orden #$ordenId - $pares pares producidos',
      icono: Icons.factory_rounded,
      color: Colors.blue,
    );
  }

  // ==========================================
  // NOTIFICACIONES DE SISTEMA
  // ==========================================
  void sistemaIniciado(BuildContext context) {
    _notificar(
      context,
      titulo: '🔹 Sistema Iniciado',
      mensaje: 'Bienvenido al Sistema de Gestión del Taller',
      icono: Icons.storefront_rounded,
      color: Colors.blue,
      showSnackBar: false,
    );
  }

  void sesionIniciada(BuildContext context, String usuario) {
    _notificar(
      context,
      titulo: 'Sesión Iniciada',
      mensaje: 'Bienvenido $usuario',
      icono: Icons.verified_rounded,
      color: Colors.green,
      showSnackBar: false,
    );
  }
}
