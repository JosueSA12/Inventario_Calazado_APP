import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:inventario/core/theme/app_colors.dart';

class FormularioEditar extends StatefulWidget {
  final Map<String, dynamic> material;

  const FormularioEditar({super.key, required this.material});

  @override
  State<FormularioEditar> createState() => _FormularioEditarState();
}

class _FormularioEditarState extends State<FormularioEditar> {
  final _formKey = GlobalKey<FormState>();
  bool _estaCargando = false;

  late TextEditingController _nombreController;
  late TextEditingController _cantidadController;
  late TextEditingController _proveedorController;

  late String _categoriaSeleccionada;
  late String _unidadSeleccionada;

  final List<String> _categorias = [
    'Cuero',
    'Suelas',
    'Hilos',
    'Pegamentos / Tintes',
    'Herrajes / Ojales',
  ];

  final List<String> _unidades = [
    'Metros',
    'Pares',
    'Bobinas',
    'Litros',
    'Unidades',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.material['insumo'] ?? '',
    );
    _cantidadController = TextEditingController(
      text: widget.material['cantidad']?.toString() ?? '0',
    );
    _proveedorController = TextEditingController(
      text:
          (widget.material['proveedor'] == 'Sin Proveedor' ||
              widget.material['proveedor'] == null)
          ? ''
          : widget.material['proveedor'],
    );

    _categoriaSeleccionada = _categorias.contains(widget.material['categoria'])
        ? widget.material['categoria']
        : _categorias.first;

    _unidadSeleccionada = _unidades.contains(widget.material['medida'])
        ? widget.material['medida']
        : _unidades.first;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  // Función para actualizar el material en la base de datos
  Future<void> _actualizarMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _estaCargando = true);

    final String urlApi = 'http://10.0.2.2:3000/api/materiales';

    try {
      final response = await http.put(
        Uri.parse(urlApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "codigo": widget.material['codigo'],
          "insumo": _nombreController.text.trim(),
          "categoria": _categoriaSeleccionada,
          "cantidad": double.parse(_cantidadController.text),
          "medida": _unidadSeleccionada,
          "proveedor": _proveedorController.text.trim().isEmpty
              ? null
              : _proveedorController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception:', '').trim()}',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Editar Material',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Insumo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Este campo es requerido'
                      : null,
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _categoriaSeleccionada,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  items: _categorias
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _categoriaSeleccionada = value!),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cantidadController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        validator: (value) =>
                            (double.tryParse(value ?? '') == null)
                            ? 'Cantidad inválida'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _unidadSeleccionada,
                        decoration: InputDecoration(
                          labelText: 'Unidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        items: _unidades
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _unidadSeleccionada = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _proveedorController,
                  decoration: InputDecoration(
                    labelText: 'Proveedor / Marca',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 40),

                // Diseño de los botones
                Row(
                  children: [
                    // Botón Cancelar
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _estaCargando
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        label: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFEF4444,
                          ), // Rojo suave
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          minimumSize: const Size(double.infinity, 54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón Guardar
                    Expanded(
                      child: ElevatedButton.icon(
                        // ← Cambiado a Expanded normal (sin flex 2)
                        onPressed: _estaCargando ? null : _actualizarMaterial,
                        icon: const Icon(Icons.save_rounded, size: 20),
                        label: const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF10B981,
                          ), // Verde suave
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          minimumSize: const Size(double.infinity, 54),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
