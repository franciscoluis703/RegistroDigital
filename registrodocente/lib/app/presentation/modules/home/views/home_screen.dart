
// lib/app/presentation/modules/home/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../widgets/avatar_genero_widget.dart';
import '../../../routes/routes.dart';
import '../../../../data/services/supabase_service.dart';

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
    },
    'calificaciones': {
      'icon': Icons.grade,
      'label': 'Calificaciones',
      'route': '/calificaciones',
    },
    'promocion': {
      'icon': Icons.school,
      'label': 'Promoción',
      'route': '/promocion_grado',
    },
    'horario': {
      'icon': Icons.access_time,
      'label': 'Horario',
      'route': '/horario-clase',
    },
    'calendario': {
      'icon': Icons.calendar_today,
      'label': 'Calendario',
      'route': '/calendario-escolar',
    },
    'cursos': {
      'icon': Icons.home,
      'label': 'Cursos',
      'route': '/cursos',
    },
    'perfil': {
      'icon': Icons.person,
      'label': 'Perfil',
      'route': '/perfil',
    },
  };

  // Lista de actividades más usadas (ordenadas por frecuencia)
  List<String> _actividadesFrecuentes = [];

  // Datos del usuario
  String _nombreUsuario = 'Usuario';
  String _emailUsuario = '';

  @override
  void initState() {
    super.initState();
    _cargarActividadesFrecuentes();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreUsuario = prefs.getString('usuario_nombre') ?? 'Usuario';
      _emailUsuario = prefs.getString('usuario_email') ?? '';
    });
  }

  Future<void> _cargarActividadesFrecuentes() async {
    final prefs = await SharedPreferences.getInstance();
    final actividadesJson = prefs.getString('actividades_uso');

    if (actividadesJson != null) {
      // Cargar el mapa de uso de actividades
      final Map<String, dynamic> usoActividades = json.decode(actividadesJson);

      // Ordenar por frecuencia de uso (de mayor a menor)
      final actividadesOrdenadas = usoActividades.entries.toList()
        ..sort((a, b) => (b.value as int).compareTo(a.value as int));

      setState(() {
        _actividadesFrecuentes = actividadesOrdenadas
          .map((e) => e.key)
          .take(5)
          .toList();
      });
    } else {
      // Si no hay datos, usar actividades por defecto
      setState(() {
        _actividadesFrecuentes = [
          'asistencia',
          'calificaciones',
          'promocion',
          'horario',
          'calendario',
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

    // Incrementar el contador de uso
    usoActividades[actividadId] = (usoActividades[actividadId] ?? 0) + 1;

    // Guardar actualizado
    await prefs.setString('actividades_uso', json.encode(usoActividades));

    // Recargar las actividades frecuentes
    await _cargarActividadesFrecuentes();
  }

  void _navegarAActividad(String actividadId, String ruta) {
    _registrarUsoActividad(actividadId);
    Navigator.pushNamed(context, ruta);
  }

  void _mostrarAdvertencias(BuildContext context) {
    // Lista de advertencias (esto debería venir de una fuente de datos real)
    final List<Map<String, dynamic>> advertencias = [
      {
        'titulo': 'Asistencias pendientes',
        'descripcion': 'Tienes 3 días sin registrar asistencia en Lengua Española',
        'tipo': 'asistencia',
        'icono': Icons.check_circle_outline,
        'color': Colors.orange,
        'ruta': '/asistencias_menu',
        'actividadId': 'asistencia',
      },
      {
        'titulo': 'Calificaciones incompletas',
        'descripcion': '5 estudiantes sin calificación en el periodo actual',
        'tipo': 'calificaciones',
        'icono': Icons.grade,
        'color': Colors.red,
        'ruta': '/calificaciones',
        'actividadId': 'calificaciones',
      },
      {
        'titulo': 'Horario sin configurar',
        'descripcion': 'Aún no has configurado tu horario de clases',
        'tipo': 'horario',
        'icono': Icons.access_time,
        'color': Colors.blue,
        'ruta': '/horario-clase',
        'actividadId': 'horario',
      },
    ];

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
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Advertencias',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${advertencias.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${advertencias.length} ${advertencias.length == 1 ? "advertencia pendiente" : "advertencias pendientes"}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: advertencias.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay advertencias',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: advertencias.length,
                        itemBuilder: (context, index) {
                          final advertencia = advertencias[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: (advertencia['color'] as Color).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _navegarAActividad(
                                  advertencia['actividadId'] as String,
                                  advertencia['ruta'] as String,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: (advertencia['color'] as Color).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        advertencia['icono'] as IconData,
                                        color: advertencia['color'] as Color,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            advertencia['titulo'] as String,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            advertencia['descripcion'] as String,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: advertencia['color'] as Color,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _SettingsBottomSheet(),
    );
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        // Cerrar sesión en Supabase
        final supabase = SupabaseService.instance;
        await supabase.signOut();

        // Limpiar datos locales (opcional - si quieres mantener preferencias del usuario, comenta estas líneas)
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.clear();

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
              content: Text('Error al cerrar sesión: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Cabecera con foto y datos
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _navegarAActividad('perfil', '/perfil');
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
                        const SizedBox(height: 4),
                        const Text(
                          'Centro Educativo Eugenio M. deHostos',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Regional: 17 | Distrito: 04',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón de advertencias
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 28, color: Colors.orange),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => _mostrarAdvertencias(context),
                    tooltip: 'Advertencias',
                  ),
                  // Botón de configuración
                  IconButton(
                    icon: const Icon(Icons.settings, size: 28),
                    onPressed: () => _showSettingsBottomSheet(context),
                    tooltip: 'Configuración',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Accesos rápidos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.flash_on, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Accesos Rápidos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _actividadesFrecuentes.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _actividadesFrecuentes.map((actividadId) {
                            final actividad = _actividadesDisponibles[actividadId];
                            if (actividad == null) return const SizedBox.shrink();

                            return _QuickAccessChip(
                              icon: actividad['icon'] as IconData,
                              label: actividad['label'] as String,
                              onTap: () => _navegarAActividad(
                                actividadId,
                                actividad['route'] as String,
                              ),
                            );
                          }).toList(),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Botones tipo card
              Expanded(
                child: Column(
                  children: [
                    _MenuCard(
                      icon: Icons.home,
                      label: 'Cursos',
                      onTap: () {
                        _navegarAActividad('cursos', '/cursos');
                      },
                      color: Colors.red,
                    ),
                    _MenuCard(
                      icon: Icons.access_time,
                      label: 'Horario de clase',
                      onTap: () {
                        _navegarAActividad('horario', '/horario-clase');
                      },
                      color: Colors.orange,
                    ),
                    _MenuCard(
                      icon: Icons.calendar_today,
                      label: 'Calendario escolar',
                      onTap: () {
                        _navegarAActividad('calendario', '/calendario-escolar');
                      },
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _SettingsBottomSheet extends StatefulWidget {
  const _SettingsBottomSheet();

  @override
  State<_SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<_SettingsBottomSheet> {
  Future<void> _handleSignOut() async {
    try {
      // Cerrar sesión en Supabase
      final supabase = SupabaseService.instance;
      await supabase.signOut();

      // Limpiar datos locales (opcional)
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();

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
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Opción de cerrar sesión
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context); // Cerrar bottom sheet

              // Confirmar antes de cerrar sesión
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
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                _handleSignOut();
              }
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
