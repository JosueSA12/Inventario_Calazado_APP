import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:inventario/core/theme/app_colors.dart';

class FormularioRegistrarVenta extends StatefulWidget {
  const FormularioRegistrarVenta({super.key});

  @override
  State<FormularioRegistrarVenta> createState() =>
      _FormularioRegistrarVentaState();
}

class _FormularioRegistrarVentaState extends State<FormularioRegistrarVenta> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadController = TextEditingController();

  bool _estaCargando = false;
  bool _cargandoCatalogo = true;

  // Catálogo
  List<dynamic> _catalogoCompleto = [];

  // Listas filtradas
  List<String> _modelosDisponibles = [];
  List<int> _tallasDisponibles = [];
  List<String> _coloresDisponibles = [];

  // Selecciones del usuario
  String? _modeloSeleccionado;
  int? _tallaSeleccionada;
  String? _colorSeleccionado;

  // Guardará el calzado
  Map<String, dynamic>? _calzadoFinal;

  // Carrito interno con precios
  final List<Map<String, dynamic>> _carrito = [];

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  // Cargar datos iniciales
  Future<void> _cargarCatalogo() async {
    final String urlApi = 'http://10.0.2.2:3000/api/calzado/lista-dropdown';
    try {
      final response = await http.get(Uri.parse(urlApi));
      if (response.statusCode == 200) {
        final respuestaJson = jsonDecode(response.body);
        _catalogoCompleto = respuestaJson['data'];

        // Extraer modelos únicos y ordenarlos
        _modelosDisponibles =
            _catalogoCompleto
                .map((item) => item['modelo'].toString())
                .toSet()
                .toList()
              ..sort();

        setState(() => _cargandoCatalogo = false);
      } else {
        throw Exception();
      }
    } catch (e) {
      setState(() => _cargandoCatalogo = false);
      _mostrarSnackBar(
        'Error al conectar con el catálogo.',
        AppColors.kpiAlertas,
      );
    }
  }

  // Filtro
  void _onModeloChanged(String? nuevoModelo) {
    setState(() {
      _modeloSeleccionado = nuevoModelo;
      _tallaSeleccionada = null; // Reset dependientes
      _colorSeleccionado = null;
      _calzadoFinal = null;
      _coloresDisponibles = [];

      if (nuevoModelo != null) {
        _tallasDisponibles =
            _catalogoCompleto
                .where((item) => item['modelo'] == nuevoModelo)
                .map((item) => int.parse(item['talla'].toString()))
                .toSet()
                .toList()
              ..sort();
      }
    });
  }

  // Filtro
  void _onTallaChanged(int? nuevaTalla) {
    setState(() {
      _tallaSeleccionada = nuevaTalla;
      _colorSeleccionado = null; // Reset dependientes
      _calzadoFinal = null;

      if (nuevaTalla != null) {
        _coloresDisponibles =
            _catalogoCompleto
                .where(
                  (item) =>
                      item['modelo'] == _modeloSeleccionado &&
                      item['talla'] == nuevaTalla,
                )
                .map((item) => item['color'].toString())
                .toSet()
                .toList()
              ..sort();
      }
    });
  }

  // Filtro
  void _onColorChanged(String? nuevoColor) {
    setState(() {
      _colorSeleccionado = nuevoColor;
      if (nuevoColor != null) {
        _calzadoFinal = _catalogoCompleto.firstWhere(
          (item) =>
              item['modelo'] == _modeloSeleccionado &&
              item['talla'] == _tallaSeleccionada &&
              item['color'] == nuevoColor,
        );
      } else {
        _calzadoFinal = null;
      }
    });
  }

  // Agregar al carrito calculando subtotal
  void _agregarAlCarrito() {
    if (_calzadoFinal == null) {
      _mostrarSnackBar(
        'Completa todos los filtros del calzado.',
        Colors.orange,
      );
      return;
    }

    final int? cantidad = int.tryParse(_cantidadController.text);
    if (cantidad == null || cantidad <= 0) {
      _mostrarSnackBar('Ingresa una cantidad válida.', Colors.orange);
      return;
    }

    final double precio = double.parse(_calzadoFinal!['precio'].toString());
    final int stockDisponible = _calzadoFinal!['stock'];

    if (cantidad > stockDisponible) {
      _mostrarSnackBar(
        'Stock insuficiente en tienda. Disponible: $stockDisponible pares.',
        AppColors.kpiAlertas,
      );
      return;
    }

    setState(() {
      _carrito.add({
        "calzadoCodigo": _calzadoFinal!['codigo'],
        "descripcion":
            "$_modeloSeleccionado (Talla $_tallaSeleccionada - $_colorSeleccionado)",
        "cantidad": cantidad,
        "precio": precio,
        "subtotal": precio * cantidad,
      });

      // Limpiar formulario de selección
      _cantidadController.clear();
      _modeloSeleccionado = null;
      _tallaSeleccionada = null;
      _colorSeleccionado = null;
      _calzadoFinal = null;
      _tallasDisponibles = [];
      _coloresDisponibles = [];
    });
  }

  // Calcular el Monto Total de la Venta
  double get _montoTotalVenta {
    return _carrito.fold(0.0, (suma, item) => suma + item['subtotal']);
  }

  Future<void> _enviarVenta() async {
    setState(() => _estaCargando = true);
    final String urlApi = 'http://10.0.2.2:3000/api/calzado/venta-multiple';

    try {
      final response = await http.post(
        Uri.parse(urlApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuarioID": "USR00001",
          "productos": _carrito
              .map(
                (item) => {
                  "calzadoCodigo": item["calzadoCodigo"],
                  "cantidad": item["cantidad"],
                },
              )
              .toList(),
        }),
      );

      final respuestaJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          _mostrarSnackBar('Venta procesada con éxito.', Colors.green.shade700);
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(respuestaJson['mensaje']);
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackBar(
          e.toString().replaceAll('Exception:', '').trim(),
          AppColors.kpiAlertas,
        );
      }
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
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
        title: const Text(
          'Registrar Nueva Venta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD DE FILTROS SECUENCIALES
            Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _cargandoCatalogo
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        key: _formKey,
                        children: [
                          // Dropdown: MODELO
                          DropdownButtonFormField<String>(
                            initialValue: _modeloSeleccionado,
                            hint: const Text('1. Seleccionar Modelo'),
                            items: _modelosDisponibles
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ),
                                )
                                .toList(),
                            onChanged: _onModeloChanged,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.style),
                            ),
                          ),
                          const SizedBox(height: 12),

                          //TALLA (Habilitado solo si hay modelo)
                          DropdownButtonFormField<int>(
                            initialValue: _tallaSeleccionada,
                            hint: const Text('2. Seleccionar Talla'),
                            items: _tallasDisponibles
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.toString()),
                                  ),
                                )
                                .toList(),
                            onChanged: _modeloSeleccionado == null
                                ? null
                                : _onTallaChanged,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.straighten),
                            ),
                          ),
                          const SizedBox(height: 12),

                          //  COLOR (Habilitado solo si hay talla)
                          DropdownButtonFormField<String>(
                            initialValue: _colorSeleccionado,
                            hint: const Text('3. Seleccionar Color'),
                            items: _coloresDisponibles
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: _tallaSeleccionada == null
                                ? null
                                : _onColorChanged,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.color_lens),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Muestra Precio y Stock
                          if (_calzadoFinal != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Stock: ${_calzadoFinal!['stock']} pares',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  Text(
                                    'Precio: S/.${_calzadoFinal!['precio']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Input Cantidad y Botón Añadir
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _cantidadController,
                                  keyboardType: TextInputType.number,
                                  enabled: _colorSeleccionado != null,
                                  decoration: InputDecoration(
                                    labelText: 'Cant.',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  onPressed: _colorSeleccionado == null
                                      ? null
                                      : _agregarAlCarrito,
                                  icon: const Icon(
                                    Icons.add_shopping_cart,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Añadir',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resumen del Carrito',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Monto Total
                Text(
                  'Total: S/.${_montoTotalVenta.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // LISTADO DE ITEMS EN EL CARRITO
            Expanded(
              child: _carrito.isEmpty
                  ? const Center(
                      child: Text('Ningún calzado añadido al detalle.'),
                    )
                  : ListView.builder(
                      itemCount: _carrito.length,
                      itemBuilder: (context, index) {
                        final item = _carrito[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: AppColors.surface,
                          child: ListTile(
                            title: Text(
                              item['descripcion'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '${item['cantidad']} pares x S/.${item['precio']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'S/.${item['subtotal'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      setState(() => _carrito.removeAt(index)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (_carrito.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _estaCargando ? null : _enviarVenta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01B327),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _estaCargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Confirmar Venta Total (S/.${_montoTotalVenta.toStringAsFixed(2)})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
