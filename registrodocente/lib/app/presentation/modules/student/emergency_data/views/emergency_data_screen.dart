import 'package:flutter/material.dart';
import '../../../../../data/services/curso_context_service.dart';
import '../../../../../data/services/firebase/estudiantes_firestore_service.dart';
import '../../../../widgets/estudiante_nombre_widget.dart';

class EmergencyDataScreen extends StatefulWidget {
  const EmergencyDataScreen({super.key});

  @override
  State<EmergencyDataScreen> createState() => _EmergencyDataScreenState();
}

class _EmergencyDataScreenState extends State<EmergencyDataScreen> {
  final _cursoContext = CursoContextService();
  final _estudiantesService = EstudiantesFirestoreService();

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
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    for (var fila in emergencia) {
      fila['enfermedades']!.dispose();
      fila['medicamentos']!.dispose();
      fila['nombreApellido']!.dispose();
      fila['telefono']!.dispose();
      fila['parentesco']!.dispose();
    }
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final cursoId = await _cursoContext.obtenerCursoActual() ?? 'default';
    final emergencias = await _estudiantesService.obtenerDatosEmergencias(cursoId);

    if (emergencias != null && mounted) {
      setState(() {
        for (int i = 0; i < emergencias.length && i < 40; i++) {
          emergencia[i]['enfermedades']!.text = emergencias[i]['enfermedades'] ?? '';
          emergencia[i]['medicamentos']!.text = emergencias[i]['medicamentos'] ?? '';
          emergencia[i]['nombreApellido']!.text = emergencias[i]['nombreApellido'] ?? '';
          emergencia[i]['telefono']!.text = emergencias[i]['telefono'] ?? '';
          emergencia[i]['parentesco']!.text = emergencias[i]['parentesco'] ?? '';
        }
      });
    }
  }

  Future<void> _guardarDatos() async {
    final cursoId = await _cursoContext.obtenerCursoActual() ?? 'default';

    // Convertir a lista de mapas
    final emergencias = emergencia.map((e) => {
      'enfermedades': e['enfermedades']!.text,
      'medicamentos': e['medicamentos']!.text,
      'nombreApellido': e['nombreApellido']!.text,
      'telefono': e['telefono']!.text,
      'parentesco': e['parentesco']!.text,
    }).toList();

    final success = await _estudiantesService.guardarDatosEmergencias(
      cursoId: cursoId,
      emergencias: emergencias,
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
        title: const Text('Datos para Emergencias'),
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
              'Datos para Emergencias',
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
                      _buildHeaderColumn('Enfermedades o\nalérgico a:', 220),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Medicamentos\nque usa', 220),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Nombre y Apellido', 220),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Teléfono', 180),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Parentesco persona\ncon la que vive', 220),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filas de estudiantes (1-40)
                  ...List.generate(40, (index) {
                    final fila = emergencia[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNumberField(index + 1, 60),
                          const SizedBox(width: 16),
                          _buildTextField(
                            controller: fila['enfermedades']!,
                            width: 220,
                          ),
                          const SizedBox(width: 16),
                          _buildTextField(
                            controller: fila['medicamentos']!,
                            width: 220,
                          ),
                          const SizedBox(width: 16),
                          _buildTextField(
                            controller: fila['nombreApellido']!,
                            width: 220,
                          ),
                          const SizedBox(width: 16),
                          _buildTextField(
                            controller: fila['telefono']!,
                            width: 180,
                          ),
                          const SizedBox(width: 16),
                          _buildTextField(
                            controller: fila['parentesco']!,
                            width: 220,
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

  Widget _buildNumberField(int number, double width) {
    return SizedBox(
      width: width,
      height: 40,
      child: EstudianteNombreWidget(
        numero: number,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 1),
          color: Colors.grey[300],
        ),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
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
}
