import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:inventario/core/theme/app_colors.dart";
import "package:inventario/core/services/notification_service.dart";

class FormularioAbastecerMaterial extends StatefulWidget {
  final Map<String, dynamic>? materialInicial;
  final String? usuarioID;

  const FormularioAbastecerMaterial({
    super.key,
    this.materialInicial,
    this.usuarioID,
  });

  @override
  State<FormularioAbastecerMaterial> createState() =>
      _FormularioAbastecerMaterialState();
}

class _FormularioAbastecerMaterialState
    extends State<FormularioAbastecerMaterial> {
  final _formKey = GlobalKey<FormState>();
  bool _estaCargando = false;

  final TextEditingController _cantidadController = TextEditingController();

  String? _categoriaSeleccionada;
  String? _unidadSeleccionada;
  String _nombreMaterial = "";
  String _proveedorMaterial = "";

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  void _cargarDatosIniciales() {
    if (widget.materialInicial != null) {
      final material = widget.materialInicial!;
      _nombreMaterial = material['insumo'] ?? material['nombre'] ?? '';
      _categoriaSeleccionada = material['categoria'] ?? '';
      _unidadSeleccionada = material['medida'] ?? '';
      _proveedorMaterial = material['proveedor'] ?? '';
    }
  }

  Future<void> _abastecerMaterial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _estaCargando = true);

    final String nombreInsumo = _nombreMaterial;

    try {
      final response = await http.post(
        Uri.parse("http://192.168.100.122:3000/api/materiales"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "insumo": nombreInsumo,
          "categoria": _categoriaSeleccionada,
          "cantidad": double.tryParse(_cantidadController.text) ?? 0.0,
          "medida": _unidadSeleccionada,
          "proveedor": _proveedorMaterial.isEmpty ? null : _proveedorMaterial,
          "usuarioID": widget.usuarioID ?? "USR00001",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          NotificationService.instance.exito(
            context,
            'Stock abastecido correctamente',
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (mounted) {
        NotificationService.instance.error(context, 'Error al abastecer: $e');
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
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: AppColors.primary,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Abastecer Material",
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
                  "ABASTECER STOCK",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // INFORMACIÓN DEL MATERIAL
                // ==========================================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Material a Abastecer",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _nombreMaterial,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _categoriaSeleccionada ?? "Sin categoría",
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _unidadSeleccionada ?? "Sin unidad",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      if (_proveedorMaterial.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Proveedor: $_proveedorMaterial",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================================
                // CANTIDAD A INGRESAR
                // ==========================================
                const Text(
                  "CANTIDAD A INGRESAR",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
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
                    hintText: "Ingresa la cantidad a agregar",
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "La cantidad es obligatoria";
                    }
                    final num? parsed = num.tryParse(value);
                    if (parsed == null) {
                      return "Ingresa un número válido";
                    }
                    if (parsed <= 0) {
                      return "La cantidad debe ser mayor a 0";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ==========================================
                // BOTÓN
                // ==========================================
                _estaCargando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _abastecerMaterial,
                        icon: const Icon(Icons.assignment_turned_in_rounded),
                        label: const Text(
                          "Confirmar Abastecimiento",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
