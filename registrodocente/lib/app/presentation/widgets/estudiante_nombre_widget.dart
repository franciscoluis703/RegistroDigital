import 'package:flutter/material.dart';
// import '../../data/services/firebase/estudiantes_firestore_service.dart';

class EstudianteNombreWidget extends StatelessWidget {
  final int numero;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color? backgroundColor;
  final BoxDecoration? decoration;
  final String? cursoId; // Opcional - para futuras mejoras

  const EstudianteNombreWidget({
    super.key,
    required this.numero,
    this.style,
    this.textAlign,
    this.backgroundColor,
    this.decoration,
    this.cursoId,
  });

  Future<void> _mostrarNombreEstudiante(BuildContext context) async {
    // Nota: La funcionalidad de mostrar nombres requiere cursoId
    // Por ahora solo mostramos el número
    // TODO: Implementar obtención de nombre desde EstudiantesFirestoreService

    if (!context.mounted) return;

    String nombre = 'Estudiante #$numero';
    // Si en el futuro se proporciona cursoId:
    // if (cursoId != null) {
    //   final nombres = await EstudiantesFirestoreService().obtenerNombresEstudiantes(cursoId!);
    //   if (numero <= nombres.length && nombres[numero - 1].isNotEmpty) {
    //     nombre = nombres[numero - 1];
    //   }
    // }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#$numero',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
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
              'Número:',
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
      onTap: () => _mostrarNombreEstudiante(context),
      onLongPress: () => _mostrarNombreEstudiante(context),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: decoration ?? (backgroundColor != null ? BoxDecoration(color: backgroundColor) : null),
        alignment: Alignment.center,
        child: Text(
          '$numero',
          style: style,
          textAlign: textAlign,
        ),
      ),
    );
  }
}
