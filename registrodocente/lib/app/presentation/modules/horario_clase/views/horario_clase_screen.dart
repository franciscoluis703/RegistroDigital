import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../widgets/estudiante_nombre_widget.dart';
import '../../../../data/services/firebase/horarios_firestore_service.dart';

class HorarioClaseScreen extends StatefulWidget {
  const HorarioClaseScreen({super.key});

  @override
  State<HorarioClaseScreen> createState() => _HorarioClaseScreenState();
}

class _HorarioClaseScreenState extends State<HorarioClaseScreen> {
  final List<HorarioPeriodo> _periodos = [];
  final _horariosService = HorariosFirestoreService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHorario();
  }

  // Cargar horario guardado o inicializar con valores por defecto
  Future<void> _cargarHorario() async {
    setState(() => _isLoading = true);

    final configuracionJson = await _horariosService.obtenerConfiguracionHorario();

    if (configuracionJson != null && configuracionJson.isNotEmpty) {
      // Cargar horario guardado desde Supabase
      try {
        final List<dynamic> periodosJson = jsonDecode(configuracionJson);
        setState(() {
          _periodos.clear();
          _periodos.addAll(
            periodosJson.map((p) => HorarioPeriodo.fromJson(p)).toList(),
          );
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Error al decodificar horario: $e');
        _inicializarPeriodos();
        setState(() => _isLoading = false);
      }
    } else {
      // Inicializar con periodos por defecto
      _inicializarPeriodos();
      setState(() => _isLoading = false);
    }
  }

  void _inicializarPeriodos() {
    // Inicializar con periodos por defecto
    _periodos.addAll([
      HorarioPeriodo(numero: 1, horaInicio: '8:00 AM', horaFin: '8:45 AM'),
      HorarioPeriodo(numero: 2, horaInicio: '8:45 AM', horaFin: '9:30 AM'),
      HorarioPeriodo(numero: 3, horaInicio: '9:30 AM', horaFin: '10:15 AM'),
      HorarioPeriodo(
        numero: 4,
        horaInicio: '10:15 AM',
        horaFin: '10:30 AM',
        esRecreo: true,
        nombre: 'RECREO',
      ),
      HorarioPeriodo(numero: 5, horaInicio: '10:30 AM', horaFin: '11:15 AM'),
      HorarioPeriodo(numero: 6, horaInicio: '11:15 AM', horaFin: '12:00 PM'),
      HorarioPeriodo(
        numero: 7,
        horaInicio: '12:00 PM',
        horaFin: '1:00 PM',
        esAlmuerzo: true,
        nombre: 'ALMUERZO',
      ),
      HorarioPeriodo(numero: 8, horaInicio: '1:00 PM', horaFin: '1:45 PM'),
      HorarioPeriodo(numero: 9, horaInicio: '1:45 PM', horaFin: '2:30 PM'),
      HorarioPeriodo(numero: 10, horaInicio: '2:30 PM', horaFin: '3:15 PM'),
    ]);
  }

  // Guardar horario en Supabase
  Future<void> _guardarHorarioEnStorage() async {
    try {
      final periodosJson = _periodos.map((p) => p.toJson()).toList();
      final configuracionJson = jsonEncode(periodosJson);
      final success = await _horariosService.guardarConfiguracionHorario(configuracionJson);

      if (!success) {
        debugPrint('Error al guardar horario en Supabase');
      }
    } catch (e) {
      debugPrint('Error al guardar horario: $e');
    }
  }

  void _agregarPeriodo() {
    setState(() {
      _periodos.add(HorarioPeriodo(
        numero: _periodos.length + 1,
        horaInicio: '',
        horaFin: '',
      ));
    });
    _guardarHorarioEnStorage();
  }

  void _eliminarPeriodo(int index) {
    setState(() {
      _periodos.removeAt(index);
      // Renumerar
      for (int i = 0; i < _periodos.length; i++) {
        _periodos[i].numero = i + 1;
      }
    });
    _guardarHorarioEnStorage();
  }

  void _editarPeriodo(int index) {
    final periodo = _periodos[index];

    showDialog(
      context: context,
      builder: (context) => _DialogEditarPeriodo(
        periodo: periodo,
        onSave: () {
          setState(() {});
          _guardarHorarioEnStorage();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Horario de Clase'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Horario de Clase'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
            onPressed: _guardarHorario,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _agregarPeriodo,
            tooltip: 'Agregar período',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFbfa661),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Hora',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...[
                    'Lunes',
                    'Martes',
                    'Miércoles',
                    'Jueves',
                    'Viernes'
                  ].asMap().entries.map((entry) {
                    final isLast = entry.key == 4;
                    return Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFbfa661),
                          borderRadius: isLast
                              ? const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              // Filas de períodos
              ...List.generate(_periodos.length, (index) {
                final periodo = _periodos[index];
                final isLast = index == _periodos.length - 1;

                return Row(
                  children: [
                    // Columna de hora
                    GestureDetector(
                      onTap: () => _editarPeriodo(index),
                      child: Container(
                        width: 60,
                        height: 70,
                        decoration: BoxDecoration(
                          color: periodo.esRecreo || periodo.esAlmuerzo
                              ? Colors.orange[100]
                              : Colors.grey[200],
                          border: Border(
                            left: BorderSide(color: Colors.grey[300]!),
                            right: BorderSide(color: Colors.grey[300]!),
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                          borderRadius: isLast
                              ? const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${periodo.numero}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (periodo.alarmaActiva)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.alarm,
                                      size: 14,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                              ],
                            ),
                            if (periodo.horaInicio.isNotEmpty)
                              Text(
                                '${periodo.horaInicio}\n${periodo.horaFin}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Celdas de días
                    ...List.generate(5, (diaIndex) {
                      final isLastDay = diaIndex == 4;
                      final colorCelda = periodo.colores[diaIndex];

                      return Expanded(
                        child: GestureDetector(
                          onTap: periodo.esRecreo || periodo.esAlmuerzo
                              ? null
                              : () => _editarMateria(index, diaIndex),
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: periodo.esRecreo || periodo.esAlmuerzo
                                  ? Colors.orange[100]
                                  : colorCelda?.withOpacity(0.3) ?? Colors.white,
                              border: Border(
                                right: BorderSide(color: Colors.grey[300]!),
                                bottom: BorderSide(color: Colors.grey[300]!),
                                left: colorCelda != null
                                    ? BorderSide(color: colorCelda, width: 4)
                                    : BorderSide.none,
                              ),
                              borderRadius: isLast && isLastDay
                                  ? const BorderRadius.only(
                                      bottomRight: Radius.circular(12),
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              periodo.esRecreo || periodo.esAlmuerzo
                                  ? periodo.nombre
                                  : periodo.materias[diaIndex],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: periodo.esRecreo ||
                                        periodo.esAlmuerzo
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: periodo.esRecreo || periodo.esAlmuerzo
                                    ? Colors.orange[900]
                                    : Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _guardarHorario,
          icon: const Icon(Icons.save),
          label: const Text('Guardar Horario'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFbfa661),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  void _editarMateria(int periodoIndex, int diaIndex) {
    final periodo = _periodos[periodoIndex];
    final controller = TextEditingController(text: periodo.materias[diaIndex]);
    Color? colorSeleccionado = periodo.colores[diaIndex];

    final List<String> diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Período ${periodo.numero} - ${diasSemana[diaIndex]}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de materia
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Materia',
                      hintText: 'Ej: Matemática, Español...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  // Selector de color
                  const Text(
                    'Color de identificación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Opción sin color
                      _buildColorOption(
                        context,
                        null,
                        colorSeleccionado,
                        'Sin color',
                        () {
                          setDialogState(() {
                            colorSeleccionado = null;
                          });
                        },
                      ),
                      // Colores disponibles
                      ...[
                        Colors.red[300]!,
                        Colors.pink[300]!,
                        Colors.purple[300]!,
                        Colors.deepPurple[300]!,
                        Colors.indigo[300]!,
                        Colors.blue[300]!,
                        Colors.lightBlue[300]!,
                        Colors.cyan[300]!,
                        Colors.teal[300]!,
                        Colors.green[300]!,
                        Colors.lightGreen[300]!,
                        Colors.lime[300]!,
                        Colors.yellow[300]!,
                        Colors.amber[300]!,
                        Colors.orange[300]!,
                        Colors.deepOrange[300]!,
                        Colors.brown[300]!,
                        Colors.grey[300]!,
                      ].map((color) {
                        return _buildColorOption(
                          context,
                          color,
                          colorSeleccionado,
                          '',
                          () {
                            setDialogState(() {
                              colorSeleccionado = color;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  if (colorSeleccionado != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorSeleccionado!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorSeleccionado!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: colorSeleccionado!),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Vista previa del color seleccionado',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.dispose();
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    periodo.materias[diaIndex] = controller.text;
                    periodo.colores[diaIndex] = colorSeleccionado;
                  });
                  _guardarHorarioEnStorage();
                  controller.dispose();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFbfa661),
                ),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    Color? color,
    Color? colorSeleccionado,
    String label,
    VoidCallback onTap,
  ) {
    final isSelected = color == colorSeleccionado;

    if (color == null) {
      // Opción "Sin color"
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Línea diagonal para indicar "sin color"
              CustomPaint(
                size: const Size(50, 50),
                painter: _DiagonalLinePainter(),
              ),
              if (isSelected)
                const Center(
                  child: Icon(
                    Icons.check,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[400]!,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              )
            : null,
      ),
    );
  }

  Future<void> _guardarHorario() async {
    await _guardarHorarioEnStorage();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horario guardado correctamente en la base de datos'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// Painter para la línea diagonal de "sin color"
class _DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      const Offset(5, 5),
      Offset(size.width - 5, size.height - 5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HorarioPeriodo {
  int numero;
  String horaInicio;
  String horaFin;
  List<String> materias;
  List<Color?> colores;  // Color para cada día
  bool esRecreo;
  bool esAlmuerzo;
  String nombre;
  bool alarmaActiva;

  HorarioPeriodo({
    required this.numero,
    required this.horaInicio,
    required this.horaFin,
    this.esRecreo = false,
    this.esAlmuerzo = false,
    this.nombre = '',
    this.alarmaActiva = false,
  }) : materias = List.generate(5, (_) => ''),
       colores = List.generate(5, (_) => null);

  // Convertir a JSON para guardar
  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'materias': materias,
      'colores': colores.map((c) => c?.toARGB32()).toList(),
      'esRecreo': esRecreo,
      'esAlmuerzo': esAlmuerzo,
      'nombre': nombre,
      'alarmaActiva': alarmaActiva,
    };
  }

  // Crear desde JSON
  factory HorarioPeriodo.fromJson(Map<String, dynamic> json) {
    final periodo = HorarioPeriodo(
      numero: json['numero'] ?? 0,
      horaInicio: json['horaInicio'] ?? '',
      horaFin: json['horaFin'] ?? '',
      esRecreo: json['esRecreo'] ?? false,
      esAlmuerzo: json['esAlmuerzo'] ?? false,
      nombre: json['nombre'] ?? '',
      alarmaActiva: json['alarmaActiva'] ?? false,
    );

    // Restaurar materias
    if (json['materias'] != null) {
      periodo.materias = List<String>.from(json['materias']);
    }

    // Restaurar colores
    if (json['colores'] != null) {
      periodo.colores = (json['colores'] as List)
          .map((c) => c != null ? Color(c as int) : null)
          .toList();
    }

    return periodo;
  }
}

class _DialogEditarPeriodo extends StatefulWidget {
  final HorarioPeriodo periodo;
  final VoidCallback onSave;

  const _DialogEditarPeriodo({
    required this.periodo,
    required this.onSave,
  });

  @override
  State<_DialogEditarPeriodo> createState() => _DialogEditarPeriodoState();
}

class _DialogEditarPeriodoState extends State<_DialogEditarPeriodo> {
  late bool esRecreo;
  late bool esAlmuerzo;
  late String nombre;
  late bool alarmaActiva;

  @override
  void initState() {
    super.initState();
    esRecreo = widget.periodo.esRecreo;
    esAlmuerzo = widget.periodo.esAlmuerzo;
    nombre = widget.periodo.nombre;
    alarmaActiva = widget.periodo.alarmaActiva;
  }

  Future<void> _seleccionarHora(bool esInicio) async {
    final TimeOfDay? tiempo = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (tiempo != null && context.mounted) {
      final hora = tiempo.format(context);
      setState(() {
        if (esInicio) {
          widget.periodo.horaInicio = hora;
        } else {
          widget.periodo.horaFin = hora;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configurar Período ${widget.periodo.numero}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de período
            const Text(
              'Tipo de período',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Recreo'),
                    value: esRecreo,
                    onChanged: (value) {
                      setState(() {
                        esRecreo = value ?? false;
                        if (esRecreo) {
                          esAlmuerzo = false;
                          nombre = 'RECREO';
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Almuerzo'),
                    value: esAlmuerzo,
                    onChanged: (value) {
                      setState(() {
                        esAlmuerzo = value ?? false;
                        if (esAlmuerzo) {
                          esRecreo = false;
                          nombre = 'ALMUERZO';
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Horario
            const Text(
              'Horario',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _seleccionarHora(true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inicio',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            widget.periodo.horaInicio.isEmpty
                                ? 'Seleccionar'
                                : widget.periodo.horaInicio,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _seleccionarHora(false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fin',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            widget.periodo.horaFin.isEmpty
                                ? 'Seleccionar'
                                : widget.periodo.horaFin,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Alarma
            Container(
              decoration: BoxDecoration(
                color: alarmaActiva ? Colors.orange[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: alarmaActiva ? Colors.orange[300]! : Colors.grey[300]!,
                ),
              ),
              child: SwitchListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      color: alarmaActiva ? Colors.orange[700] : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Activar alarma',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                subtitle: Text(
                  alarmaActiva
                      ? 'La alarma sonará al inicio de este período'
                      : 'Sin alarma configurada',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                value: alarmaActiva,
                activeColor: Colors.orange[700],
                onChanged: (value) {
                  setState(() {
                    alarmaActiva = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.periodo.esRecreo = esRecreo;
            widget.periodo.esAlmuerzo = esAlmuerzo;
            widget.periodo.nombre = nombre;
            widget.periodo.alarmaActiva = alarmaActiva;
            widget.onSave();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFbfa661),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
