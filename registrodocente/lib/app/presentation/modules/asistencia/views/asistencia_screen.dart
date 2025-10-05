import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../data/services/asistencia_service.dart';
import '../../../../data/services/estudiantes_service.dart';
import '../../../widgets/estudiante_nombre_widget.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  final _asistenciaService = AsistenciaService();
  final _estudiantesService = EstudiantesService();
  int mesActualIndex = 0;
  List<String> _nombresEstudiantes = [];

  void _crear10Meses(BuildContext context, String curso, String seccion) {
    String mesSeleccionado = 'Agosto';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Crear Registros de Asistencia'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona el mes inicial:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Se crearán automáticamente 10 meses consecutivos',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: mesSeleccionado,
                    isExpanded: true,
                    items: AsistenciaService.mesesDelAnio
                        .map((mes) =>
                            DropdownMenuItem(value: mes, child: Text(mes)))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        mesSeleccionado = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Se crearán los meses:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...() {
                          int mesIndex = AsistenciaService.mesesDelAnio.indexOf(mesSeleccionado);
                          List<Widget> mesesWidgets = [];
                          for (int i = 0; i < 10; i++) {
                            int indexActual = (mesIndex + i) % 12;
                            mesesWidgets.add(
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 2),
                                child: Text(
                                  '${i + 1}. ${AsistenciaService.mesesDelAnio[indexActual]}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            );
                          }
                          return mesesWidgets;
                        }(),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    await _asistenciaService.crear10Meses(mesSeleccionado, curso, seccion);
                    setState(() {
                      mesActualIndex = 0;
                    });

                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('10 meses de asistencia creados correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Crear 10 Meses'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener argumentos del curso/sección
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'Curso';
    final seccion = args?['seccion'] ?? 'A';
    final nombreDocente = args?['docente'] ?? 'Francisco Luis Yean';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registro de Asistencia - $curso Sec. $seccion'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _asistenciaService.obtenerRegistros(curso, seccion),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final registros = snapshot.data ?? [];
          final existenRegistros = registros.isNotEmpty;

          return !existenRegistros
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay registros de asistencia',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _crear10Meses(context, curso, seccion),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear registros de asistencia'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Navegación entre meses
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.blue.shade200, width: 2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: mesActualIndex > 0
                            ? () {
                                setState(() {
                                  mesActualIndex--;
                                });
                              }
                            : null,
                        tooltip: 'Mes anterior',
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              registros[mesActualIndex]['mes'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'Mes ${mesActualIndex + 1} de ${registros.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: mesActualIndex < registros.length - 1
                            ? () {
                                setState(() {
                                  mesActualIndex++;
                                });
                              }
                            : null,
                        tooltip: 'Mes siguiente',
                      ),
                    ],
                  ),
                ),
                // Contenido del mes actual
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 80,
                          color: Colors.blue.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          registros[mesActualIndex]['mes'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistroAsistenciaMateria(
                                  materia: registros[mesActualIndex]['materia'],
                                  nombreDocente: nombreDocente,
                                  mes: registros[mesActualIndex]['mes'],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_calendar),
                          label: const Text('Editar Asistencia'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
        },
      ),
    );
  }
}

class RegistroAsistenciaMateria extends StatefulWidget {
  final String materia;
  final String nombreDocente;
  final String mes;

  const RegistroAsistenciaMateria({
    super.key,
    required this.materia,
    required this.nombreDocente,
    required this.mes,
  });

  @override
  State<RegistroAsistenciaMateria> createState() =>
      _RegistroAsistenciaState();
}

class _RegistroAsistenciaState extends State<RegistroAsistenciaMateria> {
  late TextEditingController docenteController;
  late TextEditingController mesController;
  final _asistenciaService = AsistenciaService();

  // 40 estudiantes (días) x 22 columnas (1-20, 21, T, %)
  List<List<String>> asistencia =
      List.generate(40, (_) => List.generate(22, (_) => ''));

  // Días del mes para cada estudiante (columna)
  List<TextEditingController> diasMesControllers =
      List.generate(21, (_) => TextEditingController());

  // Feriados: mapa que indica si una columna es feriado y su descripción
  Map<int, String> feriados = {};

