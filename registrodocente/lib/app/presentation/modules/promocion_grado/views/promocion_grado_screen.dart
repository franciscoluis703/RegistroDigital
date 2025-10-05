import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../data/services/calificaciones_service.dart';

class PromocionGradoScreen extends StatefulWidget {
  const PromocionGradoScreen({super.key});

  @override
  State<PromocionGradoScreen> createState() => _PromocionGradoScreenState();
}

class _PromocionGradoScreenState extends State<PromocionGradoScreen> {
  final int numRows = 40;
  late List<List<TextEditingController>> controllers;
  final _calificacionesService = CalificacionesService();
  bool _calificacionesCargadas = false;

  // Controladores para asignatura, grado y docente
  final TextEditingController _asignaturaController = TextEditingController();
  final TextEditingController _gradoController = TextEditingController();
  final TextEditingController _docenteController = TextEditingController();

  // Método para verificar calificaciones incompletas
  void _verificarCalificacionesIncompletas() {
    List<String> advertencias = [];

    for (int i = 0; i < numRows; i++) {
      // Solo verificar si el estudiante tiene C.F (hay datos del estudiante)
      if (controllers[i][0].text.isNotEmpty) {
        int numeroEstudiante = i + 1;

        // Verificar Calificación Completiva (C.C.F < 70 y falta C.E.C)
        String ccf = controllers[i][4].text; // C.C.F
        String cec = controllers[i][2].text; // C.E.C
        bool faltaCompletiva = false;

        if (ccf.isNotEmpty) {
          double? ccfValue = double.tryParse(ccf);
          if (ccfValue != null && ccfValue < 70 && cec.isEmpty) {
            advertencias.add('Estudiante #$numeroEstudiante: Falta Calificación Completiva (C.E.C)');
            faltaCompletiva = true;
          }
        }

        // Solo verificar extraordinaria si NO falta completiva
        if (!faltaCompletiva) {
          // Verificar Calificación Extraordinaria (C.C.F < 70 y falta C.E.EX)
          if (ccf.isNotEmpty) {
            double? ccfValue = double.tryParse(ccf);
            String ceex = controllers[i][6].text; // C.E.EX
            bool faltaExtraordinaria = false;

            if (ccfValue != null && ccfValue < 70 && ceex.isEmpty) {
              advertencias.add('Estudiante #$numeroEstudiante: Falta Calificación Extraordinaria (C.E.EX)');
              faltaExtraordinaria = true;
            }

            // Solo verificar especiales si NO falta extraordinaria
            if (!faltaExtraordinaria) {
              // Verificar Calificación Especial (C.EX.F < 70 y falta C.F o C.E de especiales)
              String cexf = controllers[i][8].text; // C.EX.F
              if (cexf.isNotEmpty) {
                double? cexfValue = double.tryParse(cexf);
                String cfEspecial = controllers[i][9].text; // C.F (CALIFICACIONES ESPECIALES)
                String ceEspecial = controllers[i][10].text; // C.E (CALIFICACIONES ESPECIALES)
                if (cexfValue != null && cexfValue < 70) {
                  // Primero verificar si falta C.F
                  if (cfEspecial.isEmpty) {
                    advertencias.add('Estudiante #$numeroEstudiante: Falta Calificación Especial (C.F)');
                  } else if (ceEspecial.isEmpty) {
                    // Solo mostrar que falta C.E si C.F ya está completo
                    advertencias.add('Estudiante #$numeroEstudiante: Falta Calificación Especial (C.E)');
                  }
                }
              }
            }
          }
        }
      }
    }

    if (advertencias.isNotEmpty) {
      _mostrarDialogoAdvertencia(advertencias);
    }
  }

