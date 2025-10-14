import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/firebase/firebase_auth_service.dart';

/// Provider para gestionar el estado global del usuario
/// MIGRADO A FIREBASE - Usa FirebaseAuthService en lugar de Supabase
class UserProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _nombre = '';
  String _email = '';
  String _fotoPerfil = 'https://i.pravatar.cc/150?img=3';
  String _centroEducativo = '';
  String _regional = '';
  String _distrito = '';
  String? _genero;
  bool _isLoading = true;

  // Getters
  String get nombre => _nombre;
  String get email => _email;
  String get fotoPerfil => _fotoPerfil;
  String get centroEducativo => _centroEducativo;
  String get regional => _regional;
  String get distrito => _distrito;
  String? get genero => _genero;
  bool get isLoading => _isLoading;

  /// Obtener iniciales del nombre para mostrar en avatares
  String get iniciales {
    if (_nombre.isEmpty) return '?';
    final partes = _nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return _nombre[0].toUpperCase();
  }

  /// Cargar datos del usuario desde Firebase
  Future<void> cargarDatosUsuario() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Obtener perfil desde Firebase Firestore
      final perfil = await _authService.getCurrentUserProfile();

      if (perfil != null) {
        _nombre = perfil['nombre_completo'] ?? '';
        _email = perfil['email'] ?? '';
        _fotoPerfil = perfil['avatar_url'] ?? 'https://i.pravatar.cc/150?img=3';
        _centroEducativo = perfil['centro_educativo'] ?? 'Centro Educativo Eugenio M. de Hostos';
        _regional = perfil['regional'] ?? '17';
        _distrito = perfil['distrito'] ?? '04';
        _genero = perfil['genero'];

        debugPrint('✅ Perfil cargado desde Firebase');
      } else {
        // Fallback: cargar desde SharedPreferences si no existe perfil
        await _cargarDesdeSharedPreferences();
      }
    } catch (e) {
      debugPrint('Error al cargar datos del usuario desde Firebase: $e');
      // Intentar cargar desde SharedPreferences como fallback
      await _cargarDesdeSharedPreferences();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar datos desde SharedPreferences (fallback)
  Future<void> _cargarDesdeSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _nombre = prefs.getString('usuario_nombre') ?? '';
      _email = prefs.getString('usuario_email') ?? '';

      // Si encontramos datos en SharedPreferences, intentar crear el perfil en Firebase
      if (_nombre.isNotEmpty || _email.isNotEmpty) {
        debugPrint('Migrando datos de SharedPreferences a Firebase...');
        try {
          await _authService.updateProfile(
            nombreCompleto: _nombre.isEmpty ? null : _nombre,
          );
          debugPrint('✅ Perfil migrado exitosamente a Firebase');
        } catch (e) {
          debugPrint('Error al migrar perfil a Firebase: $e');
        }
      }
    } catch (e) {
      debugPrint('Error al cargar desde SharedPreferences: $e');
    }
  }

  /// Actualizar nombre del usuario
  void actualizarNombre(String nuevoNombre) {
    _nombre = nuevoNombre;
    notifyListeners();
  }

  /// Actualizar email del usuario
  void actualizarEmail(String nuevoEmail) {
    _email = nuevoEmail;
    notifyListeners();
  }

  /// Actualizar foto de perfil
  void actualizarFotoPerfil(String nuevaFoto) {
    _fotoPerfil = nuevaFoto;
    notifyListeners();
  }

  /// Actualizar todos los datos del usuario
  void actualizarDatos({
    String? nombre,
    String? email,
    String? fotoPerfil,
    String? centroEducativo,
    String? regional,
    String? distrito,
    String? genero,
  }) {
    if (nombre != null) _nombre = nombre;
    if (email != null) _email = email;
    if (fotoPerfil != null) _fotoPerfil = fotoPerfil;
    if (centroEducativo != null) _centroEducativo = centroEducativo;
    if (regional != null) _regional = regional;
    if (distrito != null) _distrito = distrito;
    if (genero != null) _genero = genero;

    notifyListeners();
  }

  /// Limpiar datos del usuario (al cerrar sesión)
  void limpiarDatos() {
    _nombre = '';
    _email = '';
    _fotoPerfil = 'https://i.pravatar.cc/150?img=3';
    _centroEducativo = '';
    _regional = '';
    _distrito = '';
    _genero = null;
    _isLoading = false;
    notifyListeners();
  }
}
