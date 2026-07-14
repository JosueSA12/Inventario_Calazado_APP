class AlertaMaterial {
  final String codigo;
  final String insumo;
  final String categoria;
  final double cantidad;
  final String medida;
  final String proveedor;

  const AlertaMaterial({
    required this.codigo,
    required this.insumo,
    required this.categoria,
    required this.cantidad,
    required this.medida,
    required this.proveedor,
  });

  factory AlertaMaterial.fromJson(Map<String, dynamic> json) {
    return AlertaMaterial(
      codigo: json["codigo"]?.toString() ?? "",
      insumo: json["insumo"]?.toString() ?? "Sin nombre",
      categoria: json["categoria"]?.toString() ?? "General",
      cantidad: (json["cantidad"] as num?)?.toDouble() ?? 0.0,
      medida: json["medida"]?.toString() ?? "",
      proveedor: json["proveedor"]?.toString() ?? "Sin Proveedor",
    );
  }
}
