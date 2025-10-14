import 'package:flutter/material.dart';
import '../../../../domain/models/carpeta_evidencia.dart';
import '../../../../domain/models/foto_evidencia.dart';
import '../../../../data/services/firebase/evidencias_firestore_service.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/dojo_card.dart';
import '../../../widgets/common/dojo_input.dart';
import '../../../widgets/common/empty_state.dart';

/// 🎨 Pantalla de Evidencias - Diseño ClassDojo
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
          SnackBar(
            content: Text('Error al cargar contenido: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.create_new_folder, color: AppColors.secondary),
            SizedBox(width: 12),
            Text('Nueva Carpeta'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DojoInput(
                controller: nombreController,
                label: 'Nombre de la carpeta',
                hint: 'Ej: Proyecto Ciencias',
                prefixIcon: Icons.folder,
              ),
              const SizedBox(height: 16),
              DojoInput(
                controller: descripcionController,
                label: 'Descripción (opcional)',
                hint: 'Breve descripción de la carpeta',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
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
            SnackBar(
              content: const Text('Carpeta creada exitosamente'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al crear la carpeta'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Future<void> _mostrarOpcionesSubida() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Subir Evidencia',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 24),
              _buildUploadOption(
                icon: Icons.camera_alt,
                title: 'Tomar Foto',
                subtitle: 'Captura una foto con la cámara',
                color: AppColors.secondary,
                onTap: () {
                  Navigator.pop(context);
                  _subirFoto('camara');
                },
              ),
              const SizedBox(height: 12),
              _buildUploadOption(
                icon: Icons.photo_library,
                title: 'Desde Galería',
                subtitle: 'Selecciona una foto de tu galería',
                color: AppColors.info,
                onTap: () {
                  Navigator.pop(context);
                  _subirFoto('galeria');
                },
              ),
              const SizedBox(height: 12),
              _buildUploadOption(
                icon: Icons.attach_file,
                title: 'Subir Archivo',
                subtitle: 'PDF, DOC, XLS, PPT, TXT',
                color: AppColors.tertiary,
                onTap: () {
                  Navigator.pop(context);
                  _subirArchivo();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return DojoCard(
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Future<void> _subirFoto(String source) async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();

    // Verificar que estemos dentro de una carpeta
    if (_carpetaActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes estar dentro de una carpeta para subir fotos'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              source == 'camara' ? Icons.camera_alt : Icons.photo_library,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 12),
            Text(source == 'camara' ? 'Tomar Foto' : 'Desde Galería'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DojoInput(
                controller: nombreController,
                label: 'Nombre de la foto',
                hint: 'Ej: Proyecto finalizado',
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),
              DojoInput(
                controller: descripcionController,
                label: 'Descripción (opcional)',
                hint: 'Breve descripción de la foto',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: Text(source == 'camara' ? 'Tomar Foto' : 'Seleccionar'),
          ),
        ],
      ),
    );

    if (resultado == true && nombreController.text.isNotEmpty) {
      setState(() => _isLoading = true);

      FotoEvidencia? foto;
      if (source == 'galeria') {
        foto = await _evidenciasService.pickAndUploadFromGallery(
          carpetaId: _carpetaActual!.id,
          nombre: nombreController.text,
          descripcion: descripcionController.text.isEmpty ? null : descripcionController.text,
        );
      } else if (source == 'camara') {
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
            SnackBar(
              content: const Text('Foto subida exitosamente'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al subir la foto'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Future<void> _subirArchivo() async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();

    // Verificar que estemos dentro de una carpeta
    if (_carpetaActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes estar dentro de una carpeta para subir archivos'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.attach_file, color: AppColors.tertiary),
            SizedBox(width: 12),
            Text('Subir Archivo'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DojoCard(
                style: DojoCardStyle.warning,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Puedes subir archivos PDF, DOC, XLS, PPT, TXT e imágenes',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DojoInput(
                controller: nombreController,
                label: 'Nombre del archivo',
                hint: 'Ej: Informe final',
                prefixIcon: Icons.insert_drive_file,
              ),
              const SizedBox(height: 16),
              DojoInput(
                controller: descripcionController,
                label: 'Descripción (opcional)',
                hint: 'Breve descripción del archivo',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
            ),
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
            SnackBar(
              content: const Text('Archivo subido exitosamente'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al subir el archivo'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 12),
            Text('Confirmar Eliminación'),
          ],
        ),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
            SnackBar(
              content: const Text('Carpeta eliminada exitosamente'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al eliminar la carpeta'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarFoto(FotoEvidencia foto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline, color: AppColors.error),
            SizedBox(width: 12),
            Text('Confirmar Eliminación'),
          ],
        ),
        content: Text('¿Estás seguro de que deseas eliminar la foto "${foto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
            SnackBar(
              content: const Text('Foto eliminada exitosamente'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        _cargarContenido();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al eliminar la foto'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.photo_library, size: 24),
            SizedBox(width: 8),
            Text('Evidencias'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: _crearCarpeta,
            tooltip: 'Nueva carpeta',
          ),
        ],
      ),
      floatingActionButton: _carpetaActual != null
          ? FloatingActionButton.extended(
              onPressed: _mostrarOpcionesSubida,
              backgroundColor: AppColors.secondary,
              elevation: 4,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Subir',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          // Breadcrumb (Ruta de navegación)
          if (_rutaCarpeta.isNotEmpty)
            DojoCard(
              style: DojoCardStyle.normal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
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
                            child: Text(
                              'Inicio',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          for (var i = 0; i < _rutaCarpeta.length; i++) ...[
                            Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
                            TextButton(
                              onPressed: i == _rutaCarpeta.length - 1
                                  ? null
                                  : () {
                                      setState(() => _carpetaActual = _rutaCarpeta[i]);
                                      _cargarContenido();
                                    },
                              child: Text(
                                _rutaCarpeta[i].nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: i == _rutaCarpeta.length - 1
                                      ? AppColors.textSecondary
                                      : AppColors.secondary,
                                ),
                              ),
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
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.secondary),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarContenido,
                    color: AppColors.secondary,
                    child: _subcarpetas.isEmpty && _fotos.isEmpty
                        ? EmptyState(
                            icon: Icons.folder_open,
                            title: _carpetaActual == null
                                ? 'No hay carpetas'
                                : 'Carpeta vacía',
                            message: _carpetaActual == null
                                ? 'Crea tu primera carpeta para organizar tus evidencias'
                                : 'Sube fotos o crea subcarpetas',
                            iconColor: AppColors.info,
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Carpetas
                              if (_subcarpetas.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(Icons.folder, color: AppColors.warning, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Carpetas',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ..._subcarpetas.map((carpeta) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: DojoCard(
                                        style: DojoCardStyle.normal,
                                        onTap: () => _abrirCarpeta(carpeta),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  color: AppColors.warning.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Icon(
                                                  Icons.folder,
                                                  color: AppColors.warning,
                                                  size: 32,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      carpeta.nombre,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                    ),
                                                    if (carpeta.descripcion != null) ...[
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        carpeta.descripcion!,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: AppColors.textSecondary,
                                                            ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline),
                                                color: AppColors.error,
                                                onPressed: () => _eliminarCarpeta(carpeta),
                                                tooltip: 'Eliminar carpeta',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )),
                                const SizedBox(height: 16),
                              ],

                              // Fotos
                              if (_fotos.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(Icons.photo, color: AppColors.info, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fotos y Archivos',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: _fotos.length,
                                  itemBuilder: (context, index) {
                                    final foto = _fotos[index];
                                    return GestureDetector(
                                      onTap: () => _verFoto(foto),
                                      onLongPress: () => _eliminarFoto(foto),
                                      child: DojoCard(
                                        style: DojoCardStyle.normal,
                                        padding: EdgeInsets.zero,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Image.network(
                                                foto.urlFoto,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Center(
                                                    child: Icon(
                                                      Icons.error,
                                                      color: AppColors.error,
                                                      size: 32,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black.withValues(alpha: 0.8),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  borderRadius: const BorderRadius.only(
                                                    bottomLeft: Radius.circular(16),
                                                    bottomRight: Radius.circular(16),
                                                  ),
                                                ),
                                                child: Text(
                                                  foto.nombre,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
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

/// 🎨 Visor de Fotos - Diseño ClassDojo
class _VisorFotoScreen extends StatelessWidget {
  final FotoEvidencia foto;

  const _VisorFotoScreen({required this.foto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 80, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar la imagen',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (foto.descripcion != null)
            DojoCard(
              style: DojoCardStyle.normal,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: AppColors.info, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Descripción:',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    foto.descripcion!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
