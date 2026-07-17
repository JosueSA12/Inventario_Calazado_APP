import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:inventario/core/providers/notificacion_provider.dart';

class ReporteFiltros extends StatefulWidget {
  final String? tipoFiltro;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final List<String> tiposFiltro;
  final Function(String?) onTipoChanged;
  final Function(DateTime?) onFechaInicioChanged;
  final Function(DateTime?) onFechaFinChanged;
  final VoidCallback onAplicar;
  final VoidCallback onCargarPorDefecto;

  const ReporteFiltros({
    super.key,
    this.tipoFiltro,
    required this.fechaInicio,
    required this.fechaFin,
    required this.tiposFiltro,
    required this.onTipoChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onAplicar,
    required this.onCargarPorDefecto,
  });

  @override
  State<ReporteFiltros> createState() => _ReporteFiltrosState();
}

class _ReporteFiltrosState extends State<ReporteFiltros> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCargarPorDefecto();
    });
  }

  void _showSimpleDatePicker(
    BuildContext context,
    Function(DateTime) onChanged,
    DateTime? fecha,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime tempDate = fecha ?? DateTime.now();
        return AlertDialog(
          title: const Text('Seleccionar fecha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () {
                      setState(() {
                        tempDate = DateTime(
                          tempDate.year,
                          tempDate.month - 1,
                          tempDate.day,
                        );
                      });
                    },
                  ),
                  Text(
                    '${tempDate.year}/${tempDate.month.toString().padLeft(2, '0')}/${tempDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () {
                      setState(() {
                        tempDate = DateTime(
                          tempDate.year,
                          tempDate.month + 1,
                          tempDate.day,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                onChanged(tempDate);
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFechaPicker({
    required String label,
    required DateTime? fecha,
    required Function(DateTime) onChanged,
  }) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () async {
            try {
              final date = await showDatePicker(
                context: context,
                initialDate: fecha ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: const Locale('es', 'ES'),
              );
              if (date != null && context.mounted) {
                onChanged(date);
              }
            } catch (e) {
              _showSimpleDatePicker(context, onChanged, fecha);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.fechaInicio != null || widget.fechaFin != null
                    ? Colors.blue.shade700
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: widget.fechaInicio != null || widget.fechaFin != null
                      ? Colors.blue.shade700
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fecha != null
                        ? DateFormat('yyyy-MM-dd').format(fecha)
                        : label,
                    style: TextStyle(
                      color: fecha != null
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getNombreFiltro(String tipo) {
    switch (tipo) {
      case 'DIA':
        return 'Hoy';
      case 'SEMANA':
        return 'Semana';
      case 'MES':
        return 'Mes';
      case 'ANIO':
        return 'Año';
      default:
        return tipo;
    }
  }

  bool _hayFechasSeleccionadas() {
    return widget.fechaInicio != null && widget.fechaFin != null;
  }

  bool _puedeAplicar() {
    return _hayFechasSeleccionadas();
  }

  void _validarYAplicar() {
    if (!_puedeAplicar()) {
      final notificacionProvider = Provider.of<NotificacionProvider>(
        context,
        listen: false,
      );

      final notificacion = Notificacion(
        id: 'error_filtros_${DateTime.now().millisecondsSinceEpoch}', // ✅ Agregar id
        titulo: 'Error en Reportes',
        mensaje:
            'Debes seleccionar una fecha de inicio y fin para aplicar el filtro.',
        icono: Icons.warning_amber_rounded,
        color: Colors.orange,
        timestamp: DateTime.now(),
        leida: false,
      );

      notificacionProvider.agregarNotificacion(notificacion);
      return;
    }

    widget.onAplicar();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            children: widget.tiposFiltro.map((tipo) {
              final bool selected = widget.tipoFiltro == tipo;
              return FilterChip(
                label: Text(_getNombreFiltro(tipo)),
                selected: selected,
                onSelected: (selected) {
                  if (selected) {
                    widget.onTipoChanged(tipo);
                  } else {
                    widget.onTipoChanged(null);
                  }
                },
                selectedColor: Colors.blue.shade100,
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                  color: selected ? Colors.blue.shade700 : Colors.grey.shade700,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFechaPicker(
                  label: "Fecha Inicio",
                  fecha: widget.fechaInicio,
                  onChanged: widget.onFechaInicioChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFechaPicker(
                  label: "Fecha Fin",
                  fecha: widget.fechaFin,
                  onChanged: widget.onFechaFinChanged,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _validarYAplicar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _puedeAplicar()
                      ? Colors.blue.shade700
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text("Aplicar"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
