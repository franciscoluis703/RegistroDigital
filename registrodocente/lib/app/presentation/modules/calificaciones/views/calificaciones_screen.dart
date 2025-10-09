import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../data/services/calificaciones_service.dart';
import '../../../../data/services/curso_context_service.dart';
import '../../../widgets/estudiante_nombre_widget.dart';

class CalificacionesScreen extends StatefulWidget {
  const CalificacionesScreen({super.key});

  @override
  State<CalificacionesScreen> createState() => _CalificacionesScreenState();
}

class _CalificacionesScreenState extends State<CalificacionesScreen> {
  // Datos independientes para cada grupo (8 columnas por grupo: P1, RP1, P2, RP2, P3, RP3, P4, RP4)
  List<List<String>> notasGrupo1 = List.generate(40, (_) => List.generate(8, (_) => ''));
  List<List<String>> notasGrupo2 = List.generate(40, (_) => List.generate(8, (_) => ''));
  List<List<String>> notasGrupo3 = List.generate(40, (_) => List.generate(8, (_) => ''));
  List<List<String>> notasGrupo4 = List.generate(40, (_) => List.generate(8, (_) => ''));

  int paginaActual = 0; // 0 = Grupos 1 y 2, 1 = Grupos 3 y 4 + Promedios

  final _calificacionesService = CalificacionesService();
  final _cursoContext = CursoContextService();
  bool _datosInicializados = false;

  // Nombres personalizados de los grupos
  String nombreGrupo1 = 'GRUPO 1:';
  String nombreGrupo2 = 'GRUPO 2:';
  String nombreGrupo3 = 'GRUPO 3';
  String nombreGrupo4 = 'GRUPO 4';