  void _mostrarDialogoAdvertencia(List<String> advertencias) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 8),
              const Text('Calificaciones Incompletas'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: advertencias.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          advertencias[index],
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar menú de opciones de impresión/exportación
  void _mostrarOpcionesImpresion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.print, color: Colors.blue),
              SizedBox(width: 8),
              Text('Exportar/Imprimir'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.print, color: Colors.blue),
                title: const Text('Imprimir'),
                subtitle: const Text('Enviar a impresora'),
                onTap: () {
                  Navigator.of(context).pop();
                  _imprimirPDF();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Exportar PDF'),
                subtitle: const Text('Guardar como archivo PDF'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportarPDF();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Exportar CSV'),
                subtitle: const Text('Guardar como archivo CSV'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportarCSV();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Generar PDF
  Future<pw.Document> _generarPDF() async {
    final pdf = pw.Document();

    // Preparar datos
    final List<List<String>> datos = [];

    // Encabezado
    datos.add([
      'N°', 'C.F.', '50% C.F', 'C.E.C', '50% C.E.C', 'C.C.F',
      '30% C.F', 'C.E.EX', '70% C.E.EX', 'C.EX.F',
      'C.F (Esp)', 'C.E (Esp)', 'A', 'R'
    ]);

    // Datos de estudiantes
    for (int i = 0; i < numRows; i++) {
      if (controllers[i][0].text.isNotEmpty) {
        datos.add([
          (i + 1).toString(),
          controllers[i][0].text,
          controllers[i][1].text,
          controllers[i][2].text,
          controllers[i][3].text,
          controllers[i][4].text,
          controllers[i][5].text,
          controllers[i][6].text,
          controllers[i][7].text,
          controllers[i][8].text,
          controllers[i][9].text,
          controllers[i][10].text,
          controllers[i][11].text,
          controllers[i][12].text,
        ]);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PROMOCIÓN DEL GRADO',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Docente: ${_docenteController.text}'),
              pw.Text('Asignatura: ${_asignaturaController.text}'),
              pw.Text('Grado: ${_gradoController.text}'),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                data: datos,
                cellStyle: const pw.TextStyle(fontSize: 8),
                headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // Imprimir PDF
  Future<void> _imprimirPDF() async {
    final pdf = await _generarPDF();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Exportar PDF
  Future<void> _exportarPDF() async {
    try {
      final pdf = await _generarPDF();
      final bytes = await pdf.save();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/promocion_grado_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF guardado en: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar PDF: $e')),
        );
      }
    }
  }

  // Exportar CSV
  Future<void> _exportarCSV() async {
    try {
      final List<List<String>> datos = [];

      // Información general
      datos.add(['PROMOCIÓN DEL GRADO']);
      datos.add(['Docente', _docenteController.text]);
      datos.add(['Asignatura', _asignaturaController.text]);
      datos.add(['Grado', _gradoController.text]);
      datos.add([]);

      // Encabezado
      datos.add([
        'N°', 'C.F.', '50% C.F', 'C.E.C', '50% C.E.C', 'C.C.F',
        '30% C.F', 'C.E.EX', '70% C.E.EX', 'C.EX.F',
        'C.F (Especiales)', 'C.E (Especiales)', 'A', 'R'
      ]);

      // Datos de estudiantes
      for (int i = 0; i < numRows; i++) {
        if (controllers[i][0].text.isNotEmpty) {
          datos.add([
            (i + 1).toString(),
            controllers[i][0].text,
            controllers[i][1].text,
            controllers[i][2].text,
            controllers[i][3].text,
            controllers[i][4].text,
            controllers[i][5].text,
            controllers[i][6].text,
            controllers[i][7].text,
            controllers[i][8].text,
            controllers[i][9].text,
            controllers[i][10].text,
            controllers[i][11].text,
            controllers[i][12].text,
          ]);
        }
      }

      final csv = const ListToCsvConverter().convert(datos);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/promocion_grado_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV guardado en: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar CSV: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Inicializar controladores: 40 filas x 13 columnas (sin contar la columna de numeración)
    controllers = List.generate(
      numRows,
      (row) => List.generate(
        13,
        (col) => TextEditingController(),
      ),
    );

    // Agregar listeners para guardado automático
    _asignaturaController.addListener(_guardarAutomaticamente);
    _gradoController.addListener(_guardarAutomaticamente);
    _docenteController.addListener(_guardarAutomaticamente);
  }

  // Guardar automáticamente
  void _guardarAutomaticamente() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';
    final seccion = args?['seccion'] ?? 'A';

    final datosPromocion = controllers.map((fila) =>
      fila.map((controller) => controller.text).toList()
    ).toList();

    _calificacionesService.guardarPromocionGrado(
      curso: curso,
      seccion: seccion,
      datosPromocion: datosPromocion,
      asignatura: _asignaturaController.text,
      grado: _gradoController.text,
      docente: _docenteController.text,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_calificacionesCargadas) {
      _cargarCalificacionesFinales();
      _calificacionesCargadas = true;
    }
  }

  void _cargarCalificacionesFinales() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';
    final seccion = args?['seccion'] ?? 'A';

    // Intentar cargar datos guardados previamente
    final datosGuardados = await _calificacionesService.obtenerPromocionGrado(
      curso: curso,
      seccion: seccion,
    );

    if (datosGuardados != null) {
      // Cargar datos guardados
      final promocion = datosGuardados['datosPromocion'] as List<List<String>>;
      for (int i = 0; i < numRows && i < promocion.length; i++) {
        for (int j = 0; j < 13 && j < promocion[i].length; j++) {
          controllers[i][j].text = promocion[i][j];
        }
      }

      _asignaturaController.text = datosGuardados['asignatura'] ?? '';
      _gradoController.text = datosGuardados['grado'] ?? '';
      _docenteController.text = datosGuardados['docente'] ?? '';

      // Saltar la carga de calificaciones finales si ya hay datos guardados
    } else {
      // Si no hay datos guardados, cargar solo las calificaciones finales
      // Obtener calificaciones finales del servicio
      final calificaciones = _calificacionesService.obtenerCalificacionesFinales(curso, seccion);

    // Verificar si han pasado 5 días desde la carga
    final hanPasado5Dias = _calificacionesService.hanPasado5Dias(curso, seccion);

    // Cargar las calificaciones en la columna C.F. (columna 0)
    for (int i = 0; i < numRows && i < calificaciones.length; i++) {
      if (calificaciones[i].isNotEmpty) {
        controllers[i][0].text = calificaciones[i];

        // Si han pasado 5 días y C.E.C está vacía, copiar C.F a C.E.C
        if (hanPasado5Dias && controllers[i][2].text.isEmpty) {
          controllers[i][2].text = calificaciones[i];
          // Calcular 50% C.E.C
          double? cf = double.tryParse(calificaciones[i]);
          if (cf != null) {
            double cincuentaPorciento = cf * 0.5;
            controllers[i][3].text = cincuentaPorciento.toStringAsFixed(2);
            _calcularSumaYActualizar(i);
          }
        }

        // Si han pasado 5 días y C.E.EX está vacía, copiar C.C.F a C.E.EX
        if (hanPasado5Dias && controllers[i][6].text.isEmpty && controllers[i][4].text.isNotEmpty) {
          controllers[i][6].text = controllers[i][4].text;
          // Calcular 70% C.E.EX
          double? ccf = double.tryParse(controllers[i][4].text);
          if (ccf != null) {
            double setentaPorciento = ccf * 0.7;
            controllers[i][7].text = setentaPorciento.toStringAsFixed(2);
            _calcularSumaExtraordinaria(i);
          }
        }

        // Si han pasado 35 días y C.F (columna 9 de CALIFICACIONES ESPECIALES) está vacía, copiar C.EX.F a C.F
        final hanPasado35Dias = _calificacionesService.hanPasado35Dias(curso, seccion);
        if (hanPasado35Dias && controllers[i][9].text.isEmpty && controllers[i][8].text.isNotEmpty) {
          controllers[i][9].text = controllers[i][8].text;
        }

        // Si han pasado 3 días y C.E (columna 10 de CALIFICACIONES ESPECIALES) está vacía, copiar C.F
        final hanPasado3Dias = _calificacionesService.hanPasado3Dias(curso, seccion);
        if (hanPasado3Dias && controllers[i][10].text.isEmpty && controllers[i][9].text.isNotEmpty) {
          controllers[i][10].text = controllers[i][9].text;
          // Verificar si C.E < 70 para marcar X en R o ✓ en A
          double? ce = double.tryParse(controllers[i][10].text);
          if (ce != null && ce < 70) {
            controllers[i][11].text = '';
            controllers[i][12].text = 'X';
          } else if (ce != null && ce >= 70) {
            controllers[i][11].text = '✓';
            controllers[i][12].text = '';
          }
        }

        // Si C.F. < 70, calcular y colocar el 50% en la siguiente columna
        double? cf = double.tryParse(calificaciones[i]);
        if (cf != null && cf < 70) {
          double cincuentaPorciento = cf * 0.5;
          controllers[i][1].text = cincuentaPorciento.toStringAsFixed(2);
        } else if (cf != null && cf >= 70) {
          // Marcar ✓ en columna A (columna 11)
          controllers[i][11].text = '✓';
        }
      }
    }
    } // Cierre del else

    // Agregar listeners a todos los controladores para guardado automático
    for (var fila in controllers) {
      for (var controller in fila) {
        controller.addListener(_guardarAutomaticamente);
      }
    }
  }

  void _calcularSumaYActualizar(int row) {
    // Sumar columna "50% C.F" (columna 1) + columna "50% C.C.F" (columna 3)
    // Resultado en columna C.C.F (columna 4)

    String valor1 = controllers[row][1].text;
    String valor3 = controllers[row][3].text;

    double? num1 = double.tryParse(valor1);
    double? num3 = double.tryParse(valor3);

    if (num1 != null && num3 != null) {
      double suma = num1 + num3;
      int redondeado = suma.ceil(); // Redondear hacia arriba
      controllers[row][4].text = redondeado.toString();

      // Si C.C.F >= 70, bloquear columnas extraordinarias y especiales, y marcar A
      if (redondeado >= 70) {
        controllers[row][5].text = '';  // 30% C.F
        controllers[row][6].text = '';  // C.E.EX
        controllers[row][7].text = '';  // 70% C.E.EX
        controllers[row][8].text = '';  // C.EX.F
        controllers[row][9].text = '';  // C.F (CALIFICACIONES ESPECIALES)
        controllers[row][10].text = ''; // C.E (CALIFICACIONES ESPECIALES)
        controllers[row][11].text = '✓'; // Marcar ✓ en columna A
        controllers[row][12].text = ''; // Limpiar columna R
      } else {
        // Si C.C.F < 70, calcular el 30% y colocarlo en la columna "30% C.F" (columna 5)
        double treintaPorciento = redondeado * 0.3;
        controllers[row][5].text = treintaPorciento.toStringAsFixed(2);
        _calcularSumaExtraordinaria(row);
      }
    } else if (num1 != null && num3 == null) {
      int redondeado = num1.ceil(); // Redondear hacia arriba
      controllers[row][4].text = redondeado.toString();

      // Si C.C.F >= 70, bloquear columnas extraordinarias y especiales, y marcar A
      if (redondeado >= 70) {
        controllers[row][5].text = '';  // 30% C.F
        controllers[row][6].text = '';  // C.E.EX
        controllers[row][7].text = '';  // 70% C.E.EX
        controllers[row][8].text = '';  // C.EX.F
        controllers[row][9].text = '';  // C.F (CALIFICACIONES ESPECIALES)
        controllers[row][10].text = ''; // C.E (CALIFICACIONES ESPECIALES)
        controllers[row][11].text = '✓'; // Marcar ✓ en columna A
        controllers[row][12].text = ''; // Limpiar columna R
      } else {
        // Si C.C.F < 70, calcular el 30% y colocarlo en la columna "30% C.F" (columna 5)
        double treintaPorciento = redondeado * 0.3;
        controllers[row][5].text = treintaPorciento.toStringAsFixed(2);
        _calcularSumaExtraordinaria(row);
      }
    } else if (num1 == null && num3 != null) {
      int redondeado = num3.ceil(); // Redondear hacia arriba
      controllers[row][4].text = redondeado.toString();

      // Si C.C.F >= 70, bloquear columnas extraordinarias y especiales, y marcar A
      if (redondeado >= 70) {
        controllers[row][5].text = '';  // 30% C.F
        controllers[row][6].text = '';  // C.E.EX
        controllers[row][7].text = '';  // 70% C.E.EX
        controllers[row][8].text = '';  // C.EX.F
        controllers[row][9].text = '';  // C.F (CALIFICACIONES ESPECIALES)
        controllers[row][10].text = ''; // C.E (CALIFICACIONES ESPECIALES)
        controllers[row][11].text = '✓'; // Marcar ✓ en columna A
        controllers[row][12].text = ''; // Limpiar columna R
      } else {
        // Si C.C.F < 70, calcular el 30% y colocarlo en la columna "30% C.F" (columna 5)
        double treintaPorciento = redondeado * 0.3;
        controllers[row][5].text = treintaPorciento.toStringAsFixed(2);
        _calcularSumaExtraordinaria(row);
      }
    } else {
      controllers[row][4].text = '';
    }
  }

  void _calcularSumaExtraordinaria(int row) {
    // Sumar columna "30% C.F" (columna 5) + columna "70% C.E.EX" (columna 7)
    // Resultado en columna C.EX.F (columna 8)

    String valor5 = controllers[row][5].text;
    String valor7 = controllers[row][7].text;

    double? num5 = double.tryParse(valor5);
    double? num7 = double.tryParse(valor7);

    if (num5 != null && num7 != null) {
      double suma = num5 + num7;
      int redondeado = suma.ceil(); // Redondear hacia arriba
      controllers[row][8].text = redondeado.toString();

      // Si C.EX.F >= 70, bloquear columnas especiales y marcar A
      if (redondeado >= 70) {
        controllers[row][9].text = '';  // C.F (CALIFICACIONES ESPECIALES)
        controllers[row][10].text = ''; // C.E (CALIFICACIONES ESPECIALES)
        controllers[row][11].text = '✓'; // Marcar ✓ en columna A
        controllers[row][12].text = ''; // Limpiar columna R
      }
    } else if (num5 != null && num7 == null) {
      int redondeado = num5.ceil(); // Redondear hacia arriba
      controllers[row][8].text = redondeado.toString();

      // Si C.EX.F >= 70, bloquear columnas especiales y marcar A
      if (redondeado >= 70) {
        controllers[row][9].text = '';  // C.F (CALIFICACIONES ESPECIALES)
        controllers[row][10].text = ''; // C.E (CALIFICACIONES ESPECIALES)
        controllers[row][11].text = '✓'; // Marcar ✓ en columna A
        controllers[row][12].text = ''; // Limpiar columna R
      }
    } else if (num5 == null && num7 != null) {
      int redondeado = num7.ceil(); // Redondear hacia arriba
      controllers[row][8].text = redondeado.toString();

      // Si C.EX.F >= 70, bloquear columnas especiales y marcar A
      if (redondeado >= 70) {
        controllers[row][9].text = '';  // C.F (CALIFICACIONES ESPECIALES)
        controllers[row][10].text = ''; // C.E (CALIFICACIONES ESPECIALES)
        controllers[row][11].text = '✓'; // Marcar ✓ en columna A
        controllers[row][12].text = ''; // Limpiar columna R
      }
    } else {
      controllers[row][8].text = '';
    }
  }

  @override
  void dispose() {
    // Liberar todos los controladores
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    _asignaturaController.dispose();
    _gradoController.dispose();
    _docenteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(curso.toUpperCase()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _verificarCalificacionesIncompletas,
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Verificar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Imprimir/Exportar',
            onPressed: _mostrarOpcionesImpresion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo para el nombre del docente
                Container(
                  width: 930,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade700, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'DOCENTE:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _docenteController,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            isDense: true,
                            hintText: 'Ingrese el nombre del docente',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tabla
                _buildTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade700, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera fila: ASIGNATURA y GRADO
          Row(
            children: [
              Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  border: Border(
                    right: BorderSide(color: Colors.blue.shade900, width: 1),
                    bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'N°',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  border: Border(
                    right: BorderSide(color: Colors.blue.shade900, width: 1),
                    bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                  ),
                ),
              ),
              Container(
                width: 650,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  border: Border(
                    right: BorderSide(color: Colors.blue.shade900, width: 1),
                    bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        'ASIGNATURA:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _asignaturaController,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 4),
                          isDense: true,
                        ),
                        cursorColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 170,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  border: Border(
                    bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        'GRADO:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _gradoController,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 4),
                          isDense: true,
                        ),
                        cursorColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Segunda y tercera fila combinadas
          Stack(
            children: [
              Column(
                children: [
                  // Segunda fila: Encabezados principales
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          border: Border(
                            right: BorderSide(color: Colors.blue.shade900, width: 1),
                            bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          border: Border(
                            right: BorderSide(color: Colors.blue.shade900, width: 1),
                            bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                          ),
                        ),
                      ),
                      Container(
                        width: 260,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          border: Border(
                            right: BorderSide(color: Colors.blue.shade900, width: 1),
                            bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'CALIFICACION\nCOMPLETIVA',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        width: 260,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          border: Border(
                            right: BorderSide(color: Colors.blue.shade900, width: 1),
                            bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'CALIFICACIONES\nEXTRAORDINARIA',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        width: 130,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          border: Border(
                            right: BorderSide(color: Colors.blue.shade900, width: 1),
                            bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'CALIFICAC\nIONES\nESPECIAL\nES',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, height: 1.1, color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        width: 170,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          border: Border(
                            bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'SITUACION\nFINAL EN\nLA\nASIGNATURA',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, height: 1.1, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Tercera fila: Subencabezados
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          border: Border(
                            right: BorderSide(color: Colors.blue.shade900, width: 1),
                            bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          border: Border(
                            right: BorderSide(color: Colors.blue.shade900, width: 1),
                            bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                          ),
                        ),
                      ),
                      _buildSubHeader('50%\nC.F', 65),
                      _buildSubHeader('C.E.C', 65),
                      _buildSubHeader('50%\nC.E.C', 65),
                      _buildSubHeader('C.C.F', 65),
                      _buildSubHeader('30%\nC.F', 65),
                      _buildSubHeader('C.\nE.E.X', 65),
                      _buildSubHeader('70%\nC.E.E\nX', 65),
                      _buildSubHeader('C.\nEX.F', 65),
                      _buildSubHeader('C.F', 65),
                      _buildSubHeader('C.E', 65),
                      _buildSubHeader('A', 85),
                      _buildSubHeader('R', 85),
                    ],
                  ),
                ],
              ),
              // N° superpuesto que ocupa ambas filas
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 50,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    border: Border(
                      right: BorderSide(color: Colors.blue.shade900, width: 1),
                      bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                    ),
                  ),
                ),
              ),
              // C.F. superpuesto que ocupa ambas filas
              Positioned(
                left: 50,
                top: 0,
                child: Container(
                  width: 60,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    border: Border(
                      right: BorderSide(color: Colors.blue.shade900, width: 1),
                      bottom: BorderSide(color: Colors.blue.shade900, width: 1),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'C.F.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Filas de datos
          ...List.generate(
            numRows,
            (index) => Row(
              children: [
                _buildNumberCell(index + 1, 50),
                _buildDataCell(index, 0, 60),
                _buildDataCell(index, 1, 65),
                _buildDataCell(index, 2, 65),
                _buildDataCell(index, 3, 65),
                _buildDataCell(index, 4, 65),
                _buildDataCell(index, 5, 65),
                _buildDataCell(index, 6, 65),
                _buildDataCell(index, 7, 65),
                _buildDataCell(index, 8, 65),
                _buildDataCell(index, 9, 65),
                _buildDataCell(index, 10, 65),
                _buildDataCell(index, 11, 85),
                _buildDataCell(index, 12, 85),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader(String text, double width) {
    return Container(
      width: width,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        border: Border(
          right: BorderSide(color: Colors.blue.shade900, width: 1),
          bottom: BorderSide(color: Colors.blue.shade900, width: 1),
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, height: 1.1, color: Colors.blue.shade900),
        ),
      ),
    );
  }

  Widget _buildNumberCell(int number, double width) {
    final isEvenRow = (number - 1) % 2 == 0;
    final backgroundColor = Colors.grey.shade300;

    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.blue.shade300, width: 1),
          bottom: BorderSide(color: Colors.blue.shade300, width: 1),
        ),
        color: backgroundColor,
      ),
      child: Center(
        child: Text(
          number.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue.shade900),
        ),
      ),
    );
  }

  Widget _buildDataCell(int row, int col, double width) {
    final isEvenRow = row % 2 == 0;

    // Verificar si C.F. >= 70 para bloquear columnas 1-10
    // Verificar si C.C.F >= 70 para bloquear columnas 5-10 (extraordinarias y especiales)
    // Columnas: 1=50% C.F, 2=C.E.C, 3=50% C.E.C, 4=C.C.F,
    //           5=30% C.F, 6=C.E.EX, 7=70% C.E.EX, 8=C.EX.F,
    //           9=C.F (CALIFICACIONES ESPECIALES), 10=C.E (CALIFICACIONES ESPECIALES)
    bool bloqueada = false;
    Color backgroundColor = isEvenRow ? Colors.white : Colors.blue.shade50;

    // Si C.F. >= 70, bloquear todas las columnas de recuperación (1-10)
    if (col >= 1 && col <= 10) {
      String cfValue = controllers[row][0].text;
      double? cf = double.tryParse(cfValue);
      if (cf != null && cf >= 70) {
        bloqueada = true;
        backgroundColor = Colors.grey.shade300;
      }
    }

    // Si C.C.F >= 70, bloquear columnas extraordinarias y especiales (5-10)
    if (col >= 5 && col <= 10 && !bloqueada) {
      String ccfValue = controllers[row][4].text;
      double? ccf = double.tryParse(ccfValue);
      if (ccf != null && ccf >= 70) {
        bloqueada = true;
        backgroundColor = Colors.grey.shade300;
      }
    }

    // Si C.EX.F >= 70, bloquear columnas especiales (9-10)
    if (col >= 9 && col <= 10 && !bloqueada) {
      String cexfValue = controllers[row][8].text;
      double? cexf = double.tryParse(cexfValue);
      if (cexf != null && cexf >= 70) {
        bloqueada = true;
        backgroundColor = Colors.grey.shade300;
      }
    }

    // Bloquear columnas calculadas automáticamente
    // Columna "50% C.F" (columna 1), "50% C.E.C" (columna 3), "30% C.F" (columna 5), "70% C.E.E.X" (columna 7)
    // Columna "A" (columna 11), Columna "R" (columna 12)
    if (col == 1 || col == 3 || col == 5 || col == 7 || col == 11 || col == 12) {
      bloqueada = true;
      backgroundColor = Colors.grey.shade200;
    }

    // Determinar color del texto para columnas A (11) y R (12)
    Color textColor = Colors.black;
    if (col == 11 && controllers[row][col].text == '✓') {
      textColor = Colors.green;
    } else if (col == 12 && controllers[row][col].text == 'X') {
      textColor = Colors.red;
    } else if (bloqueada) {
      textColor = Colors.grey.shade600;
    }

    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.blue.shade300, width: 1),
          bottom: BorderSide(color: Colors.blue.shade300, width: 1),
        ),
        color: backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: TextField(
          controller: col < 13 ? controllers[row][col] : null,
          enabled: !bloqueada,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: col == 11 || col == 12 ? 16 : 11,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            filled: false,
          ),
          cursorColor: Colors.black,
          keyboardType: col == 11 || col == 12 ? TextInputType.text : TextInputType.number,
          onChanged: (value) {
            // Si es la columna C.F. (columna 0), calcular y actualizar el 50%
            if (col == 0 && value.isNotEmpty) {
              double? cf = double.tryParse(value);
              if (cf != null && cf < 70) {
                double cincuentaPorciento = cf * 0.5;
                controllers[row][1].text = cincuentaPorciento.toStringAsFixed(2);
                _calcularSumaYActualizar(row);
                setState(() {});
              } else if (cf != null && cf >= 70) {
                // Si C.F. >= 70, limpiar las columnas bloqueadas
                controllers[row][1].text = '';  // 50% C.F
                controllers[row][2].text = '';  // C.E.C
                controllers[row][3].text = '';  // 50% C.E.C
                controllers[row][4].text = '';  // C.C.F
                controllers[row][5].text = '';  // 30% C.F
                controllers[row][6].text = '';  // C.E.EX
                controllers[row][7].text = '';  // 70% C.E.EX
                controllers[row][8].text = '';  // C.EX.F
                controllers[row][9].text = '';  // C.F (CALIFICACIONES ESPECIALES)
                controllers[row][10].text = ''; // C.E (CALIFICACIONES ESPECIALES)
                // Marcar ✓ verde en columna A (columna 11)
                controllers[row][11].text = '✓'; // Marcar ✓ en columna A
                controllers[row][12].text = ''; // Limpiar columna R
                setState(() {});
              }
            }

            // Si es la columna C.E (columna 10), verificar si < 70 para marcar X en R
            if (col == 10 && value.isNotEmpty) {
              double? ce = double.tryParse(value);
              if (ce != null && ce < 70) {
                // Marcar X roja en columna R (columna 12)
                controllers[row][11].text = ''; // Limpiar columna A
                controllers[row][12].text = 'X'; // Marcar X en columna R
                setState(() {});
              } else if (ce != null && ce >= 70) {
                // Marcar ✓ verde en columna A (columna 11)
                controllers[row][11].text = '✓'; // Marcar ✓ en columna A
                controllers[row][12].text = ''; // Limpiar columna R
                setState(() {});
              }
            } else if (col == 10 && value.isEmpty) {
              // Si se borra C.E, limpiar A y R
              controllers[row][11].text = '';
              controllers[row][12].text = '';
              setState(() {});
            }

            // Si es la columna C.E.C (columna 2), calcular y actualizar el 50% en la columna "50% C.C.F" (columna 3)
            if (col == 2 && value.isNotEmpty) {
              double? cec = double.tryParse(value);
              if (cec != null) {
                double cincuentaPorciento = cec * 0.5;
                controllers[row][3].text = cincuentaPorciento.toStringAsFixed(2);
                _calcularSumaYActualizar(row);
                setState(() {});
              }
            } else if (col == 2 && value.isEmpty) {
              // Si se borra C.E.C, limpiar la columna 50% C.C.F
              controllers[row][3].text = '';
              _calcularSumaYActualizar(row);
              setState(() {});
            }

            // Si es la columna C.E.EX (columna 6), calcular y actualizar el 70% en la columna "70% C.E.EX" (columna 7)
            if (col == 6 && value.isNotEmpty) {
              double? ceex = double.tryParse(value);
              if (ceex != null) {
                double setentaPorciento = ceex * 0.7;
                controllers[row][7].text = setentaPorciento.toStringAsFixed(2);
                _calcularSumaExtraordinaria(row);
                setState(() {});
              }
            } else if (col == 6 && value.isEmpty) {
              // Si se borra C.E.EX, limpiar la columna 70% C.E.EX
              controllers[row][7].text = '';
              _calcularSumaExtraordinaria(row);
              setState(() {});
            }

            // Recalcular suma cuando cambia la columna 50% C.F (columna 1)
            if (col == 1) {
              _calcularSumaYActualizar(row);
            }
          },
        ),
      ),
    );
  }
}
