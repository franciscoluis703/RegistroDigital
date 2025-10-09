import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'activity_log_service.dart';

/// Servicio de Autenticación Persistente con Supabase
/// Maneja login, logout, registro y persistencia de sesión
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final ActivityLogService _activityLog = ActivityLogService();

  // Keys para SharedPreferences
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  /// Obtener el usuario actual autenticado
  User? get currentUser => _supabase.auth.currentUser;

  /// Obtener el ID del usuario actual
  String? get currentUserId => currentUser?.id;

  /// Verificar si hay un usuario autenticado
  bool get isAuthenticated => currentUser != null;

  /// Stream de cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

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
      // Registrar en Supabase Auth
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre_completo': nombreCompleto,
          'telefono': telefono,
          'centro_educativo': centroEducativo,
          'regional': regional,
          'distrito': distrito,
        },
      );

      if (response.user == null) {
        throw Exception('Error al crear usuario');
      }

      // Guardar información local
      await _saveUserDataLocally(response.user!, response.session);

      // Registrar actividad
      await _activityLog.log(
        action: 'register',
        entityType: 'auth',
        details: {
          'email': email,
          'nombre_completo': nombreCompleto,
        },
      );

      return {
        'success': true,
        'user': response.user,
        'message': 'Usuario registrado exitosamente. Verifica tu correo.',
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
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Credenciales inválidas');
      }

      // Guardar información local
      await _saveUserDataLocally(response.user!, response.session);

      // Cargar perfil del usuario
      final profile = await _loadUserProfile(response.user!.id);

      // Registrar actividad
      await _activityLog.log(
        action: 'login',
        entityType: 'auth',
        details: {
          'email': email,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return {
        'success': true,
        'user': response.user,
        'profile': profile,
        'message': 'Inicio de sesión exitoso',
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

  /// Iniciar sesión con Google (OAuth)
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final bool success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://registrodigital.online/auth/callback',
      );

      // El flujo de OAuth redirige al usuario, el callback se maneja automáticamente
      return {
        'success': success,
        'message': 'Redirigiendo a Google...',
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
      // Registrar actividad antes de cerrar sesión
      await _activityLog.log(
        action: 'logout',
        entityType: 'auth',
        details: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Cerrar sesión en Supabase
      await _supabase.auth.signOut();

      // Limpiar datos locales
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
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://registrodigital.online/reset-password',
      );

      return {
        'success': true,
        'message': 'Email de recuperación enviado. Revisa tu correo.',
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
      if (!isAuthenticated) {
        throw Exception('Usuario no autenticado');
      }

      final UserResponse response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Error al actualizar contraseña');
      }

      // Registrar actividad
      await _activityLog.log(
        action: 'update_password',
        entityType: 'auth',
        details: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return {
        'success': true,
        'message': 'Contraseña actualizada exitosamente',
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

  /// Obtener perfil del usuario actual
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated || currentUserId == null) return null;

    try {
      return await _loadUserProfile(currentUserId!);
    } catch (e) {
      print('Error al cargar perfil: $e');
      return null;
    }
  }

  /// Actualizar perfil del usuario
  Future<Map<String, dynamic>> updateProfile({
    String? nombreCompleto,
    String? telefono,
    String? centroEducativo,
    String? regional,
    String? distrito,
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
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', currentUserId!);

      // Actualizar cache local
      final updatedProfile = await _loadUserProfile(currentUserId!);
      if (updatedProfile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUserProfile, json.encode(updatedProfile));
      }

      // Registrar actividad
      await _activityLog.log(
        action: 'update',
        entityType: 'profile',
        entityId: currentUserId,
        details: updates,
      );

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

  /// Guardar datos del usuario localmente
  Future<void> _saveUserDataLocally(User user, Session? session) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserEmail, user.email ?? '');

    if (session != null) {
      await prefs.setString(_keyAccessToken, session.accessToken);
      if (session.refreshToken != null) {
        await prefs.setString(_keyRefreshToken, session.refreshToken!);
      }
    }

    // Cargar y guardar perfil
    final profile = await _loadUserProfile(user.id);
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
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
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

  /// Cargar perfil del usuario desde Supabase
  Future<Map<String, dynamic>?> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error al cargar perfil desde Supabase: $e');
      return null;
    }
  }

  // ============================================
  // SESIÓN AUTOMÁTICA
  // ============================================

  /// Intentar restaurar sesión automáticamente al iniciar la app
  Future<bool> tryAutoLogin() async {
    try {
      // Supabase automáticamente restaura la sesión si existe un token válido
      final session = _supabase.auth.currentSession;

      if (session != null && currentUser != null) {
        // Actualizar datos locales
        await _saveUserDataLocally(currentUser!, session);

        print('Sesión restaurada automáticamente para: ${currentUser!.email}');
        return true;
      }

      return false;
    } catch (e) {
      print('Error al restaurar sesión: $e');
      return false;
    }
  }

  /// Refrescar el token de acceso
  Future<bool> refreshSession() async {
    try {
      final AuthResponse response = await _supabase.auth.refreshSession();

      if (response.session != null && response.user != null) {
        await _saveUserDataLocally(response.user!, response.session);
        return true;
      }

      return false;
    } catch (e) {
      print('Error al refrescar sesión: $e');
      return false;
    }
  }
}
