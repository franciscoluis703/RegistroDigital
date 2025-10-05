import 'package:flutter/material.dart';

class CondicionInicialScreen extends StatefulWidget {
  const CondicionInicialScreen({super.key});

  @override
  State<CondicionInicialScreen> createState() => _CondicionInicialScreenState();
}

class _CondicionInicialScreenState extends State<CondicionInicialScreen> {
  // Lista de 40 filas con controllers
  List<Map<String, dynamic>> estudiantes = List.generate(
    40,
    (_) => {
      'correoController': TextEditingController(),
      'promovido': false,
      'repitente': false,
      'reingreso': false,
      'aplazado': false,
    },
  );

  @override
  void dispose() {
    for (var estudiante in estudiantes) {
      (estudiante['correoController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _guardarDatos() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos guardados correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Condición inicial del estudiante'),
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
              // Cabecera principal con dos secciones
              Row(
                children: [
                  // Columna número (vacía negra)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  ),
                  // Sección izquierda (vacía negra)
                  Container(
                    width: 370,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  ),
                  // Sección derecha con título
                  Container(
                    width: 320,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Condición inicial del estudiante',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              // Fila de encabezados
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      color: Colors.grey[300],
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      '#',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 370,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      color: Colors.grey[300],
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'Correo Electrónico',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _HeaderCell('Promovido', width: 80),
                  _HeaderCell('Repitente', width: 80),
                  _HeaderCell('Reingreso', width: 80),
                  _HeaderCell('Aplazado', width: 80),
                ],
              ),
              // Filas de datos
              SizedBox(
                height: 600,
                width: 740,
                child: ListView.builder(
                  itemCount: estudiantes.length,
                  itemBuilder: (context, index) {
                    final estudiante = estudiantes[index];
                    return Row(
                      children: [
                        _NumberCell(index + 1),
                        _EditableCell(
                          controller: estudiante['correoController'],
                          width: 370,
                        ),
                        _CheckboxCell(
                          value: estudiante['promovido'],
                          onChanged: (value) {
                            setState(() {
                              estudiante['promovido'] = value ?? false;
                              if (value == true) {
                                estudiante['repitente'] = false;
                                estudiante['reingreso'] = false;
                                estudiante['aplazado'] = false;
                              }
                            });
                          },
                        ),
                        _CheckboxCell(
                          value: estudiante['repitente'],
                          onChanged: (value) {
                            setState(() {
                              estudiante['repitente'] = value ?? false;
                              if (value == true) {
                                estudiante['promovido'] = false;
                                estudiante['reingreso'] = false;
                                estudiante['aplazado'] = false;
                              }
                            });
                          },
                        ),
                        _CheckboxCell(
                          value: estudiante['reingreso'],
                          onChanged: (value) {
                            setState(() {
                              estudiante['reingreso'] = value ?? false;
                              if (value == true) {
                                estudiante['promovido'] = false;
                                estudiante['repitente'] = false;
                                estudiante['aplazado'] = false;
                              }
                            });
                          },
                        ),
                        _CheckboxCell(
                          value: estudiante['aplazado'],
                          onChanged: (value) {
                            setState(() {
                              estudiante['aplazado'] = value ?? false;
                              if (value == true) {
                                estudiante['promovido'] = false;
                                estudiante['repitente'] = false;
                                estudiante['reingreso'] = false;
                              }
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _guardarDatos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFbfa661),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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
        color: Colors.grey[300],
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
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

class _CheckboxCell extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _CheckboxCell({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
