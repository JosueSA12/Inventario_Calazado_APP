import 'package:flutter/material.dart';

class FormularioCalzado extends StatefulWidget {
  const FormularioCalzado({super.key});

  @override
  State<FormularioCalzado> createState() => _FormularioCalzadoState();
}

class _FormularioCalzadoState extends State<FormularioCalzado> {
  final _formKey = GlobalKey<FormState>();

  final List<int> _tallasDisponibles = [36, 37, 38, 39, 40, 41, 42, 43, 44];
  int? _tallaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Calzado'),
        backgroundColor: Colors.brown.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Detalles del Calzado Terminado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 16),

              // Campo: Modelo
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre del Modelo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.style),
                  hintText: 'Ej. Bota Casual Vaquera',
                ),
              ),
              const SizedBox(height: 16),

              // Campo: Color
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                  hintText: 'Ej. Negro Mate / Café Miel',
                ),
              ),
              const SizedBox(height: 16),

              // Campo Desplegable: Talla
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Talla / Número',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_size),
                ),
                value: _tallaSeleccionada,
                items: _tallasDisponibles.map((int talla) {
                  return DropdownMenuItem<int>(
                    value: talla,
                    child: Text('Talla $talla'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tallaSeleccionada = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Fila para Cantidad y Precio
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad (Pares)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Precio Venta',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              ElevatedButton.icon(
                onPressed: () {
                  // LOGICA PARA GUARDAR EL CALZADO EN EL INVENTARIO / FALTA
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text(
                  'Guardar en Inventario',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
