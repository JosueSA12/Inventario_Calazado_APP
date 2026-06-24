import 'package:flutter/material.dart';

class _Estilos {
  static const Color textDark = Color(0xFF2C2520);
  static const Color textLight = Color(0xFF7A726C);
  static const Color dangerColor = Color(0xFFDC2626);
  static const Color primaryColor = Color(0xFF4A3423);
}

// ==========================================================================
// WIDGET: DETALLE PARA MATERIALES CON BAJO STOCK
// ==========================================================================
class DetalleBajoStockSheet extends StatelessWidget {
  final String codigo;
  final String insumo;
  final String categoria;
  final double cantidad;
  final String medida;
  final String proveedor;
  final VoidCallback? onOrdenarMas; // Acción para abastecer

  const DetalleBajoStockSheet({
    super.key,
    required this.codigo,
    required this.insumo,
    required this.categoria,
    required this.cantidad,
    required this.medida,
    required this.proveedor,
    this.onOrdenarMas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 24),

          // Encabezado de Emergencia / Alerta
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _Estilos.dangerColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _Estilos.dangerColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALERTA: STOCK BAJO EL MÍNIMO',
                      style: TextStyle(
                        fontSize: 11,
                        color: _Estilos.dangerColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      insumo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _Estilos.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1),

          _buildRow('Código Sistema', codigo, isCode: true),
          _buildRow('Categoría', categoria),
          _buildRow('Proveedor sugerido', proveedor),
          _buildRow(
            'Stock Actual Crítico',
            '$cantidad $medida',
            isDanger: true,
          ),

          const SizedBox(height: 24),

          // Botón de Acción Rápida
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onOrdenarMas ?? () => Navigator.pop(context),
              icon: const Icon(
                Icons.shopping_cart_checkout_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'Gestionar Abastecimiento',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Estilos.dangerColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================
//  DETALLE GENERAL DE MATERIALES
// ====================================
class DetalleMaterialGeneralSheet extends StatelessWidget {
  final String codigo;
  final String insumo;
  final String categoria;
  final double cantidad;
  final String medida;
  final String proveedor;

  const DetalleMaterialGeneralSheet({
    super.key,
    required this.codigo,
    required this.insumo,
    required this.categoria,
    required this.cantidad,
    required this.medida,
    required this.proveedor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 24),

          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _Estilos.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: _Estilos.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FICHA GENERAL DEL MATERIAL',
                      style: TextStyle(
                        fontSize: 11,
                        color: _Estilos.textLight,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      insumo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _Estilos.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1),

          _buildRow('Código Sistema', codigo, isCode: true),
          _buildRow('Categoría', categoria),
          _buildRow('Proveedor', proveedor),

          const Divider(height: 24, thickness: 1),

          _buildRow('Stock Disponible', '$cantidad $medida', isPrimary: true),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ====================================
// COMPONENTES AUXILIARES DE DISEÑO
// ====================================
Widget _buildDragHandle() {
  return Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

Widget _buildRow(
  String label,
  String value, {
  bool isCode = false,
  bool isDanger = false,
  bool isPrimary = false,
}) {
  Color valColor = _Estilos.textDark;
  if (isDanger) valColor = _Estilos.dangerColor;
  if (isPrimary) valColor = _Estilos.primaryColor;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: _Estilos.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value.trim().isEmpty ? '-' : value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valColor,
              fontSize: (isDanger || isPrimary) ? 16 : 14,
              fontWeight: (isDanger || isPrimary || isCode)
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontFamily: isCode ? 'monospace' : null,
            ),
          ),
        ),
      ],
    ),
  );
}
