import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../domain/models/carpeta_evidencia.dart';
import '../../../domain/models/foto_evidencia.dart';

/// Servicio de Evidencias con Firebase Storage y Firestore
/// Reemplazo completo de CarpetasEvidenciaService y FotosEvidenciaService
///
/// Funcionalidades:
/// - Gestión de carpetas jerárquicas
/// - Subida y gestión de fotos
/// - Firebase Storage para almacenamiento
/// - Firestore para metadata
///
/// Estructura:
/// Firestore: users/{uid}/evidencias/carpetas/{carpetaId}
/// Firestore: users/{uid}/evidencias/fotos/{fotoId}
/// Storage: users/{uid}/evidencias/{carpetaId}/{filename}
class EvidenciasFirestoreService {
  static final EvidenciasFirestoreService _instance = EvidenciasFirestoreService._internal();
  factory EvidenciasFirestoreService() => _instance;
  EvidenciasFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  String? get _currentUserId => _auth.currentUser?.uid;

  // ============================================
  // REFERENCIAS
  // ============================================

  CollectionReference<Map<String, dynamic>> _getCarpetasCollection() {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('evidencias')
        .doc('metadata')
        .collection('carpetas');
  }

  CollectionReference<Map<String, dynamic>> _getFotosCollection() {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('evidencias')
        .doc('metadata')
        .collection('fotos');
  }

  String _getStoragePath(String carpetaId) {
    return 'users/$_currentUserId/evidencias/$carpetaId';
  }

  // ============================================
  // GESTIÓN DE CARPETAS
  // ============================================

