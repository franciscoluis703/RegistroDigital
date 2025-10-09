import 'package:flutter/foundation.dart';
import '../../data/services/perfil_supabase_service.dart';

/// Provider para gestionar el estado global del usuario
class UserProvider extends ChangeNotifier {
  final PerfilSupabaseService _perfilService = PerfilSupabaseService();

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

  /// Cargar datos del usuario desde Supabase
  Future<void> cargarDatosUsuario() async {
    _isLoading = true;
    notifyListeners();

    try {
      final perfil = await _perfilService.obtenerPerfil();

      if (perfil != null) {
        _nombre = perfil['nombre'] ?? '';
        _email = perfil['email'] ?? '';
        _fotoPerfil = perfil['foto_perfil'] ?? 'https://i.pravatar.cc/150?img=3';
        _centroEducativo = perfil['centro_educativo'] ?? 'Centro Educativo Eugenio M. de Hostos';
        _regional = perfil['regional'] ?? '17';
        _distrito = perfil['distrito'] ?? '04';
        _genero = perfil['genero'];
      }
    } catch (e) {
      debugPrint('Error al cargar datos del usuario: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
