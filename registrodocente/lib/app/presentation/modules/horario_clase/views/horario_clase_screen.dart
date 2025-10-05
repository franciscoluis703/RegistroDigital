import 'package:flutter/material.dart';

class HorarioClaseScreen extends StatefulWidget {
  const HorarioClaseScreen({super.key});

  @override
  State<HorarioClaseScreen> createState() => _HorarioClaseScreenState();
}

class _HorarioClaseScreenState extends State<HorarioClaseScreen> {
  // Lista de tablas de horarios
  final List<HorarioTable> _tablas = [
    HorarioTable(nombre: 'Horario Principal'),
  ];

  int _tablaActualIndex = 0;
  bool _cambiosNoGuardados = false;

  void _marcarCambio() {
    if (!_cambiosNoGuardados) {
      setState(() {
        _cambiosNoGuardados = true;
      });
    }
  }

  void _guardarCambios() {
    // TODO: Implementar guardado en base de datos o archivo
    setState(() {
      _cambiosNoGuardados = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Horario guardado correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _agregarTabla() {
    showDialog(
      context: context,
      builder: (context) {
        String nombreTabla = 'Horario ${_tablas.length + 1}';
        return AlertDialog(
          title: const Text('Nueva Tabla de Horario'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre de la tabla',
              hintText: 'Ej: Horario Vespertino',
            ),
            onChanged: (value) => nombreTabla = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tablas.add(HorarioTable(
                    nombre: nombreTabla.isEmpty
                        ? 'Horario ${_tablas.length + 1}'
                        : nombreTabla,
                  ));
                  _tablaActualIndex = _tablas.length - 1;
                });
                _marcarCambio();
                Navigator.pop(context);
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarTabla() {
    if (_tablas.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe existir al menos una tabla de horario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tabla'),
        content: Text(
          '¿Estás seguro de eliminar "${_tablas[_tablaActualIndex].nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tablas.removeAt(_tablaActualIndex);
                if (_tablaActualIndex >= _tablas.length) {
                  _tablaActualIndex = _tablas.length - 1;
                }
              });
              _marcarCambio();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tabla eliminada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _renombrarTabla() {
    String nuevoNombre = _tablas[_tablaActualIndex].nombre;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Renombrar Tabla'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nuevo nombre',
            ),
            controller: TextEditingController(text: nuevoNombre),
            onChanged: (value) => nuevoNombre = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tablas[_tablaActualIndex].nombre = nuevoNombre;
                });
                _marcarCambio();
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmarSalida() async {
    if (!_cambiosNoGuardados) return true;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambios sin guardar'),
        content: const Text(
          '¿Deseas guardar los cambios antes de salir?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Salir sin guardar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _guardarCambios();
              Navigator.pop(context, true);
            },
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _confirmarSalida();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        title: Row(
          children: [
            const Text('Horario de Clase'),
            if (_cambiosNoGuardados) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sin guardar',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_cambiosNoGuardados)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Guardar cambios',
              onPressed: _guardarCambios,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'renombrar':
                  _renombrarTabla();
                  break;
                case 'eliminar':
                  _eliminarTabla();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'renombrar',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Renombrar tabla'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar tabla', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de tabla
          if (_tablas.length > 1)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.orange.shade200, width: 2),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: _tablaActualIndex > 0
                        ? () {
                            setState(() {
                              _tablaActualIndex--;
                            });
                          }
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      _tablas[_tablaActualIndex].nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: _tablaActualIndex < _tablas.length - 1
                        ? () {
                            setState(() {
                              _tablaActualIndex++;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),

          // Tabla de horario
          Expanded(
            child: _HorarioTableWidget(
              horarioTable: _tablas[_tablaActualIndex],
              onUpdate: () {
                setState(() {});
                _marcarCambio();
              },
            ),
          ),

          // Barra de acciones inferior
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _agregarTabla,
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva Tabla'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _guardarCambios,
                    icon: const Icon(Icons.save),
                    label: Text(_cambiosNoGuardados
                        ? 'Guardar Cambios'
                        : 'Todo Guardado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cambiosNoGuardados
                          ? Colors.green
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

class HorarioTable {
  String nombre;
  List<List<HorarioCelda>> celdas;

  HorarioTable({required this.nombre})
      : celdas = List.generate(
          10,
          (_) => List.generate(
            6,
            (_) => HorarioCelda(),
          ),
        );
}

class HorarioCelda {
  String texto;
  Color color;
  String? horaInicio;
  String? horaFin;
  bool alarmaActiva;

  HorarioCelda({
    this.texto = '',
    this.color = Colors.white,
    this.horaInicio,
    this.horaFin,
    this.alarmaActiva = false,
  });
}

class _HorarioTableWidget extends StatefulWidget {
  final HorarioTable horarioTable;
  final VoidCallback onUpdate;

  const _HorarioTableWidget({
    required this.horarioTable,
    required this.onUpdate,
  });

  @override
  State<_HorarioTableWidget> createState() => _HorarioTableWidgetState();
}

class _HorarioTableWidgetState extends State<_HorarioTableWidget> {
  final List<String> _diasSemana = [
    'Hora',
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
  ];

  final List<Color> _coloresDisponibles = [
    Colors.white,
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.pink.shade100,
    Colors.teal.shade100,
    Colors.cyan.shade100,
  ];

  Future<void> _seleccionarHora(BuildContext context, bool esInicio, Function(String) onSelected) async {
    final TimeOfDay? tiempo = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (tiempo != null && context.mounted) {
      final hora = tiempo.format(context);
      onSelected(hora);
    }
  }

  void _editarHorario(int fila) {
    final celda = widget.horarioTable.celdas[fila][0];
    String? horaInicio = celda.horaInicio;
    String? horaFin = celda.horaFin;
    bool alarmaActiva = celda.alarmaActiva;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('Configurar Período ${fila + 1}'),
                ],
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Horario del período',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    // Hora de inicio
                    InkWell(
                      onTap: () async {
                        await _seleccionarHora(context, true, (hora) {
                          setStateDialog(() {
                            horaInicio = hora;
                          });
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, color: Colors.blue),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hora de inicio',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  horaInicio ?? 'Sin configurar',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.edit, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Hora de fin
                    InkWell(
                      onTap: () async {
                        await _seleccionarHora(context, false, (hora) {
                          setStateDialog(() {
                            horaFin = hora;
                          });
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, color: Colors.orange),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hora de fin',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  horaFin ?? 'Sin configurar',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.edit, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Alarma
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: alarmaActiva ? Colors.orange.shade50 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: alarmaActiva ? Colors.orange : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alarm,
                            color: alarmaActiva ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alarma',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Notificar al iniciar el período',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: alarmaActiva,
                            onChanged: (value) {
                              setStateDialog(() {
                                alarmaActiva = value;
                              });
                            },
                            activeTrackColor: Colors.orange.shade300,
                            thumbColor: WidgetStateProperty.resolveWith<Color>(
                              (states) => states.contains(WidgetState.selected)
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Limpiar configuración
                    widget.horarioTable.celdas[fila][0].horaInicio = null;
                    widget.horarioTable.celdas[fila][0].horaFin = null;
                    widget.horarioTable.celdas[fila][0].alarmaActiva = false;
                    widget.onUpdate();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Limpiar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.horarioTable.celdas[fila][0].horaInicio = horaInicio;
                    widget.horarioTable.celdas[fila][0].horaFin = horaFin;
                    widget.horarioTable.celdas[fila][0].alarmaActiva = alarmaActiva;
                    widget.onUpdate();
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editarCelda(int fila, int columna) {
    // Si es la columna de Hora (columna 0), mostrar editor de horario
    if (columna == 0) {
      _editarHorario(fila);
      return;
    }

    final celda = widget.horarioTable.celdas[fila][columna];
    String nuevoTexto = celda.texto;
    Color nuevoColor = celda.color;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Editar ${_diasSemana[columna]} - Hora ${fila + 1}'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Materia/Actividad',
                        hintText: 'Ej: Matemáticas',
                      ),
                      controller: TextEditingController(text: nuevoTexto),
                      onChanged: (value) => nuevoTexto = value,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Color de fondo:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _coloresDisponibles.map((color) {
                        final isSelected = color == nuevoColor;
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              nuevoColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.grey,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Limpiar celda
                    widget.horarioTable.celdas[fila][columna].texto = '';
                    widget.horarioTable.celdas[fila][columna].color =
                        Colors.white;
                    widget.onUpdate();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Limpiar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.horarioTable.celdas[fila][columna].texto =
                        nuevoTexto;
                    widget.horarioTable.celdas[fila][columna].color =
                        nuevoColor;
                    widget.onUpdate();
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHorarioCell(HorarioCelda celda, int fila) {
    final tieneHorario = celda.horaInicio != null && celda.horaFin != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${fila + 1}°',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (tieneHorario) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 10, color: Colors.blue),
              const SizedBox(width: 2),
              Text(
                celda.horaInicio!,
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(
            celda.horaFin!,
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
        ],
        if (celda.alarmaActiva)
          const Icon(Icons.alarm, size: 12, color: Colors.orange),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Encabezado con días de la semana
              Row(
                children: _diasSemana.asMap().entries.map((entry) {
                  return Container(
                    width: 120,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
              // Filas de horario
              ...List.generate(10, (fila) {
                return Row(
                  children: List.generate(6, (columna) {
                    final celda = widget.horarioTable.celdas[fila][columna];
                    return GestureDetector(
                      onTap: () => _editarCelda(fila, columna),
                      child: Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          color: celda.color,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(4),
                        child: columna == 0
                            ? _buildHorarioCell(celda, fila)
                            : Text(
                                celda.texto,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
