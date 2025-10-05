import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/routes.dart';
import '../../../widgets/avatar_genero_widget.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/educational_card.dart';

class CursoDetalleScreen extends StatefulWidget {
  const CursoDetalleScreen({super.key});

  @override
  State<CursoDetalleScreen> createState() => _CursoDetalleScreenState();
}

class _CursoDetalleScreenState extends State<CursoDetalleScreen> {
  String _nombreDocente = 'Usuario';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('usuario_nombre') ?? 'Usuario';
    setState(() {
      _nombreDocente = nombre;
    });
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
                      color: AppColors.textPrimary.withValues(alpha: 0.08),
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
                    Divider(color: Colors.grey.withValues(alpha: 0.3)),
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
                                '$curso - Sección $seccion',
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
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.calificaciones,
                            arguments: {
                              'curso': curso,
                              'seccion': seccion,
                            },
                          );
                        },
                      ),
                      EducationalCard(
                        icon: Icons.trending_up,
                        title: 'Promoción del grado',
                        subtitle: 'Avance académico',
                        color: AppColors.promocion,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.promocionGrado,
                            arguments: {
                              'curso': curso,
                              'seccion': seccion,
                            },
                          );
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
