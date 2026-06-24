import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Estilos basados en tu diseño de calzado/taller
  final Color primaryColor = const Color(0xFF4A3423);
  final Color backgroundColor = const Color(0xFFFDFBF9);
  final Color textDark = const Color(0xFF2C2520);

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos actuales del material
    _nombreController = TextEditingController(text: widget.material['insumo']);
    _cantidadController = TextEditingController(
      text: widget.material['cantidad'].toString(),
    );
    _proveedorController = TextEditingController(
      text: widget.material['proveedor'] == 'Sin Proveedor'
          ? ''
          : widget.material['proveedor'] ?? '',
    );

    // Asignamos categorías y medidas validadas
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

  Future<void> _actualizarMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _estaCargando = true;
    });

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
        if (mounted) {
          // Retornamos true para avisarle a MaterialesView que debe refrescar la lista
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🚨 Error: ${e.toString().replaceAll('Exception:', '')}',
            ),
            backgroundColor: const Color(0xFFDC2626),
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Editar Material ${widget.material['codigo']}',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Insumo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Campo requerido'
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _categoriaSeleccionada = value!;
                }),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cantidadController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          (double.tryParse(value ?? '') == null)
                          ? 'Inválido'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _unidadSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Medida',
                        border: OutlineInputBorder(),
                      ),
                      items: _unidades
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _unidadSeleccionada = value!;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _proveedorController,
                decoration: const InputDecoration(
                  labelText: 'Proveedor / Marca',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              _estaCargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A3423),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _actualizarMaterial,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
