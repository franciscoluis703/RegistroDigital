import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio de Subida de Imágenes con Firebase Storage
/// Reemplazo completo de ImageUploadService (Supabase Storage)
///
/// Funcionalidades:
/// - Subir fotos desde galería o cámara
/// - Gestión de avatares/fotos de perfil
/// - URLs públicas de descarga
/// - Eliminación de fotos antiguas
///
/// Estructura en Firebase Storage:
/// users/{uid}/profile/avatar.jpg
/// users/{uid}/photos/{timestamp}_{filename}
class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  String? get _currentUserId => _auth.currentUser?.uid;

  // ============================================
  // RUTAS DE ALMACENAMIENTO
  // ============================================

  /// Ruta base del usuario
  String _getUserBasePath() {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return 'users/$_currentUserId';
  }

  /// Ruta para foto de perfil
  String _getProfilePhotoPath() {
    return '${_getUserBasePath()}/profile/avatar.jpg';
  }

  /// Ruta para fotos generales
  String _getPhotoPath(String filename) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${_getUserBasePath()}/photos/${timestamp}_$filename';
  }

  // ============================================
  // SUBIR FOTOS DE PERFIL
  // ============================================

  /// Seleccionar foto desde galería y subirla como foto de perfil
  Future<String?> pickAndUploadProfileFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _uploadProfilePhoto(File(image.path));
    } catch (e) {
      return null;
    }
  }

  /// Tomar foto con cámara y subirla como foto de perfil
  Future<String?> pickAndUploadProfileFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _uploadProfilePhoto(File(image.path));
    } catch (e) {
      return null;
    }
  }

  /// Subir archivo como foto de perfil
  Future<String?> _uploadProfilePhoto(File file) async {
    try {
      // Eliminar foto de perfil anterior si existe
      await _deleteProfilePhoto();

      // Subir nueva foto
      final ref = _storage.ref().child(_getProfilePhotoPath());
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': _currentUserId ?? 'unknown',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Obtener URL de descarga
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Registrar actividad (temporalmente deshabilitado)
      // TODO: Re-implementar activity logging sin dependencia circular

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Eliminar foto de perfil actual
  Future<bool> _deleteProfilePhoto() async {
    try {
      final ref = _storage.ref().child(_getProfilePhotoPath());
      await ref.delete();
      return true;
    } catch (e) {
      // La foto puede no existir, no es un error crítico
      return false;
    }
  }

  /// Obtener URL de foto de perfil actual
  Future<String?> getProfilePhotoUrl() async {
    try {
      final ref = _storage.ref().child(_getProfilePhotoPath());
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // SUBIR FOTOS GENERALES
  // ============================================

  /// Seleccionar foto desde galería y subirla
  Future<String?> pickAndUploadFromGallery({String? filename}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      final file = File(image.path);
      final name = filename ?? image.name;

      return await uploadPhoto(file, name);
    } catch (e) {
      return null;
    }
  }

  /// Tomar foto con cámara y subirla
  Future<String?> pickAndUploadFromCamera({String? filename}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      final file = File(image.path);
      final name = filename ?? 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';

      return await uploadPhoto(file, name);
    } catch (e) {
      return null;
    }
  }

  /// Subir archivo de foto general
  Future<String?> uploadPhoto(File file, String filename) async {
    try {
      final ref = _storage.ref().child(_getPhotoPath(filename));

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': _currentUserId ?? 'unknown',
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalFilename': filename,
          },
        ),
      );

      // Obtener URL de descarga
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Registrar actividad (temporalmente deshabilitado)
      // TODO: Re-implementar activity logging sin dependencia circular

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Eliminar foto por URL
  Future<bool> deletePhotoByUrl(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();

      // Registrar actividad (temporalmente deshabilitado)
      // TODO: Re-implementar activity logging sin dependencia circular

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Verificar si existe foto de perfil
  Future<bool> hasProfilePhoto() async {
    try {
      final ref = _storage.ref().child(_getProfilePhotoPath());
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener metadata de una foto
  Future<FullMetadata?> getPhotoMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      return null;
    }
  }

  /// Listar todas las fotos del usuario
  Future<List<String>> listUserPhotos() async {
    try {
      final ref = _storage.ref().child('${_getUserBasePath()}/photos');
      final result = await ref.listAll();

      final List<String> urls = [];
      for (var item in result.items) {
        try {
          final url = await item.getDownloadURL();
          urls.add(url);
        } catch (e) {
          // Ignorar errores individuales
        }
      }

      return urls;
    } catch (e) {
      return [];
    }
  }

  /// Limpiar todas las fotos del usuario (usar con precaución)
  Future<bool> deleteAllUserPhotos() async {
    try {
      final ref = _storage.ref().child('${_getUserBasePath()}/photos');
      final result = await ref.listAll();

      for (var item in result.items) {
        try {
          await item.delete();
        } catch (e) {
          // Continuar aunque falle una foto
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener tamaño total de almacenamiento usado
  Future<int> getTotalStorageSize() async {
    try {
      final ref = _storage.ref().child(_getUserBasePath());
      final result = await ref.listAll();

      int totalSize = 0;
      for (var item in result.items) {
        try {
          final metadata = await item.getMetadata();
          totalSize += metadata.size ?? 0;
        } catch (e) {
          // Ignorar errores
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
