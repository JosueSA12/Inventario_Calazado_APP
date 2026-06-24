import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:inventario/core/theme/app_colors.dart';

// Imports
import 'package:inventario/clases/alerta_material.dart';
import 'package:inventario/core/widgets/alerta_card.dart';
import 'package:inventario/core/widgets/empty_alertas_state.dart';
import 'package:inventario/core/widgets/detalle_material_sheet.dart';

class AlertasStockView extends StatefulWidget {
  const AlertasStockView({super.key});

  @override
  State<AlertasStockView> createState() => _AlertasStockViewState();
}

class _AlertasStockViewState extends State<AlertasStockView> {
  final String urlAlertas = 'http://10.0.2.2:3000/api/materiales/alertas';
  late Future<List<AlertaMaterial>> _alertasFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _categoriaSeleccionada;
  bool _ordenAscendente = true;

  @override
  void initState() {
    super.initState();
    _alertasFuture = obtenerAlertas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refrescarAlertas() async {
    setState(() {
      _alertasFuture = obtenerAlertas();
    });
  }

  Future<List<AlertaMaterial>> obtenerAlertas() async {
    try {
      final response = await http
          .get(Uri.parse(urlAlertas))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AlertaMaterial.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar: $e');
    }
  }

  //Listar y filtrar alertas
  List<AlertaMaterial> _filtrarYOrdenar(List<AlertaMaterial> alertas) {
    List<AlertaMaterial> resultado = List.from(alertas);

    if (_searchQuery.isNotEmpty) {
      resultado = resultado.where((item) {
        return item.insumo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.proveedor.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.categoria.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_categoriaSeleccionada != null) {
      resultado = resultado
          .where((item) => item.categoria == _categoriaSeleccionada)
          .toList();
    }

    resultado.sort(
      (a, b) => _ordenAscendente
          ? a.cantidad.compareTo(b.cantidad)
          : b.cantidad.compareTo(a.cantidad),
    );

    return resultado;
  }

  //Mostrar detalle del material con bajo stock
  void _mostrarDetalleMaterial(BuildContext context, AlertaMaterial material) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DetalleBajoStockSheet(
        codigo: material.codigo,
        insumo: material.insumo,
        categoria: material.categoria,
        cantidad: material.cantidad,
        medida: material.medida,
        proveedor: material.proveedor,
        onOrdenarMas: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.kpiAlertas),
            SizedBox(width: 8),
            Text(
              'Alertas de Abastecimiento',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
            onPressed: _refrescarAlertas,
          ),
        ],
      ),
      body: FutureBuilder<List<AlertaMaterial>>(
        future: _alertasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.kpiAlertas),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.kpiAlertas,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}'.replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refrescarAlertas,
                      icon: const Icon(Icons.replay),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kpiAlertas,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final alertas = snapshot.data ?? [];
          final alertasFiltradas = _filtrarYOrdenar(alertas);

          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar insumo / material',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
              ),

              // Filtro desplegable
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      "Categoría:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _categoriaSeleccionada,
                            isExpanded: true,
                            hint: const Text("Todas las categorías"),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text("Todas las categorías"),
                              ),
                              ...alertas.map((e) => e.categoria).toSet().map((
                                cat,
                              ) {
                                return DropdownMenuItem<String?>(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                            ],
                            onChanged: (String? newValue) {
                              setState(() => _categoriaSeleccionada = newValue);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Lista
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.kpiAlertas,
                  onRefresh: _refrescarAlertas,
                  child: alertasFiltradas.isEmpty
                      ? const EmptyAlertasState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: alertasFiltradas.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return AlertaCard(
                              material: alertasFiltradas[index],
                              onTap: () => _mostrarDetalleMaterial(
                                context,
                                alertasFiltradas[index],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
