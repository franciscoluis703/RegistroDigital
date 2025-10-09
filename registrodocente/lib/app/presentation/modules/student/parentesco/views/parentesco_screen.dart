import 'package:flutter/material.dart';
import '../../../../../data/services/curso_context_service.dart';
import '../../../../../data/services/estudiantes_supabase_service.dart';
import '../../../../widgets/estudiante_nombre_widget.dart';

class ParentescoScreen extends StatefulWidget {
  const ParentescoScreen({super.key});

  @override
  State<ParentescoScreen> createState() => _ParentescoScreenState();
}

class _ParentescoScreenState extends State<ParentescoScreen> {
  final _cursoContext = CursoContextService();
  final _estudiantesService = EstudiantesSupabaseService();

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
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    for (var fila in parentesco) {
      fila['padreNombre']!.dispose();
      fila['padreTelefono']!.dispose();
      fila['madreNombre']!.dispose();
      fila['madreTelefono']!.dispose();
      fila['tutorNombre']!.dispose();
      fila['tutorTelefono']!.dispose();
    }
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final cursoId = await _cursoContext.obtenerCursoActual() ?? 'default';
    final parentescos = await _estudiantesService.obtenerDatosParentesco(cursoId);

    if (parentescos != null && mounted) {
      setState(() {
        for (int i = 0; i < parentescos.length && i < 40; i++) {
          parentesco[i]['padreNombre']!.text = parentescos[i]['padreNombre'] ?? '';
          parentesco[i]['padreTelefono']!.text = parentescos[i]['padreTelefono'] ?? '';
          parentesco[i]['madreNombre']!.text = parentescos[i]['madreNombre'] ?? '';
          parentesco[i]['madreTelefono']!.text = parentescos[i]['madreTelefono'] ?? '';
          parentesco[i]['tutorNombre']!.text = parentescos[i]['tutorNombre'] ?? '';
          parentesco[i]['tutorTelefono']!.text = parentescos[i]['tutorTelefono'] ?? '';
        }
      });
    }
  }

  Future<void> _guardarDatos() async {
    final cursoId = await _cursoContext.obtenerCursoActual() ?? 'default';

    // Convertir a lista de mapas
    final parentescos = parentesco.map((e) => {
      'padreNombre': e['padreNombre']!.text,
      'padreTelefono': e['padreTelefono']!.text,
      'madreNombre': e['madreNombre']!.text,
      'madreTelefono': e['madreTelefono']!.text,
      'tutorNombre': e['tutorNombre']!.text,
      'tutorTelefono': e['tutorTelefono']!.text,
    }).toList();

    final success = await _estudiantesService.guardarDatosParentesco(
      cursoId: cursoId,
      parentescos: parentescos,
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
        title: const Text('Parentesco'),
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
              'Parentesco',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tabla con scroll
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
                        _buildHeaderColumn('Padre\nNombre(s) y Apellido(s)', 240),
                        const SizedBox(width: 16),
                        _buildHeaderColumn('Padre\nTeléfono', 160),
                        const SizedBox(width: 16),
                        _buildHeaderColumn('Madre\nNombre(s) y Apellido(s)', 240),
                        const SizedBox(width: 16),
                        _buildHeaderColumn('Madre\nTeléfono', 160),
                        const SizedBox(width: 16),
                        _buildHeaderColumn('Tutor\nNombre(s) y Apellido(s)', 240),
                        const SizedBox(width: 16),
                        _buildHeaderColumn('Tutor\nTeléfono', 160),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Filas de estudiantes (1-40)
                    ...List.generate(40, (index) {
                      final fila = parentesco[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNumberField(index + 1, 60),
                            const SizedBox(width: 16),
                            _buildTextField(
                              controller: fila['padreNombre']!,
                              width: 240,
                            ),
                            const SizedBox(width: 16),
                            _buildTextField(
                              controller: fila['padreTelefono']!,
                              width: 160,
                            ),
                            const SizedBox(width: 16),
                            _buildTextField(
                              controller: fila['madreNombre']!,
                              width: 240,
                            ),
                            const SizedBox(width: 16),
                            _buildTextField(
                              controller: fila['madreTelefono']!,
                              width: 160,
                            ),
                            const SizedBox(width: 16),
                            _buildTextField(
                              controller: fila['tutorNombre']!,
                              width: 240,
                            ),
                            const SizedBox(width: 16),
                            _buildTextField(
                              controller: fila['tutorTelefono']!,
                              width: 160,
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 32),

                    // Botón Guardar (moverlo DENTRO del Column)
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
