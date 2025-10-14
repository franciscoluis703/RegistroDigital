import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AsistenciasMenuScreen extends StatefulWidget {
  const AsistenciasMenuScreen({super.key});

  @override
  State<AsistenciasMenuScreen> createState() => _AsistenciasMenuScreenState();
}

class _AsistenciasMenuScreenState extends State<AsistenciasMenuScreen> {
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
    // Obtener argumentos del curso/sección
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final curso = args?['curso'] ?? 'Curso';
    final seccion = args?['seccion'] ?? 'A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Asistencias - $curso Sec. $seccion'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Cabecera con información del curso
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school,
                            size: 20,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$curso - Sección $seccion',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Título
              const Text(
                'Selecciona el tipo de asistencia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Botones de asistencia
              Expanded(
                child: Column(
                  children: [
                    _MenuCard(
                      icon: Icons.checklist,
                      label: 'Registro de asistencia',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/asistencia',
                          arguments: {
                            'curso': curso,
                            'seccion': seccion,
                            'docente': _nombreDocente,
                          },
                        );
                      },
                      color: Colors.green,
                    ),
                    _MenuCard(
                      icon: Icons.assessment,
                      label: 'Asistencia a Evaluaciones Completivas',
                      onTap: () {
                        Navigator.pushNamed(context, '/asistencia_evaluaciones');
                      },
                      color: Colors.teal,
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
                color: color.withOpacity(0.2),
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
