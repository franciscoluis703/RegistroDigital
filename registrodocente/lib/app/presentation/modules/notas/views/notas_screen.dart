import 'package:flutter/material.dart';
import '../../../../data/services/firebase/notas_firestore_service.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/dojo_card.dart';
import '../../../widgets/common/dojo_button.dart';
import '../../../widgets/common/dojo_input.dart';
import '../../../widgets/common/empty_state.dart';

/// 🎨 Pantalla de Bloc de Notas - Diseño ClassDojo
class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final _notasService = NotasFirestoreService();
  List<Map<String, dynamic>> _notas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarNotas();
  }

  Future<void> _cargarNotas() async {
    setState(() => _isLoading = true);
    final notas = await _notasService.obtenerNotas();
    setState(() {
      _notas = notas;
      _isLoading = false;
    });
  }

  Future<void> _crearNota() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditorNotaScreen(),
      ),
    );

    if (result == true) {
      _cargarNotas();
    }
  }

  Future<void> _editarNota(Map<String, dynamic> nota) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorNotaScreen(nota: nota),
      ),
    );

    if (result == true) {
      _cargarNotas();
    }
  }

  Future<void> _eliminarNota(String notaId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline, color: AppColors.error),
            SizedBox(width: 12),
            Text('Eliminar nota'),
          ],
        ),
        content: const Text('¿Estás seguro que deseas eliminar esta nota?'),
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _notasService.eliminarNota(notaId);
      _cargarNotas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nota eliminada exitosamente'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Color _getColorFromIndex(int index) {
    final colors = [
      AppColors.accent,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.pink,
      AppColors.info,
      AppColors.warning,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.note_add, size: 24),
            SizedBox(width: 8),
            Text('Bloc de Notas'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearNota,
        backgroundColor: AppColors.secondary,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Nota',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.secondary,
              ),
            )
          : _notas.isEmpty
              ? const EmptyState(
                  icon: Icons.note_alt_outlined,
                  title: 'No hay notas',
                  message: 'Toca el botón + para crear una nota',
                  iconColor: AppColors.accent,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notas.length,
                  itemBuilder: (context, index) {
                    final nota = _notas[index];
                    final color = _getColorFromIndex(index);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DojoCard(
                        style: DojoCardStyle.normal,
                        onTap: () => _editarNota(nota),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.note,
                                      color: color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      nota['titulo'] ?? 'Sin título',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: AppColors.error,
                                    iconSize: 24,
                                    onPressed: () => _eliminarNota(nota['id']),
                                    tooltip: 'Eliminar nota',
                                  ),
                                ],
                              ),
                              if (nota['contenido'] != null &&
                                  nota['contenido'].toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  nota['contenido'],
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatearFecha(nota['updated_at'] ?? nota['created_at']),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textTertiary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null) return '';
    try {
      final fecha = DateTime.parse(fechaStr);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fecha);

      if (diferencia.inDays == 0) {
        if (diferencia.inHours == 0) {
          if (diferencia.inMinutes == 0) {
            return 'Hace un momento';
          }
          return 'Hace ${diferencia.inMinutes} min';
        }
        return 'Hace ${diferencia.inHours} h';
      } else if (diferencia.inDays == 1) {
        return 'Ayer';
      } else if (diferencia.inDays < 7) {
        return 'Hace ${diferencia.inDays} días';
      } else {
        return '${fecha.day}/${fecha.month}/${fecha.year}';
      }
    } catch (e) {
      return '';
    }
  }
}

/// 🎨 Editor de Notas - Diseño ClassDojo
class EditorNotaScreen extends StatefulWidget {
  final Map<String, dynamic>? nota;

  const EditorNotaScreen({super.key, this.nota});

  @override
  State<EditorNotaScreen> createState() => _EditorNotaScreenState();
}

class _EditorNotaScreenState extends State<EditorNotaScreen> {
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  final _notasService = NotasFirestoreService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.nota != null) {
      _tituloController.text = widget.nota!['titulo'] ?? '';
      _contenidoController.text = widget.nota!['contenido'] ?? '';
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  Future<void> _guardarNota() async {
    if (_tituloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El título es obligatorio'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.nota != null) {
        // Actualizar nota existente
        await _notasService.actualizarNota(
          widget.nota!['id'],
          _tituloController.text,
          _contenidoController.text,
        );
      } else {
        // Crear nueva nota
        await _notasService.crearNota(
          _tituloController.text,
          _contenidoController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.nota != null ? 'Nota actualizada' : 'Nota creada'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.nota != null ? 'Editar Nota' : 'Nueva Nota'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DojoButton(
              text: 'Guardar',
              icon: Icons.check,
              style: DojoButtonStyle.secondary,
              size: DojoButtonSize.small,
              isLoading: _isSaving,
              onPressed: _guardarNota,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Card con el formulario
              DojoCard(
                style: DojoCardStyle.normal,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Icono decorativo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.secondaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.note_add,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campo de título
                    DojoInput(
                      label: 'Título de la nota',
                      hint: 'Escribe un título descriptivo',
                      controller: _tituloController,
                      prefixIcon: Icons.title,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El título es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo de contenido
                    DojoInput(
                      label: 'Contenido',
                      hint: 'Escribe tus notas aquí...',
                      controller: _contenidoController,
                      prefixIcon: Icons.notes,
                      maxLines: 12,
                      textInputAction: TextInputAction.newline,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Información adicional
              DojoCard(
                style: DojoCardStyle.secondary,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tus notas se guardan automáticamente en la nube',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
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