  // Columna activa (día que está pasando lista actualmente)
  int? columnaActiva;

  // Variables para guardar
  String? _cursoActual;
  String? _seccionActual;

  // Función para marcar/desmarcar día como feriado
  void _marcarDiaFeriado(int columna) {
    if (feriados.containsKey(columna)) {
      // Si ya es feriado, preguntar si desea quitarlo
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quitar día sin clase'),
          content: Text('¿Desea quitar "${feriados[columna]}" del día ${columna + 1}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  feriados.remove(columna);
                });
                _guardarAutomaticamente();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Quitar'),
            ),
          ],
        ),
      );
    } else {
      // Si no es feriado, permitir marcarlo
      final motivoController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Marcar día ${columna + 1} como día sin clase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingrese el motivo:'),
              const SizedBox(height: 12),
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  hintText: 'Ej: Feriado Nacional, Suspensión de clases',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (motivoController.text.isNotEmpty) {
                  setState(() {
                    feriados[columna] = motivoController.text;
                  });
                  _guardarAutomaticamente();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Debe ingresar un motivo'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
    }
  }

  // Guardar automáticamente los datos
  Future<void> _guardarAutomaticamente() async {
    if (_cursoActual != null && _seccionActual != null) {
      final diasMesTextos = diasMesControllers.map((c) => c.text).toList();
      await _asistenciaService.guardarDatosAsistencia(
        curso: _cursoActual!,
        seccion: _seccionActual!,
        mes: widget.mes,
        asistencia: asistencia,
        feriados: feriados,
        diasMes: diasMesTextos,
      );
    }
  }

  // Cargar datos guardados
  Future<void> _cargarDatos() async {
    if (_cursoActual != null && _seccionActual != null) {
      final datos = await _asistenciaService.obtenerDatosAsistencia(
        curso: _cursoActual!,
        seccion: _seccionActual!,
        mes: widget.mes,
      );

      if (datos != null) {
        setState(() {
          asistencia = datos['asistencia'] as List<List<String>>;
          feriados = datos['feriados'] as Map<int, String>;
          final diasMes = datos['diasMes'] as List<String>;
          for (int i = 0; i < diasMes.length && i < diasMesControllers.length; i++) {
            diasMesControllers[i].text = diasMes[i];
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    docenteController = TextEditingController(text: widget.nombreDocente);
    mesController = TextEditingController(text: widget.mes);

    // Agregar listeners a los controladores de días del mes
    for (var controller in diasMesControllers) {
      controller.addListener(() {
        _guardarAutomaticamente();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener curso y sección del contexto
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null && _cursoActual == null) {
      _cursoActual = widget.materia;
      _seccionActual = 'A'; // Ajustar según tu lógica
      _cargarDatos();
    }
  }

  @override
  void dispose() {
    docenteController.dispose();
    mesController.dispose();
    for (var controller in diasMesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _seleccionarColumnaActiva(int columna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones del día'),
        content: Text(
          '¿Qué deseas hacer con el día ${columna + 1}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _marcarComoFeriado(columna);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(
              feriados.containsKey(columna)
                  ? 'Editar feriado'
                  : 'Marcar como feriado',
            ),
          ),
          if (feriados.containsKey(columna))
            TextButton(
              onPressed: () {
                setState(() {
                  feriados.remove(columna);
                });
                _guardarAutomaticamente();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feriado eliminado'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Quitar feriado'),
            ),
          TextButton(
            onPressed: () {
              setState(() {
                columnaActiva = columna;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pasando lista para el día ${columna + 1}'),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Pasar lista'),
          ),
        ],
      ),
    );
  }

  void _marcarComoFeriado(int columna) {
    TextEditingController feriadoController =
        TextEditingController(text: feriados[columna] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como Feriado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Día ${columna + 1}'),
            const SizedBox(height: 16),
            TextField(
              controller: feriadoController,
              decoration: const InputDecoration(
                labelText: '¿Qué se celebra?',
                hintText: 'Ej: Día de la Independencia',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              feriadoController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (feriadoController.text.trim().isNotEmpty) {
                setState(() {
                  feriados[columna] = feriadoController.text.trim();
                });
                _guardarAutomaticamente();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Feriado marcado: ${feriadoController.text.trim()}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              feriadoController.dispose();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _cambiarEstado(int fila, int col) {
    setState(() {
      // Ciclo: vacío -> P -> A -> T -> E -> R -> vacío
      switch (asistencia[fila][col]) {
        case '':
          asistencia[fila][col] = 'P';
          break;
        case 'P':
          asistencia[fila][col] = 'A';
          break;
        case 'A':
          asistencia[fila][col] = 'T';
          break;
        case 'T':
          asistencia[fila][col] = 'E';
          break;
        case 'E':
          asistencia[fila][col] = 'R';
          break;
        case 'R':
          asistencia[fila][col] = '';
          break;
      }
    });
    // Guardar automáticamente después de cambiar el estado
    _guardarAutomaticamente();
  }

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'P':
        return Colors.green;
      case 'A':
        return Colors.red;
      case 'T':
        return Colors.orange;
      case 'E':
        return Colors.yellow;
      case 'R':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }

  int _calcularTotal(int dia) {
    int total = 0;
    // Contar columnas 0-20 (21 columnas en total)
    for (int i = 0; i <= 20; i++) {
      // Si la columna NO es feriado Y tiene algún valor registrado
      if (!feriados.containsKey(i) && asistencia[dia][i].isNotEmpty) {
        total++;
      }
    }
    return total;
  }

  int _calcularTotalDiasTrabajados() {
    // Contar cuántos días se pasó lista (excluyendo feriados)
    int diasTrabajados = 0;
    for (int i = 0; i <= 20; i++) {
      if (!feriados.containsKey(i)) {
        // Verificar si algún estudiante tiene asistencia registrada ese día
        bool hayAsistencia = false;
        for (int estudiante = 0; estudiante < 40; estudiante++) {
          if (asistencia[estudiante][i].isNotEmpty) {
            hayAsistencia = true;
            break;
          }
        }
        if (hayAsistencia) {
          diasTrabajados++;
        }
      }
    }
    return diasTrabajados;
  }

  double _calcularPorcentaje(int estudiante) {
    final diasTrabajados = _calcularTotalDiasTrabajados();
    if (diasTrabajados == 0) return 0.0;

    int diasPresente = 0;
    // Contar días con 'P' (Presente)
    for (int i = 0; i <= 20; i++) {
      if (!feriados.containsKey(i) && asistencia[estudiante][i] == 'P') {
        diasPresente++;
      }
    }

    return (diasPresente / diasTrabajados) * 100;
  }

  Color _getColorPorcentaje(double porcentaje) {
    // Verde: 90-100%
    if (porcentaje >= 90) {
      return Colors.green.shade100;
    }
    // Amarillo: 80-89%
    else if (porcentaje >= 80) {
      return Colors.yellow.shade100;
    }
    // Naranja: 70-79%
    else if (porcentaje >= 70) {
      return Colors.orange.shade100;
    }
    // Rojo: menos de 70%
    else if (porcentaje > 0) {
      return Colors.red.shade100;
    }
    // Blanco: sin datos
    return Colors.white;
  }

  Future<void> _imprimirAsistencia(BuildContext context) async {
    final pdf = pw.Document();

    // Agregar una página al PDF con la tabla de asistencia
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Text(
                widget.materia.toUpperCase(),
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Docente: ${docenteController.text}'),
              pw.Text('Mes: ${mesController.text}'),
              pw.SizedBox(height: 16),
              // Tabla de asistencia
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Encabezado de la tabla
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Día', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      ...List.generate(20, (i) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(child: pw.Text('${i + 1}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      )),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('21', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('T', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Filas de estudiantes
                  ...List.generate(40, (diaIndex) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('${diaIndex + 1}'),
                        ),
                        ...List.generate(21, (columnaIndex) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Center(child: pw.Text(asistencia[diaIndex][columnaIndex])),
                          );
                        }),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Center(child: pw.Text(_calcularTotal(diaIndex).toString())),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Center(child: pw.Text('${_calcularPorcentaje(diaIndex).toStringAsFixed(0)}%')),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Mostrar el diálogo de impresión
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.materia.toUpperCase()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar verificación de asistencias
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad de verificación en desarrollo'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
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
            tooltip: 'Imprimir',
            onPressed: () => _imprimirAsistencia(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Indicador de columna activa
            if (columnaActiva != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[900]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pasando lista para el día ${columnaActiva! + 1}\nToca los números de estudiantes para marcar asistencia',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.blue[900],
                      onPressed: () {
                        setState(() {
                          columnaActiva = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Modo pasar lista desactivado'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      tooltip: 'Desactivar modo pasar lista',
                    ),
                  ],
                ),
              ),
            // Leyenda de porcentajes
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Leyenda de Porcentaje de Asistencia',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _LeyendaItem(color: Colors.green.shade100, texto: '≥90% Excelente'),
                      _LeyendaItem(color: Colors.yellow.shade100, texto: '80-89% Bueno'),
                      _LeyendaItem(color: Colors.orange.shade100, texto: '70-79% Regular'),
                      _LeyendaItem(color: Colors.red.shade100, texto: '<70% Bajo'),
                    ],
                  ),
                ],
              ),
            ),
            // Tabla completa
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  children: [
                    // Fila de Mes
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              border: Border(
                                right: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            child: const Text(
                              'Mes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextField(
                                controller: mesController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Encabezado con título "DÍAS TRABAJADOS"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      child: const Text(
                        'DÍAS TRABAJADOS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Sección de tabla de asistencia
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              // Primera fila de encabezados (números 1-20, 21, T, %)
                              Row(
                                children: [
                                  // Columna "DÍAS" (vacía en esta fila)
                                  Container(
                                    width: 50,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      border: Border.all(color: Colors.black),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'DÍAS',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  // Columnas 1-20 (clickeables)
                                  ...List.generate(
                                    20,
                                    (index) => GestureDetector(
                                      onTap: () => _seleccionarColumnaActiva(index),
                                      onLongPress: () => _marcarDiaFeriado(index),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: feriados.containsKey(index)
                                              ? Colors.orange[300]
                                              : (columnaActiva == index
                                                  ? Colors.blue[300]
                                                  : Colors.grey[300]),
                                          border: Border.all(color: Colors.black),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                color: (columnaActiva == index ||
                                                        feriados.containsKey(index))
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            if (feriados.containsKey(index))
                                              const Icon(
                                                Icons.celebration,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Columna 21 (clickeable)
                                  GestureDetector(
                                    onTap: () => _seleccionarColumnaActiva(20),
                                    onLongPress: () => _marcarDiaFeriado(20),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: feriados.containsKey(20)
                                            ? Colors.orange[300]
                                            : (columnaActiva == 20
                                                ? Colors.blue[300]
                                                : Colors.grey[300]),
                                        border: Border.all(color: Colors.black),
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '21',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: (columnaActiva == 20 ||
                                                      feriados.containsKey(20))
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          if (feriados.containsKey(20))
                                            const Icon(
                                              Icons.celebration,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Columna T
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      border: Border.all(color: Colors.black),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'T',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  // Columna %
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      border: Border.all(color: Colors.black),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Segunda fila: Días del mes (editables)
                              Row(
                                children: [
                                  // Celda vacía para alinear con "DÍAS"
                                  Container(
                                    width: 50,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(color: Colors.black),
                                    ),
                                  ),
                                  // Campos de texto para días del mes (1-20)
                                  ...List.generate(
                                    20,
                                    (index) => Container(
                                      width: 35,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: columnaActiva == index
                                              ? Colors.blue
                                              : Colors.black,
                                          width: columnaActiva == index ? 2 : 1,
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: TextField(
                                        controller: diasMesControllers[index],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 10),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 2),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        maxLength: 2,
                                        buildCounter: (context,
                                                {required currentLength,
                                                required isFocused,
                                                maxLength}) =>
                                            null,
                                      ),
                                    ),
                                  ),
                                  // Campo día 21
                                  Container(
                                    width: 35,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: columnaActiva == 20
                                            ? Colors.blue
                                            : Colors.black,
                                        width: columnaActiva == 20 ? 2 : 1,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: TextField(
                                      controller: diasMesControllers[20],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 2),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 2,
                                      buildCounter: (context,
                                              {required currentLength,
                                              required isFocused,
                                              maxLength}) =>
                                          null,
                                    ),
                                  ),
                                  // Celdas vacías para T y %
                                  Container(
                                    width: 35,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(color: Colors.black),
                                    ),
                                  ),
                                  Container(
                                    width: 35,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),

                              // Filas de días (1-40)
                              ...List.generate(40, (diaIndex) {
                                return Row(
                                  children: [
                                    // Columna de días (1-40) - clickeable cuando hay columna activa
                                    GestureDetector(
                                      onTap: columnaActiva != null
                                          ? () {
                                              _cambiarEstado(
                                                  diaIndex, columnaActiva!);
                                            }
                                          : null,
                                      child: Container(
                                        width: 50,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: columnaActiva != null
                                              ? Colors.blue[50]
                                              : Colors.white,
                                          border: Border.all(color: Colors.black),
                                        ),
                                        alignment: Alignment.center,
                                        child: EstudianteNombreWidget(
                                          numero: diaIndex + 1,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: columnaActiva != null
                                                ? Colors.blue[900]
                                                : Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    // Celdas de asistencia (columnas 1-20)
                                    ...List.generate(
                                      20,
                                      (colIndex) => GestureDetector(
                                        onTap: feriados.containsKey(colIndex)
                                            ? () {
                                                // Mostrar información del feriado
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Feriado: ${feriados[colIndex]}',
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                    duration: const Duration(
                                                        seconds: 2),
                                                  ),
                                                );
                                              }
                                            : () {
                                                _cambiarEstado(
                                                    diaIndex, colIndex);
                                              },
                                        child: Container(
                                          width: 35,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: columnaActiva == colIndex
                                                  ? Colors.blue
                                                  : Colors.black,
                                              width: columnaActiva == colIndex
                                                  ? 2
                                                  : 1,
                                            ),
                                            color: feriados.containsKey(colIndex)
                                                ? Colors.orange[100]
                                                : _getColorForEstado(
                                                    asistencia[diaIndex]
                                                        [colIndex]),
                                          ),
                                          alignment: Alignment.center,
                                          child: feriados.containsKey(colIndex)
                                              ? const Icon(
                                                  Icons.celebration,
                                                  size: 16,
                                                  color: Colors.orange,
                                                )
                                              : Text(
                                                  asistencia[diaIndex][colIndex],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: asistencia[diaIndex]
                                                                [colIndex] ==
                                                            'E'
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    // Celda 21
                                    GestureDetector(
                                      onTap: feriados.containsKey(20)
                                          ? () {
                                              // Mostrar información del feriado
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Feriado: ${feriados[20]}',
                                                  ),
                                                  backgroundColor: Colors.orange,
                                                  duration:
                                                      const Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          : () {
                                              _cambiarEstado(diaIndex, 20);
                                            },
                                      child: Container(
                                        width: 35,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: columnaActiva == 20
                                                ? Colors.blue
                                                : Colors.black,
                                            width: columnaActiva == 20 ? 2 : 1,
                                          ),
                                          color: feriados.containsKey(20)
                                              ? Colors.orange[100]
                                              : _getColorForEstado(
                                                  asistencia[diaIndex][20]),
                                        ),
                                        alignment: Alignment.center,
                                        child: feriados.containsKey(20)
                                            ? const Icon(
                                                Icons.celebration,
                                                size: 16,
                                                color: Colors.orange,
                                              )
                                            : Text(
                                                asistencia[diaIndex][20],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                  color: asistencia[diaIndex]
                                                              [20] ==
                                                          'E'
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Celda T (Total)
                                    Container(
                                      width: 35,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        color: Colors.grey[200],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _calcularTotal(diaIndex).toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    // Celda % (Porcentaje de asistencia)
                                    Container(
                                      width: 35,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        color: _getColorPorcentaje(_calcularPorcentaje(diaIndex)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${_calcularPorcentaje(diaIndex).toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información de guardado automático
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Todos los cambios se guardan automáticamente',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeyendaItem extends StatelessWidget {
  final Color color;
  final String texto;

  const _LeyendaItem({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