  // Editar nombre de grupo
  void _editarNombreGrupo(int numeroGrupo) {
    String nombreActual = '';
    switch (numeroGrupo) {
      case 1:
        nombreActual = nombreGrupo1;
        break;
      case 2:
        nombreActual = nombreGrupo2;
        break;
      case 3:
        nombreActual = nombreGrupo3;
        break;
      case 4:
        nombreActual = nombreGrupo4;
        break;
    }

    final controller = TextEditingController(text: nombreActual);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar nombre del Grupo $numeroGrupo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre del grupo',
              hintText: 'Ej: Comunicativa, Pensamiento lógico...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  switch (numeroGrupo) {
                    case 1:
                      nombreGrupo1 = controller.text;
                      break;
                    case 2:
                      nombreGrupo2 = controller.text;
                      break;
                    case 3:
                      nombreGrupo3 = controller.text;
                      break;
                    case 4:
                      nombreGrupo4 = controller.text;
                      break;
                  }
                });
                _guardarNombresGrupos(context);
                controller.dispose();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Verificar calificaciones incompletas
  void _verificarCalificacionesIncompletas() {
    List<String> advertencias = [];

    for (int i = 0; i < 40; i++) {
      int numeroEstudiante = i + 1;

      // Verificar cada grupo
      for (int grupo = 0; grupo < 4; grupo++) {
        List<List<String>> datosGrupo;
        String nombreGrupo;

        switch (grupo) {
          case 0:
            datosGrupo = notasGrupo1;
            nombreGrupo = 'Grupo 1';
            break;
          case 1:
            datosGrupo = notasGrupo2;
            nombreGrupo = 'Grupo 2';
            break;
          case 2:
            datosGrupo = notasGrupo3;
            nombreGrupo = 'Grupo 3';
            break;
          case 3:
            datosGrupo = notasGrupo4;
            nombreGrupo = 'Grupo 4';
            break;
          default:
            continue;
        }

        // Verificar si hay alguna calificación en este grupo para este estudiante
        bool tieneCalificaciones = false;
        for (int col = 0; col < 8; col++) {
          if (datosGrupo[i][col].isNotEmpty) {
            tieneCalificaciones = true;
            break;
          }
        }

        if (tieneCalificaciones) {
          // Verificar cada par P/RP de forma secuencial
          for (int p = 0; p < 4; p++) {
            int colP = p * 2;  // 0, 2, 4, 6
            int colRP = colP + 1; // 1, 3, 5, 7
            String nombreP = 'P${p + 1}';
            String nombreRP = 'RP${p + 1}';

            String valorP = datosGrupo[i][colP];
            String valorRP = datosGrupo[i][colRP];

            // Si P está vacía, solo advertir y no seguir con los siguientes períodos
            if (valorP.isEmpty) {
              advertencias.add('Estudiante #$numeroEstudiante - $nombreGrupo: Falta calificación $nombreP');
              // No verificar más períodos para este estudiante en este grupo
              break;
            }

            // Si P < 70 y RP está vacía
            double? notaP = double.tryParse(valorP);
            if (notaP != null && notaP < 70 && valorRP.isEmpty) {
              advertencias.add('Estudiante #$numeroEstudiante - $nombreGrupo: Falta recuperación $nombreRP ($nombreP = $valorP < 70)');
            }
          }
        }
      }
    }

    if (advertencias.isNotEmpty) {
      _mostrarDialogoAdvertencias(advertencias);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ No hay calificaciones incompletas'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _mostrarDialogoAdvertencias(List<String> advertencias) {
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
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Se encontraron ${advertencias.length} advertencia(s):',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Expanded(
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
              ],
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

  // Calcular promedio de un grupo (wrapper para _calcularPC)
  String _calcularPromedioGrupo(List<String> notasGrupo) {
    // Determinar qué grupo es basándose en la referencia
    int grupoIndex = 0;
    if (identical(notasGrupo, notasGrupo1.isNotEmpty ? notasGrupo1[0] : null)) {
      grupoIndex = 0;
    } else if (identical(notasGrupo, notasGrupo2.isNotEmpty ? notasGrupo2[0] : null)) {
      grupoIndex = 1;
    } else if (identical(notasGrupo, notasGrupo3.isNotEmpty ? notasGrupo3[0] : null)) {
      grupoIndex = 2;
    } else if (identical(notasGrupo, notasGrupo4.isNotEmpty ? notasGrupo4[0] : null)) {
      grupoIndex = 3;
    }

    // Encontrar el índice de fila
    int filaIndex = -1;
    if (grupoIndex == 0) {
      filaIndex = notasGrupo1.indexOf(notasGrupo);
    } else if (grupoIndex == 1) {
      filaIndex = notasGrupo2.indexOf(notasGrupo);
    } else if (grupoIndex == 2) {
      filaIndex = notasGrupo3.indexOf(notasGrupo);
    } else if (grupoIndex == 3) {
      filaIndex = notasGrupo4.indexOf(notasGrupo);
    }

    if (filaIndex < 0) return '';

    return _calcularPC(filaIndex, grupoIndex);
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
                subtitle: const Text('Enviar a impresora (ambas páginas)'),
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

  // Generar PDF con ambas páginas
  Future<pw.Document> _generarPDF(String curso, String seccion) async {
    final pdf = pw.Document();

    // Página 1: Grupos 1 y 2
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CALIFICACIONES DE RENDIMIENTO - $curso - Sección $seccion',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Página 1: Grupos 1 y 2', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 8),
              _construirTablaPDF([notasGrupo1, notasGrupo2], ['Grupo 1', 'Grupo 2']),
            ],
          );
        },
      ),
    );

    // Página 2: Grupos 3 y 4 + Promedios
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CALIFICACIONES DE RENDIMIENTO - $curso - Sección $seccion',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Página 2: Grupos 3, 4 y Promedios', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 8),
              _construirTablaPDFConPromedios([notasGrupo3, notasGrupo4], ['Grupo 3', 'Grupo 4']),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _construirTablaPDF(List<List<List<String>>> grupos, List<String> nombresGrupos) {
    final List<List<String>> datos = [];

    // Encabezados
    List<String> encabezado = ['N°'];
    for (var nombre in nombresGrupos) {
      encabezado.addAll(['P1', 'RP1', 'P2', 'RP2', 'P3', 'RP3', 'P4', 'RP4']);
    }
    datos.add(encabezado);

    // Datos de estudiantes
    for (int i = 0; i < 40; i++) {
      List<String> fila = [(i + 1).toString()];
      for (var grupo in grupos) {
        fila.addAll(grupo[i]);
      }
      datos.add(fila);
    }

    return pw.Table.fromTextArray(
      data: datos,
      cellStyle: const pw.TextStyle(fontSize: 7),
      headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.center,
    );
  }

  pw.Widget _construirTablaPDFConPromedios(List<List<List<String>>> grupos, List<String> nombresGrupos) {
    final List<List<String>> datos = [];

    // Encabezados
    List<String> encabezado = ['N°'];
    for (var nombre in nombresGrupos) {
      encabezado.addAll(['P1', 'RP1', 'P2', 'RP2', 'P3', 'RP3', 'P4', 'RP4']);
    }
    encabezado.addAll(['PP1', 'PP2', 'PP3', 'PP4', 'C.F.']);
    datos.add(encabezado);

    // Datos de estudiantes
    for (int i = 0; i < 40; i++) {
      List<String> fila = [(i + 1).toString()];
      for (var grupo in grupos) {
        fila.addAll(grupo[i]);
      }
      // Agregar promedios
      fila.add(_calcularPromedioGrupo(notasGrupo1[i]));
      fila.add(_calcularPromedioGrupo(notasGrupo2[i]));
      fila.add(_calcularPromedioGrupo(notasGrupo3[i]));
      fila.add(_calcularPromedioGrupo(notasGrupo4[i]));
      fila.add(_calcularCalificacionFinal(i));
      datos.add(fila);
    }

    return pw.Table.fromTextArray(
      data: datos,
      cellStyle: const pw.TextStyle(fontSize: 6),
      headerStyle: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.center,
    );
  }

  // Imprimir PDF
  Future<void> _imprimirPDF() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';
    final seccion = args?['seccion'] ?? 'A';

    final pdf = await _generarPDF(curso, seccion);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Exportar PDF
  Future<void> _exportarPDF() async {
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';
      final seccion = args?['seccion'] ?? 'A';

      final pdf = await _generarPDF(curso, seccion);
      final bytes = await pdf.save();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/calificaciones_${DateTime.now().millisecondsSinceEpoch}.pdf');
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
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';
      final seccion = args?['seccion'] ?? 'A';

      final List<List<String>> datos = [];

      // Información general
      datos.add(['CALIFICACIONES DE RENDIMIENTO']);
      datos.add(['Curso', curso]);
      datos.add(['Sección', seccion]);
      datos.add([]);

      // Encabezados completos
      List<String> encabezado = ['N°'];
      encabezado.addAll(['G1-P1', 'G1-RP1', 'G1-P2', 'G1-RP2', 'G1-P3', 'G1-RP3', 'G1-P4', 'G1-RP4']);
      encabezado.addAll(['G2-P1', 'G2-RP1', 'G2-P2', 'G2-RP2', 'G2-P3', 'G2-RP3', 'G2-P4', 'G2-RP4']);
      encabezado.addAll(['G3-P1', 'G3-RP1', 'G3-P2', 'G3-RP2', 'G3-P3', 'G3-RP3', 'G3-P4', 'G3-RP4']);
      encabezado.addAll(['G4-P1', 'G4-RP1', 'G4-P2', 'G4-RP2', 'G4-P3', 'G4-RP3', 'G4-P4', 'G4-RP4']);
      encabezado.addAll(['PP1', 'PP2', 'PP3', 'PP4', 'C.F.']);
      datos.add(encabezado);

      // Datos de estudiantes
      for (int i = 0; i < 40; i++) {
        List<String> fila = [(i + 1).toString()];
        fila.addAll(notasGrupo1[i]);
        fila.addAll(notasGrupo2[i]);
        fila.addAll(notasGrupo3[i]);
        fila.addAll(notasGrupo4[i]);
        fila.add(_calcularPromedioGrupo(notasGrupo1[i]));
        fila.add(_calcularPromedioGrupo(notasGrupo2[i]));
        fila.add(_calcularPromedioGrupo(notasGrupo3[i]));
        fila.add(_calcularPromedioGrupo(notasGrupo4[i]));
        fila.add(_calcularCalificacionFinal(i));
        datos.add(fila);
      }

      final csv = const ListToCsvConverter().convert(datos);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/calificaciones_${DateTime.now().millisecondsSinceEpoch}.csv');
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
  Widget build(BuildContext context) {
    // Cargar notas guardadas si aún no se han cargado
    if (!_datosInicializados) {
      _cargarNotasGuardadas(context);
    }

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';
    final seccion = args?['seccion'] ?? 'A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('$curso - Sección $seccion'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
            onPressed: () => _guardarAutomaticamente(context),
          ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!, width: 1),
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Encabezado con materia y grado
                        _buildEncabezadoPrincipal(curso),
                        // Sección de competencias con grupos
                        paginaActual == 0
                          ? _buildSeccionCompetencias()
                          : _buildSeccionCompetenciasPagina2(),
                        // Tabla de calificaciones
                        paginaActual == 0
                          ? _buildTablaCalificacionesPagina1()
                          : _buildTablaCalificacionesPagina2(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Botones de navegación
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (paginaActual == 1)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        paginaActual = 0;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Anterior'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  )
                else
                  const SizedBox(),
                if (paginaActual == 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        paginaActual = 1;
                      });
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Siguiente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  )
                else
                  const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezadoPrincipal(String materia) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
              ),
              child: Text(
                'MATERIA: $materia',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'GRADO:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionCompetencias() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta COMPETENCIAS (vertical)
          Container(
            width: 45,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              border: Border(
                right: BorderSide(color: Colors.grey[400]!, width: 1),
              ),
            ),
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: const Text(
                  'COMPETENCIAS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          // GRUPO 1
          Expanded(
            child: GestureDetector(
              onTap: () => _editarNombreGrupo(1),
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombreGrupo1,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // GRUPO 2
          Expanded(
            child: GestureDetector(
              onTap: () => _editarNombreGrupo(2),
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombreGrupo2,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                      ],
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

  Widget _buildSeccionCompetenciasPagina2() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta COMPETENCIAS (vertical)
          Container(
            width: 45,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              border: Border(
                right: BorderSide(color: Colors.grey[400]!, width: 1),
              ),
            ),
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: const Text(
                  'COMPETENCIAS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          // GRUPO 3
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _editarNombreGrupo(3),
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombreGrupo3,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // GRUPO 4
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _editarNombreGrupo(4),
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombreGrupo4,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Promedio de Competencias Específicas
          Expanded(
            flex: 1,
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Promedio de Competencias Específicas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablaCalificacionesPagina1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Encabezados de columnas
        _buildEncabezadosColumnas(),
        // Filas de estudiantes
        ...List.generate(40, (index) => _buildFilaEstudiantePagina1(index + 1)),
      ],
    );
  }

  Widget _buildTablaCalificacionesPagina2() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Encabezados de columnas para página 2
        _buildEncabezadosColumnasPagina2(),
        // Filas de estudiantes
        ...List.generate(40, (index) => _buildFilaEstudiantePagina2(index + 1)),
      ],
    );
  }

  Widget _buildEncabezadosColumnas() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('', 45, true),
          // Grupo 1
          _buildHeaderCell('P1', 60, false),
          _buildHeaderCell('RP1', 60, false),
          _buildHeaderCell('P2', 60, false),
          _buildHeaderCell('RP2', 60, false),
          _buildHeaderCell('P3', 60, false),
          _buildHeaderCell('RP3', 60, false),
          _buildHeaderCell('P4', 60, false),
          _buildHeaderCell('RP4', 60, false),
          // Grupo 2
          _buildHeaderCell('P1', 60, false),
          _buildHeaderCell('RP1', 60, false),
          _buildHeaderCell('P2', 60, false),
          _buildHeaderCell('RP2', 60, false),
          _buildHeaderCell('P3', 60, false),
          _buildHeaderCell('RP3', 60, false),
          _buildHeaderCell('P4', 60, false),
          _buildHeaderCell('RP4', 60, false),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width, bool isFirst) {
    return Container(
      width: width,
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          left: isFirst ? BorderSide.none : BorderSide(color: Colors.grey[400]!, width: 1),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEncabezadosColumnasPagina2() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('', 45, true),
          // Grupo 3
          _buildHeaderCell('P1', 60, false),
          _buildHeaderCell('RP1', 60, false),
          _buildHeaderCell('P2', 60, false),
          _buildHeaderCell('RP2', 60, false),
          _buildHeaderCell('P3', 60, false),
          _buildHeaderCell('RP3', 60, false),
          _buildHeaderCell('P4', 60, false),
          _buildHeaderCell('RP4', 60, false),
          // Grupo 4
          _buildHeaderCell('P1', 60, false),
          _buildHeaderCell('RP1', 60, false),
          _buildHeaderCell('P2', 60, false),
          _buildHeaderCell('RP2', 60, false),
          _buildHeaderCell('P3', 60, false),
          _buildHeaderCell('RP3', 60, false),
          _buildHeaderCell('P4', 60, false),
          _buildHeaderCell('RP4', 60, false),
          // Promedios
          _buildHeaderCellVertical('PC1 COMP.', 50, false),
          _buildHeaderCellVertical('PC2 COMP.', 50, false),
          _buildHeaderCellVertical('PC3 COMP.', 50, false),
          _buildHeaderCellVertical('PC4 COMP.', 50, false),
          _buildHeaderCellVertical('CALIFICACIÓN FINAL', 80, false),
        ],
      ),
    );
  }

  Widget _buildHeaderCellVertical(String text, double width, bool isFirst) {
    return Container(
      width: width,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          left: isFirst ? BorderSide.none : BorderSide(color: Colors.grey[400]!, width: 1),
        ),
      ),
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          text.replaceAll('\n', ' '),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFilaEstudiantePagina1(int numero) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildNumeroCell(numero),
          // Grupo 1 (8 columnas)
          ...List.generate(8, (colIndex) => _buildEditableCell(numero - 1, colIndex, notasGrupo1)),
          // Grupo 2 (8 columnas)
          ...List.generate(8, (colIndex) => _buildEditableCell(numero - 1, colIndex, notasGrupo2)),
        ],
      ),
    );
  }

  Widget _buildFilaEstudiantePagina2(int numero) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildNumeroCell(numero),
          // Grupo 3 (8 columnas)
          ...List.generate(8, (colIndex) => _buildEditableCell(numero - 1, colIndex, notasGrupo3)),
          // Grupo 4 (8 columnas)
          ...List.generate(8, (colIndex) => _buildEditableCell(numero - 1, colIndex, notasGrupo4)),
          // Promedios (5 columnas: PC1, PC2, PC3, PC4, CALIFICACIÓN FINAL)
          ...List.generate(5, (colIndex) => _buildPromedioCell(numero - 1, colIndex)),
        ],
      ),
    );
  }

  String _calcularPC(int fila, int grupoIndex) {
    // grupoIndex: 0=PC1(Grupo1), 1=PC2(Grupo2), 2=PC3(Grupo3), 3=PC4(Grupo4)
    List<List<String>> datos;

    // Seleccionar el grupo correcto - cada PC usa su propio grupo
    switch (grupoIndex) {
      case 0:
        datos = notasGrupo1; // PC1 usa datos del Grupo 1
        break;
      case 1:
        datos = notasGrupo2; // PC2 usa datos del Grupo 2
        break;
      case 2:
        datos = notasGrupo3; // PC3 usa datos del Grupo 3
        break;
      case 3:
        datos = notasGrupo4; // PC4 usa datos del Grupo 4
        break;
      default:
        return '';
    }

    // Lógica: Si P < 70, usar RP; si P >= 70, usar P
    // P1(0)/RP1(1), P2(2)/RP2(3), P3(4)/RP3(5), P4(6)/RP4(7)
    List<int> indicesP = [0, 2, 4, 6];
    List<int> indicesRP = [1, 3, 5, 7];

    List<double> valores = [];

    for (int i = 0; i < 4; i++) {
      int indiceP = indicesP[i];
      int indiceRP = indicesRP[i];

      String valorP = datos[fila][indiceP];
      String valorRP = datos[fila][indiceRP];

      double? notaP = double.tryParse(valorP);
      double? notaRP = double.tryParse(valorRP);

      // Si P < 70 y existe RP, usar RP; de lo contrario usar P
      if (notaP != null) {
        if (notaP < 70 && notaRP != null) {
          valores.add(notaRP);
        } else {
          valores.add(notaP);
        }
      }
    }

    if (valores.length != 4) return ''; // Solo calcular si hay 4 valores
    double promedio = valores.reduce((a, b) => a + b) / 4;
    return promedio.toStringAsFixed(2);
  }

  String _calcularCalificacionFinal(int fila) {
    // C.F. = (PC1+PC2+PC3+PC4)/4
    List<double> valores = [];

    for (int i = 0; i < 4; i++) {
      String pc = _calcularPC(fila, i);
      if (pc.isNotEmpty) {
        double? num = double.tryParse(pc);
        if (num != null) {
          valores.add(num);
        }
      }
    }

    if (valores.length != 4) return ''; // Solo calcular si hay 4 PC
    double promedio = valores.reduce((a, b) => a + b) / 4;
    // Redondeo normal
    int calificacionFinal = promedio.round();
    return calificacionFinal.toString();
  }

  Future<void> _actualizarCalificacionesEnServicio(BuildContext context) async {
    // Obtener cursoId desde CursoContextService (igual que promocion_grado_screen)
    final cursoId = await _cursoContext.obtenerCursoActual() ?? 'default';

    print('🔍 GUARDANDO CALIFICACIONES FINALES con cursoId: $cursoId');

    // Calcular todas las calificaciones finales
    List<String> calificacionesFinales = [];
    for (int i = 0; i < 40; i++) {
      final cf = _calcularCalificacionFinal(i);
      if (cf.isNotEmpty) {
        calificacionesFinales.add(cf);
        print('   Estudiante $i: CF = $cf');
      } else {
        calificacionesFinales.add('');
      }
    }

    // Guardar usando el cursoId (sin seccion) para que coincida con promocion_grado_screen
    await _calificacionesService.guardarCalificacionesFinales(cursoId, '', calificacionesFinales);
    print('✅ Calificaciones guardadas con key: calificaciones_finales_${cursoId}_');
  }

  // Guardar nombres de grupos
  Future<void> _guardarNombresGrupos(BuildContext context) async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';
    final seccion = args?['seccion'] ?? 'A';

    await _calificacionesService.guardarNombresGrupos(
      curso: curso,
      seccion: seccion,
      nombreGrupo1: nombreGrupo1,
      nombreGrupo2: nombreGrupo2,
      nombreGrupo3: nombreGrupo3,
      nombreGrupo4: nombreGrupo4,
    );
  }

  // Cargar nombres de grupos
  Future<void> _cargarNombresGrupos(String curso, String seccion) async {
    final nombres = await _calificacionesService.obtenerNombresGrupos(
      curso: curso,
      seccion: seccion,
    );

    if (nombres != null && mounted) {
      setState(() {
        nombreGrupo1 = nombres['grupo1'] ?? 'GRUPO 1:';
        nombreGrupo2 = nombres['grupo2'] ?? 'GRUPO 2:';
        nombreGrupo3 = nombres['grupo3'] ?? 'GRUPO 3';
        nombreGrupo4 = nombres['grupo4'] ?? 'GRUPO 4';
      });
    }
  }

  // Guardar automáticamente todas las notas
  Future<void> _guardarAutomaticamente(BuildContext context) async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';
    final seccion = args?['seccion'] ?? 'A';

    await _calificacionesService.guardarNotasGrupos(
      curso: curso,
      seccion: seccion,
      notasGrupo1: notasGrupo1,
      notasGrupo2: notasGrupo2,
      notasGrupo3: notasGrupo3,
      notasGrupo4: notasGrupo4,
    );

    // También guardar las calificaciones finales
    if (context.mounted) {
      await _actualizarCalificacionesEnServicio(context);
    }
  }

  // Cargar notas guardadas
  Future<void> _cargarNotasGuardadas(BuildContext context) async {
    if (_datosInicializados) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'LENGUA ESPAÑOLA';
    final seccion = args?['seccion'] ?? 'A';

    final datos = await _calificacionesService.obtenerNotasGrupos(
      curso: curso,
      seccion: seccion,
    );

    if (datos != null) {
      setState(() {
        notasGrupo1 = datos['grupo1'] as List<List<String>>;
        notasGrupo2 = datos['grupo2'] as List<List<String>>;
        notasGrupo3 = datos['grupo3'] as List<List<String>>;
        notasGrupo4 = datos['grupo4'] as List<List<String>>;
        _datosInicializados = true;
      });
    } else {
      setState(() {
        _datosInicializados = true;
      });
    }

    // Cargar nombres de grupos
    await _cargarNombresGrupos(curso, seccion);
  }

  Widget _buildPromedioCell(int fila, int colIndex) {
    double width = colIndex == 4 ? 80.0 : 50.0; // CALIFICACIÓN FINAL es más ancha

    // Calcular valor automáticamente
    String valorCalculado = '';
    if (colIndex < 4) {
      valorCalculado = _calcularPC(fila, colIndex);
    } else {
      valorCalculado = _calcularCalificacionFinal(fila);
    }

    return Container(
      width: width,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Color gris claro para celdas calculadas
        border: Border(
          left: BorderSide(color: Colors.grey[400]!, width: 1),
          bottom: BorderSide(color: Colors.grey[400]!, width: 0.5),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: Text(
        valorCalculado,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNumeroCell(int numero) {
    return SizedBox(
      width: 45,
      height: 32,
      child: EstudianteNombreWidget(
        numero: numero,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey[400]!, width: 1),
          ),
          color: Colors.grey[300],
        ),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEditableCell(int fila, int colIndex, List<List<String>> datos) {
    // Determinar si es columna P (0, 2, 4, 6)
    bool esColumnaP = colIndex % 2 == 0;

    // Verificar si es una columna RP y si la P correspondiente es >= 70
    bool esColumnaRP = !esColumnaP;
    bool bloqueada = false;

    if (esColumnaRP) {
      // Determinar la columna P correspondiente
      int columnaP = colIndex - 1; // RP1(1) -> P1(0), RP2(3) -> P2(2), etc.
      String valorP = datos[fila][columnaP];
      double? notaP = double.tryParse(valorP);

      if (notaP != null && notaP >= 70) {
        bloqueada = true;
      }
    }

    // Crear un controller con el valor actual
    final controller = TextEditingController(text: datos[fila][colIndex]);

    // Colocar el cursor al final del texto
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Container(
      width: 60,
      height: 32,
      decoration: BoxDecoration(
        color: bloqueada
          ? Colors.grey[400]
          : (esColumnaP ? const Color(0xFFE0E0E0) : Colors.white),
        border: Border(
          left: BorderSide(color: Colors.grey[400]!, width: 1),
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: !bloqueada,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 11,
          color: bloqueada ? Colors.grey[600] : Colors.black87,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        ),
        onChanged: (value) {
          // Verificar que el P anterior esté lleno (solo para columnas P)
          if (esColumnaP && colIndex > 0) {
            int colAnterior = colIndex - 2; // P anterior
            if (colAnterior >= 0 && datos[fila][colAnterior].isEmpty) {
              String periodoActual = 'P${(colIndex ~/ 2) + 1}';
              String periodoAnterior = 'P${(colAnterior ~/ 2) + 1}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Debe completar $periodoAnterior antes de llenar $periodoActual'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
              controller.text = datos[fila][colIndex];
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
              return;
            }
          }

          // Validar que el valor esté entre 0 y 100
          if (value.isEmpty) {
            datos[fila][colIndex] = value;
            setState(() {});
            return;
          }

          double? numero = double.tryParse(value);
          if (numero != null) {
            if (numero < 0) {
              // Mostrar mensaje de error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se permiten números menores a 0'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
              controller.text = datos[fila][colIndex];
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            } else if (numero > 100) {
              // Mostrar mensaje de error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se permiten números mayores a 100'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
              controller.text = datos[fila][colIndex];
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            } else {
              datos[fila][colIndex] = value;
            }
          } else {
            // Si no es un número válido, no guardar
            controller.text = datos[fila][colIndex];
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          }

          setState(() {});
          // Guardar automáticamente todas las notas
          _guardarAutomaticamente(context);
        },
      ),
    );
  }
}