  /// Crear carpeta
  Future<CarpetaEvidencia?> crearCarpeta({
    required String nombre,
    String? carpetaPadreId,
    String? descripcion,
  }) async {
    try {
      final docRef = _getCarpetasCollection().doc();

      final carpeta = CarpetaEvidencia(
        id: docRef.id,
        nombre: nombre,
        descripcion: descripcion,
        carpetaPadreId: carpetaPadreId,
        usuarioId: _currentUserId!,
        fechaCreacion: DateTime.now(),
      );

      await docRef.set({
        'nombre': carpeta.nombre,
        'descripcion': carpeta.descripcion,
        'carpeta_padre_id': carpeta.carpetaPadreId,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Registrar actividad (temporalmente deshabilitado)
      // TODO: Re-implementar activity logging sin dependencia circular

      return carpeta;
    } catch (e) {
      return null;
    }
  }

  /// Obtener carpetas raíz (sin padre)
  Future<List<CarpetaEvidencia>> obtenerCarpetasRaiz() async {
    try {
      final snapshot = await _getCarpetasCollection()
          .where('carpeta_padre_id', isNull: true)
          .orderBy('created_at', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CarpetaEvidencia(
          id: doc.id,
          nombre: data['nombre'] ?? '',
          descripcion: data['descripcion'],
          carpetaPadreId: data['carpeta_padre_id'],
          usuarioId: _currentUserId!,
          fechaCreacion: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener subcarpetas de una carpeta
  Future<List<CarpetaEvidencia>> obtenerSubcarpetas(String carpetaPadreId) async {
    try {
      final snapshot = await _getCarpetasCollection()
          .where('carpeta_padre_id', isEqualTo: carpetaPadreId)
          .orderBy('created_at', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CarpetaEvidencia(
          id: doc.id,
          nombre: data['nombre'] ?? '',
          descripcion: data['descripcion'],
          carpetaPadreId: data['carpeta_padre_id'],
          usuarioId: _currentUserId!,
          fechaCreacion: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener ruta completa de una carpeta
  Future<List<CarpetaEvidencia>> obtenerRutaCarpeta(String carpetaId) async {
    try {
      final List<CarpetaEvidencia> ruta = [];
      String? currentId = carpetaId;

      while (currentId != null) {
        final doc = await _getCarpetasCollection().doc(currentId).get();
        if (!doc.exists) break;

        final data = doc.data()!;
        final carpeta = CarpetaEvidencia(
          id: doc.id,
          nombre: data['nombre'] ?? '',
          descripcion: data['descripcion'],
          carpetaPadreId: data['carpeta_padre_id'],
          usuarioId: _currentUserId!,
          fechaCreacion: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );

        ruta.insert(0, carpeta);
        currentId = carpeta.carpetaPadreId;
      }

      return ruta;
    } catch (e) {
      return [];
    }
  }

  /// Eliminar carpeta y todo su contenido
  Future<bool> eliminarCarpeta(String carpetaId) async {
    try {
      // Eliminar subcarpetas recursivamente
      final subcarpetas = await obtenerSubcarpetas(carpetaId);
      for (var subcarpeta in subcarpetas) {
        await eliminarCarpeta(subcarpeta.id);
      }

      // Eliminar fotos de la carpeta
      final fotos = await obtenerFotosDeCarpeta(carpetaId);
      for (var foto in fotos) {
        await eliminarFoto(foto.id);
      }

      // Eliminar carpeta
      await _getCarpetasCollection().doc(carpetaId).delete();

      // Registrar actividad (temporalmente deshabilitado)
      // TODO: Re-implementar activity logging sin dependencia circular

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // GESTIÓN DE FOTOS
  // ============================================

  /// Obtener fotos de una carpeta
  Future<List<FotoEvidencia>> obtenerFotosDeCarpeta(String carpetaId) async {
    try {
      final snapshot = await _getFotosCollection()
          .where('carpeta_id', isEqualTo: carpetaId)
          .orderBy('created_at', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FotoEvidencia(
          id: doc.id,
          carpetaId: data['carpeta_id'] ?? '',
          nombre: data['nombre'] ?? '',
          descripcion: data['descripcion'],
          urlFoto: data['url_foto'] ?? '',
          usuarioId: _currentUserId!,
          fechaCreacion: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Subir foto desde galería
  Future<FotoEvidencia?> pickAndUploadFromGallery({
    required String carpetaId,
    required String nombre,
    String? descripcion,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _uploadFoto(
        file: File(image.path),
        carpetaId: carpetaId,
        nombre: nombre,
        descripcion: descripcion,
        filename: image.name,
      );
    } catch (e) {
      return null;
    }
  }

  /// Subir foto desde cámara
  Future<FotoEvidencia?> pickAndUploadFromCamera({
    required String carpetaId,
    required String nombre,
    String? descripcion,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      final filename = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';

      return await _uploadFoto(
        file: File(image.path),
        carpetaId: carpetaId,
        nombre: nombre,
        descripcion: descripcion,
        filename: filename,
      );
    } catch (e) {
      return null;
    }
  }

  /// Subir foto al storage y guardar metadata
  Future<FotoEvidencia?> _uploadFoto({
    required File file,
    required String carpetaId,
    required String nombre,
    String? descripcion,
    required String filename,
  }) async {
    try {
      // Subir a Storage
      final storagePath = '${_getStoragePath(carpetaId)}/$filename';
      final ref = _storage.ref().child(storagePath);

      await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'carpetaId': carpetaId,
            'nombre': nombre,
            'uploadedBy': _currentUserId ?? 'unknown',
          },
        ),
      );

      // Obtener URL de descarga
      final downloadUrl = await ref.getDownloadURL();

      // Guardar metadata en Firestore
      final docRef = _getFotosCollection().doc();

      final foto = FotoEvidencia(
        id: docRef.id,
        carpetaId: carpetaId,
        nombre: nombre,
        descripcion: descripcion,
        urlFoto: downloadUrl,
        usuarioId: _currentUserId!,
        fechaCreacion: DateTime.now(),
      );

      await docRef.set({
        'carpeta_id': carpetaId,
        'nombre': nombre,
        'descripcion': descripcion,
        'url_foto': downloadUrl,
        'storage_path': storagePath,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Registrar actividad (temporalmente deshabilitado)
      // TODO: Re-implementar activity logging sin dependencia circular

      return foto;
    } catch (e) {
      return null;
    }
  }

  /// Eliminar foto
  Future<bool> eliminarFoto(String fotoId) async {
    try {
      // Obtener metadata
      final doc = await _getFotosCollection().doc(fotoId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final storagePath = data['storage_path'] as String?;

      // Eliminar de Storage
      if (storagePath != null) {
        try {
          await _storage.ref().child(storagePath).delete();
        } catch (e) {
          // Continuar aunque falle
        }
      }

      // Eliminar metadata
      await _getFotosCollection().doc(fotoId).delete();

      // Registrar actividad (temporalmente deshabilitado)
      // TODO: Re-implementar activity logging sin dependencia circular

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Subir archivo desde file picker (documentos, PDFs, etc.)
  Future<FotoEvidencia?> pickAndUploadFile({
    required String carpetaId,
    required String nombre,
    String? descripcion,
  }) async {
    try {
      // Seleccionar archivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'jpg', 'jpeg', 'png'],
        withData: true, // Para web
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;

      // Verificar si estamos en web o nativo
      File? nativeFile;
      if (file.path != null) {
        nativeFile = File(file.path!);
      }

      // Obtener bytes para web
      final bytes = file.bytes;
      if (nativeFile == null && bytes == null) return null;

      // Subir a Storage
      final extension = file.extension ?? 'file';
      final filename = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final storagePath = '${_getStoragePath(carpetaId)}/$filename';
      final ref = _storage.ref().child(storagePath);

      // Determinar content type
      String contentType = 'application/octet-stream';
      if (extension == 'pdf') contentType = 'application/pdf';
      else if (extension == 'doc' || extension == 'docx') contentType = 'application/msword';
      else if (extension == 'xls' || extension == 'xlsx') contentType = 'application/vnd.ms-excel';
      else if (extension == 'ppt' || extension == 'pptx') contentType = 'application/vnd.ms-powerpoint';
      else if (extension == 'txt') contentType = 'text/plain';
      else if (extension == 'jpg' || extension == 'jpeg') contentType = 'image/jpeg';
      else if (extension == 'png') contentType = 'image/png';

      // Subir archivo
      if (nativeFile != null) {
        await ref.putFile(
          nativeFile,
          SettableMetadata(
            contentType: contentType,
            customMetadata: {
              'carpetaId': carpetaId,
              'nombre': nombre,
              'uploadedBy': _currentUserId ?? 'unknown',
              'fileType': extension,
            },
          ),
        );
      } else {
        await ref.putData(
          bytes!,
          SettableMetadata(
            contentType: contentType,
            customMetadata: {
              'carpetaId': carpetaId,
              'nombre': nombre,
              'uploadedBy': _currentUserId ?? 'unknown',
              'fileType': extension,
            },
          ),
        );
      }

      // Obtener URL de descarga
      final downloadUrl = await ref.getDownloadURL();

      // Guardar metadata en Firestore
      final docRef = _getFotosCollection().doc();

      final foto = FotoEvidencia(
        id: docRef.id,
        carpetaId: carpetaId,
        nombre: nombre,
        descripcion: descripcion,
        urlFoto: downloadUrl,
        usuarioId: _currentUserId!,
        fechaCreacion: DateTime.now(),
      );

      await docRef.set({
        'carpeta_id': carpetaId,
        'nombre': nombre,
        'descripcion': descripcion,
        'url_foto': downloadUrl,
        'storage_path': storagePath,
        'file_type': extension,
        'file_size': file.size,
        'original_filename': file.name,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Registrar actividad (temporalmente deshabilitado)
      // TODO: Re-implementar activity logging sin dependencia circular

      return foto;
    } catch (e) {
      print('Error al subir archivo: $e');
      return null;
    }
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Contar fotos en una carpeta
  Future<int> contarFotos(String carpetaId) async {
    try {
      final snapshot = await _getFotosCollection()
          .where('carpeta_id', isEqualTo: carpetaId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Contar subcarpetas
  Future<int> contarSubcarpetas(String carpetaId) async {
    try {
      final snapshot = await _getCarpetasCollection()
          .where('carpeta_padre_id', isEqualTo: carpetaId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
