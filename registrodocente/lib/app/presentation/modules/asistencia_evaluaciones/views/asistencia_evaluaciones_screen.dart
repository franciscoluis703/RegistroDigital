

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../widgets/estudiante_nombre_widget.dart';
import '../../../../data/services/curso_context_service.dart';

class AsistenciaEvaluacionesScreen extends StatefulWidget {
  const AsistenciaEvaluacionesScreen({super.key});

  @override
  State<AsistenciaEvaluacionesScreen> createState() => _AsistenciaEvaluacionesScreenState();
}

class _AsistenciaEvaluacionesScreenState extends State<AsistenciaEvaluacionesScreen> {
  final int totalEstudiantes = 40;
  final CursoContextService _cursoContext = CursoContextService();
  String _asignatura = 'Asignatura';

  // Controladores para nombre y grado
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController gradoController = TextEditingController();

  // Generamos los valores de cada celda
  List<Map<String, String>> estudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarAsignatura();
    _cargarDatos();
  }

  Future<void> _cargarAsignatura() async {
    final asignatura = await _cursoContext.obtenerAsignaturaActual();
    setState(() {
      _asignatura = asignatura;
    });
  }

  Future<String> _getKey() async {
    final cursoId = await _cursoContext.obtenerCursoActual();
    return 'asistencia_evaluaciones_${cursoId ?? 'default'}';
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();

    // Cargar datos guardados
    final datosJson = prefs.getString(key);
    if (datosJson != null) {
      final datos = json.decode(datosJson) as Map<String, dynamic>;

      // Cargar nombre y grado
      nombreController.text = datos['nombreDocente'] ?? '';
      gradoController.text = datos['grado'] ?? '';

      // Cargar asistencias
      final asistenciasGuardadas = datos['estudiantes'] as List<dynamic>?;
      if (asistenciasGuardadas != null) {
        setState(() {
          estudiantes = asistenciasGuardadas
              .map((e) => Map<String, String>.from(e))
              .toList();
        });
      } else {
        _inicializarEstudiantes();
      }
    } else {
      _inicializarEstudiantes();
    }
  }

  void _inicializarEstudiantes() {
    setState(() {
      estudiantes.clear();
      for (int i = 0; i < totalEstudiantes; i++) {
        estudiantes.add({
          "1": "",
          "2": "",
          "3": "",
          "4": "",
          "5": "",
          "6": "",
          "7": "",
          "8": "",
          "9": "",
          "10": "",
        });
      }
    });
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();

    final datos = {
      'nombreDocente': nombreController.text,
      'grado': gradoController.text,
      'estudiantes': estudiantes,
    };

    await prefs.setString(key, json.encode(datos));
  }

  @override
  void dispose() {
    nombreController.dispose();
    gradoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_asignatura),
        actions: [
          // Botón Verificar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar verificación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verificación de asistencias')),
                );
              },
              icon: const Icon(Icons.warning_amber, size: 20),
              label: const Text('Verificar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          // Botón Imprimir
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Imprimir',
            onPressed: () {
              // TODO: Implementar impresión
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Impresión de asistencias')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 990, // 11 columnas x 90px
          child: Column(
            children: [
              // Campos de Nombre y Grado
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Docente',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (_) => _guardarDatos(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: gradoController,
                        decoration: const InputDecoration(
                          labelText: 'Grado',
                          hintText: 'Ej: 5to',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (_) => _guardarDatos(),
                      ),
                    ),
                  ],
                ),
              ),
              // Tabla con encabezados
              Row(
                children: const [
                  _HeaderCell(text: "Días"),
                  _HeaderCell(text: "1"),
                  _HeaderCell(text: "2"),
                  _HeaderCell(text: "3"),
                  _HeaderCell(text: "4"),
                  _HeaderCell(text: "5"),
                  _HeaderCell(text: "6"),
                  _HeaderCell(text: "7"),
                  _HeaderCell(text: "8"),
                  _HeaderCell(text: "9"),
                  _HeaderCell(text: "10"),
                ],
              ),
              // Filas
              Expanded(
                child: SizedBox(
                  height: 600,
                  child: ListView.builder(
                    itemCount: totalEstudiantes,
                    itemBuilder: (context, index) {
                      final estudiante = estudiantes[index];
                      return Row(
                        children: [
                          _DataCell(
                            value: '${index + 1}',
                            numero: index + 1,
                          ),
                          _EditableCell(
                            value: estudiante['1']!,
                            onChanged: (val) {
                              setState(() => estudiante['1'] = val);
                              _guardarDatos();
                            },
                          ),
                          _EditableCell(
                            value: estudiante['2']!,
                            onChanged: (val) {
                              setState(() => estudiante['2'] = val);
                              _guardarDatos();
                            },
                          ),
                          _EditableCell(
                            value: estudiante['3']!,
                            onChanged: (val) {
                              setState(() => estudiante['3'] = val);
                              _guardarDatos();
                            },
                          ),
                          _EditableCell(
                            value: estudiante['4']!,
                            onChanged: (val) {
                              setState(() => estudiante['4'] = val);
                              _guardarDatos();
                            },
                          ),
                          _EditableCell(
                            value: estudiante['5']!,
                            onChanged: (val) {
                              setState(() => estudiante['5'] = val);
                              _guardarDatos();
                            },
                          ),
                          _EditableCell(
                            value: estudiante['6']!,
                            onChanged: (val) {
                              setState(() => estudiante['6'] = val);
                              _guardarDatos();
                            },
                          ),
                          _EditableCell(
                            value: estudiante['7']!,
                            onChanged: (val) {
                              setState(() => estudiante['7'] = val);
                              _guardarDatos();
                            },
                          ),
                          _EditableCell(
                            value: estudiante['8']!,
                            onChanged: (val) {
                              setState(() => estudiante['8'] = val);
                              _guardarDatos();
                            },
                          ),
                          _EditableCell(
                            value: estudiante['9']!,
                            onChanged: (val) {
                              setState(() => estudiante['9'] = val);
                              _guardarDatos();
                            },
                          ),
                          _EditableCell(
                            value: estudiante['10']!,
                            onChanged: (val) {
                              setState(() => estudiante['10'] = val);
                              _guardarDatos();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await _guardarDatos();
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Datos guardados exitosamente"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widgets auxiliares
class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(1),
      color: Colors.grey[400],
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String value;
  final int? numero; // Número del estudiante (opcional)

  const _DataCell({
    required this.value,
    this.numero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(1),
      color: Colors.grey[200],
      child: numero != null
          ? EstudianteNombreWidget(
              numero: numero!,
              textAlign: TextAlign.center,
            )
          : Text(value),
    );
  }
}

class _EditableCell extends StatelessWidget {
  final String value;
  final Function(String) onChanged;
  const _EditableCell({required this.value, required this.onChanged});

  Color _getColorForCode(String code) {
    switch (code.toUpperCase()) {
      case 'P':
        return Colors.green.shade100;
      case 'A':
        return Colors.red.shade100;
      case 'T':
        return Colors.orange.shade100;
      case 'E':
        return Colors.yellow.shade100;
      case 'R':
        return Colors.purple.shade100;
      default:
        return Colors.white;
    }
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Asistencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OptionButton(
                codigo: 'P',
                descripcion: 'Presente',
                color: Colors.green,
                onTap: () {
                  onChanged('P');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _OptionButton(
                codigo: 'A',
                descripcion: 'Ausencia',
                color: Colors.red,
                onTap: () {
                  onChanged('A');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _OptionButton(
                codigo: 'T',
                descripcion: 'Tardanza',
                color: Colors.orange,
                onTap: () {
                  onChanged('T');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _OptionButton(
                codigo: 'E',
                descripcion: 'Excusa',
                color: Colors.yellow,
                onTap: () {
                  onChanged('E');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _OptionButton(
                codigo: 'R',
                descripcion: 'Retiro voluntario',
                color: Colors.purple,
                onTap: () {
                  onChanged('R');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _OptionButton(
                codigo: '',
                descripcion: 'Limpiar',
                color: Colors.grey,
                onTap: () {
                  onChanged('');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptionsDialog(context),
      child: Container(
        width: 80,
        height: 40,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _getColorForCode(value),
          border: Border.all(color: Colors.grey.shade400),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String codigo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
    required this.codigo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.grey.shade200;
    Color borderColor = Colors.grey.shade400;

    if (color == Colors.green) {
      backgroundColor = Colors.green.shade100;
      borderColor = Colors.green.shade300;
    } else if (color == Colors.red) {
      backgroundColor = Colors.red.shade100;
      borderColor = Colors.red.shade300;
    } else if (color == Colors.orange) {
      backgroundColor = Colors.orange.shade100;
      borderColor = Colors.orange.shade300;
    } else if (color == Colors.yellow) {
      backgroundColor = Colors.yellow.shade100;
      borderColor = Colors.yellow.shade300;
    } else if (color == Colors.purple) {
      backgroundColor = Colors.purple.shade100;
      borderColor = Colors.purple.shade300;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
              ),
              alignment: Alignment.center,
              child: Text(
                codigo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                descripcion,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
