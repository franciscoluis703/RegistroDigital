import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/mixins/auto_save_mixin.dart';
import '../../../../core/utils/auto_save_controller.dart';
import '../../../../core/widgets/auto_save_indicator.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../data/services/perfil_supabase_service.dart';
import '../../../../data/services/image_upload_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> with AutoSaveMixin {
  final _perfilService = PerfilSupabaseService();
  final _imageUploadService = ImageUploadService();

  String fotoPerfil = 'https://i.pravatar.cc/150?img=3';
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _centroController = TextEditingController();
  final TextEditingController _regionalController = TextEditingController();
  final TextEditingController _distritoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  String? _genero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  @override
  AutoSaveController createAutoSaveController() {
    return AutoSaveController(
      debounceDuration: const Duration(seconds: 2),
      onSave: _guardarDatos,
    );
  }

  Future<void> _cargarDatosUsuario() async {
    setState(() => _isLoading = true);

    final perfil = await _perfilService.obtenerPerfil();

    if (perfil != null && mounted) {
      setState(() {
        _nombreController.text = perfil['nombre'] ?? '';
        _emailController.text = perfil['email'] ?? '';
        _centroController.text = perfil['centro_educativo'] ?? 'Centro Educativo Eugenio M. de Hostos';
        _regionalController.text = perfil['regional'] ?? '17';
        _distritoController.text = perfil['distrito'] ?? '04';
        _telefonoController.text = perfil['telefono'] ?? '';
        _direccionController.text = perfil['direccion'] ?? '';
        _genero = perfil['genero'];
        fotoPerfil = perfil['foto_perfil'] ?? 'https://i.pravatar.cc/150?img=3';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _guardarDatos() async {
    final result = await _perfilService.actualizarPerfil(
      nombre: _nombreController.text.trim().isEmpty ? null : _nombreController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      centroEducativo: _centroController.text.trim().isEmpty ? null : _centroController.text.trim(),
      regional: _regionalController.text.trim().isEmpty ? null : _regionalController.text.trim(),
      distrito: _distritoController.text.trim().isEmpty ? null : _distritoController.text.trim(),
      telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
      genero: _genero,
      fotoPerfil: fotoPerfil,
    );

    // Actualizar el provider global con los nuevos datos
    if (result != null && mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.actualizarDatos(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        fotoPerfil: fotoPerfil,
        centroEducativo: _centroController.text.trim(),
        regional: _regionalController.text.trim(),
        distrito: _distritoController.text.trim(),
        genero: _genero,
      );
    }

    return result != null;
  }

  Future<void> _tomarFotoYSubir() async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userId = _imageUploadService.getCurrentUserId();
      if (userId == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Usuario no autenticado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final imageUrl = await _imageUploadService.pickAndUploadFromCamera(userId);

      if (mounted) {
        Navigator.pop(context); // Cerrar indicador de carga

        if (imageUrl != null) {
          setState(() {
            fotoPerfil = imageUrl;
          });
          final saved = await _guardarDatos();
          if (mounted && saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil actualizada'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se seleccionó ninguna imagen'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seleccionarDeGaleriaYSubir() async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userId = _imageUploadService.getCurrentUserId();
      if (userId == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Usuario no autenticado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final imageUrl = await _imageUploadService.pickAndUploadFromGallery(userId);

      if (mounted) {
        Navigator.pop(context); // Cerrar indicador de carga

        if (imageUrl != null) {
          setState(() {
            fotoPerfil = imageUrl;
          });
          final saved = await _guardarDatos();
          if (mounted && saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil actualizada'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se seleccionó ninguna imagen'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarDialogoURL() {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Foto de Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa la URL de tu foto de perfil:'),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL de la imagen',
                hintText: 'https://ejemplo.com/mi-foto.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            const Text(
              'También puedes usar avatares de:\n• https://i.pravatar.cc/150?img=X\n• https://ui-avatars.com/api/?name=Tu+Nombre',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              urlController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                setState(() {
                  fotoPerfil = urlController.text.trim();
                });
                _guardarDatos();
                urlController.dispose();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Foto de perfil actualizada'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesFoto() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiar foto de perfil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Mostrar opciones de cámara y galería solo en plataformas soportadas
              if (_imageUploadService.isPlatformSupported) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: const Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _tomarFotoYSubir();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.green),
                  ),
                  title: const Text('Seleccionar de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _seleccionarDeGaleriaYSubir();
                  },
                ),
              ],
              // En Linux, mostrar un mensaje informativo
              if (!kIsWeb && Platform.isLinux)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'En Linux, usa la opción "URL de imagen" para cambiar tu foto',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.link, color: Colors.orange),
                ),
                title: const Text('Usar URL de imagen'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoURL();
                },
              ),
              if (fotoPerfil != 'https://i.pravatar.cc/150?img=3')
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  title: const Text(
                    'Eliminar foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    setState(() {
                      fotoPerfil = 'https://i.pravatar.cc/150?img=3';
                    });
                    notifyChange();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto de perfil restaurada'),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: AutoSaveIndicator(controller: autoSaveController),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Foto de perfil
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(fotoPerfil),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _mostrarOpcionesFoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Formulario de datos
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre completo',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _centroController,
                label: 'Centro educativo',
                icon: Icons.school,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _regionalController,
                      label: 'Regional',
                      icon: Icons.location_on,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _distritoController,
                      label: 'Distrito',
                      icon: Icons.location_city,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telefonoController,
                label: 'Teléfono',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _direccionController,
                label: 'Dirección',
                icon: Icons.home,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Género
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _genero,
                  decoration: InputDecoration(
                    labelText: 'Género',
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                    DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                    DropdownMenuItem(value: 'otro', child: Text('Otro')),
                  ],
                  onChanged: (value) {
                    setState(() => _genero = value);
                    notifyChange();
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Info de autoguardado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los cambios se guardan automáticamente',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (_) => notifyChange(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _centroController.dispose();
    _regionalController.dispose();
    _distritoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }
}
