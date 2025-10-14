import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/routes.dart';
import '../../../widgets/avatar_genero_widget.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/educational_card.dart';
import '../../../../data/services/firebase/estudiantes_firestore_service.dart';
import '../../../../data/services/curso_context_service.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../widgets/participation_wheel_widget.dart';

class CursoDetalleScreen extends StatefulWidget {
  const CursoDetalleScreen({super.key});

  @override
  State<CursoDetalleScreen> createState() => _CursoDetalleScreenState();
}

class _CursoDetalleScreenState extends State<CursoDetalleScreen> {
  String _nombreDocente = 'Usuario';
  final EstudiantesFirestoreService _estudiantesService = EstudiantesFirestoreService();
  final CursoContextService _cursoContext = CursoContextService();
  List<String> _nombresEstudiantes = [];
  String _cursoActual = '';
  String _seccionActual = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cargar argumentos de la ruta
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      _cursoActual = args['curso'] ?? 'Curso';
      _seccionActual = args['seccion'] ?? 'A';
    }
  }

  @override
  void initState() {
    super.initState();
    // Se cargará después de que se inicialicen las dependencias
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosUsuario();
      _cargarEstudiantes();
    });
  }

  Future<void> _cargarDatosUsuario() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _nombreDocente = userProvider.nombre.isNotEmpty ? userProvider.nombre : 'Usuario';
    });
  }

  Future<void> _cargarEstudiantes() async {
    if (_cursoActual.isEmpty) return;

    // Generar cursoId desde el nombre
    final cursoId = _cursoActual.toLowerCase().replaceAll(' ', '_').replaceAll('-', '');

    try {
      final estudiantes = await _estudiantesService.obtenerEstudiantes(cursoId);
      setState(() {
        _nombresEstudiantes = estudiantes.map((e) => e.nombre).toList();
      });
    } catch (e) {
      print('Error al cargar estudiantes: $e');
    }
  }

  void _mostrarRuletaParticipacion() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: 500,
          ),
          child: SingleChildScrollView(
            child: ParticipationWheelWidget(
              studentNames: _nombresEstudiantes,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener los argumentos pasados desde la navegación
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'Curso';
    final seccion = args?['seccion'] ?? 'A';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(curso),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Cabecera con foto y datos del docente
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.perfil);
                          },
                          child: const AvatarGeneroWidget(radius: 35),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nombreDocente,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Centro Educativo Eugenio M. de Hostos',
                                style: TextStyle(fontSize: 13),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Regional: 17 | Distrito: 04',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.withOpacity(0.3)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.school,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                curso,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón de ruleta de participación
              GestureDetector(
                onTap: _mostrarRuletaParticipacion,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[600]!,
                        Colors.purple[800]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.casino,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Ruleta de Participación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botones tipo card
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      EducationalCard(
                        icon: Icons.description,
                        title: 'Datos generales',
                        subtitle: 'Información de estudiantes',
                        color: AppColors.datosGenerales,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.generalInfo,
                            arguments: {'curso': curso, 'seccion': seccion},
                          );
                        },
                      ),
                      EducationalCard(
                        icon: Icons.checklist,
                        title: 'Asistencias',
                        subtitle: 'Control de asistencia',
                        color: AppColors.asistencia,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.asistenciasMenu,
                            arguments: {
                              'curso': curso,
                              'seccion': seccion,
                            },
                          );
                        },
                      ),
                      EducationalCard(
                        icon: Icons.grade,
                        title: 'Calificaciones de rendimiento',
                        subtitle: 'Evaluaciones y notas',
                        color: AppColors.calificaciones,
                        onTap: () async {
                          // Establecer el cursoId antes de navegar
                          final cursoId = curso.toLowerCase().replaceAll(' ', '_').replaceAll('-', '');
                          await _cursoContext.establecerCursoActual(cursoId);

                          if (mounted) {
                            Navigator.pushNamed(
                              context,
                              Routes.calificaciones,
                              arguments: {
                                'curso': curso,
                                'seccion': seccion,
                              },
                            );
                          }
                        },
                      ),
                      EducationalCard(
                        icon: Icons.trending_up,
                        title: 'Promoción del grado',
                        subtitle: 'Avance académico',
                        color: AppColors.promocion,
                        onTap: () async {
                          // Establecer el cursoId antes de navegar
                          final cursoId = curso.toLowerCase().replaceAll(' ', '_').replaceAll('-', '');
                          await _cursoContext.establecerCursoActual(cursoId);

                          if (mounted) {
                            Navigator.pushNamed(
                              context,
                              Routes.promocionGrado,
                              arguments: {
                                'curso': curso,
                                'seccion': seccion,
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
