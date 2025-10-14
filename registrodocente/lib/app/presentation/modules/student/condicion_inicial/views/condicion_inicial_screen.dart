import 'package:flutter/material.dart';

import '../../../../../data/services/curso_context_service.dart';
import '../../../../../data/services/firebase/estudiantes_firestore_service.dart';

class CondicionInicialScreen extends StatefulWidget {
  const CondicionInicialScreen({super.key});

  @override
  State<CondicionInicialScreen> createState() => _CondicionInicialScreenState();
}

class _CondicionInicialScreenState extends State<CondicionInicialScreen> {
  final _cursoContext = CursoContextService();
  final _estudiantesService = EstudiantesFirestoreService();

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
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    for (var estudiante in estudiantes) {
      (estudiante['correoController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final cursoId = await _cursoContext.obtenerCursoActual() ?? 'default';
    final condiciones = await _estudiantesService.obtenerCondicionInicial(cursoId);

    if (condiciones != null && mounted) {
      setState(() {
        for (int i = 0; i < condiciones.length && i < 40; i++) {
          estudiantes[i]['correoController'].text = condiciones[i]['correo'] ?? '';
          estudiantes[i]['promovido'] = condiciones[i]['promovido'] ?? false;
          estudiantes[i]['repitente'] = condiciones[i]['repitente'] ?? false;
          estudiantes[i]['reingreso'] = condiciones[i]['reingreso'] ?? false;
          estudiantes[i]['aplazado'] = condiciones[i]['aplazado'] ?? false;
        }
      });
    }
  }

  Future<void> _guardarDatos() async {
    final cursoId = await _cursoContext.obtenerCursoActual() ?? 'default';

    // Convertir a lista de mapas
    final condiciones = estudiantes.map((e) => {
      'correo': (e['correoController'] as TextEditingController).text,
      'promovido': e['promovido'] as bool,
      'repitente': e['repitente'] as bool,
      'reingreso': e['reingreso'] as bool,
      'aplazado': e['aplazado'] as bool,
    }).toList();

    final success = await _estudiantesService.guardarCondicionInicial(
      cursoId: cursoId,
      condiciones: condiciones,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Datos guardados correctamente'
              : 'Error al guardar los datos'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
            onPressed: _guardarDatos,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Título
          const Center(
            child: Text(
              'Condición inicial del estudiante',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tabla con scroll horizontal y vertical
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Fila de encabezados
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderColumn('#', 60),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Correo Electrónico', 300),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Promovido', 120),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Repitente', 120),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Reingreso', 120),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Aplazado', 120),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filas de estudiantes (1-40)
                  ...List.generate(40, (index) {
                    final estudiante = estudiantes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNumberFieldWithName(index + 1, 60),
                          const SizedBox(width: 16),
                          _buildTextField(
                            controller: estudiante['correoController'],
                            width: 300,
                          ),
                          const SizedBox(width: 16),
                          _buildCheckboxField(
                            value: estudiante['promovido'],
                            width: 120,
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
                          const SizedBox(width: 16),
                          _buildCheckboxField(
                            value: estudiante['repitente'],
                            width: 120,
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
                          const SizedBox(width: 16),
                          _buildCheckboxField(
                            value: estudiante['reingreso'],
                            width: 120,
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
                          const SizedBox(width: 16),
                          _buildCheckboxField(
                            value: estudiante['aplazado'],
                            width: 120,
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
                      ),
                    );
                  }),
                  const SizedBox(height: 32),

                  // Botón Guardar
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _guardarDatos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFbfa661),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(String label, double width) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[400],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNumberFieldWithName(int number, double width) {
    return SizedBox(
      width: width,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 1),
          color: Colors.grey[300],
        ),
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 1),
        ),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxField({
    required bool value,
    required double width,
    required ValueChanged<bool?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 1),
          color: Colors.white,
        ),
        child: Center(
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
