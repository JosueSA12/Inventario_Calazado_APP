import "package:flutter/material.dart";
import "dart:convert";
import "package:http/http.dart" as http;

class FormularioProduccionCalzado extends StatefulWidget {
  const FormularioProduccionCalzado({super.key});

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

  final String _baseUrl = "http://10.0.2.2:3000/api";

  // Lógica de Catálogo e Insumos
  bool _cargandoDatos = true;
  List<dynamic> _catalogoCalzadosCompleto = [];
  List<dynamic> _listaMateriales = [];

  List<String> _modelosDisponibles = [];
  List<int> _tallasDisponibles = [];
  List<String> _coloresDisponibles = [];

  // Selecciones del Usuario
  String? _modeloSeleccionado;
  int? _tallaSeleccionada;
  String? _colorSeleccionado;
  String? _calzadoCodigoFinal;

  // Selección del Usuario (Material)
  String? _materialSeleccionado;

  // Receta Detalle en Memoria Local
  final List<Map<String, dynamic>> _recetaMateriales = [];
  bool _enviandoProduccion = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _cantidadParesController.dispose();
    _cantidadPorParController.dispose();
    super.dispose();
  }

  // Carga paralela de ambos endpoints
  Future<void> _cargarDatosIniciales() async {
    try {
      final respuestas = await Future.wait([
        http.get(Uri.parse("$_baseUrl/calzado/lista-dropdown")),
        http.get(Uri.parse("$_baseUrl/materiales/dropdown")),
      ]);

      if (respuestas[0].statusCode == 200 && respuestas[1].statusCode == 200) {
        final dynamic decodedCalzados = json.decode(respuestas[0].body);
        if (decodedCalzados is List) {
          _catalogoCalzadosCompleto = decodedCalzados;
        } else if (decodedCalzados is Map &&
            decodedCalzados.containsKey("data")) {
          _catalogoCalzadosCompleto = decodedCalzados["data"] ?? [];
        }

        // Obtener modelos
        _modelosDisponibles = _catalogoCalzadosCompleto
            .map((item) => item["modelo"].toString().trim())
            .toSet()
            .toList();

        // Parsear Materiales
        _listaMateriales = json.decode(respuestas[1].body);

        setState(() => _cargandoDatos = false);
      } else {
        _mostrarErrorInicial(
          "Error al conectar con los servicios del servidor.",
        );
      }
    } catch (e) {
      _mostrarErrorInicial("Error de red al inicializar formulario: $e");
    }
  }

  void _mostrarErrorInicial(String msg) {
    setState(() => _cargandoDatos = false);
    _mostrarSnackBar(msg, Colors.red);
  }

  // Al cambiar el Modelo, filtramos las tallas
  void _onModeloCambiado(String? nuevoModelo) {
    if (nuevoModelo == null) return;
    setState(() {
      _modeloSeleccionado = nuevoModelo;
      _tallaSeleccionada = null;
      _colorSeleccionado = null;
      _calzadoCodigoFinal = null;
      _tallasDisponibles = [];
      _coloresDisponibles = [];

      // Filtrar tallas
      _tallasDisponibles = _catalogoCalzadosCompleto
          .where((item) => item["modelo"].toString().trim() == nuevoModelo)
          .map<int>((item) => int.parse(item["talla"].toString()))
          .toSet()
          .toList();
      _tallasDisponibles.sort();
    });
  }

  // Al cambiar la Talla, filtramos los colores
  void _onTallaCambiada(int? nuevaTalla) {
    if (nuevaTalla == null) return;
    setState(() {
      _tallaSeleccionada = nuevaTalla;
      _colorSeleccionado = null;
      _calzadoCodigoFinal = null;
      _coloresDisponibles = [];

      // Filtrar colores
      _coloresDisponibles = _catalogoCalzadosCompleto
          .where(
            (item) =>
                item["modelo"].toString().trim() == _modeloSeleccionado &&
                int.parse(item["talla"].toString()) == nuevaTalla,
          )
          .map((item) => item["color"].toString().trim())
          .toSet()
          .toList();
    });
  }

  // Al cambiar el Color, encontramos el código
  void _onColorCambiado(String? nuevoColor) {
    if (nuevoColor == null) return;
    setState(() {
      _colorSeleccionado = nuevoColor;

      final calzadoExacto = _catalogoCalzadosCompleto.firstWhere(
        (item) =>
            item["modelo"].toString().trim() == _modeloSeleccionado &&
            int.parse(item["talla"].toString()) == _tallaSeleccionada &&
            item["color"].toString().trim() == nuevoColor,
      );

      _calzadoCodigoFinal = calzadoExacto["codigo"].toString().trim();
    });
  }

  void _agregarMaterialALaReceta() {
    if (_materialSeleccionado == null) {
      _mostrarSnackBar("Seleccione un material primero.", Colors.orange);
      return;
    }

    final double? cantPorPar = double.tryParse(_cantidadPorParController.text);
    if (cantPorPar == null || cantPorPar <= 0) {
      _mostrarSnackBar("Ingrese una cantidad válida mayor a 0.", Colors.orange);
      return;
    }

    if (_recetaMateriales.any((m) => m["codigo"] == _materialSeleccionado)) {
      _mostrarSnackBar("Este material ya está en la receta.", Colors.orange);
      return;
    }

    final materialInfo = _listaMateriales.firstWhere(
      (m) => m["codigo"].toString().trim() == _materialSeleccionado,
    );

    setState(() {
      _recetaMateriales.add({
        "codigo": materialInfo["codigo"].toString().trim(),
        "nombre": materialInfo["nombre"].toString().trim(),
        "medida": materialInfo["medida"].toString().trim(),
        "cantidadPorPar": cantPorPar,
      });
      _cantidadPorParController.clear();
      _materialSeleccionado = null;
    });
  }

  Future<void> _enviarOrdenProduccion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_calzadoCodigoFinal == null) {
      _mostrarSnackBar(
        "Defina completamente el modelo, talla y color.",
        Colors.red,
      );
      return;
    }
    if (_recetaMateriales.isEmpty) {
      _mostrarSnackBar("Añada al menos un insumo a la receta.", Colors.red);
      return;
    }

    setState(() => _enviandoProduccion = true);

    try {
      final Map<String, dynamic> bodyRequest = {
        "calzadoCodigo": _calzadoCodigoFinal,
        "cantidadPares": int.parse(_cantidadParesController.text),
        "usuarioID": "USR00001",
        "materiales": _recetaMateriales
            .map(
              (m) => {
                "codigo": m["codigo"],
                "cantidadPorPar": m["cantidadPorPar"],
              },
            )
            .toList(),
      };

      final response = await http.post(
        Uri.parse("$_baseUrl/produccion/registrar"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(bodyRequest),
      );

      final dynamic dataResponse = json.decode(response.body);

      if (response.statusCode == 200 && dataResponse["estatus"] == "success") {
        _mostrarSnackBar(dataResponse["mensaje"], Colors.green);
        if (mounted) Navigator.pop(context);
      } else {
        _mostrarSnackBar(
          dataResponse["mensaje"] ?? "Error al procesar la orden.",
          Colors.red,
        );
      }
    } catch (e) {
      _mostrarSnackBar("Error de conexión: $e", Colors.red);
    } finally {
      setState(() => _enviandoProduccion = false);
    }
  }

  void _mostrarSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Orden de Producción"),
        backgroundColor: Colors.brown.shade100,
      ),
      body: _cargandoDatos
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      "1. Selección del Calzado",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 12),

                    //Seleccionar Modelo
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "1. Seleccione el Modelo",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.style),
                      ),
                      initialValue: _modeloSeleccionado,
                      items: _modelosDisponibles.map((String modelo) {
                        return DropdownMenuItem<String>(
                          value: modelo,
                          child: Text(modelo), // Solo muestra el nombre limpio
                        );
                      }).toList(),
                      onChanged: _onModeloCambiado,
                    ),
                    const SizedBox(height: 12),

                    // Seleccionar Talla
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "2. Seleccione la Talla",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      initialValue: _tallaSeleccionada,
                      items: _tallasDisponibles.map((int talla) {
                        return DropdownMenuItem<int>(
                          value: talla,
                          child: Text("Talla $talla"),
                        );
                      }).toList(),
                      onChanged: _modeloSeleccionado == null
                          ? null
                          : _onTallaCambiada,
                    ),
                    const SizedBox(height: 12),

                    // PASO C: Seleccionar Color
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "3. Seleccione el Color",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.color_lens),
                      ),
                      initialValue: _colorSeleccionado,
                      items: _coloresDisponibles.map((String color) {
                        return DropdownMenuItem<String>(
                          value: color,
                          child: Text(color),
                        );
                      }).toList(),
                      onChanged: _tallaSeleccionada == null
                          ? null
                          : _onColorCambiado,
                    ),
                    const SizedBox(height: 16),

                    // Input: Cantidad de pares a fabricar
                    TextFormField(
                      controller: _cantidadParesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Cantidad de Pares a Producir",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin),
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

                    const Text(
                      "2. Receta de Insumos",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card de Insumos
                    Card(
                      color: Colors.brown.shade50,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: "Seleccionar Material",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              initialValue: _materialSeleccionado,
                              items: _listaMateriales.map((dynamic item) {
                                return DropdownMenuItem<String>(
                                  value: item["codigo"].toString().trim(),
                                  child: Text(
                                    item["nombre"].toString().trim(),
                                  ), // SOLO NOMBRES LIMPIOS
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _materialSeleccionado = value),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _cantidadPorParController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: "Cantidad por Par",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.handyman),
                                      hintText: "Ej: 0.50",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton.icon(
                                    onPressed: _agregarMaterialALaReceta,
                                    icon: const Icon(Icons.add),
                                    label: const Text("Añadir"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Listado dinámico
                    _recetaMateriales.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Text(
                                "No hay materiales en la orden.",
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
                              return ListTile(
                                dense: true,
                                title: Text(
                                  item["nombre"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Gasto: ${item["cantidadPorPar"]} ${item["medida"]} por par",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => setState(
                                    () => _recetaMateriales.removeAt(index),
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 32),

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
                            : "Confirmar Lote de Producción",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
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
