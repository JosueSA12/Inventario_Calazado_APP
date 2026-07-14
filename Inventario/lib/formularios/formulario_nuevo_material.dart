import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:inventario/core/theme/app_colors.dart";
import "package:inventario/core/services/notification_service.dart";

class FormularioNuevoMaterial extends StatefulWidget {
  final String? usuarioID;

  const FormularioNuevoMaterial({super.key, this.usuarioID});

  @override
  State<FormularioNuevoMaterial> createState() =>
      _FormularioNuevoMaterialState();
}

class _FormularioNuevoMaterialState extends State<FormularioNuevoMaterial> {
  final _formKey = GlobalKey<FormState>();
  bool _estaCargando = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();

  String? _categoriaSeleccionada;
  String? _unidadSeleccionada;

  final List<String> _categorias = [
    "Cuero",
    "Suelas",
    "Hilos",
    "Pegamentos / Tintes",
    "Herrajes / Ojales",
  ];

  final List<String> _unidades = [
    "Metros",
    "Pares",
    "Bobinas",
    "Litros",
    "Unidades",
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  Future<void> _guardarMaterial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _estaCargando = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.100.122:3000/api/materiales"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "insumo": _nombreController.text.trim(),
          "categoria": _categoriaSeleccionada,
          "cantidad": double.tryParse(_cantidadController.text) ?? 0.0,
          "medida": _unidadSeleccionada,
          "proveedor": _proveedorController.text.trim().isEmpty
              ? null
              : _proveedorController.text.trim(),
          "usuarioID": widget.usuarioID ?? "USR00001",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          NotificationService.instance.exito(
            context,
            'Material registrado correctamente',
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (mounted) {
        NotificationService.instance.error(context, 'Error al registrar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _estaCargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade700.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add_box_rounded,
                color: Colors.green.shade700,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Nuevo Material",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 30),
              children: [
                const SizedBox(height: 24),
                const Text(
                  "DATOS DEL MATERIAL",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: "Nombre del Insumo",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    prefixIcon: Icon(
                      Icons.create_rounded,
                      color: AppColors.primary,
                    ),
                    hintText: "Ej. Cuero Charol Guinda 1.4mm",
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Ingresa el nombre del material";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Categoría
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Categoría o Familia",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  value: _categoriaSeleccionada,
                  items: _categorias.map((String cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _categoriaSeleccionada = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Selecciona una categoría";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Cantidad y Medida
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
                          labelText: "Cantidad",
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(
                            Icons.add_box_outlined,
                            color: AppColors.primary,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Obligatorio";
                          }
                          final num? parsed = num.tryParse(value);
                          if (parsed == null) {
                            return "Inválido";
                          }
                          if (parsed <= 0) {
                            return "> 0";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Unidad Medida",
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        value: _unidadSeleccionada,
                        items: _unidades.map((String uni) {
                          return DropdownMenuItem<String>(
                            value: uni,
                            child: Text(uni),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _unidadSeleccionada = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Selecciona medida";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Proveedor
                TextFormField(
                  controller: _proveedorController,
                  decoration: InputDecoration(
                    labelText: "Proveedor / Fabricante",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    prefixIcon: Icon(
                      Icons.business_outlined,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 32),

                // Botón
                _estaCargando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _guardarMaterial,
                        icon: const Icon(Icons.add_circle),
                        label: const Text(
                          "Registrar Material",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
