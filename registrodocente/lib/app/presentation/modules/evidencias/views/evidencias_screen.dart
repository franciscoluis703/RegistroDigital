import 'package:flutter/material.dart';
import '../../../../domain/models/carpeta_evidencia.dart';
import '../../../../domain/models/foto_evidencia.dart';
import '../../../../data/services/firebase/evidencias_firestore_service.dart';

class EvidenciasScreen extends StatefulWidget {
  const EvidenciasScreen({super.key});

  @override
  State<EvidenciasScreen> createState() => _EvidenciasScreenState();
}

class _EvidenciasScreenState extends State<EvidenciasScreen> {
  final _evidenciasService = EvidenciasFirestoreService();

  CarpetaEvidencia? _carpetaActual;
  List<CarpetaEvidencia> _subcarpetas = [];
  List<FotoEvidencia> _fotos = [];
  List<CarpetaEvidencia> _rutaCarpeta = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarContenido();
  }

  Future<void> _cargarContenido() async {
    setState(() => _isLoading = true);

    try {
      if (_carpetaActual == null) {
        // Cargar carpetas raíz
        _subcarpetas = await _evidenciasService.obtenerCarpetasRaiz();
        _fotos = [];
        _rutaCarpeta = [];
      } else {
        // Cargar subcarpetas y fotos de la carpeta actual
        _subcarpetas = await _evidenciasService.obtenerSubcarpetas(_carpetaActual!.id);
        _fotos = await _evidenciasService.obtenerFotosDeCarpeta(_carpetaActual!.id);
        _rutaCarpeta = await _evidenciasService.obtenerRutaCarpeta(_carpetaActual!.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar contenido: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _crearCarpeta() async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Carpeta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la carpeta',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (resultado == true && nombreController.text.isNotEmpty) {
      final carpeta = await _evidenciasService.crearCarpeta(
        nombre: nombreController.text,
        carpetaPadreId: _carpetaActual?.id,
        descripcion: descripcionController.text.isEmpty ? null : descripcionController.text,
      );

      if (carpeta != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Carpeta creada exitosamente')),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear la carpeta')),
          );
        }
      }
    }
  }

  Future<void> _subirFoto() async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();

    // Primero verificar que estemos dentro de una carpeta
    if (_carpetaActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes estar dentro de una carpeta para subir fotos'),
        ),
      );
      return;
    }

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subir Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la foto',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'galeria'),
            child: const Text('Desde Galería'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'camara'),
            child: const Text('Tomar Foto'),
          ),
        ],
      ),
    );

    if (resultado != null && nombreController.text.isNotEmpty) {
      setState(() => _isLoading = true);

      FotoEvidencia? foto;
      if (resultado == 'galeria') {
        foto = await _evidenciasService.pickAndUploadFromGallery(
          carpetaId: _carpetaActual!.id,
          nombre: nombreController.text,
          descripcion: descripcionController.text.isEmpty ? null : descripcionController.text,
        );
      } else if (resultado == 'camara') {
        foto = await _evidenciasService.pickAndUploadFromCamera(
          carpetaId: _carpetaActual!.id,
          nombre: nombreController.text,
          descripcion: descripcionController.text.isEmpty ? null : descripcionController.text,
        );
      }

      setState(() => _isLoading = false);

      if (foto != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto subida exitosamente')),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la foto')),
          );
        }
      }
    }
  }

  Future<void> _subirArchivo() async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();

    // Primero verificar que estemos dentro de una carpeta
    if (_carpetaActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes estar dentro de una carpeta para subir archivos'),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subir Archivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Puedes subir archivos PDF, DOC, XLS, PPT, TXT e imágenes',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del archivo',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Seleccionar Archivo'),
          ),
        ],
      ),
    );

    if (confirmar == true && nombreController.text.isNotEmpty) {
      setState(() => _isLoading = true);

      final archivo = await _evidenciasService.pickAndUploadFile(
        carpetaId: _carpetaActual!.id,
        nombre: nombreController.text,
        descripcion: descripcionController.text.isEmpty ? null : descripcionController.text,
      );

      setState(() => _isLoading = false);

      if (archivo != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Archivo subido exitosamente'), backgroundColor: Colors.green),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir el archivo'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _abrirCarpeta(CarpetaEvidencia carpeta) async {
    setState(() => _carpetaActual = carpeta);
    _cargarContenido();
  }

  Future<void> _volverAtras() async {
    if (_rutaCarpeta.length > 1) {
      setState(() => _carpetaActual = _rutaCarpeta[_rutaCarpeta.length - 2]);
    } else {
      setState(() => _carpetaActual = null);
    }
    _cargarContenido();
  }

  Future<void> _eliminarCarpeta(CarpetaEvidencia carpeta) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la carpeta "${carpeta.nombre}"?\n\n'
          'Esto eliminará también todas las subcarpetas y fotos que contenga.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      final exito = await _evidenciasService.eliminarCarpeta(carpeta.id);
      if (exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Carpeta eliminada exitosamente')),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar la carpeta')),
          );
        }
      }
    }
  }

  Future<void> _eliminarFoto(FotoEvidencia foto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la foto "${foto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      final exito = await _evidenciasService.eliminarFoto(foto.id);
      if (exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto eliminada exitosamente')),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar la foto')),
          );
        }
      }
    }
  }

  void _verFoto(FotoEvidencia foto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _VisorFotoScreen(foto: foto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencias'),
        actions: [
          if (_carpetaActual != null) ...[
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _subirFoto,
              tooltip: 'Subir foto',
            ),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _subirArchivo,
              tooltip: 'Subir archivo',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: _crearCarpeta,
            tooltip: 'Nueva carpeta',
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb (Ruta de navegación)
          if (_rutaCarpeta.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _volverAtras,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() => _carpetaActual = null);
                              _cargarContenido();
                            },
                            child: const Text('Inicio'),
                          ),
                          for (var i = 0; i < _rutaCarpeta.length; i++) ...[
                            const Icon(Icons.chevron_right),
                            TextButton(
                              onPressed: i == _rutaCarpeta.length - 1
                                  ? null
                                  : () {
                                      setState(() => _carpetaActual = _rutaCarpeta[i]);
                                      _cargarContenido();
                                    },
                              child: Text(_rutaCarpeta[i].nombre),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Contenido
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _cargarContenido,
                    child: _subcarpetas.isEmpty && _fotos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _carpetaActual == null
                                      ? 'No hay carpetas.\nCrea tu primera carpeta.'
                                      : 'Carpeta vacía.\nSube fotos o crea subcarpetas.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(8),
                            children: [
                              // Carpetas
                              if (_subcarpetas.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Carpetas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ..._subcarpetas.map((carpeta) => Card(
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.folder,
                                          color: Colors.amber,
                                          size: 40,
                                        ),
                                        title: Text(carpeta.nombre),
                                        subtitle: carpeta.descripcion != null
                                            ? Text(carpeta.descripcion!)
                                            : null,
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _eliminarCarpeta(carpeta),
                                        ),
                                        onTap: () => _abrirCarpeta(carpeta),
                                      ),
                                    )),
                                const SizedBox(height: 16),
                              ],

                              // Fotos
                              if (_fotos.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Fotos',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: _fotos.length,
                                  itemBuilder: (context, index) {
                                    final foto = _fotos[index];
                                    return GestureDetector(
                                      onTap: () => _verFoto(foto),
                                      onLongPress: () => _eliminarFoto(foto),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              foto.urlFoto,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(Icons.error),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                color: Colors.black54,
                                                child: Text(
                                                  foto.nombre,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Pantalla para ver una foto en detalle
class _VisorFotoScreen extends StatelessWidget {
  final FotoEvidencia foto;

  const _VisorFotoScreen({required this.foto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(foto.nombre),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                child: Image.network(
                  foto.urlFoto,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, size: 80),
                    );
                  },
                ),
              ),
            ),
          ),
          if (foto.descripcion != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(foto.descripcion!),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
