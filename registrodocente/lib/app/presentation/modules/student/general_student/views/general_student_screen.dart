import 'package:flutter/material.dart';
import '../../../../../data/services/estudiantes_service.dart';

class GeneralStudentScreen extends StatefulWidget {
  const GeneralStudentScreen({super.key});

  @override
  State<GeneralStudentScreen> createState() => _GeneralStudentScreenState();
}

class _GeneralStudentScreenState extends State<GeneralStudentScreen> {
  final EstudiantesService _estudiantesService = EstudiantesService();

  // Controladores para los nombres (40 estudiantes)
  List<TextEditingController> nombresControllers =
      List.generate(40, (_) => TextEditingController());

  // Controladores para los campos adicionales (40 filas x 10 columnas)
  // Columnas: sexo, día, mes, año, libro, folio, acta, cédula, rne, dirección
  List<List<TextEditingController>> camposControllers =
      List.generate(40, (_) => List.generate(10, (_) => TextEditingController()));

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  Future<void> _cargarEstudiantes() async {
    final datos = await _estudiantesService.obtenerDatosGenerales();

    if (datos != null) {
      setState(() {
        final nombres = datos['nombres'] as List<String>;
        final campos = datos['camposAdicionales'] as List<Map<String, String>>;

        for (int i = 0; i < nombresControllers.length && i < nombres.length; i++) {
          nombresControllers[i].text = nombres[i];
        }

        for (int i = 0; i < camposControllers.length && i < campos.length; i++) {
          for (int j = 0; j < 10; j++) {
            camposControllers[i][j].text = campos[i]['col_$j'] ?? '';
          }
        }
      });
    }

    // Agregar listeners para guardado automático
    for (var controller in nombresControllers) {
      controller.addListener(_guardarAutomaticamente);
    }
    for (var fila in camposControllers) {
      for (var controller in fila) {
        controller.addListener(_guardarAutomaticamente);
      }
    }
  }

  // Guardar automáticamente
  void _guardarAutomaticamente() {
    final nombres = nombresControllers.map((c) => c.text).toList();
    final campos = camposControllers.map((fila) {
      final Map<String, String> filaDatos = {};
      for (int j = 0; j < fila.length; j++) {
        filaDatos['col_$j'] = fila[j].text;
      }
      return filaDatos;
    }).toList();

    _estudiantesService.guardarDatosGenerales(
      nombres: nombres,
      camposAdicionales: campos,
    );
  }

  Future<void> _guardarEstudiantes() async {
    _guardarAutomaticamente();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos guardados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Datos generales del estudiante'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
            onPressed: _guardarEstudiantes,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Center(
              child: Text(
                'Datos generales del estudiante',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tabla con scroll horizontal
            SingleChildScrollView(
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
                      _buildHeaderColumn('NOMBRE(S) Y APELLIDOS(*)', 280),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Sexo', 100),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Día', 80),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Mes', 80),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Año', 100),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Libro', 100),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Folio', 100),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Acta', 100),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('No. Cédula\no Pasaporte', 180),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('RNE', 140),
                      const SizedBox(width: 16),
                      _buildHeaderColumn('Dirección donde reside', 280),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filas de estudiantes (1-40)
                  ...List.generate(40, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNumberField(index + 1, 60),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: nombresControllers[index],
                            width: 280,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][0],
                            width: 100,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][1],
                            width: 80,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][2],
                            width: 80,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][3],
                            width: 100,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][4],
                            width: 100,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][5],
                            width: 100,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][6],
                            width: 100,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][7],
                            width: 180,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][8],
                            width: 140,
                          ),
                          const SizedBox(width: 16),
                          _buildLabeledTextField(
                            controller: camposControllers[index][9],
                            width: 280,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 1),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField({
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

  @override
  void dispose() {
    for (var controller in nombresControllers) {
      controller.dispose();
    }
    for (var fila in camposControllers) {
      for (var controller in fila) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
