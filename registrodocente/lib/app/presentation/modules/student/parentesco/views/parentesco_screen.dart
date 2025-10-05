import 'package:flutter/material.dart';

class ParentescoScreen extends StatefulWidget {
  const ParentescoScreen({super.key});

  @override
  State<ParentescoScreen> createState() => _ParentescoScreenState();
}

class _ParentescoScreenState extends State<ParentescoScreen> {
  List<Map<String, TextEditingController>> parentesco = List.generate(
    40,
    (_) => {
      'padreNombre': TextEditingController(),
      'padreTelefono': TextEditingController(),
      'madreNombre': TextEditingController(),
      'madreTelefono': TextEditingController(),
      'tutorNombre': TextEditingController(),
      'tutorTelefono': TextEditingController(),
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parentesco'),
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
                width: 1090,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.black,
                alignment: Alignment.center,
                child: const Text(
                  'PARENTESCO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Cabeceras de secciones (PADRE, MADRE, TUTOR)
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 347,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      color: Colors.grey[400],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'PADRE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    width: 347,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      color: Colors.grey[400],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'MADRE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    width: 346,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      color: Colors.grey[400],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'TUTOR',
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
                  _HeaderCell('', width: 50),
                  _HeaderCell('Nombre(s) y\nApellido(s)', width: 230),
                  _HeaderCell('Teléfono', width: 117),
                  _HeaderCell('Nombre(s) y\nApellido(s)', width: 230),
                  _HeaderCell('Teléfono', width: 117),
                  _HeaderCell('Nombre(s) y\nApellido(s)', width: 229),
                  _HeaderCell('Teléfono', width: 117),
                ],
              ),
              // Filas de datos
              SizedBox(
                height: 600,
                width: 1090,
                child: ListView.builder(
                  itemCount: parentesco.length,
                  itemBuilder: (context, index) {
                    final fila = parentesco[index];
                    return Row(
                      children: [
                        _NumberCell(index + 1),
                        _EditableCell(controller: fila['padreNombre']!, width: 230),
                        _EditableCell(controller: fila['padreTelefono']!, width: 117),
                        _EditableCell(controller: fila['madreNombre']!, width: 230),
                        _EditableCell(controller: fila['madreTelefono']!, width: 117),
                        _EditableCell(controller: fila['tutorNombre']!, width: 229),
                        _EditableCell(controller: fila['tutorTelefono']!, width: 117),
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
    for (var i = 0; i < parentesco.length; i++) {
      // TODO: Save parent data to database
      // final fila = parentesco[i];
      // final data = {
      //   'numero': i + 1,
      //   'padreNombre': fila['padreNombre']!.text,
      //   'padreTelefono': fila['padreTelefono']!.text,
      //   'madreNombre': fila['madreNombre']!.text,
      //   'madreTelefono': fila['madreTelefono']!.text,
      //   'tutorNombre': fila['tutorNombre']!.text,
      //   'tutorTelefono': fila['tutorTelefono']!.text,
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
      width: 50,
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
