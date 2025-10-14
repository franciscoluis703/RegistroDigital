// lib/app/presentation/modules/home/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/providers/user_provider.dart';
import '../../../widgets/avatar_genero_widget.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/dojo_card.dart';
import '../../../widgets/common/dojo_badge.dart';
import '../../../widgets/common/dojo_button.dart';
import '../../../../../app/presentation/routes/routes.dart';
import '../../../../data/services/firebase/firebase_auth_service.dart';

/// 🎨 Pantalla de Home/Dashboard - Diseño ClassDojo
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
      'color': AppColors.secondary,
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
      'color': AppColors.info,
    },
    'cursos': {
      'icon': Icons.class_outlined,
      'label': 'Cursos',
      'route': '/cursos',
      'color': AppColors.error,
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
      'color': AppColors.accent,
    },
    'evidencias': {
      'icon': Icons.photo_library,
      'label': 'Evidencias',
      'route': '/evidencias',
      'color': AppColors.info,
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
            .take(6)
            .toList();
      });
    } else {
      setState(() {
        _actividadesFrecuentes = [
          'asistencia',
          'calificaciones',
          'promocion',
          'horario',
          'calendario',
          'cursos',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 12),
            Text('Cerrar sesión'),
          ],
        ),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cerrar sesión'),
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
        title: Row(
          children: const [
            Icon(Icons.menu_book, size: 24),
            SizedBox(width: 8),
            Text('Registro Docente'),
          ],
        ),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de bienvenida con diseño ClassDojo
                DojoCard(
                  style: DojoCardStyle.gradient,
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _navegarAActividad('perfil', '/perfil'),
                        child: const AvatarGeneroWidget(radius: 35),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola, ${userProvider.nombre.isEmpty ? 'Usuario' : userProvider.nombre.split(' ')[0]}! 👋',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userProvider.centroEducativo.isEmpty
                                      ? 'Centro Educativo'
                                      : userProvider.centroEducativo,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
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

                // Botón prominente de Cursos
                DojoButton(
                  text: 'Mis Cursos',
                  icon: Icons.class_outlined,
                  style: DojoButtonStyle.secondary,
                  size: DojoButtonSize.large,
                  isFullWidth: true,
                  onPressed: () => _navegarAActividad('cursos', '/cursos'),
                ),
                const SizedBox(height: 32),

                // Accesos rápidos
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: AppColors.tertiary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Accesos Rápidos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _actividadesFrecuentes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
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
                Row(
                  children: [
                    const Icon(Icons.apps, color: AppColors.secondary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Todas las Actividades',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildActivityCard(
                  'Bloc de Notas',
                  'Registra notas rápidas y observaciones',
                  Icons.note_add,
                  AppColors.accent,
                  () => _navegarAActividad('notas', '/notas'),
                ),
                _buildActivityCard(
                  'Evidencias',
                  'Gestiona fotos y documentos',
                  Icons.photo_library,
                  AppColors.info,
                  () => _navegarAActividad('evidencias', '/evidencias'),
                ),
                _buildActivityCard(
                  'Mi Perfil',
                  'Actualiza tu información personal',
                  Icons.person,
                  AppColors.secondary,
                  () => _navegarAActividad('perfil', '/perfil'),
                ),

                const SizedBox(height: 24),

                // Footer con versión
                Center(
                  child: Text(
                    'Versión 1.0.0 • ClassDojo Style',
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
      child: DojoCard(
        style: DojoCardStyle.normal,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textTertiary),
            ],
          ),
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
    return DojoCard(
      style: DojoCardStyle.normal,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
