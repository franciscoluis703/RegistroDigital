import 'package:flutter/material.dart';

class EmergencyDataScreen extends StatefulWidget {
  const EmergencyDataScreen({super.key});

  @override
  State<EmergencyDataScreen> createState() => _EmergencyDataScreenState();
}

class _EmergencyDataScreenState extends State<EmergencyDataScreen> {
  // Lista de 40 filas con TextEditingControllers
  List<Map<String, TextEditingController>> emergencia = List.generate(
    40,
    (_) => {
      'enfermedades': TextEditingController(),
      'medicamentos': TextEditingController(),
      'nombreApellido': TextEditingController(),
      'telefono': TextEditingController(),
      'parentesco': TextEditingController(),
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos para Emergencias'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Título principal
              Container(
                width: 1000,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.black,
                alignment: Alignment.center,
                child: const Text(
                  'DATOS PARA EMERGENCIAS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Subtítulos
              Row(
                children: [
                  Container(
                    width: 450,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[400],
                    alignment: Alignment.center,
                    child: const Text(
                      'DE SALUD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    width: 550,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[400],
                    alignment: Alignment.center,
                    child: const Text(
                      'LLAMAR A:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              // Cabecera de columnas
              Row(
                children: const [
                  _HeaderCell('', width: 40),
                  _HeaderCell('Enfermedades o\nalérgico a:', width: 205),
                  _HeaderCell('Medicamentos\nque usa', width: 205),
                  _HeaderCell('Nombre y Apellido', width: 183),
                  _HeaderCell('Teléfono', width: 183),
                  _HeaderCell('Parentesco persona\ncon la que vive', width: 184),
                ],
              ),
              // Filas de datos
              SizedBox(
                height: 600,
                width: 1000,
                child: ListView.builder(
                  itemCount: emergencia.length,
                  itemBuilder: (context, index) {
                    final fila = emergencia[index];
                    return Row(
                      children: [
                        _NumberCell(index + 1),
                        _EditableCell(controller: fila['enfermedades']!, width: 205),
                        _EditableCell(controller: fila['medicamentos']!, width: 205),
                        _EditableCell(controller: fila['nombreApellido']!, width: 183),
                        _EditableCell(controller: fila['telefono']!, width: 183),
                        _EditableCell(controller: fila['parentesco']!, width: 184),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _guardarDatos,
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarDatos() {
    for (var i = 0; i < emergencia.length; i++) {
      // TODO: Save emergency data to database
      // final fila = emergencia[i];
      // final data = {
      //   'numero': i + 1,
      //   'enfermedades': fila['enfermedades']!.text,
      //   'medicamentos': fila['medicamentos']!.text,
      //   'nombreApellido': fila['nombreApellido']!.text,
      //   'telefono': fila['telefono']!.text,
      //   'parentesco': fila['parentesco']!.text,
      // };
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos guardados correctamente')),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double? width;
  const _HeaderCell(this.label, {this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 120,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EditableCell extends StatelessWidget {
  final TextEditingController controller;
  final double? width;
  const _EditableCell({required this.controller, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 120,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
      ),
    );
  }
}

class _NumberCell extends StatelessWidget {
  final int number;
  const _NumberCell(this.number);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
