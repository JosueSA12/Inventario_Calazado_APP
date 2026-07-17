class ActividadItem {
  final int id;
  final DateTime fecha;
  final String tipo;
  final String descripcion;
  final String cantidad;
  final String movimiento;
  final String encargado;
  final int? referenciaId;
  final String? referenciaTipo;

  ActividadItem({
    required this.id,
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.cantidad,
    required this.movimiento,
    required this.encargado,
    this.referenciaId,
    this.referenciaTipo,
  });

  factory ActividadItem.fromJson(Map<String, dynamic> json) {
    final id = json['Id'] ?? 0;
    final tipo = json['Tipo'] ?? '';

    final refId = json['ReferenciaId'] ?? json['referenciaId'] ?? id;
    final refTipo = json['ReferenciaTipo'] ?? json['referenciaTipo'] ?? tipo;

    return ActividadItem(
      id: id,
      fecha: DateTime.parse(json['Fecha']),
      tipo: tipo,
      descripcion: json['Descripcion'] ?? '',
      cantidad: json['Cantidad']?.toString() ?? '0',
      movimiento: json['Movimiento']?.toString() ?? '',
      encargado: json['Encargado'] ?? '',
      referenciaId: refId is int ? refId : int.tryParse(refId.toString()),
      referenciaTipo: refTipo?.toString(),
    );
  }

  bool get tieneDetalle => referenciaId != null && referenciaTipo != null;
  bool get esVenta => tipo == 'VENTA';
  bool get esProduccion => tipo == 'PRODUCCION';
  bool get esMaterial => tipo == 'Material';
}
