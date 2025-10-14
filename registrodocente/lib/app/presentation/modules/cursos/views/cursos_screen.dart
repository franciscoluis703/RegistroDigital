import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/services/curso_context_service.dart';
import '../../../../data/services/firebase/cursos_firestore_service.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../widgets/avatar_genero_widget.dart';
import '../../../themes/app_colors.dart';

class CursosScreen extends StatefulWidget {
  const CursosScreen({super.key});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  final CursoContextService _cursoContext = CursoContextService();
  final CursosFirestoreService _cursosService = CursosFirestoreService();

  // Lista de cursos
  List<String> cursos = [];

  // Map para almacenar secciones de cada curso
  Map<String, List<String>> secciones = {};

  // Papelera de cursos eliminados
  List<Map<String, dynamic>> cursosEliminados = [];

  // Papelera de secciones eliminadas (curso -> lista de secciones)
  Map<String, List<String>> seccionesEliminadas = {};

  // Map para almacenar cursos ocultos
  Map<String, bool> cursosOcultos = {};

  // Control de visibilidad de cursos ocultos
  bool _mostrarOcultos = false;

  // Modo de reordenamiento
  bool _modoReordenar = false;

  bool _isLoading = true;

  // Datos del usuario
  String _nombreUsuario = 'Usuario';
  String? _cursoActivoId;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _cargarCursoActivo();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _nombreUsuario = userProvider.nombre.isNotEmpty ? userProvider.nombre : 'Usuario';
    });
  }

  Future<void> _cargarCursoActivo() async {
    final cursoId = await _cursoContext.obtenerCursoActual();
    setState(() {
      _cursoActivoId = cursoId;
    });
  }

  Future<void> _seleccionarCursoActivo(String nombreCurso, int index) async {
    // Generar ID del curso desde el nombre
    // Formato: "Tercero A - Lengua Española" -> "tercero_a_lengua_española"
    final cursoId = nombreCurso.toLowerCase().replaceAll(' ', '_').replaceAll('-', '');

    await _cursoContext.establecerCursoActual(cursoId);

    setState(() {
      _cursoActivoId = cursoId;
    });

    // Guardar cambio automáticamente
    await _guardarDatos();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Curso activo seleccionado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      nombreCurso,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Cargar datos desde Firebase
  Future<void> _cargarDatos() async {
    try {
      // Cargar cursos desde Firebase
      final cursosFirebase = await _cursosService.obtenerCursos();

      if (cursosFirebase.isNotEmpty) {
        // Convertir datos de Firebase al formato antiguo
        cursos = cursosFirebase.map((curso) {
          final nombre = curso.nombre;
          final asignatura = curso.asignatura;
          return '$nombre - $asignatura';
        }).toList();

        // Construir secciones desde Firebase
        for (var curso in cursosFirebase) {
          final nombreCompleto = '${curso.nombre} - ${curso.asignatura}';
          secciones[nombreCompleto] = curso.secciones;

          // Cargar estado oculto
          cursosOcultos[nombreCompleto] = curso.oculto;
        }

        print('✅ Cursos cargados desde Firebase: ${cursos.length}');
      } else {
        // Si no hay cursos, crear curso por defecto
        await _crearCursoPorDefecto();
      }
    } catch (e) {
      print('❌ Error al cargar desde Firebase: $e');

      // Si no hay cursos, crear curso por defecto
      if (cursos.isEmpty) {
        await _crearCursoPorDefecto();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Crear curso por defecto cuando no hay cursos
  Future<void> _crearCursoPorDefecto() async {
    print('📚 Creando curso por defecto...');

    final cursoDefecto = 'Mi Curso - Mi Asignatura';

    setState(() {
      cursos.add(cursoDefecto);
      secciones[cursoDefecto] = ['A'];
      cursosOcultos[cursoDefecto] = false;
    });

    // Guardar el curso por defecto
    await _guardarDatos();

    print('✅ Curso por defecto creado: $cursoDefecto');

    // Mostrar mensaje de bienvenida después de que se haya renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mostrarMensajeBienvenida();
      }
    });
  }

  // Mostrar mensaje de bienvenida para el curso por defecto
  void _mostrarMensajeBienvenida() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.celebration, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Hemos creado un curso de ejemplo para ti.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '¿Qué puedes hacer?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              _InstruccionItem(
                icon: Icons.edit,
                texto: 'Pulsa el botón de opciones (⋮) y selecciona "Editar nombre" para cambiar el nombre del curso.',
              ),
              SizedBox(height: 8),
              _InstruccionItem(
                icon: Icons.add_circle,
                texto: 'Usa el botón (+) en la parte superior para crear más cursos.',
              ),
              SizedBox(height: 8),
              _InstruccionItem(
                icon: Icons.class_,
                texto: 'Pulsa sobre el curso para abrirlo y gestionar sus secciones.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Abrir directamente el diálogo de edición
              _editarNombreCurso(cursos[0], 0);
            },
            child: const Text('Cambiar nombre ahora'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // Guardar datos en Firebase
  Future<void> _guardarDatos() async {
    try {
      print('🔄 Iniciando sincronización con Firebase...');

      // Obtener cursos existentes en Firebase
      final cursosExistentes = await _cursosService.obtenerCursos();
      final cursosExistentesMap = <String, String>{};

      for (var c in cursosExistentes) {
        final nombreCompleto = '${c.nombre} - ${c.asignatura}';
        cursosExistentesMap[nombreCompleto] = c.id;
      }

      // Set de cursos actuales (para detectar eliminaciones)
      final cursosActualesSet = <String>{};

      // Crear/actualizar cada curso en Firebase
      for (var i = 0; i < cursos.length; i++) {
        final nombreCompleto = cursos[i];
        cursosActualesSet.add(nombreCompleto);

        final partes = nombreCompleto.split(' - ');
        if (partes.length >= 2) {
          final nombre = partes[0];
          final asignatura = partes.sublist(1).join(' - ');
          final seccionesCurso = secciones[nombreCompleto] ?? ['A'];
          final oculto = cursosOcultos[nombreCompleto] ?? false;

          if (cursosExistentesMap.containsKey(nombreCompleto)) {
            // Actualizar curso existente
            final cursoId = cursosExistentesMap[nombreCompleto];
            final success = await _cursosService.actualizarCurso(cursoId!, {
              'nombre': nombre,
              'asignatura': asignatura,
              'secciones': seccionesCurso,
              'oculto': oculto,
            });
            if (success) {
              print('  ✅ Curso actualizado: $nombreCompleto');
            } else {
              print('  ⚠️ Error al actualizar curso: $nombreCompleto');
            }
          } else {
            // Crear nuevo curso
            final result = await _cursosService.crearCurso(
              nombre: nombre,
              asignatura: asignatura,
              secciones: seccionesCurso,
              oculto: oculto,
            );
            if (result != null) {
              print('  ✅ Curso creado: $nombreCompleto');
            } else {
              print('  ⚠️ Error al crear curso: $nombreCompleto');
            }
          }
        }
      }

      // Eliminar cursos que ya no existen localmente
      for (var nombreCompleto in cursosExistentesMap.keys) {
        if (!cursosActualesSet.contains(nombreCompleto)) {
          final cursoId = cursosExistentesMap[nombreCompleto]!;
          final success = await _cursosService.eliminarCurso(cursoId);
          if (success) {
            print('  🗑️ Curso eliminado de Firebase: $nombreCompleto');
          } else {
            print('  ⚠️ Error al eliminar curso: $nombreCompleto');
          }
        }
      }

      print('✅ Sincronización con Firebase completada');
      print('   Total cursos: ${cursos.length}');
    } catch (e) {
      print('❌ Error al sincronizar con Firebase: $e');
    }
  }


  void _agregarCurso() {
    final nombreController = TextEditingController();
    final asignaturaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.add_circle, color: Colors.blue),
              SizedBox(width: 8),
              Text('Agregar Nuevo Curso'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Completa los siguientes datos:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Curso',
                    hintText: 'Ej: Tercero A',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: asignaturaController,
                  decoration: const InputDecoration(
                    labelText: 'Asignatura',
                    hintText: 'Ej: Lengua Española',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nombreController.dispose();
                asignaturaController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              onPressed: () async {
                final nombre = nombreController.text.trim();
                final asignatura = asignaturaController.text.trim();

                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa el nombre del curso'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (asignatura.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa la asignatura'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Formato: "Tercero A - Lengua Española"
                final nombreCompleto = '$nombre - $asignatura';

                print('📝 Usuario agregando curso: $nombreCompleto');

                setState(() {
                  // Agregar al inicio de la lista
                  cursos.insert(0, nombreCompleto);
                  secciones[nombreCompleto] = ['A'];
                });

                print('   Lista actualizada. Total cursos: ${cursos.length}');
                print('   Iniciando guardado...');

                await _guardarDatos();

                print('   ✅ Guardado completado');

                nombreController.dispose();
                asignaturaController.dispose();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Curso "$nombreCompleto" agregado exitosamente'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              label: const Text('Agregar Curso'),
            ),
          ],
        );
      },
    );
  }

  void _editarNombreCurso(String cursoActual, int index) {
    // Separar nombre y asignatura del curso actual
    final partes = cursoActual.split(' - ');
    final nombreActual = partes.isNotEmpty ? partes[0] : '';
    final asignaturaActual = partes.length > 1 ? partes.sublist(1).join(' - ') : '';

    final nombreController = TextEditingController(text: nombreActual);
    final asignaturaController = TextEditingController(text: asignaturaActual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Editar Curso'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personaliza tu curso:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Curso',
                    hintText: 'Ej: Tercero A',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: asignaturaController,
                  decoration: const InputDecoration(
                    labelText: 'Asignatura',
                    hintText: 'Ej: Lengua Española',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nombreController.dispose();
                asignaturaController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              onPressed: () async {
                final nuevoNombre = nombreController.text.trim();
                final nuevaAsignatura = asignaturaController.text.trim();

                if (nuevoNombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa el nombre del curso'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (nuevaAsignatura.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa la asignatura'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final nombreCompleto = '$nuevoNombre - $nuevaAsignatura';

                if (nombreCompleto != cursoActual) {
                  setState(() {
                    // Actualizar nombre en la lista
                    cursos[index] = nombreCompleto;
                    // Actualizar secciones con el nuevo nombre
                    secciones[nombreCompleto] = secciones[cursoActual]!;
                    secciones.remove(cursoActual);
                    // Actualizar estado oculto si existe
                    if (cursosOcultos.containsKey(cursoActual)) {
                      cursosOcultos[nombreCompleto] = cursosOcultos[cursoActual]!;
                      cursosOcultos.remove(cursoActual);
                    }
                  });
                  await _guardarDatos();

                  nombreController.dispose();
                  asignaturaController.dispose();

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Curso actualizado: $nombreCompleto'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  nombreController.dispose();
                  asignaturaController.dispose();
                  Navigator.pop(context);
                }
              },
              label: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarOpcionesCurso(String curso, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<String> listaSecciones = secciones[curso]!;
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      curso,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                      _editarNombreCurso(curso, index);
                    },
                    tooltip: 'Editar nombre',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${listaSecciones.length} ${listaSecciones.length == 1 ? "sección" : "secciones"}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              // Secciones
              ...listaSecciones.map((sec) => ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.class_, color: Colors.blue),
                    ),
                    title: Text('Sección $sec'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/curso_detalle',
                        arguments: {'curso': curso, 'seccion': sec},
                      );
                    },
                    onLongPress: () {
                      if (listaSecciones.length > 1) {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Eliminar Sección'),
                            content: Text('¿Deseas mover la sección $sec a la papelera?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    // Agregar a papelera de secciones
                                    if (!seccionesEliminadas.containsKey(curso)) {
                                      seccionesEliminadas[curso] = [];
                                    }
                                    seccionesEliminadas[curso]!.add(sec);
                                    // Remover de secciones activas
                                    secciones[curso]!.remove(sec);
                                  });
                                  await _guardarDatos();
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sección $sec de $curso movida a la papelera'),
                                        action: SnackBarAction(
                                          label: 'Ver papelera',
                                          onPressed: _mostrarPapelera,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Mover a papelera',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No puedes eliminar la única sección del curso'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  )),
              const Divider(),
              const SizedBox(height: 8),
              // Botones de acción
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.green),
                ),
                title: const Text('Agregar Sección'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  setState(() {
                    String ultima = listaSecciones.last;
                    String nueva = String.fromCharCode(ultima.codeUnitAt(0) + 1);
                    listaSecciones.add(nueva);
                  });
                  await _guardarDatos();
                  navigator.pop();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (cursosOcultos[curso] ?? false)
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    (cursosOcultos[curso] ?? false)
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: (cursosOcultos[curso] ?? false)
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
                title: Text(
                  (cursosOcultos[curso] ?? false)
                      ? 'Mostrar Curso'
                      : 'Ocultar Curso',
                ),
                onTap: () async {
                  setState(() {
                    cursosOcultos[curso] = !(cursosOcultos[curso] ?? false);
                  });
                  await _guardarDatos();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          cursosOcultos[curso]!
                              ? 'Curso ocultado. Activa "Mostrar ocultos" para verlo.'
                              : 'Curso visible nuevamente',
                        ),
                        backgroundColor: cursosOcultos[curso]!
                            ? Colors.orange
                            : Colors.green,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarPapelera() {
    // Calcular total de items
    int totalSeccionesEliminadas = 0;
    seccionesEliminadas.forEach((curso, secciones) {
      totalSeccionesEliminadas += secciones.length;
    });
    int totalItems = cursosEliminados.length + totalSeccionesEliminadas;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Papelera',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$totalItems ${totalItems == 1 ? "elemento eliminado" : "elementos eliminados"}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: totalItems == 0
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.delete_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay elementos eliminados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          // Cursos eliminados
                          if (cursosEliminados.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Cursos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...cursosEliminados.asMap().entries.map((entry) {
                              final index = entry.key;
                              final cursoData = entry.value;
                              final nombreCurso = cursoData['curso'] as String;
                              final seccionesCurso = cursoData['secciones'] as List<String>;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.school, color: Colors.orange),
                                  ),
                                  title: Text(nombreCurso),
                                  subtitle: Text(
                                    '${seccionesCurso.length} ${seccionesCurso.length == 1 ? "sección" : "secciones"}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.restore, color: Colors.green),
                                        onPressed: () async {
                                          setState(() {
                                            cursos.add(nombreCurso);
                                            secciones[nombreCurso] = List<String>.from(seccionesCurso);
                                            cursosEliminados.removeAt(index);
                                          });
                                          await _guardarDatos();
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('$nombreCurso restaurado'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                        tooltip: 'Restaurar',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Eliminar permanentemente'),
                                              content: Text(
                                                '¿Estás seguro de eliminar "$nombreCurso" permanentemente? Esta acción no se puede deshacer.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      cursosEliminados.removeAt(index);
                                                    });
                                                    await _guardarDatos();
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Curso eliminado permanentemente'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Eliminar',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        tooltip: 'Eliminar permanentemente',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                          // Secciones eliminadas
                          if (seccionesEliminadas.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Secciones',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...seccionesEliminadas.entries.expand((entry) {
                              final curso = entry.key;
                              final seccionesDelCurso = entry.value;
                              return seccionesDelCurso.map((seccion) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.class_, color: Colors.purple),
                                    ),
                                    title: Text('Sección $seccion'),
                                    subtitle: Text(curso),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.restore, color: Colors.green),
                                          onPressed: () async {
                                            setState(() {
                                              if (secciones.containsKey(curso)) {
                                                secciones[curso]!.add(seccion);
                                              }
                                              seccionesEliminadas[curso]!.remove(seccion);
                                              if (seccionesEliminadas[curso]!.isEmpty) {
                                                seccionesEliminadas.remove(curso);
                                              }
                                            });
                                            await _guardarDatos();
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Sección $seccion de $curso restaurada'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                          tooltip: 'Restaurar',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Eliminar permanentemente'),
                                                content: Text(
                                                  '¿Estás seguro de eliminar la Sección $seccion de $curso permanentemente?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        seccionesEliminadas[curso]!.remove(seccion);
                                                        if (seccionesEliminadas[curso]!.isEmpty) {
                                                          seccionesEliminadas.remove(curso);
                                                        }
                                                      });
                                                      await _guardarDatos();
                                                      if (context.mounted) {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Sección eliminada permanentemente'),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: const Text(
                                                      'Eliminar',
                                                      style: TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          tooltip: 'Eliminar permanentemente',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            }),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _eliminarCurso(String curso, int index) async {
    setState(() {
      cursosEliminados.add({
        'curso': curso,
        'secciones': List<String>.from(secciones[curso]!),
      });
      secciones.remove(curso);
      cursos.removeAt(index);
    });
    await _guardarDatos();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$curso movido a la papelera'),
          action: SnackBarAction(
            label: 'Ver papelera',
            onPressed: _mostrarPapelera,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_modoReordenar ? 'Reordenar Cursos' : 'Cursos'),
        actions: [
          if (!_modoReordenar) ...[
            IconButton(
              icon: Icon(
                _mostrarOcultos ? Icons.visibility : Icons.visibility_off,
                color: _mostrarOcultos ? AppColors.primary : AppColors.textTertiary,
              ),
              onPressed: () {
                setState(() {
                  _mostrarOcultos = !_mostrarOcultos;
                });
              },
              tooltip: _mostrarOcultos ? 'Ocultar cursos ocultos' : 'Mostrar cursos ocultos',
            ),
            IconButton(
              icon: const Icon(Icons.swap_vert),
              onPressed: () {
                setState(() {
                  _modoReordenar = true;
                });
              },
              tooltip: 'Reordenar cursos',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _mostrarPapelera,
              tooltip: 'Papelera',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _agregarCurso,
              tooltip: 'Agregar curso',
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _modoReordenar = false;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await _guardarDatos();

                if (mounted) {
                  setState(() {
                    _modoReordenar = false;
                  });

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Orden guardado exitosamente'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Listo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Cabecera con foto y datos del docente
                  Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/perfil');
                    },
                    child: const AvatarGeneroWidget(radius: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombreUsuario,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Centro Educativo Eugenio M. de Hostos',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Regional: 17 | Distrito: 04',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Lista de cursos o mensaje cuando está vacío
              Expanded(
                child: cursos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 100,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No hay cursos registrados',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Presiona el botón + para crear tu primer curso',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _agregarCurso,
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Curso'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _modoReordenar
                      ? ReorderableListView.builder(
                          itemCount: cursos.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final curso = cursos.removeAt(oldIndex);
                              cursos.insert(newIndex, curso);
                            });
                          },
                          itemBuilder: (context, index) {
                            String curso = cursos[index];
                            final isHidden = cursosOcultos[curso] ?? false;

                            List<String> listaSecciones = secciones[curso]!;
                            final cursoId = curso.toLowerCase().replaceAll(' ', '_').replaceAll('-', '');
                            final isActive = _cursoActivoId == cursoId;

                            return Container(
                              key: ValueKey(curso),
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isHidden ? AppColors.surfaceVariant : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: isActive
                                    ? Border.all(color: AppColors.secondary, width: 2)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.drag_handle, color: AppColors.textTertiary),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _getColorForIndex(index).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.school,
                                      color: _getColorForIndex(index),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          curso,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isHidden ? AppColors.textDisabled : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${listaSecciones.length} ${listaSecciones.length == 1 ? "sección" : "secciones"}',
                                          style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: cursos.length,
                          itemBuilder: (context, index) {
                            String curso = cursos[index];
                            final isHidden = cursosOcultos[curso] ?? false;

                            // Filtrar cursos ocultos según el toggle
                            if (isHidden && !_mostrarOcultos) {
                              return const SizedBox.shrink();
                            }

                            List<String> listaSecciones = secciones[curso]!;
                            final cursoId = curso.toLowerCase().replaceAll(' ', '_').replaceAll('-', '');
                            final isActive = _cursoActivoId == cursoId;

                            return _CursoCard(
                              curso: curso,
                              numSecciones: listaSecciones.length,
                              isActive: isActive,
                              isHidden: isHidden,
                              onTap: () {
                                // Un solo clic: seleccionar como curso activo
                                _seleccionarCursoActivo(curso, index);
                              },
                              onDoubleTap: () {
                                // Doble clic: abrir el curso
                                Navigator.pushNamed(
                                  context,
                                  '/curso_detalle',
                                  arguments: {'curso': curso, 'seccion': listaSecciones.first},
                                );
                              },
                              onOptionsPressed: () => _mostrarOpcionesCurso(curso, index),
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar Curso'),
                                    content: Text('¿Deseas mover "$curso" a la papelera?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _eliminarCurso(curso, index);
                                        },
                                        child: const Text(
                                          'Mover a papelera',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              color: _getColorForIndex(index),
                            );
                          },
                        ),
              ),
                ],
              ),
            ),
          ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.tertiary,
      AppColors.info,
      AppColors.success,
    ];
    return colors[index % colors.length];
  }
}

// Widget para mostrar instrucciones en el diálogo de bienvenida
class _InstruccionItem extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _InstruccionItem({
    required this.icon,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _CursoCard extends StatelessWidget {
  final String curso;
  final int numSecciones;
  final bool isActive;
  final bool isHidden;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onOptionsPressed;
  final Color color;

  const _CursoCard({
    required this.curso,
    required this.numSecciones,
    this.isActive = false,
    this.isHidden = false,
    required this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onOptionsPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHidden ? AppColors.surfaceVariant : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: AppColors.secondary, width: 2)
              : isHidden
                  ? Border.all(color: AppColors.divider, width: 1)
                  : null,
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.secondary.withOpacity(0.2)
                  : isHidden
                      ? AppColors.textPrimary.withOpacity(0.04)
                      : AppColors.textPrimary.withOpacity(0.08),
              blurRadius: isActive ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.school,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          curso,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isHidden ? AppColors.textDisabled : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isHidden)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility_off, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Oculto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Activo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$numSecciones ${numSecciones == 1 ? "sección" : "secciones"}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            if (onOptionsPressed != null)
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textTertiary),
                onPressed: onOptionsPressed,
                tooltip: 'Opciones',
              ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
