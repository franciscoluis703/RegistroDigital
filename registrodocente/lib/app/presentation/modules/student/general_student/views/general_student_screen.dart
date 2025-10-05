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

  bool _isLoading = true;

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

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
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
            onPressed: _guardarEstudiantes,
            tooltip: 'Guardar estudiantes',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              children: [
                // Encabezado principal
                Container(
                  width: 1200,
                  padding: const EdgeInsets.all(12),
                  color: Colors.black,
                  child: const Text(
                    'Datos generales del estudiante',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Fila de encabezados de columnas
                Row(
                  children: [
                    // Foto
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 90,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: Border.all(color: Colors.black),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Nombre y Apellidos
                    Column(
                      children: [
                        Container(
                          width: 250,
                          height: 90,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: Border.all(color: Colors.black),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'NOMBRE(S) Y APELLIDOS(*)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'en orden alfabético',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Sexo
                    _buildHeaderCell('Sexo', 50, hasSubheaders: true),
                    // Del acta de nacimiento
                    Column(
                      children: [
                        Container(
                          width: 300,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: Border.all(color: Colors.black),
                          ),
                          child: const Text(
                            'Del acta de nacimiento',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _buildSubHeaderCell('Día', 45),
                            _buildSubHeaderCell('Mes', 45),
                            _buildSubHeaderCell('Año', 55),
                            _buildSubHeaderCell('Libro', 55),
                            _buildSubHeaderCell('Folio', 50),
                            _buildSubHeaderCell('Acta', 50),
                          ],
                        ),
                      ],
                    ),
                    // No. Cédula o Pasaporte
                    _buildHeaderCell('No. Cédula\no Pasaporte', 130),
                    // RNE
                    _buildHeaderCell('RNE', 90),
                    // Dirección donde reside
                    _buildHeaderCell('Dirección donde reside', 280),
                  ],
                ),

                // Filas de datos (40 filas)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(40, (rowIndex) {
                        return Row(
                          children: [
                            // Número
                            Container(
                              width: 80,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Text(
                                '${rowIndex + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            // Nombre
                            Container(
                              width: 250,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: TextField(
                                controller: nombresControllers[rowIndex],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            // Sexo
                            _buildDataCell(50, rowIndex, 0),
                            // Día
                            _buildDataCell(45, rowIndex, 1),
                            // Mes
                            _buildDataCell(45, rowIndex, 2),
                            // Año
                            _buildDataCell(55, rowIndex, 3),
                            // Libro
                            _buildDataCell(55, rowIndex, 4),
                            // Folio
                            _buildDataCell(50, rowIndex, 5),
                            // Acta
                            _buildDataCell(50, rowIndex, 6),
                            // No. Cédula o Pasaporte
                            _buildDataCell(130, rowIndex, 7),
                            // RNE
                            _buildDataCell(90, rowIndex, 8),
                            // Dirección donde reside
                            _buildDataCell(280, rowIndex, 9),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width,
      {bool hasSubheaders = false}) {
    return Container(
      width: width,
      height: hasSubheaders ? 90 : 90,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.black),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSubHeaderCell(String text, double width) {
    return Container(
      width: width,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.black),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildDataCell(double width, int row, int col) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        controller: camposControllers[row][col],
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 11),
        textAlign: TextAlign.center,
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
