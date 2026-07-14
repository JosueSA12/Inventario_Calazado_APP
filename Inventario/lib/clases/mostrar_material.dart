class MaterialModel {
  final String id;
  final String codigo;
  final String insumo;
  final String categoria;
  final double cantidad;
  final String medida;
  final String proveedor;
  final bool esBajoStock;

  const MaterialModel({
    required this.id,
    required this.codigo,
    required this.insumo,
    required this.categoria,
    required this.cantidad,
    required this.medida,
    required this.proveedor,
    required this.esBajoStock,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    final cantidad = double.tryParse(json["cantidad"].toString()) ?? 0.0;
    final stockMinimo =
        double.tryParse(json["stockMinimo"]?.toString() ?? "5") ?? 5.0;

    return MaterialModel(
      id: json["id"]?.toString() ?? "",
      codigo: json["codigo"]?.toString() ?? "",
      insumo: json["insumo"]?.toString() ?? "Sin nombre",
      categoria: json["categoria"]?.toString() ?? "General",
      cantidad: cantidad,
      medida: json["medida"]?.toString() ?? "",
      proveedor: json["proveedor"]?.toString() ?? "Sin proveedor",
      esBajoStock: cantidad < stockMinimo,
    );
  }
}
