import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormularioMaterial extends StatefulWidget {
  const FormularioMaterial({super.key});

  @override
  State<FormularioMaterial> createState() => _FormularioMaterialState();
}

class _FormularioMaterialState extends State<FormularioMaterial> {
  final _formKey = GlobalKey<FormState>();
  bool _estaCargando = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();

  final List<String> _categorias = [
    'Cuero',
    'Suelas',
    'Hilos',
    'Pegamentos / Tintes',
    'Herrajes / Ojales',
  ];
  String? _categoriaSeleccionada;

  // Unidades de medida
  final List<String> _unidades = [
    'Metros',
    'Pares',
    'Bobinas',
    'Litros',
    'Unidades',
  ];
  String? _unidadSeleccionada;

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  // FUNCIÓN PRINCIPAL: Consumir la API de Node.js
  Future<void> _guardarMaterialEnBaseDeDatos() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _estaCargando = true;
    });

    final String urlInsertar = 'http://10.0.2.2:3000/api/materiales';

    try {
      final response = await http.post(
        Uri.parse(urlInsertar),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "insumo": _nombreController.text.trim(),
          "categoria": _categoriaSeleccionada,
          "cantidad": double.tryParse(_cantidadController.text) ?? 0.0,
          "medida": _unidadSeleccionada,
          "proveedor": _proveedorController.text.trim().isEmpty
              ? null
              : _proveedorController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respuestaJson = jsonDecode(response.body);
        final String mensajeServidor = respuestaJson['mensaje'];

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(' $mensajeServidor'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red.shade700,
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
      appBar: AppBar(
        title: const Text('Registrar Material / Insumo'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Detalles de la Materia Prima',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              // Campo: Nombre del Material
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Insumo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                  hintText: 'Ej. Cuero Badana Negro o Pegamento XL',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre del material';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown: Categoría de Material
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Material',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _categoriaSeleccionada,
                items: _categorias.map((String cat) {
                  return DropdownMenuItem<String>(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 16),

              // Fila para Cantidad y Unidad de Medida
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
                        prefixIcon: Icon(Icons.add_chart),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        if (double.tryParse(value) == null) return 'Inválido';
                        if (double.parse(value) < 0) return '>= 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Medida',
                        border: OutlineInputBorder(),
                      ),
                      value: _unidadSeleccionada,
                      items: _unidades.map((String uni) {
                        return DropdownMenuItem<String>(
                          value: uni,
                          child: Text(uni),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _unidadSeleccionada = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Selecciona medida' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo: Proveedor
              TextFormField(
                controller: _proveedorController,
                decoration: const InputDecoration(
                  labelText: 'Proveedor / Marca',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                  hintText: 'Ej. Curtiembre San José',
                ),
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              _estaCargando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _guardarMaterialEnBaseDeDatos,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Registrar Material',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
