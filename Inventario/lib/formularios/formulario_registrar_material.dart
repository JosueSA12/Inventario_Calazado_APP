// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:inventario/core/theme/app_colors.dart";

class FormularioMaterial extends StatefulWidget {
  final Map<String, dynamic>? materialInicial;

  const FormularioMaterial({super.key, this.materialInicial});

  @override
  State<FormularioMaterial> createState() => _FormularioMaterialState();
}

class _FormularioMaterialState extends State<FormularioMaterial> {
  final _formKey = GlobalKey<FormState>();
  bool _estaCargando = false;
  bool _cargandoMaterialesExistentes = true;

  // Controladores de Texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();

  // Estado para alternar entre Material Existente y Nuevo
  bool _esMaterialNuevo = false;

  // Listas de Configuración Dinámica/Estática
  List<dynamic> _materialesExistentes = [];
  Map<String, dynamic>? _materialSeleccionado;

  final List<String> _categorias = [
    "Cuero",
    "Suelas",
    "Hilos",
    "Pegamentos / Tintes",
    "Herrajes / Ojales",
  ];
  String? _categoriaSeleccionada;

  final List<String> _unidades = [
    "Metros",
    "Pares",
    "Bobinas",
    "Litros",
    "Unidades",
  ];
  String? _unidadSeleccionada;

  @override
  void initState() {
    super.initState();
    _obtenerMaterialesDelTaller();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  // Metodo para obtener la lista de materiales existentes del taller
  Future<void> _obtenerMaterialesDelTaller() async {
    final String urlListar = "http://10.0.2.2:3000/api/materiales/dropdown";
    try {
      final response = await http.get(Uri.parse(urlListar));
      if (response.statusCode == 200) {
        setState(() {
          _materialesExistentes = json.decode(response.body);
          _cargandoMaterialesExistentes = false;

          if (widget.materialInicial != null) {
            _esMaterialNuevo = false;
            _materialSeleccionado = _materialesExistentes.firstWhere(
              (mat) => mat['codigo'] == widget.materialInicial!['codigo'],
              orElse: () => null,
            );
            // Rellenamos los campos automáticamente con los datos de la alerta
            if (_materialSeleccionado != null) {
              _categoriaSeleccionada = _materialSeleccionado?['categoria'];
              _unidadSeleccionada = _materialSeleccionado?['medida'];
              _proveedorController.text =
                  _materialSeleccionado?['proveedor'] ?? '';
            }
          }
        });
      } else {
        setState(() => _cargandoMaterialesExistentes = false);
      }
    } catch (e) {
      setState(() => _cargandoMaterialesExistentes = false);
      debugPrint("Error cargando materiales: $e");
    }
  }

  // Metodo para guardar el material en la base de datos
  Future<void> _guardarMaterialEnBaseDeDatos() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _estaCargando = true);
    final String urlInsertar = "http://10.0.2.2:3000/api/materiales";

    // Definimos el nombre según el modo elegido
    final String nombreInsumo = _esMaterialNuevo
        ? _nombreController.text.trim()
        : (_materialSeleccionado?["MaterialNombre"] ??
              _materialSeleccionado?["nombre"] ??
              "");

