import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/mixins/auto_save_mixin.dart';
import '../../../../core/utils/auto_save_controller.dart';
import '../../../../core/widgets/auto_save_indicator.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../data/services/firebase/firebase_auth_service.dart';
import '../../../../data/services/firebase/image_upload_service.dart';
import '../../../themes/app_colors.dart';
import '../../../widgets/common/dojo_card.dart';
import '../../../widgets/common/dojo_input.dart';
import '../../../widgets/common/dojo_button.dart';
import '../../../routes/routes.dart';

/// 🎨 Pantalla de Perfil - Diseño ClassDojo
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> with AutoSaveMixin {
  final _authService = FirebaseAuthService();
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

    try {
      final perfil = await _authService.getCurrentUserProfile();

      if (perfil != null && mounted) {
        setState(() {
          _nombreController.text = perfil['nombre_completo'] ?? '';
          _emailController.text = perfil['email'] ?? '';
          _centroController.text = perfil['centro_educativo'] ?? 'Centro Educativo Eugenio M. de Hostos';
          _regionalController.text = perfil['regional'] ?? '17';
          _distritoController.text = perfil['distrito'] ?? '04';
          _telefonoController.text = perfil['telefono'] ?? '';
          _direccionController.text = perfil['direccion'] ?? '';
          _genero = perfil['genero'];
          fotoPerfil = perfil['avatar_url'] ?? 'https://i.pravatar.cc/150?img=3';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _guardarDatos() async {
    try {
      await _authService.updateProfile(
        nombreCompleto: _nombreController.text.trim().isEmpty ? null : _nombreController.text.trim(),
        centroEducativo: _centroController.text.trim().isEmpty ? null : _centroController.text.trim(),
        regional: _regionalController.text.trim().isEmpty ? null : _regionalController.text.trim(),
        distrito: _distritoController.text.trim().isEmpty ? null : _distritoController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        direccion: _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
        genero: _genero,
        avatarUrl: fotoPerfil,
      );

      if (mounted) {
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

      return true;
    } catch (e) {
      print('Error al guardar perfil: $e');
      return false;
    }
  }

  Future<void> _tomarFotoYSubir() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imageUrl = await _imageUploadService.pickAndUploadProfileFromCamera();

      if (mounted) {
        Navigator.pop(context);

        if (imageUrl != null) {
          setState(() => fotoPerfil = imageUrl);
          final saved = await _guardarDatos();
          if (mounted && saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil actualizada ✓'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _seleccionarDeGaleriaYSubir() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imageUrl = await _imageUploadService.pickAndUploadProfileFromGallery();

      if (mounted) {
        Navigator.pop(context);

        if (imageUrl != null) {
          setState(() => fotoPerfil = imageUrl);
          final saved = await _guardarDatos();
          if (mounted && saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil actualizada ✓'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cambiar foto de perfil',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 24),
              if (!kIsWeb && !Platform.isLinux) ...[
                _buildPhotoOption(
                  Icons.camera_alt,
                  'Tomar foto',
                  AppColors.primary,
                  () async {
                    Navigator.pop(context);
                    await _tomarFotoYSubir();
                  },
                ),
                const SizedBox(height: 12),
                _buildPhotoOption(
                  Icons.photo_library,
                  'Galería',
                  AppColors.secondary,
                  () async {
                    Navigator.pop(context);
                    await _seleccionarDeGaleriaYSubir();
                  },
                ),
                const SizedBox(height: 12),
              ],
              _buildPhotoOption(
                Icons.link,
                'URL de imagen',
                AppColors.tertiary,
                () {
                  Navigator.pop(context);
                  _mostrarDialogoURL();
                },
              ),
              if (fotoPerfil != 'https://i.pravatar.cc/150?img=3') ...[
                const SizedBox(height: 12),
                _buildPhotoOption(
                  Icons.delete,
                  'Eliminar foto',
                  AppColors.error,
                  () async {
                    setState(() => fotoPerfil = 'https://i.pravatar.cc/150?img=3');
                    notifyChange();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Foto restaurada')),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption(IconData icon, String text, Color color, VoidCallback onTap) {
    return DojoCard(
      style: DojoCardStyle.normal,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoURL() {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('URL de Imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DojoInput(
              label: 'URL de la imagen',
              hint: 'https://ejemplo.com/foto.jpg',
              prefixIcon: Icons.link,
              controller: urlController,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            Text(
              'Puedes usar: pravatar.cc o ui-avatars.com',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
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
          DojoButton(
            text: 'Guardar',
            style: DojoButtonStyle.primary,
            size: DojoButtonSize.small,
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                setState(() => fotoPerfil = urlController.text.trim());
                _guardarDatos();
                urlController.dispose();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
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
              // Foto de perfil con diseño ClassDojo
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 8,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(fotoPerfil),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _mostrarOpcionesFoto,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.secondaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Métodos de Acceso
              DojoCard(
                style: DojoCardStyle.primary,
                onTap: () => Navigator.pushNamed(context, Routes.authProviders),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.security, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Métodos de Acceso',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gestiona tus métodos de inicio de sesión',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Información Personal
              Row(
                children: [
                  const Icon(Icons.person, color: AppColors.secondary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Información Personal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DojoCard(
                style: DojoCardStyle.normal,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    DojoInput(
                      controller: _nombreController,
                      label: 'Nombre completo',
                      prefixIcon: Icons.person_outline,
                      onChanged: (_) => notifyChange(),
                    ),
                    const SizedBox(height: 16),
                    DojoInput(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => notifyChange(),
                    ),
                    const SizedBox(height: 16),
                    DojoInput(
                      controller: _centroController,
                      label: 'Centro educativo',
                      prefixIcon: Icons.school_outlined,
                      onChanged: (_) => notifyChange(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DojoInput(
                            controller: _regionalController,
                            label: 'Regional',
                            prefixIcon: Icons.location_on_outlined,
                            onChanged: (_) => notifyChange(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DojoInput(
                            controller: _distritoController,
                            label: 'Distrito',
                            prefixIcon: Icons.location_city_outlined,
                            onChanged: (_) => notifyChange(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DojoInput(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => notifyChange(),
                    ),
                    const SizedBox(height: 16),
                    DojoInput(
                      controller: _direccionController,
                      label: 'Dirección',
                      prefixIcon: Icons.home_outlined,
                      maxLines: 2,
                      onChanged: (_) => notifyChange(),
                    ),
                    const SizedBox(height: 16),
                    // Género dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _genero,
                      decoration: const InputDecoration(
                        labelText: 'Género',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info de autoguardado
              DojoCard(
                style: DojoCardStyle.success,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Los cambios se guardan automáticamente',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
