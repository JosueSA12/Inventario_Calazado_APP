import "package:flutter/material.dart";
import "/screens/navegacion_page.dart";

class Home extends StatelessWidget {
  final Map<String, dynamic>? usuario;

  const Home({super.key, this.usuario});

  static const routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return AppNavigation(usuario: usuario);
  }
}
