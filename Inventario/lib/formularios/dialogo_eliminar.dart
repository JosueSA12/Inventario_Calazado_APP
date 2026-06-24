import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:inventario/core/theme/app_colors.dart';

class DialogoEliminar extends StatefulWidget {
  final String codigo;
  final String nombre;

  const DialogoEliminar({
    super.key,
    required this.codigo,
    required this.nombre,
  });

  @override
  State<DialogoEliminar> createState() => _DialogoEliminarState();
}

class _DialogoEliminarState extends State<DialogoEliminar> {
  bool _estaCargando = false;
  // Método para eliminar el material
  Future<void> _eliminarMaterial() async {
    setState(() => _estaCargando = true);

    final String urlApi =
        'http://10.0.2.2:3000/api/materiales/${widget.codigo}';

    try {
      final response = await http.delete(Uri.parse(urlApi));

      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar: ${e.toString().replaceAll('Exception:', '').trim()}',
            ),
            backgroundColor: AppColors.kpiAlertas,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.kpiAlertas.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.kpiAlertas,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Eliminar Material',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: Text(
        '¿Estás seguro de que deseas eliminar el material "${widget.nombre}"?\n\nEsta acción no se puede deshacer.',
        style: TextStyle(color: AppColors.textDark, fontSize: 15, height: 1.5),
      ),
      actions: [
        Row(
          children: [
            // Botón Cancelar
            Expanded(
              child: TextButton(
                onPressed: _estaCargando
                    ? null
                    : () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Botón Eliminar
            Expanded(
              child: ElevatedButton(
                onPressed: _estaCargando ? null : _eliminarMaterial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kpiAlertas,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _estaCargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
