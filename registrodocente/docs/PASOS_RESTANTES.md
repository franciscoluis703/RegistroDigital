# Pasos Restantes - Implementación Supabase

## ✅ Completado Hasta Ahora

1. ✅ Script SQL creado (`supabase_persistencia_completa.sql`)
2. ✅ Dependencias agregadas al `pubspec.yaml`
3. ✅ Archivo `.env` creado con credenciales
4. ✅ `main.dart` actualizado con Hive y dotenv
5. ✅ `supabase_config.dart` actualizado para usar `.env`
6. ✅ Servicios creados:
   - `auth_service.dart`
   - `activity_log_service.dart`
7. ✅ Pantalla de login creada

## 📋 Pasos Siguientes

### PASO 1: Ejecutar Script SQL en Supabase

1. Ve a: https://supabase.com/dashboard/project/fqghquowfozmmbohzebb
2. Click en **SQL Editor**
3. Click en **New Query**
4. Copia TODO el contenido de `supabase_persistencia_completa.sql`
5. Pégalo y haz click en **Run**
6. Verifica que se crearon todas las tablas

### PASO 2: Crear Pantalla de Registro

Archivo: `lib/app/presentation/modules/auth/views/register_screen.dart`

Similar a `login_screen.dart` pero con campos adicionales:
- Nombre completo
- Centro educativo
- Regional
- Distrito
- Teléfono

### PASO 3: Actualizar Rutas

En `lib/app/presentation/routes/routes.dart`, agregar:

```dart
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/register_screen.dart';

class Routes {
  static const String login = '/';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  // ... otras rutas existentes

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(), // Ya existe
      // ... otras rutas
    };
  }
}
```

### PASO 4: Proteger Rutas con Auth

Crear `lib/app/core/middleware/auth_middleware.dart`:

```dart
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class AuthMiddleware extends StatelessWidget {
  final Widget child;

  const AuthMiddleware({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    // Si no está autenticado, redirigir a login
    if (!authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return child;
  }
}
```

Usar en rutas protegidas:
```dart
home: (context) => AuthMiddleware(child: const HomeScreen()),
```

### PASO 5: Migrar Servicios Existentes

Para cada servicio en `lib/app/data/services/`:

**EJEMPLO: estudiantes_service.dart**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'activity_log_service.dart';

class EstudiantesService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  final ActivityLogService _activityLog = ActivityLogService();

  String? get _userId => _authService.currentUserId;

  // Obtener estudiantes de un curso
  Future<List<Map<String, dynamic>>> obtenerEstudiantes(String cursoId) async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('estudiantes')
          .select()
          .eq('user_id', _userId!)
          .eq('curso_id', cursoId)
          .order('numero', ascending: true);

      await _activityLog.log(
        action: 'read',
        entityType: 'estudiantes',
        entityId: cursoId,
      );

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  // Guardar estudiante
  Future<bool> guardarEstudiante({
    required String cursoId,
    required String nombre,
    required int numero,
    // ... otros campos
  }) async {
    if (_userId == null) return false;

    try {
      await _supabase.from('estudiantes').insert({
        'user_id': _userId,
        'curso_id': cursoId,
        'numero': numero,
        'nombre_completo': nombre,
        // ... otros campos
      });

      await _activityLog.log(
        action: 'create',
        entityType: 'estudiantes',
        details: {'nombre': nombre},
      );

      return true;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }
}
```

### PASO 6: Crear Servicio de Cursos

Archivo: `lib/app/data/services/cursos_service.dart`

```dart
class CursosService {
  // Similar a estudiantes pero para la tabla 'cursos'
  // Métodos:
  // - obtenerCursos()
  // - crearCurso()
  // - obtenerCursoActual()
  // - establecerCursoActual(cursoId)
}
```

### PASO 7: Actualizar HomeScreen

En `lib/app/presentation/modules/home/views/home_screen.dart`:

1. Cargar perfil del usuario al iniciar
2. Mostrar nombre y foto
3. Botón de logout que llame a `AuthService().signOut()`

### PASO 8: Testing

1. Ejecutar app: `flutter run -d chrome`
2. Crear cuenta nueva
3. Login con esa cuenta
4. Crear algunos datos (estudiantes, asistencias, etc.)
5. Logout
6. Login nuevamente
7. Verificar que los datos siguen ahí

### PASO 9: Build y Deploy

```bash
# Build
flutter build web --release

# Deploy a Firebase
firebase deploy --only hosting
```

## 🚀 Comandos Rápidos

```bash
# Instalar dependencias
flutter pub get

# Run en modo desarrollo
flutter run -d chrome

# Build para producción
flutter build web --release

# Deploy a Firebase
firebase deploy --only hosting

# Ver logs de Supabase
# Ir a: https://supabase.com/dashboard/project/fqghquowfozmmbohzebb/logs
```

## 📝 Checklist Final

- [ ] Script SQL ejecutado en Supabase
- [ ] Tablas creadas correctamente
- [ ] RLS habilitado en todas las tablas
- [ ] Login funciona
- [ ] Registro funciona
- [ ] Datos se guardan en Supabase
- [ ] Datos son específicos por usuario
- [ ] Logout funciona
- [ ] Auto-login funciona
- [ ] Logs de actividad se registran
- [ ] Build web exitoso
- [ ] Deploy a registrodigital.online

## 🔗 Enlaces Útiles

- Supabase Dashboard: https://supabase.com/dashboard/project/fqghquowfozmmbohzebb
- Firebase Console: https://console.firebase.google.com/project/registro-docente-app
- Dominio: https://registrodigital.online

## 💡 Próximos Pasos Avanzados

1. Implementar sincronización offline con Hive
2. Agregar realtime subscriptions
3. Implementar caché inteligente
4. Agregar tests unitarios
5. Implementar analytics
6. Agregar notificaciones push

## 📞 Soporte

Si encuentras problemas:
1. Revisa los logs en DevTools (F12 en Chrome)
2. Verifica las políticas RLS en Supabase
3. Confirma que el usuario esté autenticado
4. Revisa los logs de actividad en la base de datos
