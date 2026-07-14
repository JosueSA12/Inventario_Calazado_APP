import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventario/core/widgets/custom_animations.dart';

// ==========================================
// ANIMACIÓN: VENTA EXITOSA
// ==========================================
Future<void> showVentaExitosaAnimation(BuildContext context) async {
  final completer = Completer<void>();

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (context.mounted) {
          Navigator.pop(context);
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Confeti de fondo
                Positioned(
                  top: -20,
                  left: -20,
                  right: -20,
                  bottom: -20,
                  child: const ConfettiAnimation(particleCount: 50, size: 200),
                ),
                // Contenido principal
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SuccessAnimation(size: 80),
                    const SizedBox(height: 16),
                    const Text(
                      "¡Venta exitosa!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "La venta se procesó correctamente",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "¡Éxito!",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return completer.future;
}

// ==========================================
// ANIMACIÓN: ERROR EN VENTA
// ==========================================
void showVentaErrorAnimation(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (context.mounted) Navigator.pop(context);
      });

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ErrorAnimation(size: 80),
                const SizedBox(height: 16),
                const Text(
                  "¡Error en la venta!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mensaje,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ==========================================
// ANIMACIÓN: CARRITO VACÍO (SNACKBAR)
// ==========================================
void showCarritoVacioAnimation(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text("El carrito está vacío")),
        ],
      ),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}
