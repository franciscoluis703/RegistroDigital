import 'package:flutter/material.dart';
import '../../data/services/estudiantes_service.dart';

class EstudianteNombreWidget extends StatelessWidget {
  final int numero;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color? backgroundColor;
  final BoxDecoration? decoration;

  const EstudianteNombreWidget({
    super.key,
    required this.numero,
    this.style,
    this.textAlign,
    this.backgroundColor,
    this.decoration,
  });

  Future<void> _mostrarNombreEstudiante(BuildContext context) async {
    final nombres = await EstudiantesService().obtenerNombresEstudiantes();

    if (!context.mounted) return;

    String nombre = 'Sin nombre registrado';
    if (numero <= nombres.length && nombres[numero - 1].isNotEmpty) {
      nombre = nombres[numero - 1];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#$numero',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Estudiante'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => _mostrarNombreEstudiante(context),
      child: Container(
        decoration: decoration,
        color: backgroundColor,
        child: Text(
          '$numero',
          style: style,
          textAlign: textAlign,
        ),
      ),
    );
  }
}
