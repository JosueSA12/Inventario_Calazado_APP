import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/configuracion_provider.dart';
import 'package:inventario/core/theme/app_colors.dart';
import 'package:inventario/screens/configuracion/widgets/perfil_card.dart';
import 'package:inventario/screens/configuracion/widgets/preferencias_card.dart';
import 'package:inventario/screens/configuracion/widgets/notificaciones_card.dart';
import 'package:inventario/screens/configuracion/widgets/acerca_de_card.dart';
import 'package:inventario/screens/configuracion/widgets/cerrar_sesion_card.dart';
import 'package:inventario/screens/configuracion/widgets/configuracion_footer.dart';
import 'package:inventario/screens/navegacion_page.dart';

class ConfiguracionScreen extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  const ConfiguracionScreen({super.key, this.usuario});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  void _irAtras() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AppNavigation(usuario: widget.usuario),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;
    final nombre = usuario?['UsuarioNombre'] ?? usuario?['nombre'] ?? 'Usuario';
    final correo =
        usuario?['UsuarioCorreo'] ?? usuario?['correo'] ?? 'usuario@taller.com';
    final rol =
        (usuario?['TipoUsuarioCodigo'] ?? usuario?['tipo'] ?? 'EMP01') ==
            'ADM01'
        ? 'Administrador'
        : 'Artesano';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Configuración'),
          backgroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _irAtras,
            tooltip: 'Volver',
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              PerfilCard(nombre: nombre, correo: correo, rol: rol),
              const SizedBox(height: 16),
              const PreferenciasCard(),
              const SizedBox(height: 16),
              const NotificacionesCard(),
              const SizedBox(height: 16),
              const AcercaDeCard(),
              const SizedBox(height: 16),
              const CerrarSesionCard(),
              const SizedBox(height: 16),
              const ConfiguracionFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
