import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Servicio de Autenticación con Firebase
/// Reemplazo completo de Supabase Auth
///
/// Funcionalidades:
/// - Sign Up con email/contraseña
/// - Sign In con email/contraseña
/// - Sign In con Google
/// - Reset password
/// - Update password
/// - Persistencia automática de sesión
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Keys para SharedPreferences (cache local)
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserProfile = 'user_profile';

  /// Obtener el usuario actual autenticado
  User? get currentUser => _auth.currentUser;

  /// Obtener el ID del usuario actual (uid)
  String? get currentUserId => currentUser?.uid;

  /// Verificar si hay un usuario autenticado
  bool get isAuthenticated => currentUser != null;

  /// Stream de cambios en el estado de autenticación
  /// Se actualiza automáticamente cuando el usuario inicia/cierra sesión
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ============================================
  // REGISTRO DE USUARIO
  // ============================================

  /// Registrar nuevo usuario con email y contraseña
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String nombreCompleto,
    String? telefono,
    String? centroEducativo,
    String? regional,
    String? distrito,
  }) async {
    try {
      // 1. Crear usuario en Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Error al crear usuario');
      }

      final user = userCredential.user!;

      // 2. Actualizar display name
      await user.updateDisplayName(nombreCompleto);

      // 3. Crear perfil en Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': email,
        'nombre_completo': nombreCompleto,
        'telefono': telefono,
        'centro_educativo': centroEducativo,
        'regional': regional,
        'distrito': distrito,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // 4. Enviar email de verificación
      await user.sendEmailVerification();

      // 5. Guardar información local
      await _saveUserDataLocally(user);

      // 6. Registrar actividad (temporalmente deshabilitado para evitar circular dependency)
      // TODO: Re-implementar activity logging sin dependencia circular
      // await _activityLog.log(
      //   action: 'register',
      //   entityType: 'auth',
      //   details: {
      //     'email': email,
      //     'nombre_completo': nombreCompleto,
      //   },
      // );

      return {
        'success': true,
        'userId': user.uid,
        'email': user.email,
        'message': 'Usuario registrado exitosamente. Verifica tu correo.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al registrar usuario: ${e.toString()}',
      };
    }
  }

  // ============================================
  // INICIO DE SESIÓN
  // ============================================

  /// Iniciar sesión con email y contraseña
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Autenticar con Firebase
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Credenciales inválidas');
      }

      final user = userCredential.user!;

      // 2. Guardar información local
      await _saveUserDataLocally(user);

      // 3. Cargar perfil del usuario desde Firestore
      final profile = await _loadUserProfile(user.uid);

      // 4. Registrar actividad (temporalmente deshabilitado)
      // await _activityLog.log(
      //   action: 'login',
      //   entityType: 'auth',
      //   details: {
      //     'email': email,
      //     'timestamp': DateTime.now().toIso8601String(),
      //   },
      // );

      return {
        'success': true,
        'userId': user.uid,
        'email': user.email,
        'profile': profile,
        'message': 'Inicio de sesión exitoso',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al iniciar sesión: ${e.toString()}',
      };
    }
  }

  // ============================================
  // INICIO DE SESIÓN CON GOOGLE
  // ============================================

  /// Iniciar sesión con Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // 1. Iniciar flujo de Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Inicio de sesión cancelado',
        };
      }

      // 2. Obtener credenciales de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Autenticar con Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Error al autenticar con Google');
      }

      final user = userCredential.user!;
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // 4. Si es nuevo usuario, crear perfil en Firestore
      if (isNewUser) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': user.email,
          'nombre_completo': user.displayName ?? '',
          'avatar_url': user.photoURL,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      // 5. Guardar información local
      await _saveUserDataLocally(user);

      // 6. Cargar perfil
      final profile = await _loadUserProfile(user.uid);

      // 7. Registrar actividad (temporalmente deshabilitado)
      // await _activityLog.log(
      //   action: 'login_google',
      //   entityType: 'auth',
      //   details: {
      //     'email': user.email,
      //     'new_user': isNewUser,
      //   },
      // );

      return {
        'success': true,
        'userId': user.uid,
        'email': user.email,
        'profile': profile,
        'is_new_user': isNewUser,
        'message': 'Inicio de sesión exitoso con Google',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al iniciar sesión con Google: ${e.toString()}',
      };
    }
  }

  // ============================================
  // CERRAR SESIÓN
  // ============================================

  /// Cerrar sesión del usuario actual
  Future<Map<String, dynamic>> signOut() async {
    try {
      // 1. Registrar actividad antes de cerrar sesión (temporalmente deshabilitado)
      // await _activityLog.log(
      //   action: 'logout',
      //   entityType: 'auth',
      //   details: {
      //     'timestamp': DateTime.now().toIso8601String(),
      //   },
      // );

      // 2. Cerrar sesión en Google si estaba activo
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // 3. Cerrar sesión en Firebase
      await _auth.signOut();

      // 4. Limpiar datos locales
      await _clearUserDataLocally();

      return {
        'success': true,
        'message': 'Sesión cerrada exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al cerrar sesión: ${e.toString()}',
      };
    }
  }

  // ============================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ============================================

  /// Enviar email de recuperación de contraseña
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      return {
        'success': true,
        'message': 'Email de recuperación enviado. Revisa tu correo.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al enviar email: ${e.toString()}',
      };
    }
  }

  /// Actualizar contraseña (debe estar autenticado)
  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    try {
      if (!isAuthenticated || currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await currentUser!.updatePassword(newPassword);

      // Registrar actividad (temporalmente deshabilitado)
      // await _activityLog.log(
      //   action: 'update_password',
      //   entityType: 'auth',
      //   details: {
      //     'timestamp': DateTime.now().toIso8601String(),
      //   },
      // );

      return {
        'success': true,
        'message': 'Contraseña actualizada exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al actualizar contraseña: ${e.toString()}',
      };
    }
  }

  // ============================================
  // PERFIL DE USUARIO
  // ============================================

  /// Obtener perfil del usuario actual desde Firestore
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated || currentUserId == null) return null;

    try {
      return await _loadUserProfile(currentUserId!);
    } catch (e) {
      print('Error al cargar perfil: $e');
      return null;
    }
  }

  /// Actualizar perfil del usuario en Firestore
  Future<Map<String, dynamic>> updateProfile({
    String? nombreCompleto,
    String? telefono,
    String? centroEducativo,
    String? regional,
    String? distrito,
    String? direccion,
    String? genero,
    String? avatarUrl,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('Usuario no autenticado');
      }

      final Map<String, dynamic> updates = {};
      if (nombreCompleto != null) updates['nombre_completo'] = nombreCompleto;
      if (telefono != null) updates['telefono'] = telefono;
      if (centroEducativo != null) updates['centro_educativo'] = centroEducativo;
      if (regional != null) updates['regional'] = regional;
      if (distrito != null) updates['distrito'] = distrito;
      if (direccion != null) updates['direccion'] = direccion;
      if (genero != null) updates['genero'] = genero;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      updates['updated_at'] = FieldValue.serverTimestamp();

      // Actualizar en Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId!)
          .update(updates);

      // Actualizar displayName en Firebase Auth si cambió el nombre
      if (nombreCompleto != null) {
        await currentUser!.updateDisplayName(nombreCompleto);
      }

      // Actualizar cache local
      final updatedProfile = await _loadUserProfile(currentUserId!);
      if (updatedProfile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUserProfile, json.encode(updatedProfile));
      }

      // Registrar actividad (temporalmente deshabilitado)
      // await _activityLog.log(
      //   action: 'update',
      //   entityType: 'profile',
      //   entityId: currentUserId,
      //   details: updates,
      // );

      return {
        'success': true,
        'profile': updatedProfile,
        'message': 'Perfil actualizado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al actualizar perfil: ${e.toString()}',
      };
    }
  }

  // ============================================
  // PERSISTENCIA LOCAL
  // ============================================

  /// Guardar datos del usuario localmente (cache)
  Future<void> _saveUserDataLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyUserId, user.uid);
    await prefs.setString(_keyUserEmail, user.email ?? '');

    // Cargar y guardar perfil
    final profile = await _loadUserProfile(user.uid);
    if (profile != null) {
      await prefs.setString(_keyUserProfile, json.encode(profile));
    }
  }

  /// Limpiar datos del usuario localmente
  Future<void> _clearUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserProfile);
  }

  /// Obtener perfil del usuario desde cache local
  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_keyUserProfile);

      if (profileJson != null) {
        return json.decode(profileJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error al obtener perfil en cache: $e');
      return null;
    }
  }

  /// Cargar perfil del usuario desde Firestore
  Future<Map<String, dynamic>?> _loadUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      print('Error al cargar perfil desde Firestore: $e');
      return null;
    }
  }

  // ============================================
  // SESIÓN AUTOMÁTICA
  // ============================================

  /// Firebase automáticamente mantiene la sesión
  /// No necesita implementación adicional como Supabase
  /// authStateChanges() se encarga de notificar cambios
  Future<bool> tryAutoLogin() async {
    try {
      final user = currentUser;

      if (user != null) {
        // Actualizar datos locales
        await _saveUserDataLocally(user);
        print('Sesión restaurada automáticamente para: ${user.email}');
        return true;
      }

      return false;
    } catch (e) {
      print('Error al restaurar sesión: $e');
      return false;
    }
  }

  // ============================================
  // REAUTENTICACIÓN
  // ============================================

  /// Reautenticar usuario con contraseña (necesario para operaciones sensibles)
  Future<Map<String, dynamic>> reauthenticateWithPassword(String password) async {
    try {
      if (!isAuthenticated || currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final email = currentUser!.email;
      if (email == null) {
        throw Exception('Email no disponible');
      }

      // Crear credencial con email y contraseña actual
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Reautenticar
      await currentUser!.reauthenticateWithCredential(credential);

      return {
        'success': true,
        'message': 'Reautenticación exitosa',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al reautenticar: ${e.toString()}',
      };
    }
  }

  /// Reautenticar usuario con Google
  Future<Map<String, dynamic>> reauthenticateWithGoogle() async {
    try {
      if (!isAuthenticated || currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Iniciar flujo de Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Reautenticación cancelada',
        };
      }

      // Obtener credenciales
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Reautenticar
      await currentUser!.reauthenticateWithCredential(credential);

      return {
        'success': true,
        'message': 'Reautenticación exitosa con Google',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al reautenticar con Google: ${e.toString()}',
      };
    }
  }

  // ============================================
  // ACTUALIZAR EMAIL
  // ============================================

  /// Actualizar email del usuario (requiere reautenticación reciente)
  Future<Map<String, dynamic>> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      if (!isAuthenticated || currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // 1. Reautenticar primero (por seguridad)
      final reauthResult = await reauthenticateWithPassword(currentPassword);
      if (!reauthResult['success']) {
        return reauthResult;
      }

      // 2. Actualizar email en Firebase Auth
      await currentUser!.updateEmail(newEmail);

      // 3. Enviar verificación al nuevo email
      await currentUser!.sendEmailVerification();

      // 4. Actualizar en Firestore
      await _firestore.collection('users').doc(currentUserId!).update({
        'email': newEmail,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // 5. Actualizar cache local
      await _saveUserDataLocally(currentUser!);

      // 6. Registrar actividad (temporalmente deshabilitado)
      // await _activityLog.log(
      //   action: 'update_email',
      //   entityType: 'auth',
      //   details: {
      //     'new_email': newEmail,
      //   },
      // );

      return {
        'success': true,
        'message': 'Email actualizado. Verifica tu nuevo correo.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al actualizar email: ${e.toString()}',
      };
    }
  }

  // ============================================
  // ELIMINAR CUENTA
  // ============================================

  /// Eliminar cuenta del usuario (requiere reautenticación reciente)
  Future<Map<String, dynamic>> deleteAccount({
    required String password,
  }) async {
    try {
      if (!isAuthenticated || currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final userId = currentUserId!;

      // 1. Reautenticar primero (por seguridad)
      final reauthResult = await reauthenticateWithPassword(password);
      if (!reauthResult['success']) {
        return reauthResult;
      }

      // 2. Registrar actividad antes de eliminar (temporalmente deshabilitado)
      // await _activityLog.log(
      //   action: 'delete_account',
      //   entityType: 'auth',
      //   details: {
      //     'timestamp': DateTime.now().toIso8601String(),
      //   },
      // );

      // 3. Eliminar datos de Firestore
      await _deleteUserData(userId);

      // 4. Eliminar cuenta de Firebase Auth
      await currentUser!.delete();

      // 5. Cerrar sesión de Google si estaba activo
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // 6. Limpiar datos locales
      await _clearUserDataLocally();

      return {
        'success': true,
        'message': 'Cuenta eliminada exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al eliminar cuenta: ${e.toString()}',
      };
    }
  }

  /// Eliminar todos los datos del usuario en Firestore
  Future<void> _deleteUserData(String userId) async {
    try {
      // Eliminar documento principal del usuario
      await _firestore.collection('users').doc(userId).delete();

      // Eliminar subcolecciones si existen
      // Nota: Firestore no elimina subcolecciones automáticamente
      final collections = [
        'cursos',
        'notas',
        'horarios',
        'evidencias',
        'activity_logs',
      ];

      for (final collectionName in collections) {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection(collectionName)
            .get();

        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print('Error al eliminar datos del usuario: $e');
      // No lanzar excepción para que continúe con la eliminación de la cuenta
    }
  }

  // ============================================
  // VERIFICACIÓN DE EMAIL
  // ============================================

  /// Verificar si el email del usuario está verificado
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Enviar email de verificación
  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      if (!isAuthenticated || currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      if (isEmailVerified) {
        return {
          'success': false,
          'message': 'El email ya está verificado',
        };
      }

      await currentUser!.sendEmailVerification();

      return {
        'success': true,
        'message': 'Email de verificación enviado',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al enviar verificación: ${e.toString()}',
      };
    }
  }

  /// Recargar información del usuario (útil después de verificar email)
  Future<void> reloadUser() async {
    if (isAuthenticated && currentUser != null) {
      await currentUser!.reload();
    }
  }

  // ============================================
  // CAMBIAR CONTRASEÑA CON REAUTENTICACIÓN
  // ============================================

  /// Cambiar contraseña (requiere contraseña actual)
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (!isAuthenticated || currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // 1. Reautenticar primero
      final reauthResult = await reauthenticateWithPassword(currentPassword);
      if (!reauthResult['success']) {
        return reauthResult;
      }

      // 2. Actualizar contraseña
      await currentUser!.updatePassword(newPassword);

      // 3. Registrar actividad (temporalmente deshabilitado)
      // await _activityLog.log(
      //   action: 'change_password',
      //   entityType: 'auth',
      //   details: {
      //     'timestamp': DateTime.now().toIso8601String(),
      //   },
      // );

      return {
        'success': true,
        'message': 'Contraseña cambiada exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': e.code,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al cambiar contraseña: ${e.toString()}',
      };
    }
  }

  // ============================================
  // MENSAJES DE ERROR
  // ============================================

  /// Convertir códigos de error de Firebase a mensajes legibles
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'La contraseña es demasiado débil. Usa al menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Este email ya está registrado. Intenta iniciar sesión.';
      case 'user-not-found':
        return 'No existe una cuenta con este email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'El formato del email es inválido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacta al soporte.';
      case 'requires-recent-login':
        return 'Por seguridad, necesitas volver a iniciar sesión.';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
