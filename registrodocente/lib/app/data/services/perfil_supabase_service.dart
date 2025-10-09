import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class PerfilSupabaseService {
  final SupabaseClient? _supabase = SupabaseService.instance.client;

  /// Obtener perfil del usuario actual
  Future<Map<String, dynamic>?> obtenerPerfil() async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('perfiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      // Error al obtener perfil
      return null;
    }
  }

  /// Crear o actualizar perfil
  Future<Map<String, dynamic>?> actualizarPerfil({
    String? nombre,
    String? email,
    String? fotoPerfil,
    String? genero,
    String? centroEducativo,
    String? regional,
    String? distrito,
    String? telefono,
    String? direccion,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final datos = <String, dynamic>{};
      if (nombre != null) datos['nombre'] = nombre;
      if (email != null) datos['email'] = email;
      if (fotoPerfil != null) datos['foto_perfil'] = fotoPerfil;
      if (genero != null) datos['genero'] = genero;
      if (centroEducativo != null) datos['centro_educativo'] = centroEducativo;
      if (regional != null) datos['regional'] = regional;
      if (distrito != null) datos['distrito'] = distrito;
      if (telefono != null) datos['telefono'] = telefono;
      if (direccion != null) datos['direccion'] = direccion;

      final response = await supabase
          .from('perfiles')
          .upsert({
            'id': userId,
            ...datos,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      // Error al actualizar perfil
      return null;
    }
  }

  /// Subir foto de perfil (Storage)
  Future<String?> subirFotoPerfil(String filePath, Uint8List fileBytes) async {
    try {
      final supabase = _supabase;
      if (supabase == null) return null;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Eliminar foto anterior si existe
      try {
        await supabase.storage
            .from('perfiles')
            .remove(['$userId/foto_perfil.jpg']);
      } catch (e) {
        // No existe foto anterior
      }

      // Subir nueva foto
      await supabase.storage
          .from('perfiles')
          .uploadBinary(
            '$userId/foto_perfil.jpg',
            fileBytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Obtener URL pública
      final url = supabase.storage
          .from('perfiles')
          .getPublicUrl('$userId/foto_perfil.jpg');

      // Actualizar perfil con la nueva URL
      await actualizarPerfil(fotoPerfil: url);

      return url;
    } catch (e) {
      // Error al subir foto
      return null;
    }
  }

  /// Verificar si el perfil está completo
  Future<bool> perfilCompleto() async {
    try {
      final perfil = await obtenerPerfil();
      if (perfil == null) return false;

      return perfil['nombre'] != null &&
          perfil['centro_educativo'] != null &&
          perfil['regional'] != null &&
          perfil['distrito'] != null;
    } catch (e) {
      return false;
    }
  }
}
