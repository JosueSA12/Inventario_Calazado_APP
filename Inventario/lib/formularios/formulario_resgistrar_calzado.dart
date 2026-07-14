import "package:flutter/material.dart";
import "dart:convert";
import "package:http/http.dart" as http;
import "package:inventario/core/theme/app_colors.dart";
import "package:inventario/core/services/notification_service.dart";

class FormularioProduccionCalzado extends StatefulWidget {
  final Map<String, dynamic>? calzadoInicial;
  final String? usuarioID;

  const FormularioProduccionCalzado({
    super.key,
    this.calzadoInicial,
    this.usuarioID,
  });

  @override
  State<FormularioProduccionCalzado> createState() =>
      _FormularioProduccionCalzadoState();
}

class _FormularioProduccionCalzadoState
    extends State<FormularioProduccionCalzado> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadParesController =
      TextEditingController();
  final TextEditingController _cantidadPorParController =
      TextEditingController();

  final String _baseUrl = "http://192.168.100.122:3000/api";

  bool _cargandoDatos = true;
  List<dynamic> _listaMateriales = [];

  // ==========================================
  // DATOS DEL CALZADO PRESELECCIONADO
  // ==========================================
  String _modelo = "";
  String _talla = "";
  String _color = "";
  String _codigo = "";

  // ==========================================
  // FILTROS PARA MATERIALES
  // ==========================================
  String? _categoriaMaterialSeleccionada;
  String? _materialSeleccionado;
  final List<String> _categoriasMateriales = [
    'Cuero',
    'Suelas',
    'Hilos',
    'Pegamentos / Tintes',
    'Herrajes / Ojales',
  ];

  final List<Map<String, dynamic>> _recetaMateriales = [];
  bool _enviandoProduccion = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
    _cargarCalzadoInicial();
  }

  void _cargarCalzadoInicial() {
    if (widget.calzadoInicial != null) {
      setState(() {
        _modelo = widget.calzadoInicial!["modelo"] ?? "";
        _talla = widget.calzadoInicial!["talla"]?.toString() ?? "";
        _color = widget.calzadoInicial!["color"] ?? "";
        _codigo = widget.calzadoInicial!["codigo"] ?? "";
      });
    }
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/materiales/dropdown"),
      );

      if (response.statusCode == 200) {
        _listaMateriales = json.decode(response.body);
        setState(() => _cargandoDatos = false);
      } else {
        _mostrarErrorInicial("Error al conectar con el servidor.");
      }
    } catch (e) {
      _mostrarErrorInicial("Error de red: $e");
    }
  }

  void _mostrarErrorInicial(String msg) {
    setState(() => _cargandoDatos = false);
    _mostrarSnackBar(msg, Colors.red);
  }

  // ==========================================
  // FILTRO DE MATERIALES POR CATEGORÍA
  // ==========================================
  List<dynamic> get _materialesFiltrados {
    if (_categoriaMaterialSeleccionada == null) {
      return _listaMateriales;
    }
    return _listaMateriales
        .where(
          (item) =>
              item["categoria"].toString().trim() ==
              _categoriaMaterialSeleccionada,
        )
        .toList();
  }

  void _onMaterialSeleccionado(String? codigo) {
    setState(() {
      _materialSeleccionado = codigo;

      if (codigo != null) {
        final materialInfo = _listaMateriales.firstWhere(
          (m) => m["codigo"].toString().trim() == codigo,
          orElse: () => null,
        );

        if (materialInfo != null) {
          final stockActual = materialInfo["stockActual"] ?? 0.0;
          if (stockActual < 5) {
            _mostrarSnackBar(
              "⚠️ El insumo '${materialInfo["nombre"]}' tiene stock bajo (${stockActual.toStringAsFixed(1)} ${materialInfo["medida"]} disponibles)",
              AppColors.kpiAlertas,
            );
          }
        }
      }
    });
  }

  void _agregarMaterialALaReceta() {
    if (_materialSeleccionado == null) {
      _mostrarSnackBar("Seleccione un material.", Colors.orange);
      return;
    }

    final double? cantPorPar = double.tryParse(_cantidadPorParController.text);
    if (cantPorPar == null || cantPorPar <= 0) {
      _mostrarSnackBar("Ingrese una cantidad válida > 0.", Colors.orange);
      return;
    }

    if (_recetaMateriales.any((m) => m["codigo"] == _materialSeleccionado)) {
      _mostrarSnackBar("Este material ya está en la receta.", Colors.orange);
      return;
    }

    final materialInfo = _listaMateriales.firstWhere(
      (m) => m["codigo"].toString().trim() == _materialSeleccionado,
    );

    // Verificar si hay suficiente stock
    final stockActual = materialInfo["stockActual"] ?? 0.0;
    final cantidadPares = int.tryParse(_cantidadParesController.text) ?? 0;
    final cantidadNecesaria = cantPorPar * cantidadPares;

    if (cantidadPares > 0 && stockActual < cantidadNecesaria) {
      _mostrarSnackBar(
        "⚠️ Stock insuficiente para '${materialInfo["nombre"]}'. Disponible: ${stockActual.toStringAsFixed(1)} ${materialInfo["medida"]}",
        AppColors.kpiAlertas,
      );
      return;
    }

    setState(() {
      _recetaMateriales.add({
        "codigo": materialInfo["codigo"].toString().trim(),
        "nombre": materialInfo["nombre"].toString().trim(),
        "medida": materialInfo["medida"].toString().trim(),
        "categoria": materialInfo["categoria"].toString().trim(),
        "cantidadPorPar": cantPorPar,
        "stockActual": stockActual,
      });
      _cantidadPorParController.clear();
      _materialSeleccionado = null;
    });
  }

  Future<void> _enviarOrdenProduccion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_codigo.isEmpty) {
      _mostrarSnackBar(
        "Error: No hay código de calzado seleccionado.",
        Colors.red,
      );
      return;
    }
    if (_recetaMateriales.isEmpty) {
      NotificationService.instance.error(
        context,
        "Añada al menos un insumo a la receta.",
      );
    }

    setState(() => _enviandoProduccion = true);

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/produccion/registrar"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "calzadoCodigo": _codigo,
          "cantidadPares": int.parse(_cantidadParesController.text),
          "usuarioID": widget.usuarioID ?? "USR00001",
          "materiales": _recetaMateriales
              .map(
                (m) => {
                  "codigo": m["codigo"],
                  "cantidadPorPar": m["cantidadPorPar"],
                },
              )
              .toList(),
        }),
      );

      final dataResponse = json.decode(response.body);

      if (response.statusCode == 200 && dataResponse["estatus"] == "success") {
        if (mounted) {
          NotificationService.instance.produccionCreada(
            context,
            dataResponse["data"]?["ordenId"] ?? 0,
            int.parse(_cantidadParesController.text),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          NotificationService.instance.error(
            context,
            dataResponse["mensaje"] ?? "Error al procesar la producción.",
          );
        }
      }
    } catch (e) {
      _mostrarSnackBar("Error de conexión: $e", Colors.red);
    } finally {
      setState(() => _enviandoProduccion = false);
    }
  }

  void _mostrarSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                color: Colors.purple.shade700.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.factory_rounded,
                color: Colors.purple,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Registrar Producción",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: _cargandoDatos
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.purple,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Cargando datos...",
                    style: TextStyle(color: AppColors.textLight, fontSize: 14),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    // ==========================================
                    // INFORMACIÓN DEL CALZADO PRESELECCIONADO
                    // ==========================================
                    const Text(
                      "Calzado a Producir",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          Text(
                            _modelo.isNotEmpty ? _modelo : "No seleccionado",
                            style: const TextStyle(
                              fontSize: 18,
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
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade700.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Talla: $_talla",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.purple.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade700.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Color: $_color",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.purple.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Código: $_codigo",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ==========================================
                    // CANTIDAD DE PARES
                    // ==========================================
                    const Text(
                      "Cantidad a Producir",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cantidadParesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Cantidad de Pares",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.pin),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Ingrese los pares";
                        }
                        final n = int.tryParse(value);
                        if (n == null || n <= 0) return "Debe ser mayor a 0";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ==========================================
                    // RECETA DE INSUMOS
                    // ==========================================
                    const Text(
                      "Receta de Insumos",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Card(
                      color: AppColors.surface,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Filtrar por categoría
                            SizedBox(
                              width: double.infinity,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: "Filtrar por Categoría",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.category),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                value: _categoriaMaterialSeleccionada,
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text("Todas las categorías"),
                                  ),
                                  ..._categoriasMateriales.map((String cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat,
                                      child: Text(cat),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _categoriaMaterialSeleccionada = value;
                                    _materialSeleccionado = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Seleccionar material
                            SizedBox(
                              width: double.infinity,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "Seleccionar Material",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.inventory_2),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                value: _materialSeleccionado,
                                items: _materialesFiltrados.map((dynamic item) {
                                  final bool esBajoStock =
                                      (item["stockActual"] ?? 0.0) < 5;
                                  return DropdownMenuItem<String>(
                                    value: item["codigo"].toString().trim(),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item["nombre"].toString().trim(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (esBajoStock)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.kpiAlertas
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              "⚠️",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.kpiAlertas,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: _onMaterialSeleccionado,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Cantidad por par
                            TextFormField(
                              controller: _cantidadPorParController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: "Cantidad por Par",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.handyman),
                                hintText: "Ej: 0.50",
                                filled: true,
                                fillColor: AppColors.background,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Botón añadir
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _agregarMaterialALaReceta,
                                icon: const Icon(Icons.add),
                                label: const Text("Añadir a Receta"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista de materiales
                    _recetaMateriales.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                "No hay materiales en la receta",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recetaMateriales.length,
                            separatorBuilder: (_, _) => const Divider(),
                            itemBuilder: (context, index) {
                              final item = _recetaMateriales[index];
                              final bool esBajoStock =
                                  (item["stockActual"] ?? 0.0) < 5;
                              return ListTile(
                                dense: true,
                                leading: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: esBajoStock
                                        ? AppColors.kpiAlertas.withOpacity(0.15)
                                        : Colors.purple.shade700.withOpacity(
                                            0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: esBajoStock
                                            ? AppColors.kpiAlertas
                                            : Colors.purple.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item["nombre"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  "Gasto: ${item["cantidadPorPar"]} ${item["medida"]} por par${esBajoStock ? " ⚠️ Stock bajo" : ""}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: esBajoStock
                                        ? AppColors.kpiAlertas
                                        : Colors.grey.shade600,
                                    fontWeight: esBajoStock
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _recetaMateriales.removeAt(index),
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 32),

                    // Botón confirmar
                    ElevatedButton.icon(
                      onPressed: _enviandoProduccion
                          ? null
                          : _enviarOrdenProduccion,
                      icon: _enviandoProduccion
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.build_circle),
                      label: Text(
                        _enviandoProduccion
                            ? "Registrando lote..."
                            : "Confirmar Producción",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade700,
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
    );
  }
}
