import 'package:flutter/material.dart';
import '../../../../data/services/notas_service.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final _notasService = NotasService();
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
        title: const Text('Eliminar nota'),
        content: const Text('¿Estás seguro que deseas eliminar esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
          const SnackBar(content: Text('Nota eliminada')),
        );
      }
    }
  }

  Color _getColorFromIndex(int index) {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc de Notas'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearNota,
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Nota'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay notas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para crear una nota',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notas.length,
                  itemBuilder: (context, index) {
                    final nota = _notas[index];
                    final color = _getColorFromIndex(index);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: color.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _editarNota(nota),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.note,
                                      color: color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      nota['titulo'] ?? 'Sin título',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red[400],
                                    onPressed: () => _eliminarNota(nota['id']),
                                  ),
                                ],
                              ),
                              if (nota['contenido'] != null && nota['contenido'].isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  nota['contenido'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatearFecha(nota['updated_at'] ?? nota['created_at']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
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

class EditorNotaScreen extends StatefulWidget {
  final Map<String, dynamic>? nota;

  const EditorNotaScreen({super.key, this.nota});

  @override
  State<EditorNotaScreen> createState() => _EditorNotaScreenState();
}

class _EditorNotaScreenState extends State<EditorNotaScreen> {
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  final _notasService = NotasService();
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
        const SnackBar(content: Text('El título es obligatorio')),
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
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: Text(widget.nota != null ? 'Editar Nota' : 'Nueva Nota'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _guardarNota,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                hintText: 'Título de la nota',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: const Icon(Icons.title),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contenidoController,
                decoration: InputDecoration(
                  hintText: 'Escribe tus notas aquí...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
