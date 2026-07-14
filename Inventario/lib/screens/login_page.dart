import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:inventario/home.dart';
import 'package:inventario/core/providers/carrito_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String baseUrl = 'http://192.168.100.122:3000/api/seguridad';

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? usuarioLogueado;

    Future<String?> authUser(LoginData data) async {
      try {
        final url = Uri.parse('$baseUrl/login');
        final respuesta = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usuarioInput': data.name.trim(),
            'usuarioPassword': data.password,
          }),
        );

        final datosJson = jsonDecode(respuesta.body);
        if (respuesta.statusCode == 200 && datosJson['estatus'] == 'success') {
          usuarioLogueado = datosJson['usuario'];
          return null;
        } else {
          return datosJson['mensaje'] ?? 'Usuario o contraseña incorrectos';
        }
      } catch (e) {
        return 'No se pudo conectar con el servidor del taller.';
      }
    }

    Future<String?> recoverPassword(String name) async {
      try {
        final url = Uri.parse('$baseUrl/restablecer-password');
        final respuesta = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usuarioLogin': name.trim(),
            'nuevaPassword': '123456PasswordChanged',
          }),
        );
        final datosJson = jsonDecode(respuesta.body);
        if (respuesta.statusCode == 200 && datosJson['estatus'] == 'success') {
          return null;
        } else {
          return datosJson['mensaje'] ??
              'No se pudo restablecer la contraseña.';
        }
      } catch (e) {
        return 'Error de red al intentar conectar con el servidor.';
      }
    }

    return FlutterLogin(
      title: 'TALLER DE CALZADO',
      logo: const AssetImage('assets/imagenes/logo_taller.png'),
      onLogin: authUser,
      onSignup: (data) => Future.value(null),
      onRecoverPassword: recoverPassword,
      userValidator: (value) {
        if (value == null || value.isEmpty || value.length < 3) {
          return 'Ingrese un usuario o correo válido';
        }
        return null;
      },
      onSubmitAnimationCompleted: () {
        final usuario = usuarioLogueado;
        final usuarioID = usuario?['id'] ?? usuario?['UsuarioID'] ?? 'USR00001';

        // Inicializar carrito con el usuario
        final carritoProvider = Provider.of<CarritoProvider>(
          context,
          listen: false,
        );
        carritoProvider.inicializarCarrito(usuarioID);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home(usuario: usuario)),
        );
      },
      theme: LoginTheme(
        primaryColor: const Color.fromARGB(255, 204, 193, 190),
        accentColor: const Color.fromARGB(240, 5, 4, 4),
        pageColorLight: Colors.brown.shade50,
        pageColorDark: const Color.fromARGB(255, 241, 225, 222),
        logoWidth: 0.65,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontSize: 28,
        ),
        errorColor: const Color.fromARGB(255, 235, 16, 16),
        buttonTheme: LoginButtonTheme(
          backgroundColor: const Color.fromARGB(255, 115, 175, 199),
          highlightColor: Colors.amber,
          elevation: 5,
          highlightElevation: 8,
        ),
      ),
      messages: LoginMessages(
        userHint: 'Usuario / Correo',
        passwordHint: 'Contraseña',
        loginButton: 'INICIAR SESIÓN',
        signupButton: 'REGISTRARSE',
        forgotPasswordButton: '¿Olvidaste tu contraseña?',
        recoverPasswordButton: 'RESTABLECER',
        goBackButton: 'VOLVER',
      ),
    );
  }
}
