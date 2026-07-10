import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

import "package:inventario/core/widgets/calzado_card.dart";

class CalzadosView extends StatefulWidget {
  const CalzadosView({super.key});

  @override
  State<CalzadosView> createState() => _CalzadosViewState();
}

class _CalzadosViewState extends State<CalzadosView> {
  final String urlCalzados = "http://192.168.100.122:3000/api/calzados";
  late Future<List<dynamic>> _calzadosFuture;

  final Color accentColor = const Color(0xFF8B5E3C);

  // Filtros
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";
  String _sortBy = "precio_asc";
  String? _filtroModelo;
  String? _filtroTalla;

  @override
  void initState() {
    super.initState();
    _calzadosFuture = obtenerCalzados();
  }

  Future<List<dynamic>> obtenerCalzados() async {
    try {
      final response = await http.get(Uri.parse(urlCalzados));
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception("Error en el servidor");
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  // Función para aplicar filtros y ordenamiento
  List<dynamic> _aplicarFiltros(List<dynamic> lista) {
    List<dynamic> resultado = List.from(lista);

    if (_searchTerm.isNotEmpty) {
      final busqueda = _searchTerm.toLowerCase();
      resultado = resultado.where((item) {
        final modelo = (item["modelo"] ?? "").toString().toLowerCase();
        final marca = (item["marca"] ?? "").toString().toLowerCase();
        return modelo.contains(busqueda) || marca.contains(busqueda);
      }).toList();
    }

    if (_filtroModelo != null) {
      resultado = resultado
          .where((item) => item["modelo"] == _filtroModelo)
          .toList();
    }

    if (_filtroTalla != null) {
      resultado = resultado
          .where((item) => (item["talla"] ?? "").toString() == _filtroTalla)
          .toList();
    }

    resultado.sort((a, b) {
      if (_sortBy == "precio_asc") {
        return (a["precio"] ?? 0).compareTo(b["precio"] ?? 0);
      } else if (_sortBy == "precio_desc") {
        return (b["precio"] ?? 0).compareTo(a["precio"] ?? 0);
      } else {
        return (a["modelo"] ?? "").compareTo(b["modelo"] ?? "");
      }
    });

    return resultado;
  }

  void _mostrarFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filtros",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const Text(
                "Modelo",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              FutureBuilder<List<dynamic>>(
                future: _calzadosFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final modelos = snapshot.data!
                      .map((e) => e["modelo"]?.toString())
                      .whereType<String>()
                      .toSet()
                      .toList();

                  return DropdownButton<String>(
                    value: _filtroModelo,
                    isExpanded: true,
                    hint: const Text("Todos los modelos"),
                    items: modelos
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _filtroModelo = val);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              const Text(
                "Talla",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              FutureBuilder<List<dynamic>>(
                future: _calzadosFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final tallas = snapshot.data!
                      .map((e) => e["talla"]?.toString())
                      .whereType<String>()
                      .toSet()
                      .toList();

                  return DropdownButton<String>(
                    value: _filtroTalla,
                    isExpanded: true,
                    hint: const Text("Todas las tallas"),
                    items: tallas
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _filtroTalla = val);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              const Text(
                "Ordenar por",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: "precio_asc",
                    child: Text("Precio: Menor a Mayor"),
                  ),
                  DropdownMenuItem(
                    value: "precio_desc",
                    child: Text("Precio: Mayor a Menor"),
                  ),
                  DropdownMenuItem(value: "nombre", child: Text("Nombre A-Z")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _sortBy = val);
                    Navigator.pop(context);
                  }
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filtroModelo = null;
                      _filtroTalla = null;
                      _sortBy = "precio_asc";
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Limpiar Filtros"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: accentColor,
                    size: 34,
                  ),
                  const SizedBox(width: 16),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Calzados ",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A3423),
                          ),
                        ),
                        TextSpan(
                          text: "en Venta",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w300,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Buscador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchTerm = value),
                  decoration: InputDecoration(
                    hintText: "Buscar por modelo",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botón de Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () => _mostrarFiltros(context),
                icon: const Icon(Icons.tune, size: 22),
                label: const Text("Filtros", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 2,
                  shadowColor: Colors.black26,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Grid
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _calzadosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text("Error al cargar"));
                  }

                  final listaFiltrada = _aplicarFiltros(snapshot.data!);

                  if (listaFiltrada.isEmpty) {
                    return const Center(
                      child: Text("No se encontraron resultados"),
                    );
                  }

                  Map<String, List<Map<String, dynamic>>> agrupados = {};
                  for (var item in listaFiltrada) {
                    final map = Map<String, dynamic>.from(item);
                    final modelo = map["modelo"]?.toString() ?? "Sin modelo";
                    agrupados.putIfAbsent(modelo, () => []).add(map);
                  }

                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.50,
                          ),
                      itemCount: agrupados.length,
                      itemBuilder: (context, index) {
                        final modelo = agrupados.keys.elementAt(index);
                        return TarjetaCalzado(variantes: agrupados[modelo]!);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