    try {
      final response = await http.post(
        Uri.parse(urlInsertar),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "insumo": nombreInsumo,
          "categoria": _categoriaSeleccionada,
          "cantidad": double.tryParse(_cantidadController.text) ?? 0.0,
          "medida": _unidadSeleccionada,
          "proveedor": _proveedorController.text.trim().isEmpty
              ? null
              : _proveedorController.text.trim(),
          "usuarioID": "USR00001", // Tu usuario por defecto
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respuestaJson = jsonDecode(response.body);
        final String mensajeServidor =
            respuestaJson["mensaje"] ?? "Operación exitosa";

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensajeServidor),
              backgroundColor: const Color(0xFF2E7D32),
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
            content: Text("Error al procesar: $e"),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
        title: const Text(
          "Ingreso de Materiales",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: _cargandoMaterialesExistentes
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 30),
                    children: [
                      const SizedBox(height: 8),

                      // TARJETA DE CONTROL: ALTERNAR NUEVO O EXISTENTE
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _esMaterialNuevo
                                      ? Icons.add_box_rounded
                                      : Icons.loop_rounded,
                                  color: _esMaterialNuevo
                                      ? const Color(0xFF2E7D32)
                                      : AppColors.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _esMaterialNuevo
                                          ? "Insumo Nuevo"
                                          : "Abastecer Existente",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      _esMaterialNuevo
                                          ? "Creará un registro nuevo"
                                          : "Incrementará el stock actual",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: _esMaterialNuevo,
                              activeColor: const Color(0xFF2E7D32),
                              onChanged: (val) {
                                setState(() {
                                  _esMaterialNuevo = val;
                                  // Limpiar campos
                                  _materialSeleccionado = null;
                                  _nombreController.clear();
                                  _categoriaSeleccionada = null;
                                  _unidadSeleccionada = null;
                                  _proveedorController.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      ),

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
                      //Metodo de selección de material (Nuevo/Existente)
                      if (!_esMaterialNuevo) ...[
                        DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: const InputDecoration(
                            labelText: "Seleccione el Material del Taller",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          value: _materialSeleccionado,
                          items: _materialesExistentes.map((dynamic mat) {
                            final String nombre =
                                mat["MaterialNombre"] ??
                                mat["nombre"] ??
                                "Sin nombre";

                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: mat as Map<String, dynamic>,
                              child: Text(
                                nombre,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _materialSeleccionado = value;
                              _categoriaSeleccionada =
                                  value?["MaterialCategoria"] ??
                                  value?["categoria"];
                              _unidadSeleccionada =
                                  value?["MaterialMedida"] ?? value?["medida"];
                              _proveedorController.text =
                                  value?["MaterialProveedor"] ??
                                  value?["proveedor"] ??
                                  "";
                            });
                          },
                          validator: (value) => value == null
                              ? "Por favor elija un material"
                              : null,
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: "Nombre del Insumo Nuevo",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            prefixIcon: Icon(Icons.create_rounded),
                            hintText: "Ej. Cuero Charol Guinda 1.4mm",
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? "Ingresa el nombre del material"
                              : null,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // DROPDOWN DE CATEGORÍA
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Categoría o Familia",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        value: _categoriaSeleccionada,
                        items: _categorias.map((String cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: _esMaterialNuevo
                            ? (value) {
                                setState(() => _categoriaSeleccionada = value);
                              }
                            : null,
                        validator: (value) =>
                            value == null ? "Selecciona una categoría" : null,
                      ),

                      const SizedBox(height: 16),

                      // CANTIDAD Y MEDIDA
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cantidadController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: "Cantidad",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                prefixIcon: Icon(Icons.add_box_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Obligatorio";
                                }
                                final num? parsed = num.tryParse(value);
                                if (parsed == null) return "Inválido";
                                if (parsed <= 0) return "> 0";
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Unidad Medida",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              value: _unidadSeleccionada,
                              items: _unidades.map((String uni) {
                                return DropdownMenuItem<String>(
                                  value: uni,
                                  child: Text(uni),
                                );
                              }).toList(),
                              onChanged: _esMaterialNuevo
                                  ? (value) {
                                      setState(
                                        () => _unidadSeleccionada = value,
                                      );
                                    }
                                  : null, // Bloqueado si es existente
                              validator: (value) =>
                                  value == null ? "Selecciona medida" : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // PROVEEDOR
                      TextFormField(
                        controller: _proveedorController,
                        decoration: const InputDecoration(
                          labelText: "Proveedor / Fabricante",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // BOTÓN
                      _estaCargando
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: _guardarMaterialEnBaseDeDatos,
                              icon: Icon(
                                _esMaterialNuevo
                                    ? Icons.add_circle
                                    : Icons.assignment_turned_in_rounded,
                              ),
                              label: Text(
                                _esMaterialNuevo
                                    ? "Crear e Ingresar Stock"
                                    : "Confirmar Abastecimiento",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _esMaterialNuevo
                                    ? const Color(0xFF2E7D32)
                                    : AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
