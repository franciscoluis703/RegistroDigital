
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralInfoScreen extends StatefulWidget {
  const GeneralInfoScreen({super.key});

  @override
  State<GeneralInfoScreen> createState() => _GeneralInfoScreenState();
}

class _GeneralInfoScreenState extends State<GeneralInfoScreen> {
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

  void _guardarDatos() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos guardados correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Datos Generales'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
            onPressed: _guardarDatos,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Cabecera con foto y datos del docente/centro
              Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=3', // Cambia por tu imagen
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombreDocente,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
              // Botones
              Expanded(
                child: ListView(
                  children: [
                    _MenuCard(
                      icon: Icons.person,
                      label: 'Información del Centro',
                      onTap: () {
                        Navigator.pushNamed(context, '/centro_educativo');
                      },
                      color: Colors.blue,
                    ),
                    _MenuCard(
                      icon: Icons.person_outline,
                      label: 'Datos generales del estudiante',
                      onTap: () {
                        Navigator.pushNamed(context, '/general_student');
                      },
                      color: Colors.green,
                    ),
                    _MenuCard(
                      icon: Icons.assessment,
                      label: 'Condición inicial del estudiante',
                      onTap: () {
                        Navigator.pushNamed(context, '/condicion_inicial');
                      },
                      color: Colors.orange,
                    ),
                    _MenuCard(
                      icon: Icons.medical_services,
                      label: 'Datos para emergencias',
                      onTap: () {
                        Navigator.pushNamed(context, '/emergency_data');
                      },
                      color: Colors.red,
                    ),
                    _MenuCard(
                      icon: Icons.family_restroom,
                      label: 'Parentesco',
                      onTap: () {
                        Navigator.pushNamed(context, '/parentesco');
                      },
                      color: Colors.purple,
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
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
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
