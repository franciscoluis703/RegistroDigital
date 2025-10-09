import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  // Firebase Storage solo disponible en plataformas soportadas
  FirebaseStorage? _storage;

  ImageUploadService() {
    // Solo inicializar Firebase Storage en plataformas soportadas
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows)) {
        _storage = FirebaseStorage.instance;
      }
    } catch (e) {
      debugPrint('Firebase Storage no disponible en esta plataforma: $e');
    }
  }

  /// Verificar si la plataforma soporta selección de imágenes
  bool get isPlatformSupported {
    if (kIsWeb) return true;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows;
  }

  /// Seleccionar imagen de la galería
  Future<XFile?> pickImageFromGallery() async {
    try {
      // En Linux, Image Picker no funciona de forma nativa
      if (!kIsWeb && Platform.isLinux) {
        debugPrint('⚠️ Image Picker no soportado en Linux. Use la opción de URL.');
        throw UnsupportedError('Image Picker no está disponible en Linux. Por favor, use la opción de URL de imagen.');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error al seleccionar imagen de galería: $e');
      rethrow;
    }
  }

  /// Tomar foto con la cámara
  Future<XFile?> pickImageFromCamera() async {
    try {
      // En Linux, Image Picker no funciona de forma nativa
      if (!kIsWeb && Platform.isLinux) {
        debugPrint('⚠️ Image Picker no soportado en Linux. Use la opción de URL.');
        throw UnsupportedError('La cámara no está disponible en Linux. Por favor, use la opción de URL de imagen.');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
      rethrow;
    }
  }

  /// Subir imagen a Storage (Supabase o Firebase según disponibilidad)
  Future<String?> uploadImageToStorage(XFile imageFile, String userId) async {
    try {
      final String fileName = 'perfil_$userId.${imageFile.path.split('.').last}';
      final File file = File(imageFile.path);

      // Intentar usar Firebase Storage si está disponible
      if (_storage != null) {
        try {
          final Reference ref = _storage!.ref().child('profile_pictures/$fileName');
          final UploadTask uploadTask = ref.putFile(file);
          final TaskSnapshot snapshot = await uploadTask;
          final String downloadUrl = await snapshot.ref.getDownloadURL();
          return downloadUrl;
        } catch (e) {
          debugPrint('Error al subir imagen a Firebase Storage: $e');
          // Continuar para intentar con Supabase
        }
      }

      // Usar Supabase Storage como alternativa
      try {
        final bytes = await file.readAsBytes();
        final String path = 'profile_pictures/$fileName';

        // Subir archivo a Supabase Storage
        await _supabase.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
          ),
        );

        // Obtener URL pública
        final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
        return publicUrl;
      } catch (e) {
        debugPrint('Error al subir imagen a Supabase Storage: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Error general al subir imagen: $e');
      return null;
    }
  }

  /// Eliminar imagen de Storage (Firebase o Supabase según la URL)
  Future<bool> deleteImageFromStorage(String imageUrl) async {
    try {
      // Intentar eliminar de Firebase Storage si está disponible
      if (_storage != null && imageUrl.contains('firebase')) {
        try {
          final Reference ref = _storage!.refFromURL(imageUrl);
          await ref.delete();
          return true;
        } catch (e) {
          debugPrint('Error al eliminar imagen de Firebase Storage: $e');
        }
      }

      // Intentar eliminar de Supabase Storage
      if (imageUrl.contains('supabase')) {
        try {
          // Extraer la ruta del archivo de la URL de Supabase
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          final path = pathSegments.skip(pathSegments.indexOf('profile_pictures')).join('/');

          await _supabase.storage.from('avatars').remove([path]);
          return true;
        } catch (e) {
          debugPrint('Error al eliminar imagen de Supabase Storage: $e');
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error general al eliminar imagen: $e');
      return false;
    }
  }

  /// Proceso completo: seleccionar de galería y subir
  Future<String?> pickAndUploadFromGallery(String userId) async {
    final XFile? imageFile = await pickImageFromGallery();
    if (imageFile == null) return null;

    return await uploadImageToStorage(imageFile, userId);
  }

  /// Proceso completo: tomar foto y subir
  Future<String?> pickAndUploadFromCamera(String userId) async {
    final XFile? imageFile = await pickImageFromCamera();
    if (imageFile == null) return null;

    return await uploadImageToStorage(imageFile, userId);
  }

  /// Obtener el ID del usuario actual desde Supabase
  String? getCurrentUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id;
  }
}
