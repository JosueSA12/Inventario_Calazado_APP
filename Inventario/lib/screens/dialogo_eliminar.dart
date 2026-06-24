import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // Paleta de colores de tu taller
  final Color primaryColor = const Color(0xFF4A3423);
  final Color surfaceColor = Colors.white;
  final Color textDark = const Color(0xFF2C2520);
  final Color textLight = const Color(0xFF7A726C);
  final Color colorRojo = const Color(0xFFDC2626);

  Future<void> _eliminarMaterial() async {
    setState(() {
      _estaCargando = true;
    });

    final String urlApi =
        'http://10.0.2.2:3000/api/materiales/${widget.codigo}';

    try {
      final response = await http.delete(Uri.parse(urlApi));

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar: ${e.toString().replaceAll('Exception:', '')}',
            ),
            backgroundColor: colorRojo,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _estaCargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colorRojo, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Eliminar Material',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        '¿Estás seguro de que deseas eliminar el material "${widget.nombre}"?\n\nEsta acción no se puede deshacer.',
        style: TextStyle(color: textDark, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: _estaCargando ? null : () => Navigator.pop(context, false),
          child: Text('Cancelar', style: TextStyle(color: textLight)),
        ),
        _estaCargando
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFDC2626),
                  ),
                ),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorRojo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _eliminarMaterial,
                child: const Text(
                  'Eliminar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
      ],
    );
  }
}
