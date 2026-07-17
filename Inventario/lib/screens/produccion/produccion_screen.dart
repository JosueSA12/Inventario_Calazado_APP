import 'package:flutter/material.dart';
import 'package:inventario/core/utils/formatters.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/theme/app_colors.dart';
import 'package:inventario/core/providers/produccion_provider.dart';
import 'package:inventario/core/services/notification_service.dart';

class ProduccionScreen extends StatefulWidget {
  final String? usuarioID;
  final Map<String, dynamic>? calzadoInicial;

  const ProduccionScreen({super.key, this.usuarioID, this.calzadoInicial});

  @override
  State<ProduccionScreen> createState() => _ProduccionScreenState();
}

class _ProduccionScreenState extends State<ProduccionScreen> {
  final TextEditingController _cantidadController = TextEditingController();

  String _modeloSeleccionado = '';
  String _tallaSeleccionada = '';
  String _colorSeleccionado = '';
  String _calzadoCodigo = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProduccionProvider>(context, listen: false);
      provider.limpiarValidacion();
    });
    _cargarCalzadoInicial();
  }

  @override
  void didUpdateWidget(ProduccionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si el calzado cambió, limpiar la validación
    if (widget.calzadoInicial != oldWidget.calzadoInicial) {
      final provider = Provider.of<ProduccionProvider>(context, listen: false);
      provider.limpiarValidacion();
      _cantidadController.clear();
      _cargarCalzadoInicial();
    }
  }

  @override
  void dispose() {
    final provider = Provider.of<ProduccionProvider>(context, listen: false);
    provider.limpiarValidacion();
    _cantidadController.dispose();
    super.dispose();
  }

  void _cargarCalzadoInicial() {
    if (widget.calzadoInicial != null) {
      setState(() {
        _calzadoCodigo = widget.calzadoInicial!['codigo']?.toString() ?? '';
        _modeloSeleccionado = widget.calzadoInicial!['modelo'] ?? '';
        _tallaSeleccionada = widget.calzadoInicial!['talla']?.toString() ?? '';
        _colorSeleccionado = widget.calzadoInicial!['color'] ?? '';
      });
    }
  }

  // ==================== OBTENER RUTA DE IMAGEN ====================
  String obtenerRutaImagen(String modelo, String color) {
    if (modelo.isEmpty || color.isEmpty) {
      return "assets/imagenes/placeholder.png";
    }

    String quitarAcentos(String texto) {
      return texto
          .toLowerCase()
          .trim()
          .replaceAll("á", "a")
          .replaceAll("é", "e")
          .replaceAll("í", "i")
          .replaceAll("ó", "o")
          .replaceAll("ú", "u")
          .replaceAll("ñ", "n")
          .replaceAll(RegExp(r"[^a-z0-9\s]"), "")
          .replaceAll(" ", "_");
    }

    String mod = quitarAcentos(modelo);
    String col = quitarAcentos(color);

    return "assets/imagenes/${mod}_$col.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ProduccionProvider>(
        builder: (context, provider, child) {
          if (provider.cargando) return _buildLoadingState();
          if (provider.error.isNotEmpty) return _buildErrorState(provider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalzadoHeader(),
                const SizedBox(height: 24),

                _buildSectionTitle('Cantidad a Producir'),
                const SizedBox(height: 12),
                _buildCantidadInput(provider),
                const SizedBox(height: 32),

                if (provider.materialesValidacion.isNotEmpty) ...[
                  _buildResumenMateriales(provider),
                  const SizedBox(height: 32),
                  _buildBotonProducir(provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== APP BAR ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.shade700.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.factory_rounded,
              color: Colors.purple,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Producción',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textDark),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () {
            final provider = Provider.of<ProduccionProvider>(
              context,
              listen: false,
            );
            provider.limpiarValidacion();
            _cantidadController.clear();
          },
        ),
      ],
    );
  }

  // ==================== CABECERA CON IMAGEN ====================
  Widget _buildCalzadoHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Imagen
            Hero(
              tag: 'shoe_image_$_modeloSeleccionado',
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    obtenerRutaImagen(_modeloSeleccionado, _colorSeleccionado),
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        size: 38,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _modeloSeleccionado,
                    style: const TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Chips en blanco
                  Row(
                    children: [
                      _buildChip(
                        'Talla $_tallaSeleccionada',
                        Icons.straighten_rounded,
                      ),
                      const SizedBox(width: 10),
                      _buildChip(_colorSeleccionado, Icons.color_lens_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 247, 247),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGETS AUXILIARES ====================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      ),
    );
  }

  //==================== ESTADOS DE CARGA ==================
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.purple, strokeWidth: 3.5),
          SizedBox(height: 20),
          Text(
            'Cargando datos...',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProduccionProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              provider.error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.limpiarValidacion();
                _cantidadController.clear();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CANTIDAD ====================

  Widget _buildCantidadInput(ProduccionProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Numero de pares',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.pin_rounded),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            onChanged: (_) => provider.limpiarValidacion(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: provider.cargandoValidacion
                ? null
                : () => _validarStock(provider),
            icon: provider.cargandoValidacion
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              provider.cargandoValidacion ? 'Validando...' : 'Validar',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== RESUMEN DE MATERIALES ====================

  Widget _buildResumenMateriales(ProduccionProvider provider) {
    final bool tieneInsuficiente = provider.materialesValidacion.any(
      (m) => m['StockSuficiente'] == 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Resumen de Materiales'),
            const Spacer(),
            _buildStatusChip(tieneInsuficiente),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildTableHeader(),
              ...provider.materialesValidacion.map(
                (material) => _buildMaterialRow(material),
              ),
              _buildTotalRow(provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool insuficiente) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: insuficiente ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            insuficiente
                ? Icons.warning_amber_rounded
                : Icons.check_circle_rounded,
            size: 16,
            color: insuficiente ? Colors.red.shade700 : Colors.green.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            insuficiente ? 'Insuficiente' : 'Suficiente',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: insuficiente ? Colors.red.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade50,
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Material',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(
              'Necesario',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(
              'Disponible',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(
              'Estado',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(Map<String, dynamic> material) {
    final bool suficiente = material['StockSuficiente'] == 1;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        color: suficiente ? null : Colors.red.shade50,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['MaterialNombre'] ?? '',
                  style: TextStyle(
                    fontWeight: suficiente ? FontWeight.w500 : FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  material['MaterialCategoria'] ?? '',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              FormatterUtils.formatCantidadConUnidad(
                material['CantidadNecesaria'] ?? 0,
                material['MaterialMedida'] ?? '',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(
              FormatterUtils.formatCantidadConUnidad(
                material['StockActual'] ?? 0,
                material['MaterialMedida'] ?? '',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: suficiente ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: suficiente
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  suficiente ? 'OK' : 'Falta',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: suficiente
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmSummary(int cantidad, ProduccionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                obtenerRutaImagen(_modeloSeleccionado, _colorSeleccionado),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _modeloSeleccionado,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cantidad: $cantidad pares',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Materiales: ${provider.materialesValidacion.length} insumos',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(ProduccionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              'Total de materiales',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${provider.materialesValidacion.length} insumos',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTON PRODUCIR ====================

  Widget _buildBotonProducir(ProduccionProvider provider) {
    final bool puedeProducir = provider.puedeProducir;

    return Column(
      children: [
        if (!puedeProducir)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 20, color: Colors.red),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No se puede producir. Hay materiales con stock insuficiente.',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        if (!puedeProducir) const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: puedeProducir && !provider.enviando
                ? () => _confirmarProduccion(provider)
                : null,
            icon: provider.enviando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(Icons.factory_rounded, size: 24),
            label: Text(
              provider.enviando ? 'Registrando...' : 'Confirmar Producción',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: puedeProducir
                  ? Colors.purple.shade700
                  : Colors.grey.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== DIALOGOS Y LOGICA ====================

  Future<void> _validarStock(ProduccionProvider provider) async {
    if (_calzadoCodigo.isEmpty) {
      NotificationService.instance.advertencia(
        context,
        'No hay calzado seleccionado',
      );
      return;
    }

    final cantidad = int.tryParse(_cantidadController.text);
    if (cantidad == null || cantidad <= 0) {
      NotificationService.instance.advertencia(
        context,
        'Ingrese una cantidad valida',
      );
      return;
    }

    final success = await provider.validarStock(_calzadoCodigo, cantidad);
    if (!success && mounted) {
      NotificationService.instance.error(
        context,
        provider.error.isNotEmpty ? provider.error : 'Error al validar stock',
      );
    }
  }

  void _confirmarProduccion(ProduccionProvider provider) {
    final cantidad = int.parse(_cantidadController.text);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.factory_rounded, color: Colors.purple),
            SizedBox(width: 10),
            Text('Confirmar Producción'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Esta seguro de realizar esta produccion?'),
            const SizedBox(height: 16),
            _buildConfirmSummary(cantidad, provider),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _ejecutarProduccion(provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Producir'),
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarProduccion(ProduccionProvider provider) async {
    final cantidad = int.parse(_cantidadController.text);

    final result = await provider.registrarProduccion(
      _calzadoCodigo,
      cantidad,
      widget.usuarioID ?? 'USR00001',
    );

    if (!mounted) return;

    if (result['success']) {
      NotificationService.instance.exito(
        context,
        result['mensaje'] ?? 'Produccion registrada correctamente',
      );
      _resetForm(provider);
      Navigator.pop(context, true);
    } else {
      NotificationService.instance.error(
        context,
        result['mensaje'] ?? 'Error al registrar produccion',
      );
    }
  }

  void _resetForm(ProduccionProvider provider) {
    provider.limpiarValidacion();
    _cantidadController.clear();
  }
}
