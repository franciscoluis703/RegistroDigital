// lib/app/presentation/modules/home/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/providers/user_provider.dart';
import '../../../widgets/avatar_genero_widget.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/duo_card.dart';
import '../../../widgets/common/duo_button.dart';
import '../../../../../app/presentation/routes/routes.dart';
import '../../../../data/services/firebase/firebase_auth_service.dart';

/// 🦉 Pantalla de Home/Dashboard - Diseño Duolingo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mapa de actividades disponibles con su información
  final Map<String, Map<String, dynamic>> _actividadesDisponibles = {
    'asistencia': {
      'icon': Icons.check_circle_outline,
      'label': 'Asistencia',
      'route': '/asistencias_menu',
      'color': AppColors.primary,
    },
    'calificaciones': {
      'icon': Icons.grade,
      'label': 'Calificaciones',
      'route': '/calificaciones',
      'color': AppColors.warning,
    },
    'promocion': {
      'icon': Icons.school,
      'label': 'Promoción',
      'route': '/promocion_grado',
      'color': AppColors.accent,
    },
    'horario': {
      'icon': Icons.access_time,
      'label': 'Horario',
      'route': '/horario-clase',
      'color': AppColors.tertiary,
    },
    'calendario': {
      'icon': Icons.calendar_today,
      'label': 'Calendario',
      'route': '/calendario-escolar',
      'color': AppColors.pink,
    },
    'cursos': {
      'icon': Icons.class_outlined,
      'label': 'Cursos',
      'route': '/cursos',
      'color': AppColors.secondary,
    },
    'perfil': {
      'icon': Icons.person,
      'label': 'Perfil',
      'route': '/perfil',
      'color': AppColors.accent,
    },
    'notas': {
      'icon': Icons.note_add,
      'label': 'Notas',
      'route': '/notas',
      'color': AppColors.primary,
    },
    'evidencias': {
      'icon': Icons.photo_library,
      'label': 'Evidencias',
      'route': '/evidencias',
      'color': AppColors.secondary,
    },
  };

  // Lista de actividades más usadas
  List<String> _actividadesFrecuentes = [];

  @override
  void initState() {
    super.initState();
    _cargarActividadesFrecuentes();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.cargarDatosUsuario();
    });
  }

  Future<void> _cargarActividadesFrecuentes() async {
    final prefs = await SharedPreferences.getInstance();
    final actividadesJson = prefs.getString('actividades_uso');

    if (actividadesJson != null) {
      final Map<String, dynamic> usoActividades = json.decode(actividadesJson);
      final actividadesOrdenadas = usoActividades.entries.toList()
        ..sort((a, b) => (b.value as int).compareTo(a.value as int));

      setState(() {
        _actividadesFrecuentes = actividadesOrdenadas
            .map((e) => e.key)
            .take(4)
            .toList();
      });
    } else {
      setState(() {
        _actividadesFrecuentes = [
          'asistencia',
          'calificaciones',
          'notas',
          'evidencias',
        ];
      });
    }
  }

  Future<void> _registrarUsoActividad(String actividadId) async {
    final prefs = await SharedPreferences.getInstance();
    final actividadesJson = prefs.getString('actividades_uso');

    Map<String, dynamic> usoActividades = {};
    if (actividadesJson != null) {
      usoActividades = json.decode(actividadesJson);
    }

    usoActividades[actividadId] = (usoActividades[actividadId] ?? 0) + 1;
    await prefs.setString('actividades_uso', json.encode(usoActividades));
    await _cargarActividadesFrecuentes();
  }

  void _navegarAActividad(String actividadId, String ruta) {
    _registrarUsoActividad(actividadId);
    Navigator.pushNamed(context, ruta);
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          DuoButton(
            text: 'Cerrar sesión',
            style: DuoButtonStyle.error,
            size: DuoButtonSize.small,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final authService = FirebaseAuthService();
        final result = await authService.signOut();

        if (!result['success']) {
          throw Exception(result['message']);
        }

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.signIn,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registro Docente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de bienvenida limpia estilo Duolingo
                DuoCard(
                  style: DuoCardStyle.normal,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _navegarAActividad('perfil', '/perfil'),
                        child: const AvatarGeneroWidget(radius: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola, ${userProvider.nombre.isEmpty ? 'Usuario' : userProvider.nombre.split(' ')[0]}!',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userProvider.centroEducativo.isEmpty
                                      ? 'Centro Educativo'
                                      : userProvider.centroEducativo,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de Cursos prominente estilo Duolingo
                DuoCard(
                  style: DuoCardStyle.primary,
                  padding: const EdgeInsets.all(20),
                  onTap: () => _navegarAActividad('cursos', '/cursos'),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mis Cursos',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Gestiona tus grupos',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Accesos rápidos
                Text(
                  'Accesos Rápidos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),

                _actividadesFrecuentes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _actividadesFrecuentes.length,
                        itemBuilder: (context, index) {
                          final actividadId = _actividadesFrecuentes[index];
                          final actividad = _actividadesDisponibles[actividadId];
                          if (actividad == null) return const SizedBox.shrink();

                          return _QuickAccessCard(
                            icon: actividad['icon'] as IconData,
                            label: actividad['label'] as String,
                            color: actividad['color'] as Color,
                            onTap: () => _navegarAActividad(
                              actividadId,
                              actividad['route'] as String,
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 32),

                // Todas las actividades
                Text(
                  'Más Opciones',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),

                _buildActivityCard(
                  'Bloc de Notas',
                  'Registra notas rápidas',
                  Icons.note_add,
                  AppColors.primary,
                  () => _navegarAActividad('notas', '/notas'),
                ),
                _buildActivityCard(
                  'Evidencias',
                  'Gestiona fotos y documentos',
                  Icons.photo_library,
                  AppColors.secondary,
                  () => _navegarAActividad('evidencias', '/evidencias'),
                ),
                _buildActivityCard(
                  'Mi Perfil',
                  'Actualiza tu información',
                  Icons.person,
                  AppColors.accent,
                  () => _navegarAActividad('perfil', '/perfil'),
                ),

                const SizedBox(height: 24),

                // Footer limpio
                Center(
                  child: Text(
                    'Versión 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DuoCard(
        style: DuoCardStyle.flat,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      style: DuoCardStyle.flat,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
