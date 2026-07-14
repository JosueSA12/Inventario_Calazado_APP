import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/theme/app_colors.dart';
import 'package:inventario/core/providers/carrito_provider.dart';
import 'package:inventario/core/widgets/carrito_animations.dart';
import "package:inventario/core/services/notification_service.dart";

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  bool _enviando = false;
  bool _limpiando = false;

  // ==========================================
  // CONFIRMAR VENTA
  // ==========================================
  Future<void> _confirmarVenta(CarritoProvider provider) async {
    if (provider.isEmpty) {
      if (mounted) showCarritoVacioAnimation(context);
      return;
    }

    setState(() => _enviando = true);

    final result = await provider.confirmarVentaSinLimpiar();

    if (mounted) setState(() => _enviando = false);

    if (result["success"] == true) {
      if (mounted) {
        final ventaId = result["data"]?["ventaID"] ?? result["ventaId"] ?? 0;
        NotificationService.instance.ventaRealizada(
          context,
          ventaId,
          provider.total,
        );
        await showVentaExitosaAnimation(context);
        provider.limpiarCarritoDespuesDeVenta();
        if (mounted) Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        NotificationService.instance.error(
          context,
          result["mensaje"] ?? "Error al procesar la venta",
        );
        showVentaErrorAnimation(
          context,
          result["mensaje"] ?? "Error al procesar la venta",
        );
      }
    }
  }

  // ==========================================
  // LIMPIAR CARRITO
  // ==========================================
  Future<void> _limpiarCarrito(CarritoProvider provider) async {
    if (_limpiando) return;
    setState(() => _limpiando = true);

    final success = await provider.limpiarCarrito();

    if (mounted) setState(() => _limpiando = false);

    if (success && mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  // ==========================================
  // ELIMINAR ITEM
  // ==========================================
  Future<void> _eliminarItem(CarritoProvider provider, int index) async {
    final esUltimoItem = provider.items.length == 1;

    if (esUltimoItem) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("¿Vaciar carrito?"),
          content: const Text(
            "Se eliminará el último producto y el carrito quedará vacío.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Eliminar"),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    await provider.eliminarItem(index);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Producto eliminado"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );

      if (provider.isEmpty && mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  // ==========================================
  // ITEM CARD
  // ==========================================
  Widget _buildItemCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
    CarritoProvider provider,
  ) {
    final cantidad = item["cantidad"] as int;
    final stockDisponible = item["stockDisponible"] ?? 0;
    final subtotal = (item["subtotal"] ?? 0.0) as double;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cantidad
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "$cantidad",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["descripcion"] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "S/. ${item["precio"]} × $cantidad",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  if (cantidad >= stockDisponible && stockDisponible > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Máximo stock alcanzado",
                        style: TextStyle(
                          color: AppColors.kpiAlertas,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Precio y controles
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "S/. ${subtotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      Icons.remove,
                      () => provider.actualizarCantidad(index, cantidad - 1),
                      cantidad > 1,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$cantidad",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildQuantityButton(
                      Icons.add,
                      () => provider.actualizarCantidad(index, cantidad + 1),
                      cantidad < stockDisponible,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _eliminarItem(provider, index),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
    IconData icon,
    VoidCallback onPressed,
    bool enabled,
  ) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
        foregroundColor: enabled ? Colors.black87 : Colors.grey,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
      ),
      child: Icon(icon, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CarritoProvider>(context);
    final items = provider.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Mi Carrito",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: _limpiando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              onPressed: _limpiando
                  ? null
                  : () => _mostrarDialogoConfirmacion(provider),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Header con total rápido
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${items.length} productos",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "S/. ${provider.total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(items[index]["codigo"] ?? "$index"),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (_) => _eliminarItem(provider, index),
                        child: _buildItemCard(
                          context,
                          items[index],
                          index,
                          provider,
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Bar
                _buildBottomBar(provider),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          const Text(
            "Tu carrito está vacío",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Agrega productos para continuar",
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Volver a la tienda"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CarritoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 16)),
                Text(
                  "S/. ${provider.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _enviando ? null : () => _confirmarVenta(provider),
                icon: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                label: Text(
                  _enviando ? "Procesando venta..." : "Confirmar Venta",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoConfirmacion(CarritoProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("¿Limpiar carrito?"),
        content: const Text("Esta acción eliminará todos los productos."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _limpiarCarrito(provider);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Limpiar"),
          ),
        ],
      ),
    );
  }
}
