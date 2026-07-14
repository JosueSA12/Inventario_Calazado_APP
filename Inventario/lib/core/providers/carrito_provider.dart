import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CarritoProvider extends ChangeNotifier {
  final String _baseUrl = "http://192.168.100.122:3000/api";

  List<Map<String, dynamic>> _items = [];
  String? _carritoID;
  String? _usuarioID;
  BuildContext? _context;

  List<Map<String, dynamic>> get items => _items;
  String? get carritoID => _carritoID;

  double get total {
    return _items.fold(0.0, (sum, item) => sum + (item["subtotal"] as double));
  }

  int get cantidadTotal {
    return _items.fold(0, (sum, item) => sum + (item["cantidad"] as int));
  }

  bool get isEmpty => _items.isEmpty;

  // ==========================================
  // INICIALIZAR CARRITO DESDE EL SERVIDOR
  // ==========================================
  Future<void> inicializarCarrito(
    String usuarioID, {
    BuildContext? context,
  }) async {
    _usuarioID = usuarioID;
    _context = context;
    await _cargarCarrito();
  }

  // ==========================================
  // CARGAR CARRITO
  // ==========================================
  Future<void> _cargarCarrito() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/carrito/obtener?usuarioID=$_usuarioID"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["estatus"] == "success" && data["data"]["carrito"] != null) {
          _carritoID = data["data"]["carrito"]["CarritoID"].toString();
          _items = List<Map<String, dynamic>>.from(data["data"]["items"]).map((
            item,
          ) {
            return {
              "calzadoCodigo": item["CalzadoCodigo"],
              "descripcion":
                  "${item["Modelo"]} (${item["Color"]} - Talla ${item["Talla"]})",
              "cantidad": item["Cantidad"],
              "precio": double.parse(item["PrecioUnitario"].toString()),
              "subtotal": double.parse(item["Subtotal"].toString()),
              "detalleID": item["DetalleID"],
              "stockDisponible": item["StockDisponible"],
            };
          }).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error cargando carrito: $e");
    }
  }

  // ==========================================
  // AGREGAR ITEM AL CARRITO
  // ==========================================
  Future<bool> agregarItem({
    required String codigo,
    required String descripcion,
    required int cantidad,
    required double precio,
    required int stock,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/carrito/agregar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuarioID": _usuarioID,
          "calzadoCodigo": codigo,
          "cantidad": cantidad,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["estatus"] == "success") {
          await _cargarCarrito();

          if (_context != null) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('$descripcion agregado al carrito')),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error agregando al carrito: $e");
      return false;
    }
  }

  // ==========================================
  // ACTUALIZAR CANTIDAD
  // ==========================================
  Future<bool> actualizarCantidad(int index, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      return eliminarItem(index);
    }

    try {
      final detalleID = _items[index]["detalleID"];
      final response = await http.put(
        Uri.parse("$_baseUrl/carrito/actualizar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuarioID": _usuarioID,
          "detalleID": detalleID,
          "nuevaCantidad": nuevaCantidad,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["estatus"] == "success") {
          await _cargarCarrito();

          if (_context != null) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              SnackBar(
                content: const Text('Cantidad actualizada'),
                backgroundColor: Colors.blue.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error actualizando cantidad: $e");
      return false;
    }
  }

  // ==========================================
  // ELIMINAR ITEM
  // ==========================================
  Future<bool> eliminarItem(int index) async {
    try {
      final detalleID = _items[index]["detalleID"];
      final response = await http.delete(
        Uri.parse("$_baseUrl/carrito/eliminar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuarioID": _usuarioID, "detalleID": detalleID}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["estatus"] == "success") {
          await _cargarCarrito();

          if (_context != null) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              SnackBar(
                content: const Text('Producto eliminado del carrito'),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1200),
              ),
            );
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error eliminando del carrito: $e");
      return false;
    }
  }

  // ==========================================
  // LIMPIAR CARRITO
  // ==========================================
  Future<bool> limpiarCarrito() async {
    try {
      final response = await http.delete(
        Uri.parse("$_baseUrl/carrito/limpiar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuarioID": _usuarioID}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["estatus"] == "success") {
          _items.clear();
          _carritoID = null;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error limpiando carrito: $e");
      return false;
    }
  }

  // ==========================================
  // CONFIRMAR VENTA
  // ==========================================
  Future<Map<String, dynamic>> confirmarVenta() async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/carrito/confirmar-venta"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuarioID": _usuarioID}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["estatus"] == "success") {
          _items.clear();
          _carritoID = null;
          notifyListeners();
          return {"success": true, "data": data["data"]};
        }
        return {"success": false, "mensaje": data["mensaje"]};
      }
      return {"success": false, "mensaje": "Error al confirmar la venta"};
    } catch (e) {
      debugPrint("Error confirmando venta: $e");
      return {"success": false, "mensaje": e.toString()};
    }
  }

  // ==========================================
  // CONFIRMAR VENTA
  // ==========================================
  Future<Map<String, dynamic>> confirmarVentaSinLimpiar() async {
    try {
      if (_items.isEmpty) {
        return {"success": false, "mensaje": "El carrito está vacío"};
      }

      final response = await http.post(
        Uri.parse("$_baseUrl/carrito/confirmar-venta"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuarioID": _usuarioID}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["estatus"] == "success") {
          return {"success": true, "data": data["data"]};
        }
        return {"success": false, "mensaje": data["mensaje"]};
      }
      return {"success": false, "mensaje": "Error al confirmar la venta"};
    } catch (e) {
      debugPrint("Error confirmando venta sin limpiar: $e");
      return {"success": false, "mensaje": e.toString()};
    }
  }

  // ==========================================
  // LIMPIAR CARRITO DESPUÉS DE VENTA
  // ==========================================
  void limpiarCarritoDespuesDeVenta() {
    _items.clear();
    _carritoID = null;
    notifyListeners();
  }

  // ==========================================
  // MÉTODOS LOCALES (PARA UI RÁPIDA)
  // ==========================================
  void agregarItemLocal(Map<String, dynamic> item) {
    _items.add(item);
    notifyListeners();
  }

  void eliminarItemLocal(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void limpiarCarritoLocal() {
    _items.clear();
    notifyListeners();
  }
}
